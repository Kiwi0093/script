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
echo -e "${COLOR_W}=====================Warning=====================\n${NC}"
echo -e "${COLOR_W}=  This Script for Kiwi private use.            =\n${NC}"
echo -e "${COLOR_W}=  If you have any issue on usage,              =\n${NC}"
echo -e "${COLOR_W}=  Please DON'T Feedback to Kiwi                =\n${NC}"
echo -e "${COLOR_W}=  And you should take your own responsibility  =\n${NC}"
echo -e "${COLOR_W}=================================================\n${NC}"

# Choose Country for pacman-mirrors
echo -e "${COLOR1}Please choose the loaction you want to set for Mirror\n ${COLOR_H}C) China\n T) Taiwan\n L) Let me type what I want\n F) Fastest Mirror from all country\n Any other) Use Manjaro Default\n >${NC}"
while :
do
	read COUNTRY
	case $COUNTRY in
		C)
			echo -e "${COLOR2}Using China Mirrors${NC}"
			sudo pacman-mirrors -c China
			break
			;;
		T)
			echo -e "${COLOR2}Using Taiwan Mirrors${NC}"
			sudo pacman-mirrors -c Taiwan
			break
			;;
		L)
			echo -e "${COLOR2}Please input coutry you want (ie:United_States)\n${NC}"
			read COUNTRY_INPUT
			sudo pacman-mirrors -c $COUNTRY_INPUT
			break
			;;
		F)
			echo -e "${COLOR2}Use All Country for Fastest Mirror${NC}"
			sudo pacman-mirrors --fasttrack 3
			break
			;;
		*)
			echo -e "${COLOR2}Use Default setting${NC}"
			break
			;;
	esac
done

# Apply Mirrorlist and update system
echo -e "${COLOR1}Update your system${NC}"
sudo pacman -Syyu

# Install Basic tools
echo -e "${COLOR1}Install Packages${NC}"
sudo pacman -S --noconfirm yay gcc make patch fakeroot binutils neofetch vim terminator pkgconf fcitx fcitx-qt5 fcitx-configtool fcitx-chewing fcitx-mozc zsh zsh-syntax-highlighting zsh-autosuggestions zsh-theme-powerlevel10k awesome-terminal-fonts v2ray putty filezilla remmina freerdp git
echo -e "${COLOR1}Do you need pre-download ttf files for ${COLOR_H2}ttf-meslo-nerd-font-powerlevel10k${NC}\n ${COLOR_H1}Y) Yes\n N) No need.\n >${NC}"
while :
do
	read TTF
	case $TTF in
		Y)
			echo -e "${COLOR2}Download TTF files for install Issue${NC}"
			mkdir ~/.cache/yay/ttf-meslo-nerd-font-powerlevel10k
			curl -o ~/.cache/yay/ttf-meslo-nerd-font-powerlevel10k/MesloLGS-NF-Bold-1.000.ttf https://Kiwi0093.github.io/script/Manjaro/MesloLGS-NF-Bold-1.000.ttf
			curl -o ~/.cache/yay/ttf-meslo-nerd-font-powerlevel10k/MesloLGS-NF-Bold-Italic-1.000.ttf https://Kiwi0093.github.io/script/Manjaro/MesloLGS-NF-Bold-Italic-1.000.ttf
			curl -o ~/.cache/yay/ttf-meslo-nerd-font-powerlevel10k/MesloLGS-NF-Italic-1.000.ttf https://Kiwi0093.github.io/script/Manjaro/MesloLGS-NF-Italic-1.000.ttf
			curl -o ~/.cache/yay/ttf-meslo-nerd-font-powerlevel10k/MesloLGS-NF-Regular-1.000.ttf https://Kiwi0093.github.io/script/Manjaro/MesloLGS-NF-Regular-1.000.ttf
			yay -S --noconfirm ttf-meslo-nerd-font-powerlevel10k
			# Download Zeon.ttf & Install
			echo -e "${COLOR2}Download & Install Zeon font for Zeon Icon${NC}"
			sudo mkdir /usr/local/share/fonts/z
			sudo curl -o /usr/local/share/fonts/z/zeon.ttf https://Kiwi0093.github.io/script/Manjaro/zeon.ttf
			break
			;;
		N)
			echo -e "${COLOR2}Normal Installation${NC}"
			yay -S --noconfirm ttf-meslo-nerd-font-powerlevel10k
			# Download Zeon.ttf & Install
			echo -e "${COLOR2}Download & Install Zeon font for Zeon Icon${NC}"
			sudo mkdir /usr/local/share/fonts/z
			sudo curl -o /usr/local/share/fonts/z/zeon.ttf https://Kiwi0093.github.io/script/Manjaro/zeon.ttf
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install yay package 
echo -e "${COLOR1}Prepare to install package via yay${NC}"

# Install Brave
echo -e "${COLOR1}Do you want to install ${COLOR_H2}Brave-bin${NC} for your browser?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this \n >${NC}"
while :
do
	read BRAVE
	case $BRAVE in
		Y)
			echo -e "${COLOR2}Install Brave-bin via yay${NC}"
			yay -S --noconfirm brave-bin
			break
			;;
		N)	
			echo -e "${COLOR2}Skip Brave installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install Qv2ray
echo -e "${COLOR1}Do you want to install ${COLOR_H2}Qv2ray${NC}?\nIt should spend much time\n ${COLOR_H1}Y) Yes install via yay\n A) Using AppImage version\n N)No Need\n >${NC}"
while :
do
	read QV2RAY
	case $QV2RAY in
		Y)
			echo -e "${COLOR2}Install QV2Ray via yay${NC}"
			yay -S --noconfirm qv2ray
			break
			;;
		A)
			echo -e "${COLOR_H1}Please enter Qv2ray Version(ie:2.6.3)${NC}"
			read Q_VERSION
			echo -e "${COLOR2}Download QV2Ray AppImage from Github${NC}"
			mkdir ~/Applications
			wget https://github.com/Qv2ray/Qv2ray/releases/download/v${Q_VERSION}/Qv2ray.v${Q_VERSION}.linux-x64.AppImage
			mv ./Qv2ray.v* ~/Applications/Qv2ray.v${Q_VERSION}.linux-x64.AppImage
			break
			;;
		N)
			echo -e "${COLOR2}Skip Qv2ray Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install Teamviewer
echo -e "${COLOR1}Do you want to install ${COLOR_H2}Teamviewer${NC}?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this\n >${NC}"
while :
do
	read TEAM
	case $TEAM in
		Y)
			echo -e "${COLOR2}Install Teamviewer via yay${NC}"
			yay -S --noconfirm teamviewer
			break
			;;
		N)
			echo -e "${COLOR2}Skip teamviewer Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install Typora
echo -e "${COLOR1}Do you want to install ${COLOR_H2}Typora${NC}?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this\n >${NC}"
while :
do
	read TYPORA
	case $TYPORA in
		Y)
			echo -e "${COLOR2}Install Typora via yay${NC}"
			yay -S --noconfirm typora
			echo -e "${COLOR1}Do you need to Install/Set up ${COLOR_H2}Pigco${NC} for picture upload\n ${COLOR_H1}Y) Yes\n N) Please Skip\n >${NC}"
			while :
			do
				read PICGO
				case $PICGO in
					Y)
						echo -e "${COLOR2}Please install by Typora${NC}"
						typora
						break
						;;
					N)
						echo -e "${COLOR2}Skip Picgo${NC}"
						break
						;;
					*)
						echo -e "${COLOR2}Please enter your choice Y or A or N${NC}"
						;;
				esac
			done
			break
			;;
		N)
			echo -e "${COLOR2}Skip Typora Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install VMware Workstation
echo -e "${COLOR1}Do you want to install ${COLOR_H2}VMware Workstation${NC}?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this\n >${NC}"
while :
do
	read VMW
	case $TEAM in
		Y)
			echo -e "${COLOR2}Install VMware Workstation via yay${NC}"
			yay -S --noconfirm vmware-workstation
			sudo systemctl enable vmware-networks 
			sudo systemctl start vmware-networks 
			sudo systemctl enable vmware-usbarbitrator.service
			sudo systemctl start vmware-usbarbitrator.service
			break
			;;
		N)
			echo -e "${COLOR2}Skip VMware Workstation Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install Github-Desktop
echo -e "${COLOR1}Do you want to install ${COLOR_H2}Github-desktop-bin${NC}?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this\n >${NC}"
while :
do
	read GITH
	case $GITH in
		Y)
			echo -e "${COLOR2}Install Github-Desktop via yay${NC}"
			yay -S --noconfirm github-desktop-bin
			break
			;;
		N)
			echo -e "${COLOR2}Skip Github-Desktop Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Install Hexo Set
echo -e "${COLOR1}Do you want to install Do you need to Install ${COLOR_H2}Hexo${NC} for Blog or Wiki?\nIt should spend much time\n ${COLOR_H1}Y) Yes\n N) No please skip this\n >${NC}"
while :
do
	read HEXO
	case $HEXO in
		Y)
			echo -e "${COLOR2}Install basic packages for Hexo${NC}"
			yay -S --noconfirm nodejs npm
			echo -e "${COLOR1}Do you have set your own Hexo?\n ${COLOR_H1}Y) Yes\n K)I'm Kiwi please apply my setting\n >${NC}"
			while :
			do
				read H_SET
				case $H_SET in
					Y)
						echo -e "${COLOR_H1}Please input your Hexo Blog folder with full path(ie:~/hexo)\n >${NC}"
						read PATH
						mkdir $PATH
						cd $PATH
						sudo npm install -g hexo-cli
						break
						;;
					K)
						echo -e "${COLOR2}Please start restore Kiwi's Blog setting${NC}"
						mkdir ~/GitHub
						cd ~/GitHub
						git clone https://github.com/Kiwi0093/Blog.git
						git clone https://github.com/Kiwi0093/Wiki-site.git
						cd ~/GitHub/Blog/
						sudo npm install -g hexo-cli
						npm install hexo-theme-next
						cd ~/GitHub/Wiki-site
						sudo npm install -g hexo-cli
						git clone https://github.com/zthxxx/hexo-theme-Wikitten.git themes/Wikitten
						npm i -S hexo-autonofollow hexo-directory-category hexo-generator-feed hexo-generator-json-content hexo-generator-sitemap
						break
						;;
					*)
						echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
						;;
				esac
			done
			break
			;;
		N)
			echo -e "${COLOR2}Skip Hexo Installation${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Personal setting
# change shell to zsh & import powerlevel10k setting
echo -e "${COLOR2}Change default shell to zsh${NC}"
sudo chsh -s /bin/zsh
chsh -s /bin/zsh

# download setting and apply
echo -e "${COLOR2}Download and apply powerlevel10k setting${NC}"
sudo curl -o /etc/zsh/zshrc https://kiwi0093.github.io/script/Manjaro/zsh/zshrc
sudo curl -o /etc/zsh/aliasrc https://kiwi0093.github.io/script/Manjaro/zsh/aliasrc
sudo curl -o /etc/zsh/p10k.zsh https://Kiwi0093.github.io/script/Manjaro/zsh/p10k.zsh
sudo cp /etc/zsh/zshrc /root/.zshrc
cp /etc/zsh/zshrc ~/.zshrc


# Chinese Input ENV Setting
echo -e "${COLOR2}Setting Fcitx Chinese Input ENV ${NC}"
curl -o profile https://Kiwi0093.github.io/script/Manjaro/profile
sudo mv ./profile /etc/profile

# Restore Qv2ray Setting
echo -e "${COLOR1}Are you Kiwi?\nIf you are, do you need to restore your private ${COLOR_H2}Qv2ray${NC} setting\n ${COLOR_H1}Y) Yes\n N) No I don't need\n >${NC}"
while :
do
	read Q_SET
	case $Q_SET in
		Y)
			echo -e "${COLOR1}Check QV2ray installed${NC}"
			if [ -f "~/Applications/Qv2ray*AppImage" ]; then
				echo -e "${COLOR2}AppImage Version Installed${NC}"
				curl -o qv2ray.e.tar.gz https://Kiwi0093.github.io/script/Manjaro/qv2ray.e.tar.gz
				openssl enc -d -aes256 -in qv2ray.e.tar.gz -out qv2ray.tar.gz
				tar zxvf qv2ray.tar.gz
				rm -rf ~/.config/qv2ray
				mv ./qv2ray ~/.config/
				rm -rf ./qv2ray.*
			else
				echo -e "${COLOR2}No Qv2ray AppImage found${NC}"
			fi
			if [ -f "/usr/bin/qv2ray" ]; then
				echo -e "${COLOR2}Qv2ray Installed${NC}"
				curl -o qv2ray.e.tar.gz https://Kiwi0093.github.io/script/Manjaro/qv2ray.e.tar.gz
				openssl enc -d -aes256 -in qv2ray.e.tar.gz -out qv2ray.tar.gz
				tar zxvf qv2ray.tar.gz
				rm -rf ~/.config/qv2ray
				mv ./qv2ray ~/.config/
				rm -rf ./qv2ray.*
			else
				echo -e "${COLOR2}No Qv2ray found${NC}"
				fi
			break
			;;
		N)
			echo -e "${COLOR2}Skip QV2Ray Setting${NC}"
			break
			;;
		*)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
			;;
	esac
done

# Open Brave to set SYNC
echo -e "${COLOR1}Are you Kiwi?\nIf you are, do you need to SYNC your private ${COLOR_H2}Brave${NC} setting\n ${COLOR_H1}Y) Yes\n N) No I don't need\n >${NC}"
while :
do
        read B_SET
        case $B_SET in
                Y)
                        echo -e "${COLOR1}Check Brave installed${NC}"
                        if [ -f "/usr/bin/brave" ]; then
                        	echo -e "${COLOR2}Brave Installed${NC}"
				curl -o brave.e https://Kiwi0093.github.io/script/Manjaro/brave.e
				openssl enc -d -aes256 -in brave.e -out brave
				clear
				echo ""
				echo ""
				echo ""
				cat ./brave
				echo ""
				echo ""
				echo ""
				echo -e "${COLOR2}please set SYNC for your brave${NC}"
				brave
				rm ./brave*
                        else
                        	echo -e "${COLOR2}No Brave found${NC}"
                        	echo -e "${COLOR2}Skip Brave Setting${NC}"
                        fi
			break
			;;
                N)
                        echo -e "${COLOR2}Skip Brave Setting${NC}"
                        break
                        ;;
                *)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
                        ;;
        esac
done

# Open restart picgo setting
echo -e "${COLOR1}Are you Kiwi?\nIf you are, do you need to SYNC your private ${COLOR_H2}Picgo${NC} setting\n ${COLOR_H1}Y) Yes\n N) No I don't need\n >${NC}"
while :
do
        read P_SET
        case $P_SET in
                Y)
                        echo -e "${COLOR1}Check Picgo installed${NC}"
                        if [ -f "~/.config/Typora/picgo/linux/picgo" ]; then
                        	echo -e "${COLOR2}Picgo Installed${NC}"
				curl -o config.json.e https://Kiwi0093.github.io/script/Manjaro/picgo/config.json.e
                		openssl enc -d -aes256 -in config.json.e -out config.json
                		mv ./config.json ~/.picgo/
                		rm config.json.e
                        else
                        	echo -e "${COLOR2}No Picgo found${NC}"
                        	echo -e "${COLOR2}Skip picgo Setting${NC}"
                        fi
			break
			;;
                N)
                        echo -e "${COLOR2}Skip Picgo Setting${NC}"
                        break
                        ;;
                *)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
                        ;;
        esac
done

# Restore Gnome-pie Setting
echo -e "${COLOR1}Are you Kiwi?\nIf you are, do you need to restore your ${COLOR_H2}gnome-pie${NC} setting\n ${COLOR_H1}Y) Yes\n N) No I don't need\n >${NC}"
while :
do
        read P_SET
        case $P_SET in
                Y)
                        echo -e "${COLOR1}Check Gnome-Pie installed${NC}"
                        if [ -f "/usr/bin/gnome-pie" ]; then
                        	echo -e "${COLOR2}Gnome-pie Installed${NC}"
				curl -o gnome-pie.tar.gz https://Kiwi0093.github.io/script/Manjaro/gnome-pie.tar.gz
				tar zxvf gnome-pie.tar.gz
				rm -rf ~/.config/gnome-pie
				mv ./gnome-pie ~/.config
                        else
                        	echo -e "${COLOR2}No Gnome-pie found${NC}"
                        	echo -e "${COLOR2}Skip Gnome-pie Setting${NC}"
                        fi
			break
			;;
                N)
                        echo -e "${COLOR2}Skip Gnome-pie Setting${NC}"
                        break
                        ;;
                *)
			echo -e "${COLOR_H1}Please enter your choice Y or A or N${NC}"
                        ;;
        esac
done

# Install Kde Plasmaoid
echo -e "${COLOR1}Install KDE plasma Widget & Splash\n${NC}"
if [ -d "/usr/include/plasma" ];then
	echo -e "${COLOR2}KDE Plasma Found${NC}"
	curl -o plasma-simpleMonitor-v0.6.plasmoid https://Kiwi0093.github.io/script/Manjaro/plasma-simpleMonitor-v0.6.plasmoid
	plasmapkg2 -i plasma-simpleMonitor-v0.6.plasmoid ~/.local/share/plasma/plasmoids/
	rm -f plasma-simpleMonitor-v0.6.plasmoid
	curl -o  VioletEvergarden-Splash.tar.gz https://Kiwi0093.github.io/script/Manjaro/VioletEvergarden-Splash.tar.gz
	plasmapkg2 -i VioletEvergarden-Splash.tar.gz ~/.local/share/plasma/look-and-feel/
	rm -f VioletEvergarden-Splash.tar.gz
	curl -o  plasma-org.kde.plasma.desktop-appletsrc https://Kiwi0093.github.io/script/Manjaro/plasma-org.kde.plasma.desktop-appletsrc
	mv ./plasma-org.kde.plasma.desktop-appletsrc ~/.config/
else
	echo -e "${COLOR2}KDE Plasma NOT found${NC}"
fi





			
