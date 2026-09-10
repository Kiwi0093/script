#!/usr/bin/env bash
set -e

# ============================================================
# 無限迴圈輸入驗證 (留空按 Enter 即重新提示)
# ============================================================
while true; do
  read -rp "請輸入 UniFi Controller IP: " CONTROLLER_IP
  [ -n "$CONTROLLER_IP" ] && break
  echo ">> 欄位不可留空，請重新輸入！"
done

while true; do
  read -rp "請輸入 UniFi Controller 通訊埠: " CONTROLLER_PORT
  [ -n "$CONTROLLER_PORT" ] && break
  echo ">> 欄位不可留空，請重新輸入！"
done

while true; do
  read -rp "請輸入 UniFi 管理員帳號: " USERNAME
  [ -n "$USERNAME" ] && break
  echo ">> 欄位不可留空，請重新輸入！"
done

while true; do
  read -s -rp "請輸入 UniFi 管理員密碼: " PASSWORD
  echo ""
  [ -n "$PASSWORD" ] && break
  echo ">> 密碼不可留空，請重新輸入！"
done

OUTPUT_FILE="Network_UniFi_Topology.md"
COOKIE_JAR="/tmp/unifi_cookie.txt"
GEN_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# ============================================================
# 1. 登入 UniFi Controller (相容新舊版 API 路徑)
# ============================================================
echo "[1/4] 登入 UniFi Controller..."
HTTP_STATUS=$(curl -k -c "$COOKIE_JAR" \
  -H "Content-Type: application/json" \
  -X POST "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/login" \
  -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}" \
  -o /tmp/unifi_login_resp.txt -w "%{http_code}" -s)

if [ "$HTTP_STATUS" -eq 404 ]; then
  HTTP_STATUS=$(curl -k -c "$COOKIE_JAR" \
    -H "Content-Type: application/json" \
    -X POST "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/auth/login" \
    -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}" \
    -o /tmp/unifi_login_resp.txt -w "%{http_code}" -s)
fi

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "[ERROR] 登入失敗！HTTP 狀態碼: $HTTP_STATUS"
  cat /tmp/unifi_login_resp.txt
  echo ""
  rm -f /tmp/unifi_login_resp.txt "$COOKIE_JAR"
  exit 1
fi

# ============================================================
# 2. 抓取 API 資料
# ============================================================
echo "[2/4] 抓取 API 資料..."
NETWORKS_JSON=$(curl -k -s -b "$COOKIE_JAR" "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/s/default/rest/networkconf")
PROFILES_JSON=$(curl -k -s -b "$COOKIE_JAR" "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/s/default/rest/portconf")
DEVICES_JSON=$(curl -k -s -b "$COOKIE_JAR" "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/s/default/stat/device")
WIFI_JSON=$(curl -k -s -b "$COOKIE_JAR" "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/s/default/rest/wlanconf")
[ "$(echo "$WIFI_JSON" | jq '.data | length' 2>/dev/null)" = "0" ] && WIFI_JSON=$(curl -k -s -b "$COOKIE_JAR" "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/s/default/rest/wificonf")

# 登出並清理記憶體變數
curl -k -s -b "$COOKIE_JAR" -X POST "https://${CONTROLLER_IP}:${CONTROLLER_PORT}/api/logout" > /dev/null || true
rm -f "$COOKIE_JAR" /tmp/unifi_login_resp.txt
unset PASSWORD

# ============================================================
# 3. 解析並生成 Markdown 文檔
# ============================================================
echo "[3/4] 正在解析並生成 Markdown 文檔..."

cat << EOF > "$OUTPUT_FILE"
---
title: "UniFi 實體網路與交換架構手冊"
date: "${GEN_DATE}"
tags:
  - homelab
  - unifi
  - network-spec
---

# UniFi 實體網路與交換架構手冊

> 此文件由自動化 API 提取腳本於 \`${GEN_DATE}\` 產生。
> 控制器來源：\`https://${CONTROLLER_IP}:${CONTROLLER_PORT}\`

**已劃分網路網段 (Networks & VLANs)**

| 網路名稱 (Name) | VLAN ID | 子網路 (Subnet / CIDR) | 網域 (Domain) |
| :--- | :--- | :--- | :--- |
EOF

echo "$NETWORKS_JSON" | jq -r '.data[] | "| **" + .name + "** | `" + ((.vlan // .vlan_id // "0") | tostring) + "` | `" + (.ip_subnet // "無/外部路由") + "` | `" + (.domain_name // "local") + "` |"' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**實體設備清單 (UniFi Switches & APs)**

| 設備名稱 | 設備型號 | 實體 IP 位址 | MAC 位址 | 韌體版本 | 運行狀態 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

echo "$DEVICES_JSON" | jq -r '.data[] | "| **" + (.name // .model) + "** | `" + .model + "` | `" + .ip + "` | `" + .mac + "` | `" + .version + "` | " + (if .state == 1 then "在線 (Online)" else "離線 (Offline)" end) + " |"' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

**交換機連接埠狀態 (Switch Port Profiles)**

EOF

echo "$DEVICES_JSON" | jq -c '.data[] | select(.type == "usw")' | while read -r switch; do
  SW_NAME=$(echo "$switch" | jq -r '.name // .model')
  cat << EOF >> "$OUTPUT_FILE"
### 交換機：${SW_NAME}

| 埠號 (Port) | 埠名稱 (Name) | 連結狀態 (Speed/Duplex) | PoE 供電 (W) | Native Profile / VLAN | 匯總模式 (STP) |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF

  echo "$switch" | jq -r --argjson profs "$PROFILES_JSON" '
    def get_prof_name(id):
      ($profs.data[] | select(._id == id) | .name) // id;
    .port_table[] | "| Port " + (.port_idx | tostring) + " | **" + (.name // "Port " + (.port_idx | tostring)) + "** | `" + (if .up then ((.speed | tostring) + "M FDX") else "Down" end) + "` | " + (if .poe_enable then ((.poe_power // "0.0") | tostring) + "W" else "關閉" end) + " | `" + (get_prof_name(.portconf_id // .native_networkconf_id // "Default") | tostring) + "` | `" + (.stp_state // "forwarding") + "` |"
  ' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

cat << EOF >> "$OUTPUT_FILE"
**無線基地台與 SSID 配置 (Wi-Fi Networks)**

| 無線名稱 (SSID) | 啟用狀態 | 綁定 VLAN | 安全性 | 支援頻段 |
| :--- | :--- | :--- | :--- | :--- |
EOF

echo "$WIFI_JSON" | jq -r '.data[] | "| **" + .name + "** | " + (if .enabled then "啟用" else "停用" end) + " | `" + ((.vlan // .vlan_id // "1") | tostring) + "` | `" + (.security // "open") + "` | `" + (if .wlan_bands then (.wlan_bands | join(", ")) else "2.4G/5G/6G" end) + "` |"' >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

---
*UniFi Topology Data Generated.*
EOF

echo "[4/4] 匯出完成！檔案路徑：$(pwd)/${OUTPUT_FILE}"
