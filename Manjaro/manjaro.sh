#!/bin/sh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

echo -e "${COLOR1}Please input your user name for change shell\n${NC}"
read USER
#Modify Mirrorlist to setting country
echo -e "${COLOR1}Starting Modify mirrorlist to China/Taiwan servers${NC}"
sudo pacman-mirrors --country China,Taiwan,United_States
#Install
echo -e "${COLOR1}Update Mirrorlist & System${NC}"
sudo pacman -Syyu --noconfirm
echo -e "${COLOR1}Starting Install Apps${NC}"
echo -e "${COLOR2}Install yay & Base tools${NC}"
sudo pacman -Sy --noconfirm yay gcc make patch fakeroot binutils neofetch vim terminator pkgconf
echo -e "${COLOR2}Install ZSH & PowerLevel10k${NC}"
yay -Sy --noconfirm zsh zsh-syntax-highlighting zsh-autosuggestions zsh-theme-powerlevel10k ttf-meslo-nerd-font-powerlevel10k
sudo curl -o /etc/zsh/zshrc https://kiwi0093.github.io/script/Manjaro/zsh/zshrc
sudo curl -o /etc/zsh/aliasrc https://kiwi0093.github.io/script/Manjaro/zsh/aliasrc
sudo curl -o /etc/zsh/p10k.zsh https://Kiwi0093.github.io/script/Manjaro/zsh/p10k.zsh
cp /etc/zsh/zshrc ~/.zshrc
echo -e "${COLOR2}Set default shell as zsh${NC}"
sudo chsh -s /bin/zsh
sudo chsh -s /bin/zsh $USER
echo -e "${COLOR2}Install Network app Set${NC}"
yay -Sy --noconfirm brave-bin v2ray qv2ray putty filezilla remmina freerdp teamviewer rambox-bin fcitx fcitx-qt5 fcitx-configtool fcitx-chewing fcitx-mozc
echo -e "${COLOR2}Set up Chinese Input Env${NC}"
curl -o brave.e https://Kiwi0093.github.io/script/Manjaro/brave.e
openssl enc -d -aes256 -in brave.e -out brave
cat ./brave
echo -e"${COLOR2}please set SYNC for your brave${NC}"
brave
# add Chinese input support
curl -o profile https://Kiwi0093.github.io/script/Manjaro/profile
sudo mv ./profile /etc/profile
# restore Qv2ray Setting
echo -e "${COLOR2}Restore Qv2ray Setting${NC}"
curl -o qv2ray.e.tar.gz https://Kiwi0093.github.io/script/Manjaro/qv2ray.e.tar.gz
openssl enc -d -aes256 -in qv2ray.e.tar.gz -out qv2ray.tar.gz
tar zxvf qv2ray.tar.gz 
rm -rf ~/.config/qv2ray
mv ./qv2ray ~/.config/ 
echo -e "${COLOR2}Install Blog & Wiki Set${NC}"
yay -Sy --noconfirm git github-desktop-bin typora nodejs npm
echo -e "${COLOR2}Setup Blog & Wiki Env${NC}"
mkdir ~/GitHub
cd ~/GitHub
git clone https://github.com/Kiwi0093/Blog.git
git clone https://github.com/Kiwi0093/Wiki-site.git
cd ~/GitHub/Blog/
sudo npm install -g hexo-cli 
npm install hexo-theme-next
cd ~/GitHub/Wiki-site
git clone https://github.com/zthxxx/hexo-theme-Wikitten.git themes/Wikitten
npm i -S hexo-autonofollow hexo-directory-category hexo-generator-feed hexo-generator-json-content hexo-generator-sitemap
echo -e "${COLOR2}Set up Typora with Pico${NC}"
#yay -Sy --noconfirm picogo
#sudo npm install -g picgo
typora
echo -e "${COLOR1}Do you installed picgo by Typora?\nY)Yes*)Not yet\n${NC}"
while :
do
	read PICGO
	case $PICGO in
	Y)
		curl -o config.json.e https://Kiwi0093.github.io/script/Manjaro/picgo/config.json.e
		openssl enc -d -aes256 -in config.json.e -out config.json
		mv ./config.json ~/.picgo/
		rm config.json.e
		break
		;;
	*)
		echo -e "${COLOR2}Please install picgo via typora and make sure ~/.picgo/ exsist${NC}"
		;;
	esac
done
echo -e "${COLOR2}Install Other Tools${NC}"
yay -Sy --noconfirm gnome-pie
echo -e "${COLOR2}Restore Gnome-pie Setting${NC}"
curl -o gnome-pie.tar.gz https://Kiwi0093.github.io/script/Manjaro/gnome-pie.tar.gz
tar zxvf gnome-pie.tar.gz
rm -rf ~/.config/gnome-pie
mv ./gnome-pie ~/.config/
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
		curl -o plasma-simpleMonitor-v0.6.plasmoid https://Kiwi0093.github.io/script/Manjaro/plasma-simpleMonitor-v0.6.plasmoid && plasmapkg2 -i *.plasmoid ~/.local/share/plasma/plasmoids/ && rm ./plasma-simpleMonitor-v0.6.plasmoid
                curl -o VioletEvergarden-Splash.tar.gz https://Kiwi0093.github.io/script/Manjaro/VioletEvergarden-Splash.tar.gz && plasmapkg2 -i VioletEvergarden-Splash.tar.gz ~/.local/share/plasma/look-and-feel/ && rm ./VioletEvergarden-Splash.tar.gz
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
