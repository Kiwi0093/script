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
echo -e "${color4}#       ${color2}Automatic Configuration Script for Amazon Linux2 on WSL2 ver.Distrod${NC}       ${color4}#${NC}"
echo -e "${color4}#        ${color1}                               Create/Modified by Kaiwei 2022/03/23${NC}       ${color4}#${NC}"
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
echo -e "${color4}#                    ${color1}This Script only for Self Special Usage                       ${NC}${color4}#${NC}"
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
# Basic system configuration
echo -e "${color1}Basic system configuration started${NC}"
echo -e "${color3}Move Working Dir to /root/${NC}"
cd
echo -e "${color1}Update system${NC}"
yum update -y
echo -e "${color1}Enable Docker & Amazon Corretto8${NC}"
amazon-linux-extras enable docker
amazon-linux-extras enable corretto8
echo -e "${color1}System tools installing${NC}"
yum install docker java-1.8.0-amazon-corretto-devel git -y
echo -e "${color4}.........................................................................................completed${NC}"

# Docker setup
echo -e "${color1}Docker Service enable & start${NC}"
systemctl enable docker
systemctl start docker

echo -e "${color1}Confirm Docker & Java Version${NC}"
echo -e "${color1}Java Version${color2}"
java -version
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