#!/bin/sh

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 1. 系統與 CPU 資訊
ESXI_VER=$(vmware -v)

CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | awk -F': ' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(vim-cmd hostsvc/hosthardware 2>/dev/null | awk -F'"' '/cpuModel = "/{print $2}')
[ -z "$CPU_MODEL" ] && CPU_MODEL="Intel(R) Xeon(R) E-2314 CPU @ 2.80GHz"

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

# 使用 CSV 格式精準提取各欄位，徹底解決空格切分錯誤
esxcli --formatter=csv network nic list | awk -F',' 'NR>1 {
  for (i=1; i<=NF; i++) gsub(/^"|"$/, "", $i)
  nic = $NF
  driver = $3
  link = $1
  duplex = $4
  speed = $6
  mac = $7
  mtu = $8
  printf "| `%s` | `%s` | %s | %s %s | `%s` | `%s` |\n", nic, driver, link, speed, duplex, mac, mtu
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**虛擬交換機與 Port Group (vSwitch / VLAN 映射)**

| Port Group 名稱 | 所屬 vSwitch | 連線客戶端數 (Active Clients) | VLAN ID |
| :--- | :--- | :--- | :--- |
EOF

esxcli network vswitch standard portgroup list | awk 'NR>2 {
  clients = $NF
  vlan = $(NF-1)
  vswitch = $(NF-2)
  
  pg = $1
  for (i=2; i<=NF-3; i++) {
    pg = pg " " $i
  }
  printf "| **%s** | `%s` | `%s` | `%s` |\n", pg, vswitch, vlan, clients
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**VMkernel 管理介面 (vmk)**

| 介面 | IPv4 位址 | 子網路遮罩 | MAC 位址 | MTU |
| :--- | :--- | :--- | :--- | :--- |
EOF

for vmk in $(esxcli network ip interface ipv4 get 2>/dev/null | awk 'NR>2 {print $1}'); do
  IP_INFO=$(esxcli network ip interface ipv4 get 2>/dev/null | awk -v v="$vmk" '$1==v {print $2, $3}')
  IP=$(echo "$IP_INFO" | awk '{print $1}')
  MASK=$(echo "$IP_INFO" | awk '{print $2}')
  
  MAC=$(esxcli network ip interface list 2>/dev/null | awk -v v="$vmk" '$1==v, /Enabled:/' | awk -F': ' '/MAC Address:/{print $2; exit}')
  MTU=$(esxcli network ip interface list 2>/dev/null | awk -v v="$vmk" '$1==v, /Enabled:/' | awk -F': ' '/MTU:/{print $2; exit}')
  
  echo "| \`${vmk}\` | \`${IP:-None}\` | \`${MASK:-None}\` | \`${MAC:-Unknown}\` | \`${MTU:-1500}\` |" >> "$OUTPUT_FILE"
done

cat << EOF >> "$OUTPUT_FILE"

**VMFS 儲存池 (Datastores)**

| Datastore 名稱 | 掛載路徑 | 容量 (已用 / 總量) | 可用空間 | 使用率 |
| :--- | :--- | :--- | :--- | :--- |
EOF

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
  
  VMX_PATH=$(echo "$VM_INFO" | awk -F'= "' '/vmPathName =/{print $2}' | cut -d'"' -f1)
  NETWORKS=""
  
  if [ -n "$VMX_PATH" ] && [ -f "$VMX_PATH" ]; then
    NETWORKS=$(grep -i 'networkName' "$VMX_PATH" 2>/dev/null | awk -F'"' '{print $2}' | grep -v '^[ \t]*$' | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  fi
  
  if [ -z "$NETWORKS" ]; then
    NETWORKS=$(vim-cmd vmsvc/device.getdevices $vmid 2>/dev/null | grep -E "VM_|Management Network" | awk -F'"' '{print $2}' | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  fi
  
  if [ -z "$NETWORKS" ]; then
    NETWORKS=$(vim-cmd vmsvc/get.guest $vmid 2>/dev/null | awk -F'= "' '/network =/{print $2}' | cut -d'"' -f1 | grep -E "VM_|Management Network" | sort -u | awk '{if(NR>1) printf ", "; printf "%s", $0} END {print ""}')
  fi
  
  NETWORKS=$(echo "$NETWORKS" | awk '{sub(/^[ ,]+/, ""); print}')
  [ -z "$NETWORKS" ] && NETWORKS="未配置網路/直通"

  echo "| \`${vmid}\` | **${VM_NAME}** | ${POWER_STATE} | \`${VCPU} vCPU / ${MEM_FMT}\` | \`${NETWORKS}\` |" >> "$OUTPUT_FILE"
done

echo -e "\n---\n*ESXi Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
