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
				read GITKEY
				echo "${GITKEY} > /home/$NUSER/.ssh/id_rsa
				echo "${GITKEY} > /root/.ssh/id_rsa
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
				# Portainer
				echo "" >> /root/docker-compose/docker-compose.yml
				echo "  portainer:" >> /root/docker-compose/docker-compose.yml
				echo "    image:  portainer/portainer-ce:latest" >> /root/docker-compose/docker-compose.yml
				echo "    container_name: portainer" >> /root/docker-compose/docker-compose.yml
				echo "    environment:" >> /root/docker-compose/docker-compose.yml
				echo "      - PUID=1000" >> /root/docker-compose/docker-compose.yml
				echo "    ports:" >> /root/docker-compose/docker-compose.yml
				echo "      - 9000:9000" >> /root/docker-compose/docker-compose.yml
				echo "    volumes:" >> /root/docker-compose/pdocker-compose.yml
				echo "      - /var/run/docker.sock:/var/run/docker.sock" >> /root/docker-compose/docker-compose.yml
				echo "      - /var/lib/docker/volumes/portainer/data:/data" >> /root/docker-compose/docker-compose.yml
				echo "    restart: always" >> /root/docker-compose/docker-compose.yml
				docker-compose -f /root/docker-compose/docker-compose.yml up -d
				break
				;;
			*)
				continue
				;;
		esac
done
echo -e "${color4}.........................................................................................completed${NC}"

