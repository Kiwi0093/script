#!/bin/sh
#Parmeter Pre-Define
#Color for warning
COLOR_W='\e[35m'
#Color for description
COLOR1='\e[94m'
COLOR2='\e[32m'
# Color for Highlight package
COLOR_H1='\e[96m'
COLOR_H2='\e[34m'
NC='\e[0m'

#Notice before use
echo -e "${COLOR_W}=====================Warning=======================\n${NC}"
echo -e "${COLOR_W}=  Kiwi's Arch linux Auto install script Ver.1.1  =\n${NC}"
echo -e "${COLOR_W}=  Arch + Nextcloud Install script Ver.1.0        =\n${NC}"
echo -e "${COLOR_W}=  This Script for Kiwi private use.              =\n${NC}"
echo -e "${COLOR_W}=  If you have any issue on usage,                =\n${NC}"
echo -e "${COLOR_W}=  Please DON'T Feedback to Kiwi                  =\n${NC}"
echo -e "${COLOR_W}=  And you should take your own responsibility    =\n${NC}"
echo -e "${COLOR_W}===================================================\n${NC}"

#change Timezone
echo -e "${COLOR1}Please select your time zone\n${NC}${COLOR_H1}1)Taipei\n2)Shanghai\n*)Whatever..I don't care\n${NC}"
while :
do
	read ZONE
	case $ZONE in
		1)
			echo -e "${COLOR1}Set Time Zone to Asia/Taipei${NC}"
			ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
			hwclock --systohc --utc
			break
			;;
		2)
			echo -e "${COLOR1}Set Time Zone to Asia/Shanghai${NC}"
			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
			hwclock --systohc --utc
			break
			;;
		*)
			echo -e "${COLOR1}Nobody cares the local time!!${NC}"
			hwclock --systohc --utc
			break
			;;
	esac
done
echo -e "${COLOR2}Completed${NC}"

#locale-gen to add en_US & zh_TW
echo -e "${COLOR1}Setting local file${NC}"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
echo -e "${COLOR1}Generate locale.conf${NC}"
locale-gen
echo -e "${COLOR1}Setting locale.conf${NC}"
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "${COLOR2}Completed${NC}"

#Hostname
echo -e "${COLOR1}Please input your hostname\n${NC}"
read HOSTNAME
echo ${HOSTNAME} > /etc/hostname
echo "127.0.0.1 localhost ${HOSTNAME}" >> /etc/hosts
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your NIC by Mac address${NC}"
echo -e "${COLOR1}Please input your MAC Address(need to be lowcase):\n${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${OUTSIDE}'", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your IP for EXT0:${NC}"
echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
echo "Interface=EXT0" >> /etc/netctl/EXT0.service
echo "Connection=ethernet" >> /etc/netctl/EXT0.service
echo "IP=static" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your IP address:\n${NC}"
read EXT_IP
echo "Address=('${EXT_IP}/24')" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your Gateway IP address:\n${NC}"
read GATE_IP
echo "Gateway='${GATE_IP}'" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your DNS IP address:\n${NC}"
read DNS_IP
echo "DNS=('${DNS_IP}')" >> /etc/netctl/EXT0.service
echo -e "${COLOR2}Enable EXT0${NC}"
netctl enable EXT0.service
echo -e "${COLOR2}Finished.${NC}"

#Root Password
echo -e "${COLOR1}Set your root password${NC}"
passwd
chsh -s /bin/zsh
echo -e "${COLOR2}Completed${NC}"

#add User
echo -e "${COLOR1}Add user account:${NC}"
echo -n "${COLOR1}What ID you want:${NC}"
read YOURID
useradd -m -g root -s /bin/zsh ${YOURID}
passwd ${YOURID}
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Add $YOURID into sudo list${NC}"
pacman -Syu sudo
echo "${YOURID} ALL=(ALL) ALL" >> /etc/sudoers
echo -e "${COLOR2}Completed${NC}"

#install Tools
echo -e "${COLOR1}Install Packages${NC}"
echo -e "${COLOR1}tmux${NC}"
pacman -Syu --noconfirm git go base-devel tmux mariadb php php-apcu php-fpm php-gd php-imap php-intl php-imagick nginx certbot certbot-nginx nextcloud
echo -e "${COLOR2}Completed${NC}"
echo -e "${COLOR1}Install yay${NC}"
cd /root
git clone https://aur.archlinux.org/yay.git
chomd 777 yay
cd yay
sudo -u kiwi makepkg -si
rm -rf yay
sudo -u kiwi yay -S php-smbclient

#Setup service
#setup MariaDB
echo -e "${COLOR1}Start to Setup MariaDB${NC}"
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
mkdir -pv /var/lib/mysqltmp
chown mysql:mysql /var/lib/mysqltmp
echo "tmpfs   /var/lib/mysqltmp   tmpfs   rw,gid=mysql,uid=mysql,size=100M,mode=0750,noatime   0 0" >> /etc/fstab
echo "[client]" >> /etc/my.cnf
echo "default-character-set = utf8mb4" >> /etc/my.cnf
echo "" >> /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "default-character-set = utf8mb4" >> /etc/my.cnf
echo "" >> /etc/my.cnf
echo "[mysqld]" >> /etc/my.cnf
echo "collation_server = utf8mb4_unicode_ci" >> /etc/my.cnf
echo "character_set_server = utf8mb4" >> /etc/my.cnf
echo "tmpdir      = /var/lib/mysqltmp" >> /etc/my.cnf
mount /var/lib/mysqltmp
systemctl enable mariadb.service
sudo -u mysql /usr/bin/mariadbd &
echo -e "${COLOR1}MariaDB Deamon Started${NC}"
mysql_secure_installation
echo -n "${COLOR1}Please input your Username for Nextcloud Database:\n${NC}"
read NCUSER
echo -n "${COLOR1}Please input your Password for Nextcloud Database User:\n${NC}"
read NCPASSWD
mysql -u root -p -e"CREATE DATABASE nextcloud DEFAULT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci';GRANT ALL PRIVILEGES ON nextcloud.* TO '${NCUSER}'@'localhost' IDENTIFIED BY '${NCPASSWD}';FLUSH PRIVILEGES;"
echo -e "${COLOR2}MariaDB setup compleated${NC}"
#Setup PHP
echo -e "${COLOR1}change PHP setting$${NC}"
curl -o /etc/php/php.ini https://kiwi0093.github.io/script/Arch/php.ini
echo -e "${COLOR2}PHP setting completed${NC}"
#Setup nextcloud
echo -e "${COLOR1}Set up Nextcloud${NC}"
echo "nexcloud ALL=(ALL) ALL" >> /etc/sudoers
sudo -u nextcloud occ maintenance:install --database mysql --database-name nextcloud --database-host localhost --database-user ${NCUSER} --database-pass=<${NCPASSWD}> --data-dir /var/lib/nextcloud/data/
curl -o /usr/share/webapps/nextcloud/config/config.php https://kiwi0093.github.io/script/Arch/config.php
echo -e "${COLOR2}nexcloud set up compleated${NC}"
#Set up PHP-FPM
echo -e "${COLOR1}Set up PHP-FPM${NC}"
echo "[nextcloud]" > /etc/php/php-fpm.d/nextcloud.conf
echo "user = nextcloud" >> /etc/php/php-fpm.d/nextcloud.conf
echo "group = nextcloud" >> /etc/php/php-fpm.d/nextcloud.conf
echo "listen = /run/nextcloud/nextcloud.sock" >> /etc/php/php-fpm.d/nextcloud.conf
echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/php-fpm.d/nextcloud.conf
echo "env[TMP] = /tmp" >> /etc/php/php-fpm.d/nextcloud.conf
echo "" >> /etc/php/php-fpm.d/nextcloud.conf
echo "; should be accessible by your web server" >> /etc/php/php-fpm.d/nextcloud.conf
echo "listen.owner = http" >> /etc/php/php-fpm.d/nextcloud.conf
echo "listen.group = http" >> /etc/php/php-fpm.d/nextcloud.conf
echo "" >> /etc/php/php-fpm.d/nextcloud.conf
echo "pm = dynamic" >> /etc/php/php-fpm.d/nextcloud.conf
echo "pm.max_children = 15" >> /etc/php/php-fpm.d/nextcloud.conf
echo "pm.start_servers = 2" >> /etc/php/php-fpm.d/nextcloud.conf
echo "pm.min_spare_servers = 1" >> /etc/php/php-fpm.d/nextcloud.conf
echo "pm.max_spare_servers = 3" >> /etc/php/php-fpm.d/nextcloud.conf

mkdir /etc/systemd/system/php-fpm.service.d/
echo "[Service]" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "# Your data directory" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "ReadWritePaths=/var/lib/nextcloud/data" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "# Optional: add if you've set the default apps directory to be writable in config.php" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "ReadWritePaths=/usr/share/webapps/nextcloud/apps" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "# Optional: unnecessary if you've set 'config_is_read_only' => true in your config.php" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "ReadWritePaths=/usr/share/webapps/nextcloud/config" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "ReadWritePaths=/etc/webapps/nextcloud/config" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "# Optional: add if you want to use Nextcloud's internal update process" > /etc/systemd/system/php-fpm.service.d/override.conf
echo "# ReadWritePaths=/usr/share/webapps/nextcloud" > /etc/systemd/system/php-fpm.service.d/override.conf
systemctl enable php-fpm.service
echo -e "${COLOR2}PHP-FPM setting completed${NC}"

#set up nginx
echo -e "${COLOR1}Set up Nginx${NC}"
echo -n "${COLOR1}Please input you Domain for your Nextcloud Server${NC}"
read NCDOMAIN
mv /etc/nginx/nginx.conf /etc/nginx.conf.old
mkdir /etc/nginx/conf.d
mkdir /etc/nginx/sites-enabled
echo "user http;" > /etc/nginx/nginx.conf
echo "worker_processes auto;" >> /etc/nginx/nginx.conf
echo "worker_cpu_affinity auto;" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "events {" >> /etc/nginx/nginx.conf
echo "    multi_accept on;" >> /etc/nginx/nginx.conf
echo "    worker_connections 1024;" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "http {" >> /etc/nginx/nginx.conf
echo "    charset utf-8;" >> /etc/nginx/nginx.conf
echo "    sendfile on;" >> /etc/nginx/nginx.conf
echo "    tcp_nopush on;" >> /etc/nginx/nginx.conf
echo "    tcp_nodelay on;" >> /etc/nginx/nginx.conf
echo "    server_tokens off;" >> /etc/nginx/nginx.conf
echo "    log_not_found off;" >> /etc/nginx/nginx.conf
echo "    types_hash_max_size 4096;" >> /etc/nginx/nginx.conf
echo "    client_max_body_size 16M;" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "    # MIME" >> /etc/nginx/nginx.conf
echo "    include mime.types;" >> /etc/nginx/nginx.conf
echo "    default_type application/octet-stream;" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "    # logging" >> /etc/nginx/nginx.conf
echo "    access_log /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf
echo "    error_log /var/log/nginx/error.log warn;" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "    # load configs" >> /etc/nginx/nginx.conf
echo "    include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
echo "    include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf

echo "upstream php-handler {" > /etc/nginx/sites-enabled/nextcloud
echo "    unix:/run/nextcloud/nextcloud.sock;" >> /etc/nginx/sites-enabled/nextcloud
echo "    #server unix:/var/run/php/php7.4-fpm.sock;" >> /etc/nginx/sites-enabled/nextcloud
echo "}" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "server {" >> /etc/nginx/sites-enabled/nextcloud
echo "    listen 80;" >> /etc/nginx/sites-enabled/nextcloud
echo "    listen [::]:80;" >> /etc/nginx/sites-enabled/nextcloud
echo "    server_name ${NCDOMAIN};" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # Enforce HTTPS" >> /etc/nginx/sites-enabled/nextcloud
echo '    return 301 https://$server_name$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "}" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "server {" >> /etc/nginx/sites-enabled/nextcloud
echo "    listen 443      ssl http2;" >> /etc/nginx/sites-enabled/nextcloud
echo "    listen [::]:443 ssl http2;" >> /etc/nginx/sites-enabled/nextcloud
echo "    server_name ${NCDOMAIN};" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    ssl_certificate     /etc/letsencrypt/live/${NCDOMAIN}/fullchain.pem;" >> /etc/nginx/sites-enabled/nextcloud
echo "    ssl_certificate_key /etc/letsencrypt/live/${NCDOMAIN}/privkey.pem;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # set max upload size" >> /etc/nginx/sites-enabled/nextcloud
echo "    client_max_body_size 16G;" >> /etc/nginx/sites-enabled/nextcloud
echo "    fastcgi_buffers 64 4K;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # Enable gzip but do not remove ETag headers" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip on;" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip_vary on;" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip_comp_level 4;" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip_min_length 256;" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;" >> /etc/nginx/sites-enabled/nextcloud
echo "    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # HTTP response headers borrowed from Nextcloud \`.htaccess\`" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header Referrer-Policy                      \"no-referrer\"   always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-Content-Type-Options               \"nosniff\"       always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-Download-Options                   \"noopen\"        always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-Frame-Options                      \"SAMEORIGIN\"    always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-Permitted-Cross-Domain-Policies    \"none\"          always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-Robots-Tag                         \"none\"          always;" >> /etc/nginx/sites-enabled/nextcloud
echo "    add_header X-XSS-Protection                     \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # Remove X-Powered-By, which is an information leak" >> /etc/nginx/sites-enabled/nextcloud
echo "    fastcgi_hide_header X-Powered-By;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    # Path to the root of your installation" >> /etc/nginx/sites-enabled/nextcloud
echo "    root /usr/share/webapps/nextcloud;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    index index.php index.html /index.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    location = / {" >> /etc/nginx/sites-enabled/nextcloud
echo '        if ( $http_user_agent ~ ^DavClnt ) {' >> /etc/nginx/sites-enabled/nextcloud
echo '            return 302 /remote.php/webdav/$is_args$args;' >> /etc/nginx/sites-enabled/nextcloud
echo "        }" >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    location = /robots.txt {" >> /etc/nginx/sites-enabled/nextcloud
echo "        allow all;" >> /etc/nginx/sites-enabled/nextcloud
echo "        log_not_found off;" >> /etc/nginx/sites-enabled/nextcloud
echo "        access_log off;" >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    location ^~ /.well-known {' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "        location = /.well-known/carddav { return 301 /remote.php/dav/; }" >> /etc/nginx/sites-enabled/nextcloud
echo "        location = /.well-known/caldav  { return 301 /remote.php/dav/; }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }' >> /etc/nginx/sites-enabled/nextcloud
echo '        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '        return 301 /index.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }' >> /etc/nginx/sites-enabled/nextcloud
echo '    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    location ~ \.php(?:$|/) {' >> /etc/nginx/sites-enabled/nextcloud
echo '        fastcgi_split_path_info ^(.+?\.php)(/.*)$;' >> /etc/nginx/sites-enabled/nextcloud
echo '        set $path_info $fastcgi_path_info;' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '        try_files $fastcgi_script_name =404;' >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "        include fastcgi_params;" >> /etc/nginx/sites-enabled/nextcloud
echo '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> /etc/nginx/sites-enabled/nextcloud
echo '        fastcgi_param PATH_INFO $path_info;' >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice" >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_param front_controller_active true;     # Enable pretty urls" >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_pass php-handler;" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_intercept_errors on;" >> /etc/nginx/sites-enabled/nextcloud
echo "        fastcgi_request_buffering off;" >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    location ~ \.(?:css|js|svg|gif)$ {' >> /etc/nginx/sites-enabled/nextcloud
echo '        try_files $uri /index.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "        expires 6M;         # Cache-Control policy borrowed from \`.htaccess\`" >> /etc/nginx/sites-enabled/nextcloud
echo "        access_log off;     # Optional: Don't log access to assets" >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo '    location ~ \.woff2?$ {' >> /etc/nginx/sites-enabled/nextcloud
echo '        try_files $uri /index.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "        expires 7d;         # Cache-Control policy borrowed from \`.htaccess\`" >> /etc/nginx/sites-enabled/nextcloud
echo "        access_log off;     # Optional: Don't log access to assets" >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    location /remote {" >> /etc/nginx/sites-enabled/nextcloud
echo '        return 301 /remote.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "    }" >> /etc/nginx/sites-enabled/nextcloud
echo "" >> /etc/nginx/sites-enabled/nextcloud
echo "    location / {" >> /etc/nginx/sitqes-enabled/nextcloud
echo '        try_files $uri $uri/ /index.php$request_uri;' >> /etc/nginx/sites-enabled/nextcloud
echo "}" >> /etc/nginx/sites-enabled/nextcloud

systemctl enable nginx.service
echo -e "${COLOR2}Nginx setup complted${NC}"

#set up certbot
echo -e "${COLOR1}Set up Cetbot for SSL${NC}"
certbot certonly -d ${NCDOMAIN}
echo -e "${COLOR2}SSL set up Completed${NC}"

#sshd
echo -e "${COLOR1} Enable sshd${NC}"
systemctl enable sshd.service
echo -e "${COLOR2}sshd enabled${NC}"

#install Bootloader
echo -e "${COLOR1}Install grub Boot Loader into /dev/sda${NC}"
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${COLOR2}Completed${NC}"

#Finished install
sync
sync
sync
exit
