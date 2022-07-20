#!/bin/bash

#font color define
color1='\e[95m'			# Light Magenta for process step
color2='\e[96m'			# Light Cyan for input
color3='\e[91m'			# Light Red for warning
color4='\e[34m'			# Blue for process completed
NC='\e[0m'			# End code

# Warning
echo -e "${color4}####################################################################################${nc}"
echo -e "${color4}#                                                                                  #${nc}"
echo -e "${color4}#     ${color3}░█████╗░░█████╗░██████╗░██╗░░░██╗  ██████╗░██╗░██████╗░██╗░░██╗████████╗${NC}     ${color4}#${NC}"
echo -e "${color4}#     ${color3}██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝  ██╔══██╗██║██╔════╝░██║░░██║╚══██╔══╝${NC}     ${color4}#${NC}"
echo -e "${color4}#     ${color3}██║░░╚═╝██║░░██║██████╔╝░╚████╔╝░  ██████╔╝██║██║░░██╗░███████║░░░██║░░░${NC}     ${color4}#${NC}"
echo -e "${color4}#     ${color3}██║░░██╗██║░░██║██╔═══╝░░░╚██╔╝░░  ██╔══██╗██║██║░░╚██╗██╔══██║░░░██║░░░${NC}     ${color4}#${NC}"
echo -e "${color4}#     ${color3}╚█████╔╝╚█████╔╝██║░░░░░░░░██║░░░  ██║░░██║██║╚██████╔╝██║░░██║░░░██║░░░${NC}     ${color4}#${NC}"
echo -e "${color4}#     ${color3}░╚════╝░░╚════╝░╚═╝░░░░░░░░╚═╝░░░  ╚═╝░░╚═╝╚═╝░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░${NC}     ${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#        ${color2}                      For Kiwi's own Oracle Linux on OCI using Only${NC}       ${color4}#${NC}"
echo -e "${color4}#        ${color1}                               Create/Modified by Kaiwei 2022/03/14${NC}       ${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}####################################################################################${NC}"
echo -e ""
echo -e ""
echo -e ""
echo -e ""
echo -e "${color4}####################################################################################${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#          ${color3} ░██╗░░░░░░░██╗░█████╗░██████╗░███╗░░██╗██╗███╗░░██╗░██████╗░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░██║░░██╗░░██║██╔══██╗██╔══██╗████╗░██║██║████╗░██║██╔════╝░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░╚██╗████╗██╔╝███████║██████╔╝██╔██╗██║██║██╔██╗██║██║░░██╗░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░████╔═████║░██╔══██║██╔══██╗██║╚████║██║██║╚████║██║░░╚██╗           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░╚██╔╝░╚██╔╝░██║░░██║██║░░██║██║░╚███║██║██║░╚███║╚██████╔╝           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚═════╝░           ${NC}${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#                    ${color1}   This Script only for Kiwi Private Usage                    ${NC}${color4}#${NC}"
echo -e "${color4}#                    ${color1}There is no guarantee for any other environment               ${NC}${color4}#${NC}"
echo -e "${color4}#                    ${color1}Please use for your own risk                                  ${NC}${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}####################################################################################${NC}"
echo -e ""
echo -e ""
echo -e "${color2}Press Enter to Continue${NC}"
while :
do
	read ANY
	case $ANY in
		*)
			break
			;;
	esac
done

# Create New User
echo -e "${color1}Create New User for rescue${NC}"
echo -e "${color2}Please input username you want\n${NC}"
read NUSER
useradd -m -g root ${NUSER}
echo -e "${color1}Setup password for the user${NC}"
passwd ${NUSER}

# Basic system configuration
echo -e "${color1}Basic system configuration started${NC}"
echo -e "${color1}Update system${NC}"
yum update -y
/usr/libexec/oci-growfs -y
echo -e "${color1}Pre-install Docker-ce${NC}"
dnf install -y dnf-utils zip unzip
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf remove -y runc
echo -e "${color1}System tools installing${NC}"
yum install -y docker-ce --nobest
yum install -y git
echo -e "${color4}.........................................................................................completed${NC}"

# Docker setup
echo -e "${color1}Docker Service enable & start${NC}"
systemctl enable docker
systemctl start docker

echo -e "${color1}Docker Version${color2}"
docker --version

echo -e ""
echo -e ""
echo -e "${color2}Press Enter to Continue${NC}"
while :
do
       read ANY2
       case $ANY2 in
           *)
              break
              ;;
		esac
done

# Docker compose
echo -e "${color1}Docker-compose installed and configure${NC}"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo -e "${color4}.........................................................................................completed${NC}"

# git clone setting from kiwi's private git repo
echo -e "${color1}Using Kiwi's Private Repo to Configure${NC}"
echo -e "${color2}Are You Kiwi himself?(Yes/No)${NC}"
while :
do
                read KIWI
                case $KIWI in
                        Yes)
                            mkdir /home/$NUSER/.ssh
                            mkdir /root/.ssh/
                            echo -e "${color2}Please Paste your Private SSH key for Github\n${NC}"
                                vi /root/.ssh/id_rsa
                                cp /root/.ssh/id_rsa /home/$NUSER/.ssh/
                                chown -R $NUSER /home/$NUSER
                                chmod 400 /home/$NUSER/.ssh/id_rsa
                                chmod 400 /root/.ssh/id_rsa
                                cd /home/$NUSER
                                git clone git@github.com:Kiwi0093/docker-compose.git
                                docker-compose -f /home/$NUSER/docker-compose/vps/common/portainer-agent/docker-compose.yml up -d
                                docker-compose -f /home/$NUSER/docker-compose/vps/common/watchtower/docker-compose.yml up -d
                                break
                                ;;
                        No)
                            echo -e "${color1}Do you want to add Portainer & watchtower containers into your system?(Yes/No)${NC}"
                            while :
                            do
                                read CONTAINER1
                                case $CONTAINER1 in
                                    Yes)
                                        echo -e "${color1}Add portainer/watchtower containers and put docker-compose.yml into /root/docker-compose/${NC}"
                                        # add more compose files
                                        mkdir /root/docker-compose
                                        # watchtower
                                        echo -e "${color1}Create docker-compose file for watchtower & Portainer${NC}"
                                        echo "version: '3'" > /root/docker-compose/docker-compose.yml
                                        echo "services:" >> /root/docker-compose/docker-compose.yml
                                        echo "  watchtower:" >> /root/docker-compose/docker-compose.yml
                                        echo "      image: containrrr/watchtower" >> /root/docker-compose/docker-compose.yml
                                        echo "      container_name: watchtower" >> /root/docker-compose/docker-compose.yml
                                        echo "      volumes:" >> /root/docker-compose/docker-compose.yml
                                        echo "        - /var/run/docker.sock:/var/run/docker.sock" >> /root/docker-compose/docker-compose.yml
                                        echo "      environment:" >> /root/docker-compose/docker-compose.yml
                                        echo "        - TZ=Asia/Taipei" >> /root/docker-compose/docker-compose.yml
                                        echo "      restart: unless-stopped" >> /root/docker-compose/docker-compose.yml
                                        echo '      command: --cleanup --schedule "0 0 4 * * *"' >> /root/docker-compose/docker-compose.yml
                                        echo -e "${color1}Do you want to use Portainer Host?(Yes/No)${NC}"
                                        while :
                                        do
                                           read CONTAINER1
                                           case $CONTAINER1 in
                                               Yes)# Portainer
                                                   echo "" >> /root/docker-compose/docker-compose.yml
                                                   echo "  portainer:" >> /root/docker-compose/docker-compose.yml
                                                   echo "    image:  portainer/portainer-ce:latest" >> /root/docker-compose/docker-compose.yml
                                                   echo "    container_name: portainer" >> /root/docker-compose/docker-compose.yml
                                                   echo "    environment:" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - PUID=1000" >> /root/docker-compose/docker-compose.yml
                                                   echo "    ports:" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - 9000:9000" >> /root/docker-compose/docker-compose.yml
                                                   echo "    volumes:" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - /var/run/docker.sock:/var/run/docker.sock" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - /var/lib/docker/volumes/portainer/data:/data" >> /root/docker-compose/docker-compose.yml
                                                   echo "    restart: always" >> /root/docker-compose/docker-compose.yml
                                                   break
                                                   ;;
                                              No)
                                                   echo -e "${color1}Processing to Protainer-agent${NC}"
                                                   echo "portainer:" >> /root/docker-compose/docker-compose.yml
                                                   echo "    image:  portainer/agent:latest" >> /root/docker-compose/docker-compose.yml
                                                   echo "    container_name: portainer_agent" >> /root/docker-compose/docker-compose.yml
                                                   echo "    ports:" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - 9001:9001" >> /root/docker-compose/docker-compose.yml
                                                   echo "    volumes:" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - /var/run/docker.sock:/var/run/docker.sock" >> /root/docker-compose/docker-compose.yml
                                                   echo "      - /var/lib/docker/volumes:/var/lib/docker/volumes" >> /root/docker-compose/docker-compose.yml
                                                   echo "    restart: always" >> /root/docker-compose/docker-compose.yml
                                                   break
                                                   ;;
                                              *)
                                                   echo -e "${color1}Do you want to use Portainer Host?(Yes/No)${NC}"
                                                   continue
                                                   ;;
                                             esac
                                        done
                                        docker-compose -f /root/docker-compose/docker-compose.yml up -d
                                        echo -e "${color1}Do you want to Establish V2ray+Nginx Service?(Yes/No)${NC}"
                                        while :
                                        do
                                            read CONTAINER2
                                            case $CONTAINER2 in
                                            Yes)
                                                # Start from Trafik
                                                echo -e "${color1}Create v2ray.yml into /root/docker-compose/${NC}"
                                                echo -e "${color1}Please input the Domain for Trafik Dashboard${NC}"
                                                read DASHDN
                                                echo "version: '3.3'" > /root/docker-compose/v2ray.yml
                                                echo "" >> /root/docker-compose/v2ray.yml
                                                echo "services:" >> /root/docker-compose/v2ray.yml
                                                echo "  traefik:" >> /root/docker-compose/v2ray.yml
                                                echo "    image: traefik:v2.5" >> /root/docker-compose/v2ray.yml
                                                echo "    container_name: traefik" >> /root/docker-compose/v2ray.yml
                                                echo "    command:" >> /root/docker-compose/v2ray.yml
                                                echo "      - --api.insecure=false # <== DisEnabling insecure api. Default is ture." >> /root/docker-compose/v2ray.yml
                                                echo "      - --api.dashboard=true # <== Enabling the dashboard to view services, middlewares, routers, etc..." >> /root/docker-compose/v2ray.yml
                                                echo "      - --api.debug=true # <== Enabling additional endpoints for debugging and profiling" >> /root/docker-compose/v2ray.yml
                                                echo "      - --providers.docker=true # <== Enabling docker as the provider for traefik" >> /root/docker-compose/v2ray.yml
                                                echo "      - --providers.docker.exposedbydefault=false # <== Don't expose every container to traefik, only expose enabled ones" >> /root/docker-compose/v2ray.yml
                                                echo "      - --entrypoints.web.address=:80 # <== Defining an entrypoint for port :80 named web" >> /root/docker-compose/v2ray.yml
                                                echo "      - --entrypoints.web-secured.address=:443 # <== Defining an entrypoint for https on port :443 named web-secured" >> /root/docker-compose/v2ray.yml
                                                echo "      - --certificatesresolvers.myresolver.acme.httpchallenge=true" >> /root/docker-compose/v2ray.yml
                                                echo "      - --certificatesresolvers.myresolver.acme.tlschallenge=true" >> /root/docker-compose/v2ray.yml
                                                echo "      - --certificatesresolvers.myresolver.acme.email=kiwi.lin@gmail.com" >> /root/docker-compose/v2ray.yml
                                                echo "      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json" >> /root/docker-compose/v2ray.yml
                                                echo "    ports:" >> /root/docker-compose/v2ray.yml
                                                echo "      - 80:80" >> /root/docker-compose/v2ray.yml
                                                echo "      - 443:443" >> /root/docker-compose/v2ray.yml
                                                echo "      - 8080:8080" >> /root/docker-compose/v2ray.yml
                                                echo "    volumes:" >> /root/docker-compose/v2ray.yml
                                                echo "      - /var/lib/docker/volumes/traefik/letsencrypt:/letsencrypt" >> /root/docker-compose/v2ray.yml
                                                echo "      - /var/run/docker.sock:/var/run/docker.sock:ro" >> /root/docker-compose/v2ray.yml
                                                echo "    labels:" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.enable: true # <== Enable traefik on itself to view dashboard and assign subdomain to view it" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.http_catchall.rule: hostregexp(\`{host:.*}\`)" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.http_catchall.entryPoints: web" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.http_catchall.middlewares: redirect_https # <== apply redirect_https middleware which is defined in the below" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.traefik.rule: Host(\`$DASHDN\`) # <== Setting the domain for the dashboard" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.traefik.entryPoints: web-secured" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.traefik.tls: true" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.traefik.tls.certresolver: myresolver" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.traefik.service: api@internal" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.middlewares.redirect_https.redirectscheme.scheme: https # <== define a https redirection middleware" >> /root/docker-compose/v2ray.yml
                                                echo "      restart: unless-stopped" >> /root/docker-compose/v2ray.yml
                                                echo "" >> /root/docker-compose/v2ray.yml
                                                # add Nginx & V2Ray
                                                echo -e "${color1}Please input the Domain for V2ray${NC}"
                                                read V2RAYDN
                                                echo "  nginx:" >> /root/docker-compose/v2ray.yml
                                                echo "    image: lscr.io/linuxserver/nginx" >> /root/docker-compose/v2ray.yml
                                                echo "    container_name: V2ray_Nginx" >> /root/docker-compose/v2ray.yml
                                                echo "    environment:" >> /root/docker-compose/v2ray.yml
                                                echo "      - PUID=1000" >> /root/docker-compose/v2ray.yml
                                                echo "      - PGID=1000" >> /root/docker-compose/v2ray.yml
                                                echo "      - TZ=Asia/Taipei" >> /root/docker-compose/v2ray.yml
                                                echo "    expose:" >> /root/docker-compose/v2ray.yml
                                                echo "      - 80" >> /root/docker-compose/v2ray.yml
                                                echo "    restart: always" >> /root/docker-compose/v2ray.yml
                                                echo "    volumes:" >> /root/docker-compose/v2ray.yml
                                                echo "      - /var/lib/docker/volumes/v2ray/nginx/config:/config" >> /root/docker-compose/v2ray.yml
                                                echo "    links:" >> /root/docker-compose/v2ray.yml
                                                echo "      - v2ray:v2ray" >> /root/docker-compose/v2ray.yml
                                                echo "    depends_on:" >> /root/docker-compose/v2ray.yml
                                                echo "      - v2ray" >> /root/docker-compose/v2ray.yml
                                                echo "    labels:" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.enable: true # <== Enable traefik on itself to view dashboard and assign subdomain to view it" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.v2ray.rule: Host(\`V2RAYDN\`) # <== Setting the domain for the dashboard" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.v2ray.tls: true" >> /root/docker-compose/v2ray.yml
                                                echo "      traefik.http.routers.v2ray.tls.certresolver: myresolver" >> /root/docker-compose/v2ray.yml
                                                echo "" >> /root/docker-compose/v2ray.yml
                                                echo "  v2ray:" >> /root/docker-compose/v2ray.yml
                                                echo "    image: v2fly/v2fly-core" >> /root/docker-compose/v2ray.yml
                                                echo "    container_name: V2ray_V2ray" >> /root/docker-compose/v2ray.yml
                                                echo "    environment:" >> /root/docker-compose/v2ray.yml
                                                echo "      - TZ=Asia/Taipei" >> /root/docker-compose/v2ray.yml
                                                echo "    expose:" >> /root/docker-compose/v2ray.yml
                                                echo "      - 10000" >> /root/docker-compose/v2ray.yml
                                                echo "    restart: always" >> /root/docker-compose/v2ray.yml
                                                echo "    command: v2ray --config=/etc/v2ray/config.json" >> /root/docker-compose/v2ray.yml
                                                echo "    volumes:" >> /root/docker-compose/v2ray.yml
                                                echo "      - /var/lib/docker/volumes/v2ray/v2ray:/etc/v2ray" >> /root/docker-compose/v2ray.yml
                                                # Create nginx setting file
                                                echo "server {" > /root/default
                                                echo "    listen 80;" >> /root/default
                                                echo "" >> /root/default
                                                echo "    location / {" >> /root/default
                                                echo "        root   /config/www;" >> /root/default
                                                echo "        index  index.html index.htm;" >> /root/default
                                                echo "    }" >> /root/default
                                                echo "" >> /root/default
                                                echo "    location /ray {" >> /root/default
                                                echo "        proxy_redirect off;" >> /root/default
                                                echo "       proxy_pass http://v2ray:10000;" >> /root/default
                                                echo "        proxy_http_version 1.1;" >> /root/default
                                                echo "        proxy_set_header Upgrade $http_upgrade;" >> /root/default
                                                echo "        proxy_set_header Connection "upgrade";" >> /root/default
                                                echo "        proxy_set_header Host $http_host;" >> /root/default
                                                echo "    }" >> /root/default
                                                echo "" >> /root/default
                                                echo "    location ~ \.php$ {" >> /root/default
                                                echo "        deny all;" >> /root/default
                                                echo "    }" >> /root/default
                                                echo "}" >> /root/default
                                                # Create v2ray setting file
                                                echo -e "${color1}Please input UUID for V2ray${NC}"
                                                read V2RAYID
                                                echo '{' > /root/config.json
                                                echo '    "log": {' >> /root/config.json
                                                echo '        "loglevel": "warning"' >> /root/config.json
                                                echo '    },' >> /root/config.json
                                                echo '    "inbounds": [' >> /root/config.json
                                                echo '        {' >> /root/config.json
                                                echo '            "port": 10000,' >> /root/config.json
                                                echo '            "listen": "0.0.0.0",' >> /root/config.json
                                                echo '            "protocol": "vless",' >> /root/config.json
                                                echo '            "settings": {' >> /root/config.json
                                                echo '                "clients": [' >> /root/config.json
                                                echo '                   {' >> /root/config.json
                                                echo '                        "id": "$V2RAYID",' >> /root/config.json
                                                echo '                        "level": 0,' >> /root/config.json
                                                echo '                       "email": "kiwi@kaienroid.com"' >> /root/config.json
                                                echo '                    }' >> /root/config.json
                                                echo '                ],' >> /root/config.json
                                                echo '                "decryption": "none"' >> /root/config.json
                                                echo '            },' >> /root/config.json
                                                echo '            "streamSettings": {' >> /root/config.json
                                                echo '                "network": "ws",' >> /root/config.json
                                                echo '                "security": "none",' >> /root/config.json
                                                echo '                "wsSettings": {' >> /root/config.json
                                                echo '                    "path": "/ray"' >> /root/config.json
                                                echo '                }' >> /root/config.json
                                                echo '            }' >> /root/config.json
                                                echo '        }' >> /root/config.json
                                                echo '    ],' >> /root/config.json
                                                echo '    "outbounds": [' >> /root/config.json
                                                echo '        {' >> /root/config.json
                                                echo '            "protocol": "freedom"' >> /root/config.json
                                                echo '        }' >> /root/config.json
                                                echo '    ]' >> /root/config.json
                                                echo '}' >> /root/config.json

                                                echo -e "${color1}Please input the Domain for Trafik Dashboard${NC}"
                                                docker-compose -f /root/docker-compose/v2ray.yml up -d
                                                docker-compose -f /root/docker-compose/v2ray.yml down
                                                mv /root/default /var/lib/docker/volumes/v2ray/nginx/config/nginx/site-confs/
                                                mv /root/config.json /var/lib/docker/volumes/v2ray/v2ray/
                                                docker-compose -f /root/docker-compose/v2ray.yml up -d
                                                break
                                                ;;
                                            No)
                                                break
                                                ;;
                                            *)
                                                echo -e "${color1}Do you want to Establish V2ray+Nginx Service?(Yes/No)${NC}"
                                                continue
                                                ;;
                                            esac
                                        done
                                        break
                                        ;;
                                    No)
                                        break
                                        ;;
                                    *)
                                        echo -e "${color1}Do you want to add Portainer & watchtower containers into your system?(Yes/No)${NC}"
                                        continue
                                        ;;
                                esac
                            done
                                break
                                ;;
                        *)
                                continue
                                ;;
                esac
done

echo -e "${color4}.........................................................................................completed${NC}"

