#!/bin/sh
set -e

HOSTNAME=$(hostname)
OUTPUT_FILE="Node_${HOSTNAME}.md"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

OS="FreeBSD $(freebsd-version 2>/dev/null || uname -r)"
KERNEL=$(uname -r)
CPU_MODEL=$(sysctl -n hw.model)
VCPU=$(sysctl -n hw.ncpu)
RAM_BYTES=$(sysctl -n hw.physmem)
RAM_TOTAL="$(expr $RAM_BYTES / 1024 / 1024 / 1024)GB"
DEFAULT_GW=$(netstat -rn -f inet | awk '$1=="default"{print $2 " via " $6}')

cat << EOF > "$OUTPUT_FILE"
---
title: "節點手冊: ${HOSTNAME}"
date: "${GEN_DATE}"
tags:
  - homelab
  - freebsd
---

# 節點手冊：${HOSTNAME}

> 產生時間：\`${GEN_DATE}\`

**硬體與系統規格**

| 項目 | 規格值 |
| :--- | :--- |
| **主機名稱** | \`${HOSTNAME}\` |
| **作業系統** | \`${OS}\` |
| **核心版本** | \`${KERNEL}\` |
| **CPU 型號** | ${CPU_MODEL} |
| **vCPU 核心數** | \`${VCPU}\` |
| **記憶體總量** | \`${RAM_TOTAL}\` |
| **預設閘道 (Default Gateway)** | \`${DEFAULT_GW:-無}\` |

**核心網路介面 (實體 / VM 網卡 / WireGuard)**

| 介面名稱 | 類型 | 實際 IP (IPv4) | MAC 位址 | MTU | 狀態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

ifconfig -l | tr ' ' '\n' | while read -r iface; do
  case "$iface" in
    lo*|pflog*|pfsync*) continue ;;
    wg*) IF_TYPE="WireGuard 介面" ;;
    *) IF_TYPE="實體 / VM 網卡" ;;
  esac

  MAC=$(ifconfig "$iface" | awk '/ether/{print $2}')
  [ -z "$MAC" ] && MAC="N/A"
  MTU=$(ifconfig "$iface" | awk '/mtu/{for(i=1;i<=NF;i++) if($i=="mtu") print $(i+1)}')
  STATUS=$(ifconfig "$iface" | awk '/status:/{print $2}')
  [ -z "$STATUS" ] && STATUS="active"

  IPS=$(ifconfig "$iface" | awk '$1=="inet"{print "`" $2 "`"}' | paste -sd '<br>' -)
  [ -z "$IPS" ] && IPS="*未配發 IP*"

  echo "| \`${iface}\` | ${IF_TYPE} | ${IPS} | \`${MAC}\` | \`${MTU}\` | \`${STATUS}\` |" >> "$OUTPUT_FILE"
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

**儲存與掛載狀態**

| 掛載點 | 來源裝置 / 網路路徑 | 檔案系統 | 容量 (已用 / 總量) | 使用率 |
| :--- | :--- | :--- | :--- | :--- |
EOF

df -h | awk 'NR>1 && $1 !~ /^(devfs|tmpfs)/ {
  printf "| `%s` | `%s` | `%s` | %s / %s | %s |\n", $6, $1, $2, $3, $2, $5
}' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**已啟用系統服務 (/etc/rc.conf 全量)**

EOF

# 全量輸出 /etc/rc.conf 中所有帶 enable="YES" 的行
SERVICES=$(grep -E '.*_enable="[Yy][Ee][Ss]"' /etc/rc.conf 2>/dev/null | awk -F'=' '{print "* `" $1 "`"}' || true)
if [ -n "$SERVICES" ]; then
  echo "$SERVICES" >> "$OUTPUT_FILE"
else
  echo "* 無啟用中的服務" >> "$OUTPUT_FILE"
fi

echo -e "\n---\n*Raw Data Generated.*" >> "$OUTPUT_FILE"
echo "完成：$(pwd)/${OUTPUT_FILE}"
