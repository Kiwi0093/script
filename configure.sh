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
echo -e "${color4}#        ${color2}Quixant SQL-Server Automatic Configuration Script for Amazon Linux2${NC}       ${color4}#${NC}"
echo -e "${color4}#        ${color1}                               Create/Modified by Kaiwei 2022/02/23${NC}       ${color4}#${NC}"
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
echo -e "${color4}#                    ${color1}This Script only for Quixant Special Usage                    ${NC}${color4}#${NC}"
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


# SQL-Server container
echo -e "${color1}Create compose file for MS-SQL-Server 2019${NC}"
echo "version: '3'" > mssql.yml
echo "services:" >> mssql.yml
echo "  mssql:" >> mssql.yml
echo "    image:  mcr.microsoft.com/mssql/server:2019-latest" >> mssql.yml
echo "    container_name: sql-server" >> mssql.yml
echo "    environment:" >> mssql.yml
echo "      - PUID=1000" >> mssql.yml
echo "      - ACCEPT_EULA=Y" >> mssql.yml
echo -e "${color2}Setup your SA password for SQL-Server:\n${NC}"
read SAPASSWD
echo "      - SA_PASSWORD=${SAPASSWD}" >> mssql.yml
echo -e "${color2}Do you have Lience for SQL-Server?:(Y/N)\n${NC}"
while :
do
	read MSSQLLISENCE
	case $MSSQLLISENCE in
		Y)
			echo -e "${color2}Please input your lisence SN:\n${NC}"
			read MSSQLSN
			echo "      - MSSQL_PID=${MSSQLSN}" >> mssql.yml
			break
			;;
		N)	
			echo -e "${color1}Use Developer Edition${NC}"
			break
			;;
		*)	
			echo -e "${color3}Please Do you have lisence?(Y/N)"
			continue
			;;
	esac
done
			
echo "    ports:" >> mssql.yml
echo -e "${color2}Do you want to change mapping port?(Y/N default: 1433)${NC}"
while :
do
	read PORT
	case $PORT in
		Y)
			echo -e "${color2}Please input Extenal Port:${NC}"
			read PORT1
			echo "      - $PORT1:1433" >> mssql.yml
			break
			;;
		N)	
			echo -e "${color1}Use default port:1433${NC}"
			echo "      - 1433:1433" >> mssql.yml
			break
			;;
		*)
			echo -e "${color4}Please choose change port or not(Y/N)${NC}"			
			continue
			;;
	esac
done

echo "    volumes:" >> mssql.yml
echo -e "${color2}Do you want to change Database location on host?(Y/N default: /var/lib/docker/volumes/mssql):\n${NC}"
while :
do
	read CHLO
	case $CHLO in
		Y)
			echo -e "${color2}Please provide location for MS SQL DATABASE\n${NC}"
			read MSSQLDATABASELOCATE
			echo "      - $MSSQLDATABASELOCATE:/var/opt/mssql" >> mssql.yml
			break
			;;
		N)
			echo -e "${color1}Use default Location:/var/lib/docker/volumes/mssql\n${NC}"
			echo "      - /var/lib/docker/volume/mssql:/var/opt/mssql" >> mssql.yml
			break
			;;
		*)
			echo -e "${color4}Please choose to change location or not(Y/N)${NC}"
			continue
			;;
	esac
done

echo "    restart: always" >> mssql.yml
echo -e "${color4}.........................................................................................completed${NC}"
# Check File
clear
echo ""
echo ""
echo ""
cat /root/mssql.yml
echo -e "${color1}Please check the compose file is correct or not?(Y/N)${NC}"
while :
do
	read COMPOSE
	case $COMPOSE in
		Y)
			break
			;;
		N)
			echo -e "${color2}Re-creating compose file${NC}"
			echo "version: '3'" > mssql.yml
			echo "services:" >> mssql.yml
			echo "  mssql:" >> mssql.yml
			echo "    image:  mcr.microsoft.com/mssql/server:2019-latest" >> mssql.yml
			echo "    container_name: sql-server" >> mssql.yml
			echo "    environment:" >> mssql.yml
			echo "      - PUID=1000" >> mssql.yml
			echo "      - ACCEPT_EULA=Y" >> mssql.yml
			echo -e "${color2}Setup your SA password for SQL-Server:\n${NC}"
			read SAPASSWD
			echo "      - SA_PASSWORD=${SAPASSWD}" >> mssql.yml
			echo -e "${color2}Do you have Lience for SQL-Server?:(Y/N)\n${NC}"
			while :
			do
				        read MSSQLLISENCE
				        case $MSSQLLISENCE in
				               Y)
				                  echo -e "${color2}Please input your lisence SN:\n${NC}"
				                  read MSSQLSN
				                  echo "      - MSSQL_PID=${MSSQLSN}" >> mssql.yml
				                  break
				                  ;;
				               N)
						  echo -e "${color1}Use Developer Edition${NC}"
				                  break
				                  ;;
				               *)
				                  echo -e "${color3}Please Do you have lisence?(Y/N)"
				                  continue
				                  ;;
				        esac
			done

			echo "    ports:" >> mssql.yml
			echo -e "${color2}Do you want to change mapping port?(default: 1433)${NC}"
			while :
			do
				       read PORT
				       case $PORT in
				               Y)
				                  echo -e "${color2}Please input Extenal Port:${NC}"
				                  read PORT1
				                  echo "      - $PORT1:1433" >> mssql.yml
				                  break
				                  ;;
				               N)
						  echo -e "${color1}Use default port:1433${NC}"
				                  echo "      - 1433:1433" >> mssql.yml
				                  break
				                  ;;
				               *)
						  echo -e "${color4}Please choose change port or not(Y/N)${NC}"                        
				                  continue
				                  ;;
				        esac
			done

			echo "    volumes:" >> mssql.yml
			echo -e "${color2}Do you want to change Database location on host?(default: /var/lib/docker/volumes/mssql):\n${NC}"
			while :
			do
				        read CHLO
				        case $CHLO in
				             Y)
				                  echo -e "${color2}Please provide location for MS SQL DATABASE:\n${NC}"
				                  read MSSQLDATABASELOCATE
				                  echo "      - $MSSQLDATABASELOCATE:/var/opt/mssql" >> mssql.yml
				                  break
				                  ;;
				             N)
						  echo -e "${color1}Use default Location:/var/lib/docker/volumes/mssql\n${NC}"
				                  echo "      - /var/lib/docker/volume/mssql:/var/opt/mssql" >> mssql.yml
				                  break
				                  ;;
				             *)
					          echo -e "${color4}Please choose to change location or not(Y/N)${NC}"
				                  continue
				                  ;;
				       esac
			done
			echo "    restart: always" >> mssql.yml
			clear
			cat /root/mssql.yml
			echo -e "${color1}Please check the compose file is correct or not?(Y/N)${NC}"
			continue
			;;
		*)
			echo -e "${color4}Please confim your compose file is correct or not(Y/N)${NC}"
			clear
			cat /root/mssql.yml
			echo -e "${color1}Please check the compose file is correct or not?(Y/N)${NC}"
			continue
			;;
	esac
done

# Docker-compose up -d
echo -e "${color2}Do you want to build up and start MS SQL Server Container?(Y/N)\n${NC}"
while :
do
	read BUILDUP
	case $BUILDUP in
		Y)
			docker-compose -f /root/mssql.yml up -d
			break
			;;
		N)
			break
			;;
		*)
			continue
			;;
	esac
done
