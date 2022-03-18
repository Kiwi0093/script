#!/bin/bash

#font color define
color1='\e[95m'			# Light Magenta for process step
color2='\e[96m'			# Light Cyan for input
color3='\e[91m'			# Light Red for warning
color4='\e[34m'			# Blue for process completed
NC='\e[0m'			# End code

# Warning
echo -e "${color4}####################################################################################${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#          ${color3} ░██╗░░░░░░░██╗░█████╗░██████╗░███╗░░██╗██╗███╗░░██╗░██████╗░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░██║░░██╗░░██║██╔══██╗██╔══██╗████╗░██║██║████╗░██║██╔════╝░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░╚██╗████╗██╔╝███████║██████╔╝██╔██╗██║██║██╔██╗██║██║░░██╗░           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░████╔═████║░██╔══██║██╔══██╗██║╚████║██║██║╚████║██║░░╚██╗           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░╚██╔╝░╚██╔╝░██║░░██║██║░░██║██║░╚███║██║██║░╚███║╚██████╔╝           ${NC}${color4}#${NC}"
echo -e "${color4}#          ${color3} ░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚═════╝░           ${NC}${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#                    ${color1}This Script only for Manjarowsl on WSL2                       ${NC}${color4}#${NC}"
echo -e "${color4}#                    ${color1}There is no guarantee for any other environment               ${NC}${color4}#${NC}"
echo -e "${color4}#                    ${color1}Please use for your own risk                                  ${NC}${color4}#${NC}"
echo -e "${color4}#                                                                                  #${NC}"
echo -e "${color4}#                    ${color3}Please Confirm that you're running this as root               ${NC}${color4}#${NC}"
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
echo -e "${color1}Setting your Repo${NC}"
echo -e "${color2}Do you want to set location for the mirror-list?(Y for Location, others for fastest 3 location)${NC}"
while :
do
	read LT
	case $LT in
		Y)
			echo -e "${color2}Please input location you want(EX, tw for Taiwan, us for USA)\n${NC}"
			read LT2
			pacman-mirrors -c $LT2
			break
			;;
		*)
			pacman-mirrors --fasttrack 3
			break
			;;
	esac
done
echo -e "${color1}Update system${NC}"
pacman -Syyu
echo -e "${color1}Install Basic tools${NC}"
pacman -S git yay wget curl rsync sshpass zsh manjaro-zsh-config \
ttf-nerd-fonts-symbols ttf-meslo-nerd-font-powerlevel10k \
nerd-fonts-noto-sans-mono vim wireguard-tools --noconfirm 
echo -e "${color1}Install Xfce4 for GUI${NC}"
pacman -S xfce4-gtk3 xfce4-goodies xfce4-terminal network-manager-applet \
xfce4-notifyd-gtk3 xfce4-whiskermenu-plugin-gtk3 tumbler engrampa lightdm \
lightdm-gtk-greeter lightdm-gtk-greeter-settings manjaro-xfce-gtk3-settings \
manjaro-settings-manager --noconfirm
echo -e "${color1}Install GUI$ tools${NC}"
pacman -S terminator brave-browser tigervnc marktext gnome-pie --noconfirm
echo -e "${color1}Install Chinese Environment${NC}"
pacman -S adobe-source-han-serif-tw-fonts adobe-source-han-serif-hk-fonts \
adobe-source-han-serif-cn-fonts adobe-source-han-sans-tw-fonts \
adobe-source-han-sans-hk-fonts adobe-source-han-sans-cn-fonts \
adobe-source-han-serif-jp-fonts adobe-source-han-sans-jp-fonts \
fcitx fcitx-chewing fcitx-configtool fcitx-mozc fcitx-configtool --noconfirm
echo "# Add Chinese Input Support
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx" >> /etc/profile
echo "background = /usr/share/backgrounds/illyria-default-lockscreen.jpg
font-name = Cantarell Bold 12
xft-antialias = true
icon-theme-name = Papirus
screensaver-timeout = 60
theme-name = Matcha-azul
cursor-theme-name = xcursor-breeze
show-clock = false
default-user-image = #avatar-default
xft-hintstyle = hintfull
position = 50%,center 50%,center
clock-format =
panel-position = bottom
indicators = ~host;~spacer;~clock;~spacer;~language;~session;~a11y;~power" >> /etc/lightdm/lightdm-gtk-greeter.conf
echo -e "${color4}.........................................................................................completed${NC}"

# create user
echo -e "${color1}Change your root password & shell to zsh${NC}"
passwd
chsh -s /bin/zsh
echo -e "${color1}Create your User${NC}"
echo -e "${color2}What User name do you like?\n${NC}"
read USERN
useradd -m -g users -G lp,network,power,sys,wheel -s /bin/zsh $USERN
echo "%wheel ALL=(ALL) ALL" >/etc/sudoers.d/wheel
passwd $USERN
vi /etc/wsl.conf

# sysytemd
sudo -u $USERN yay genie-systemd-git 
echo 'genie -i' > /etc/init.wsl
chmod +x /etc/init.wsl
