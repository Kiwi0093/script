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
echo -e "${COLOR_W}=  This Script for Kiwi private use.              =\n${NC}"
echo -e "${COLOR_W}=  If you have any issue on usage,                =\n${NC}"
echo -e "${COLOR_W}=  Please DON'T Feedback to Kiwi                  =\n${NC}"
echo -e "${COLOR_W}=  And you should take your own responsibility    =\n${NC}"
echo -e "${COLOR_W}===================================================\n${NC}"

#start ntp
echo -e "${COLOR1}Starting NTP Service${NC}"
timedatectl set-ntp true
echo -e "${COLOR2}NTP Setup Completed${NC}"

#Modify Mirrorlist to setting country
echo -n "${COLOR1}Please Select the country you want to set for mirror list\n${NC}${COLOR_H1}C)China\nT)Taiwan\n*)whatever..I don't care\n${NC}"
while :
do
	read COUNTRY
	case $COUNTRY in
		C)
			echo -e "${COLOR2}Set China${NC}"
			sed -i '/Score/{/China/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist
			break
			;;
		T)
			echo -e "${COLOR2}SetTaiwan${NC}"
			sed -i '/Score/{/Taiwan/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist
			break
			;;
		*)
			echo -e "${COLOR2}Keep original Setting${NC}"
			break
			;;
	esac
done
echo -e "${COLOR2}Completed${NC}"

#Fdisk
echo -e "${COLOR1}Partition your HDD please create sda1 for Data and sda2 for Swap.${NC}"
fdisk /dev/sda
echo -e "${COLOR2}Partition Setup Completed${NC}"

#Format
echo -e "${COLOR1}Format /dev/sda1 as EXT4 format${NC}"
mkfs.ext4 /dev/sda1
echo -e "${COLOR2}EXT4 formatting Completed${NC}"
echo -e "${COLOR1}Format /dev/sda2 as Linux Swap${NC}"
mkswap /dev/sda2
echo -e "${COLOR2}Swap Formatting Completed${NC}"
echo -e "${COLOR1}Mount /dev/sda1 to /mnt${NC}"
mount /dev/sda1 /mnt
echo -e "${COLOR2}Completed${NC}"
echo -e "${COLOR1}Mount Swap${NC}"
swapon /dev/sda2
echo -e "${COLOR2}Completed${NC}"

#Install
echo -e "${COLOR1}Starting Install Archlinux into /mnt${NC}"
echo -e "${COLOR1}Please select your CPU vendor and Linux Kernel you want:\n${NC}${COLOR_H1}1)Intel+Linux\n2)Intel+Linux-LTS\n3)Amd+Linux\n4)Amd+Linux-LTS\n5)Linux-LTS Kernel\n*)Whatever, Normal Linux Kernel is good enough to me\n${NC}"
while :
do
	read CPU
	case $CPU in
	1)
		echo -e "${COLOR2}Linux Kernel＋Intel${NC}"
		pacman -Syyu
		pacstrap /mnt base linux linux-firmware vim zsh curl netctl intel-ucode grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	2)
		echo -e "${COLOR2}Linux-LTS Kernel＋Intel${NC}"
		pacman -Syyu
		pacstrap /mnt base linux-lts linux-firmware vim zsh curl netctl intel-ucode grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	3)
		echo -e "${COLOR2}Linux Kernel＋Amd${NC}"
		pacman -Syyu
		pacstrap /mnt base linux linux-firmware vim zsh curl netctl amd-ucode grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	4)
		echo -e "${COLOR2}Linux-LTS Kernel＋Amd${NC}"
		pacman -Syyu
		pacstrap /mnt base linux-lts linux-firmware vim zsh curl netctl amd-ucode grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	5)
		echo -e "${COLOR2}Linux-LTS Kernel${NC}"
		pacman -Syyu
		pacstrap /mnt base linux-lts linux-firmware vim zsh curl netctl grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	*)
		echo -e "${COLOR2}Linux Kernel${NC}"
		pacman -Syyu
		pacstrap /mnt base linux linux-firmware vim zsh curl netctl grub dnsutils open-vm-tools net-tools openssh
		break
		;;
	esac
done
echo -e "${COLOR2}Completed${NC}"

#fstab
echo "${COLOR1}Starting Gernerate fstab${NC}"
genfstab -U -p /mnt >> /mnt/etc/fstab
echo -e "${COLOR2}Completed${NC}"

#Copy Zsh
echo "${COLOR1}Starting Copy ZSH setting file to new Archlinux${NC}"
cp -Rv /etc/zsh /mnt/etc/
echo -e "${COLOR2}Completed${NC}"

echo -n "${COLOR1}Please select which type you want${NC}${COLOR_H1}\na)Simple Server\nb)Nextcloud Server\nc)V2Ray Server\nd)V2Ray Gateway\n*)I'm the best! let me do by my own!!\n${NC}"
while :
do
	read SCRIPT
	case $SCRIPT in
		a)
			echo -e "${COLOR2}Simple Arch Linux${NC}"
			arch-chroot /mnt /bin/zsh <(curl -L -s https://Kiwi0093.github.io/script/Arch/simple_arch.sh)
			break
			;;
		b)
			echo -e "${COLOR2}Nextcloud Server${NC}"
			arch-chroot /mnt /bin/zsh <(curl -L -s https://Kiwi0093.github.io/script/Arch/nextc_arch.sh)
			break
			;;
		c)
			echo -e "${COLOR2}V2Ray Server${NC}"
			arch-chroot /mnt /bin/zsh <(curl -L -s https://Kiwi0093.github.io/script/Arch/arch_v2ray.sh)
			break
			;;
		d)
			echo -e "${COLOR2}V2Ray Gateway${NC}"
			arch-chroot /mnt /bin/zsh <(curl -L -s https://Kiwi0093.github.io/script/Arch/arch_v2ray_gate.sh)
			break
			;;
		*)
			echo -e "${COLOR2}Yes! you're the chosen one!${NC}"
			arch-root /mnt /bin/zsh
			break
			;;
	esac
done
echo -e "${COLOR2}Finished Installation, will reboot, Good luck${NC}"

# Reboot
echo -e "${COLOR2}Rebooting...${NC}"
reboot
