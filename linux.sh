#!/usr/bin/env bash
set -e

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

OS=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || uname -s)
KERNEL=$(uname -r)
VCPU=$(nproc)
CPU_MODEL=$(lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/, "", $2); print $2}' | head -n1)
[ -z "$CPU_MODEL" ] && CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
RAM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
RAM_USED=$(free -h | awk '/^Mem:/{print $3}')
SWAP_TOTAL=$(free -h | awk '/^Swap:/{print $2}')
DEFAULT_GW=$(ip route show default 2>/dev/null | awk '{print $3 " dev " $5}')

cat << EOF > "$OUTPUT_FILE"
---
title: "節點手冊: ${HOSTNAME}"
date: "${GEN_DATE}"
tags:
  - homelab
  - node-spec
---

# 節點手冊：${HOSTNAME}

> 產生時間：\`${GEN_DATE}\`

**硬體與系統規格**

| 項目 | 規格值 |
| :--- | :--- |
| **主機名稱** | \`${HOSTNAME}\` |
| **作業系統** | \`${OS}\` |
| **核心版本** | \`${KERNEL}\` |
| **CPU 型號** | ${CPU_MODEL:-Virtual vCPU} |
| **vCPU 核心數** | \`${VCPU}\` |
| **記憶體 (已用 / 總量)** | \`${RAM_USED} / ${RAM_TOTAL}\` (Swap: \`${SWAP_TOTAL}\`) |
| **預設閘道 (Default Gateway)** | \`${DEFAULT_GW:-無}\` |

**核心網路介面 (實體 / VM 網卡 / WireGuard)**

| 介面名稱 | 類型 | 實際 IP (IPv4 / IPv6) | MAC 位址 | MTU | 狀態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

for iface in $(ls /sys/class/net); do
  if [ "$iface" = "lo" ]; then continue; fi
  
  IF_TYPE=""
  if [ -d "/sys/class/net/$iface/device" ]; then
    IF_TYPE="實體 / VM 網卡"
  elif [[ "$iface" =~ ^wg ]]; then
    IF_TYPE="WireGuard 介面"
  else
    continue
  fi

  MAC=$(cat /sys/class/net/$iface/address 2>/dev/null || echo "N/A")
  MTU=$(cat /sys/class/net/$iface/mtu 2>/dev/null || echo "N/A")
  OPERSTATE=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
  
  IPS=$(ip -o addr show dev "$iface" 2>/dev/null | awk '{print "`" $4 "`"}' | paste -sd '<br>' -)
  [ -z "$IPS" ] && IPS="*未配發 IP*"

  echo "| \`${iface}\` | ${IF_TYPE} | ${IPS} | \`${MAC}\` | \`${MTU}\` | \`${OPERSTATE}\` |" >> "$OUTPUT_FILE"
done

if command -v wg >/dev/null 2>&1 && wg show >/dev/null 2>&1; then
  cat << EOF >> "$OUTPUT_FILE"

**WireGuard Mesh 運作狀態 (wg show)**

| 介面名稱 | 允許連線 IP (Allowed IPs) | 端點 (Endpoint) |
| :--- | :--- | :--- |
EOF
  wg show all dump | tail -n +2 | while read -r dev peer _ endpoint allowed_ips _ _ _; do
    echo "| \`${dev}\` | \`${allowed_ips}\` | \`${endpoint}\` |" >> "$OUTPUT_FILE"
  done
fi

cat << EOF >> "$OUTPUT_FILE"

**儲存與磁碟掛載**

| 掛載點 | 來源裝置 / 網路路徑 | 檔案系統 | 容量 (已用 / 總量) | 使用率 |
| :--- | :--- | :--- | :--- | :--- |
EOF

df -h -T -P | awk 'NR>1 && $2 !~ /^(tmpfs|devtmpfs|overlay|squashfs)/ {
  printf "| `%s` | `%s` | `%s` | %s / %s | %s |\n", $7, $1, $2, $4, $3, $6
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**已啟用系統服務 (All Enabled Systemd Services)**

EOF

# 全量輸出所有 enabled 的 systemd 服務，不進行任何關鍵字挑選
SERVICES=$(systemctl list-unit-files --state=enabled --type=service 2>/dev/null | awk 'NR>1 && $1 ~ /\.service$/ {print "* `" $1 "`"}' || true)
if [ -n "$SERVICES" ]; then
  echo "$SERVICES" >> "$OUTPUT_FILE"
else
  echo "* 無啟用中的服務" >> "$OUTPUT_FILE"
fi

cat << EOF >> "$OUTPUT_FILE"

**Docker 容器拓撲**

EOF

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  cat << EOF >> "$OUTPUT_FILE"
| 容器名稱 | 映像檔 | 運行狀態 | 網路模式 | 埠號對應 (Port Mappings) |
| :--- | :--- | :--- | :--- | :--- |
EOF
  docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}|{{.Networks}}|{{if .Ports}}{{.Ports}}{{else}}純內部Bridge / 無Mapping{{end}}' | while IFS='|' read -r name img status net ports; do
    echo "| **${name}** | \`${img}\` | ${status} | \`${net}\` | \`${ports}\` |" >> "$OUTPUT_FILE"
  done
else
  echo "* 本節點未安裝 Docker 或無運行容器。" >> "$OUTPUT_FILE"
fi

echo -e "\n---\n*Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
