#!/bin/sh
set -e

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 1. 系統版本
ESXI_VER=$(vmware -v)

# 2. CPU 型號與核心 (相容 ESXi 8.0)
CPU_MODEL=$(vim-cmd hostsvc/hosthardware 2>/dev/null | awk -F'= "' '/cpuModel =/{print $2}' | cut -d'"' -f1)
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(esxcli hardware cpu list | awk -F': ' '/Model:/{print $2; exit}')
[ -z "$CPU_MODEL" ] && CPU_MODEL="Intel Xeon Processor"

CPU_CORES=$(vim-cmd hostsvc/hosthardware 2>/dev/null | awk '/numCpuPkgs =/{p=$3} /numCpuCores =/{c=$3} /numCpuThreads =/{t=$3} END{gsub(/[,;]/,""); print p " Pkg / " c " Cores / " t " Threads"}')
[ -z "$CPU_CORES" ] && CPU_CORES=$(esxcli hardware cpu global get | awk -F': ' '/CPU Packages:/{p=$2} /Logical Processors:/{c=$2} END{print p " Pkg / " c " Threads"}')

# 3. 實體記憶體
MEM_BYTES=$(esxcli hardware memory get | awk -F': ' '/Physical Memory:/{print $2}' | awk '{print $1}')
MEM_GB=$(expr $MEM_BYTES / 1024 / 1024 / 1024 2>/dev/null || echo "Unknown")

cat << EOF > "$OUTPUT_FILE"
---
title: "宿主機手冊: ${HOSTNAME}"
date: "${GEN_DATE}"
tags:
  - homelab
  - esxi
  - hypervisor
---

# 宿主機手冊：${HOSTNAME}

> 產生時間：\`${GEN_DATE}\`

**實體硬體與 Hypervisor 規格**

| 項目 | 規格值 |
| :--- | :--- |
| **主機名稱** | \`${HOSTNAME}\` |
| **虛擬化系統** | \`${ESXI_VER}\` |
| **CPU 型號** | ${CPU_MODEL} |
| **CPU 核心/執行緒** | \`${CPU_CORES}\` |
| **實體記憶體總量** | \`${MEM_GB} GB\` |

**實體網路卡 (Uplinks / vmnic)**

| 網卡代號 | 驅動程式 | 連結狀態 | 速度與雙工 (Speed/Duplex) | MAC 位址 | MTU |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

esxcli network nic list | awk 'NR>2 {
  printf "| `%s` | `%s` | %s | %s %s | `%s` | `%s` |\n", $1, $3, $4, $5, $6, $8, $7
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**虛擬交換機與 Port Group (vSwitch / VLAN 映射)**

| Port Group 名稱 | 所屬 vSwitch | VLAN ID | 活躍 Uplink (vmnic) |
| :--- | :--- | :--- | :--- |
EOF

esxcli network vswitch standard portgroup list | awk 'NR>2 {
  printf "| **%s** | `%s` | `%s` | `%s` |\n", $1, $2, $3, $4
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMkernel 管理介面 (vmk)**

| 介面 | IPv4 位址 | 子網路遮罩 | 廣播位址 | MAC 位址 | MTU |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

esxcli network ip interface ipv4 get | awk 'NR>2 {
  iface=$1; ip=$2; mask=$3; bc=$4
  cmd="esxcli network ip interface get -i " iface
  mac="Unknown"; mtu="Unknown"
  while ((cmd | getline line) > 0) {
    if (line ~ /MAC Address:/) { sub(/.*MAC Address: /, "", line); mac=line }
    if (line ~ /MTU:/) { sub(/.*MTU: /, "", line); mtu=line }
  }
  close(cmd)
  printf "| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |\n", iface, ip, mask, bc, mac, mtu
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMFS 儲存池 (Datastores)**

| Datastore 名稱 | 檔案系統 | 容量 (總量 / 可用) | 類型 |
| :--- | :--- | :--- | :--- |
EOF

# 相容 ESXi 8.0 儲存清單輸出格式
esxcli storage filesystem list | awk 'NR>2 {
  for (i=1; i<=NF; i++) {
    if ($i ~ /^VMFS/) {
      fstype=$i
      size_gb=int($(i+2) / 1024 / 1024 / 1024)
      free_gb=int($(i+3) / 1024 / 1024 / 1024)
      name=$2
      printf "| **%s** | `%s` | %s GB / %s GB | VMFS |\n", name, fstype, size_gb, free_gb
    }
  }
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**虛擬機矩陣 (Virtual Machines Inventory)**

| VM ID | 虛擬機名稱 | 運行狀態 | 資源分配 (vCPU / RAM) | 虛擬硬體網路 (Port Group) |
| :--- | :--- | :--- | :--- | :--- |
EOF

for vmid in $(vim-cmd vmsvc/getallvms 2>/dev/null | awk 'NR>1 {print $1}'); do
  VM_INFO=$(vim-cmd vmsvc/get.summary $vmid 2>/dev/null)
  VM_NAME=$(echo "$VM_INFO" | awk -F'= "' '/name =/{print $2}' | cut -d'"' -f1)
  POWER_STATE=$(echo "$VM_INFO" | awk -F'= "' '/powerState =/{print $2}' | cut -d'"' -f1)
  
  VCPU=$(echo "$VM_INFO" | awk -F'= ' '/numCpu =/{gsub(/[, \r\n]/, "", $2); print $2}')
  MEM_MB=$(echo "$VM_INFO" | awk -F'= ' '/memorySizeMB =/{gsub(/[, \r\n]/, "", $2); print $2}')
  MEM_FMT="$(expr $MEM_MB / 1024 2>/dev/null || echo $MEM_MB)GB"
  
  # 直接從虛擬硬體裝置定義抓取 Port Group，不抓 Guest OS 內的 Docker/Bridge IP
  NETWORKS=$(vim-cmd vmsvc/device.getdevices $vmid 2>/dev/null | awk -F'= "' '/networkName =/{print $2}' | cut -d'"' -f1 | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  [ -z "$NETWORKS" ] && NETWORKS="未配置/關機中"

  echo "| \`${vmid}\` | **${VM_NAME}** | ${POWER_STATE} | \`${VCPU} vCPU / ${MEM_FMT}\` | \`${NETWORKS}\` |" >> "$OUTPUT_FILE"
done

echo -e "\n---\n*ESXi Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
