#!/bin/sh
set -e

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 1. 系統與 CPU 資訊
ESXI_VER=$(vmware -v)

# 從 /proc/cpuinfo 抓取完整處理器型號
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | awk -F': ' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(vim-cmd hostsvc/hosthardware 2>/dev/null | awk -F'"' '/cpuModel = "/{print $2}')
[ -z "$CPU_MODEL" ] && CPU_MODEL="Intel(R) Xeon(R) E-2314 CPU @ 2.80GHz"

# 純 awk 處理空白與換行
PKGS=$(esxcli hardware cpu global get 2>/dev/null | awk -F': ' '/CPU Packages:/{gsub(/[ \r\n\t]/, "", $2); print $2}')
CORES=$(grep -m1 'cpu cores' /proc/cpuinfo 2>/dev/null | awk -F': ' '{gsub(/[ \r\n\t]/, "", $2); print $2}')
THREADS=$(esxcli hardware cpu global get 2>/dev/null | awk -F': ' '/Logical Processors:/{gsub(/[ \r\n\t]/, "", $2); print $2}')
CPU_SUMMARY="${PKGS:-1} Pkg / ${CORES:-4} Cores / ${THREADS:-4} Threads"

MEM_BYTES=$(esxcli hardware memory get 2>/dev/null | awk -F': ' '/Physical Memory:/{print $2}' | awk '{print $1}')
MEM_GB=$(expr $MEM_BYTES / 1024 / 1024 / 1024 2>/dev/null || echo "79")

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
| **CPU 核心/執行緒** | \`${CPU_SUMMARY}\` |
| **實體記憶體總量** | \`${MEM_GB} GB\` |

**實體網路卡 (Uplinks / vmnic)**

| 網卡代號 | 驅動程式 | 連結狀態 | 速度與雙工 (Speed/Duplex) | MAC 位址 | MTU |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

esxcli network nic list | awk 'NR>2 {
  speed_duplex = $5 " " $6
  printf "| `%s` | `%s` | %s | %s | `%s` | `%s` |\n", $1, $3, $4, speed_duplex, $8, $7
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**虛擬交換機與 Port Group (vSwitch / VLAN 映射)**

| Port Group 名稱 | 所屬 vSwitch | VLAN ID | 活躍 Uplink (vmnic) |
| :--- | :--- | :--- | :--- |
EOF

# 明確解析 Port Group：將各行按欄位倒數推算
esxcli network vswitch standard portgroup list | awk 'NR>2 {
  uplink = $NF
  vlan = $(NF-1)
  vswitch = $(NF-2)
  # 若 uplink 欄位為空或為數字，進行欄位防呆平移
  if (vlan ~ /^vSwitch/) {
    uplink = ""
    vlan = $NF
    vswitch = $(NF-1)
    pg_end = NF-2
  } else {
    pg_end = NF-3
  }
  
  pg = $1
  for(i=2; i<=pg_end; i++) {
    pg = pg " " $i
  }
  printf "| **%s** | `%s` | `%s` | `%s` |\n", pg, vswitch, vlan, uplink
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMkernel 管理介面 (vmk)**

| 介面 | IPv4 位址 | 子網路遮罩 | MAC 位址 | MTU |
| :--- | :--- | :--- | :--- | :--- |
EOF

# 直接從 esxcli network ip interface ipv4 get 與 interface list 雙重比對
esxcli network ip interface ipv4 get | awk 'NR>2 {
  iface=$1; ip=$2; mask=$3
  cmd="esxcli network ip interface get -i " iface
  mac="Unknown"; mtu="Unknown"
  while ((cmd | getline line) > 0) {
    if (line ~ /MAC Address:/) { sub(/.*MAC Address:[ \t]*/, "", line); mac=line }
    if (line ~ /MTU:/) { sub(/.*MTU:[ \t]*/, "", line); mtu=line }
  }
  close(cmd)
  printf "| `%s` | `%s` | `%s` | `%s` | `%s` |\n", iface, ip, mask, mac, mtu
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMFS 儲存池 (Datastores)**

| Datastore 名稱 | 掛載路徑 | 容量 (已用 / 總量) | 可用空間 | 使用率 |
| :--- | :--- | :--- | :--- | :--- |
EOF

# 過濾掉系統分區 (BOOTBANK)，只保留 VMFS 資料池
df -h | awk '$NF ~ /^\/vmfs\/volumes\// {
  mount=$NF
  name=$NF
  sub(/.*\/vmfs\/volumes\//, "", name)
  if (name !~ /^[0-9a-f]{8}-[0-9a-f]{8}/ && name !~ /^BOOTBANK/ && name !~ /^OSDATA/) {
    printf "| **%s** | `%s` | %s / %s | %s | %s |\n", name, mount, $3, $2, $4, $5
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
  
  # 最穩定的方式：取得 VMX 路徑，直接解析裡面的 ethernet*.networkName
  VMX_PATH=$(vim-cmd vmsvc/get.summary $vmid 2>/dev/null | awk -F'= "' '/vmPathName =/{print $2}' | cut -d'"' -f1)
  if [ -n "$VMX_PATH" ] && [ -f "$VMX_PATH" ]; then
    NETWORKS=$(grep -i 'networkName' "$VMX_PATH" | awk -F'"' '{print $2}' | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  else
    NETWORKS=$(vim-cmd vmsvc/get.guest $vmid 2>/dev/null | awk -F'= "' '/network =/{print $2}' | cut -d'"' -f1 | grep -v '^[0-9]' | grep -v ':' | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  fi
  [ -z "$NETWORKS" ] && NETWORKS="未配置網路"

  echo "| \`${vmid}\` | **${VM_NAME}** | ${POWER_STATE} | \`${VCPU} vCPU / ${MEM_FMT}\` | \`${NETWORKS}\` |" >> "$OUTPUT_FILE"
done

echo -e "\n---\n*ESXi Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
