#!/bin/sh
set -e

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 1. 系統與 CPU/記憶體資訊
ESXI_VER=$(vmware -v)
CPU_MODEL=$(esxcli hardware cpu global get | awk -F': ' '/CPU Model:/{print $2}')
CPU_CORES=$(esxcli hardware cpu global get | awk -F': ' '/CPU Packages:/{p=$2} /Logical Processors:/{c=$2} END{print p " Pkg / " c " Threads"}')
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

| 介面 | Port Group | IPv4 位址 | 子網路遮罩 | MTU | MAC 位址 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

esxcli network ip interface ipv4 get | awk 'NR>2 {
  iface=$1; ip=$2; mask=$3
  cmd="esxcli network ip interface get -i " iface
  pg="Unknown"; mac="Unknown"; mtu="Unknown"
  while ((cmd | getline line) > 0) {
    if (line ~ /Portgroup Name:/) { sub(/.*Portgroup Name: /, "", line); pg=line }
    if (line ~ /MAC Address:/) { sub(/.*MAC Address: /, "", line); mac=line }
    if (line ~ /MTU:/) { sub(/.*MTU: /, "", line); mtu=line }
  }
  close(cmd)
  printf "| `%s` | **%s** | `%s` | `%s` | `%s` | `%s` |\n", iface, pg, ip, mask, mtu, mac
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMFS 儲存池 (Datastores)**

| Datastore 名稱 | 檔案系統 | 容量 (總量 / 可用) | 類型 |
| :--- | :--- | :--- | :--- |
EOF

esxcli storage filesystem list | awk 'NR>2 && $3 ~ /VMFS/ {
  size_gb = int($5 / 1024 / 1024 / 1024)
  free_gb = int($6 / 1024 / 1024 / 1024)
  printf "| **%s** | `%s` | %s GB / %s GB | %s |\n", $2, $3, size_gb, free_gb, $4
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**虛擬機矩陣 (Virtual Machines Inventory)**

| VM ID | 虛擬機名稱 | 運行狀態 | 資源分配 (vCPU / RAM) | 所屬網路 (Port Group) |
| :--- | :--- | :--- | :--- | :--- |
EOF

# 迭代所有 VM，使用 awk 清理空白與逗號，不調用 tr
for vmid in $(vim-cmd vmsvc/getallvms 2>/dev/null | awk 'NR>1 {print $1}'); do
  VM_INFO=$(vim-cmd vmsvc/get.summary $vmid 2>/dev/null)
  VM_NAME=$(echo "$VM_INFO" | awk -F'= "' '/name =/{print $2}' | cut -d'"' -f1)
  POWER_STATE=$(echo "$VM_INFO" | awk -F'= "' '/powerState =/{print $2}' | cut -d'"' -f1)
  
  # 純 awk 替換，完全去除 tr 依賴
  VCPU=$(echo "$VM_INFO" | awk -F'= ' '/numCpu =/{gsub(/[, \r\n]/, "", $2); print $2}')
  MEM_MB=$(echo "$VM_INFO" | awk -F'= ' '/memorySizeMB =/{gsub(/[, \r\n]/, "", $2); print $2}')
  MEM_FMT="$(expr $MEM_MB / 1024 2>/dev/null || echo $MEM_MB)GB"
  
  # 抓取該 VM 綁定的 Portgroup
  NETWORKS=$(vim-cmd vmsvc/get.guest $vmid 2>/dev/null | awk -F'= "' '/network =/{print $2}' | cut -d'"' -f1 | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  [ -z "$NETWORKS" ] && NETWORKS="未配置/關機中"

  echo "| \`${vmid}\` | **${VM_NAME}** | ${POWER_STATE} | \`${VCPU} vCPU / ${MEM_FMT}\` | \`${NETWORKS}\` |" >> "$OUTPUT_FILE"
done

echo -e "\n---\n*ESXi Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
