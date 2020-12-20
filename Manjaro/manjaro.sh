#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#Modify Mirrorlist to setting country
echo -e "${COLOR1}Starting Modify mirrorlist to China/Taiwan servers${NC}"
#echo -n "${COLOR1}Please Select the country you want to set for mirror list\nC)China\nT)Taiwan\n*)whatever..I don't care\n${NC}"
#while :
#do
#	read COUNTRY
#	case $COUNTRY in
#		C)
#			echo -e "${COLOR2}Set China${NC}"
#			sudo pacman-mirrors -c China
#			break
#			;;
#		T)
#			echo -e "${COLOR2}SetTaiwan${NC}"
#			sudo pacman-mirrors -c Taiwan
#			break
#			;;
#		*)
#			echo -e "${COLOR2}Keep original Setting${NC}"
#			sudo pacman-mirrors --fasttrack && sudo pacman -Syy
#			break
#			;;
#	esac
#done
sudo pacman-mirrors --country China,Taiwan && sudo pacman -Syy
#Install
echo -e "${COLOR1}Update Mirrorlist & System${NC}"
sudo pacman -Syyu --noconfirm
echo -e "${COLOR1}Starting Install Apps${NC}"
echo -e "${COLOR2}Install yay & Base tools${NC}"
sudo pacman -Sy --noconfirm yay gcc make patch fakeroot binutils neofetch vim terminator pkgconf
echo -e "${COLOR2}Install ZSH & PowerLevel10k${NC}"
sudo pacman -Sy --noconfirm zsh zsh-syntax-highlighting autojump zsh-autosuggestions zsh-theme-powerlevel10k zsh-theme-powerlevel10k 
sudo curl -o /etc/zsh/zshrc https://kiwi0093.github.io/script/Manjaro/zsh/zshrc
sudo curl -o /etc/zsh/aliasrc https://kiwi0093.github.io/script/Manjaro/zsh/aliasrc
sudo curl -o /etc/zsh/p10k.zsh https://Kiwi0093.github.io/script/Manjaro/zsh/p10k.zsh
echo -e "${COLOR2}Install Network app Set${NC}"
yay -Sy --noconfirm brave-bin v2ray qv2ray putty filezilla remmina freerdp teamviewer rambox-bin
# restore Qv2ray Setting
echo -e "${COLOR2}Restore Qv2ray Setting${NC}"
curl -o https://Kiwi0093.github.io/script/Manjaro/qv2ray.e.tar.gz
openssl enc -d -aes256 -in qv2ray.e.tar.gz -out qv2ray.tar.gz
tar zxvf qv2ray.tar.gz 
mv -fv ./qv2ray/* ~/.config/qv2ray/ 
rm -rf ./qv2ray
# restore Brave Setting
echo -e "${COLOR2}Restore Brave Browser Setting${NC}"
curl -o https://Kiwi0093.github.io/script/Manjaro/Brave.e.tar.gz
openssl enc -d -aes256 -in Brave.e.tar.gz -out Brave.tar.gz
tar zxvf Brave.tar.gz 
mv -fv ./BraveSoftware/* ~/.config/BraveSoftware/
rm -rf ./Brave*
# restore Rambox Setting
echo -e "${COLOR2}Restore Rambox Setting without proxy${NC}"
curl -o https://Kiwi0093.github.io/script/Manjaro/Rambox.e.tar.gz
openssl enc -d -aes256 -in Rambox.e.tar.gz -out Rambox.tar.gz
tar zxvf Rambox.tar.gz 
mv -fv ./Rambox/* ~/.config/Rambox/
rm -rf ./Rambox*
echo -e "${COLOR2}Install Blog & Wiki Set${NC}"
yay -Sy --noconfirm git github-desktop-bin typora nodejs npm
echo -e "${COLOR2}Setup Blog & Wiki Env${NC}"
mkir ~/Github
cd ~/Github
git clone https://github.com/Kiwi0093/Blog.git
git clone https://github.com/Kiwi0093/Wiki-site.git
cd ~/github/Blog/
npm install -g hexo-cli 
npm install hexo-theme-next
cd ~/Github/Wiki-site
git clone https://github.com/zthxxx/hexo-theme-Wikitten.git themes/Wikitten
npm i -S hexo-autonofollow hexo-directory-category hexo-generator-feed hexo-generator-json-content hexo-generator-sitemap
echo -e "${COLOR2}Set up Typora with Pico${NC}"
yay -Sy --noconfirm picogo
curl -o https://Kiwi0093.github.io/script/Manjaro/picogo/config.json.e
openssl enc -d -aes256 -in config.json.e -out config.json
mv ./config.json ~/.picogo/config.json
rm config.json.e
echo -e "${COLOR2}Install Other Tools${NC}"
yay -Sy --noconfirm gnome-pie
echo -e "${COLOR2}Restore Gnome-pie Setting${NC}"
curl -o ~/.config/gnome-pie/gnome-pie.conf https://Kiwi0093.github.io/script/Manjaro/pie/gnome-pie.conf
curl -o ~/.config/gnome-pie/pie.conf https://Kiwi0093.github.io/script/Manjaro/pie/pie.conf
echo -e "${COLOR2}Do you need VMware workstation?\ny)Yes, please install\n*)No, I don't need${NC}"
while :
do
	read VMW
	case $VMW in
	y)
		echo -e "${COLOR2}Install VMware Workstation to your system${NC}"
		yay -Sy --noconfirm vmware-workstation
		break
		;;
	*)
		echo -e "${COLOR2}Skip Vmware workstation installation${NC}"
		break
		;;
	esac
done
echo -e "${COLOR1}Please select your Desktop what you want to Restore :\nk)KDE Plasma\nx)XFCE\ng)Gnome\nm)Mate\n${NC}"
while :
do
	read DESK
	case $DESK in
	k)
		echo -e "${COLOR2}For KDE${NC}"
		wget https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE0OTA1Mzc5MzUiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6IjJjMTcwNjYwYmI4YmE4NDg0ZmJlYWI1MWJkZmFhNmQ4MDJmMTlhOGFhYWI2Mzk5NWY0M2FiMzcwYmJlOGU4N2VhMDIwODU2MWI5MWI2NjYwMTdlMDc3YmFkOWUwNjcxN2IwZjg3YzMxY2NiYzQ4NzI5NDc1MGUyZGM1ZGI1ODE0IiwidCI6MTYwODM4NDQzNSwic3RmcCI6IjY2ZjUwNjJjOTM1ZDVmNzlkODczZmUwMGY5N2Q1MjZlIiwic3RpcCI6IjIxNi4xODkuNTYuNjEifQ.dK08c_JmTAFU7bcDM1Th626J1F4ueB5o2z_F3uTz0fY/plasma-simpleMonitor-v0.6.plasmoid && plasmapkg2 -i *.plasmoid ~/.local/share/plasma/plasmoids/ && rm ./plasma-simpleMonitor-v0.6.plasmoid
                wget https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE2MDgwOTEwNTkiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6IjhkMGRlN2Q4YTEzNzBkYmUxNTMxMWJlZjM1MDg5ODFmMWM2Mzc1NTA2MzkwMDA5Mzg4Y2ZiMTZjZDcxMzA2OTVjYjJiOTUyNmUwNmMyMWIyYjU5ZTNmZjhjOWI4NWNjZDIxNGZjNDAyY2QyNmFiYzJhYjcwZTNmNDVhNjEyM2JlIiwidCI6MTYwODM5OTkwOCwic3RmcCI6IjY2ZjUwNjJjOTM1ZDVmNzlkODczZmUwMGY5N2Q1MjZlIiwic3RpcCI6IjIxNi4xODkuNTYuNjEifQ.AjAGU6ppIA5q1lyufMEGH2MySoRiemMDJa4V7BifbTM/VioletEvergarden-Splash.tar.gz && plasmapkg2 -i VioletEvergarden-Splash.tar.gz ~/.local/share/plasma/look-and-feel/ && rm ./VioletEvergarden-Splash.tar.gz
		curl -o ~/.config/plasma-org.kde.plasma.desktop-appletsrc https://Kiwi0093.github.io/script/Manjaro/plasma-org.kde.plasma.desktop-appletsrc
		break
		;;
	x)
		echo -e "${COLOR2}For Xfce (Not yet)${NC}"
		break
		;;
	g)
		echo -e "${COLOR2}For Gnome (Not yet)${NC}"
		break
		;;
	m)
		echo -e "${COLOR2}For Mate (Not yet)${NC}"
		break
		;;
	*)
		echo -e "${COLOR2}Do Nothing${NC}"
		break
		;;
	esac
done
echo -e "${COLOR2}Set default shell as zsh${NC}"
sudo chsh -s /bin/zsh
chsh -s /bin/zsh
