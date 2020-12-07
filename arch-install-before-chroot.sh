#------------------------------------------------------------------------------
#(從Iso boot後直到完成change root內所有安裝/調整動作)
#------------------------------------------------------------------------------
#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#start ntp
echo -e "${COLOR1}Starting NTP Service${NC}"
timedatectl set-ntp true
echo -e "${COLOR2}NTP Setup completed${NC}"

#Modify Mirrorlist to setting country
echo -e "${COLOR1}Starting Modify mirrorlist to China servers${NC}"
echo -n "${COLOR1}Please Enter which Country you like(ie. United_State or China)${NC}"
read COUNTRY
sed -i '/Score/{/$COUNTRY/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist
echo -e "${COLOR2}Finished.${NC}"

#Fdisk
echo -e "${COLOR1}Partition your HDD please create 1 data as sda1 and 1 swap as sda2${NC}"
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
echo "${COLOR1}Starting Install Archlinux into /mnt${NC}"
pacstrap /mnt base vim zsh curl
echo -e "${COLOR2}Completed${NC}"

#fstab
echo "${COLOR1}Starting Gernerate fstab${NC}"
genfstab -U -p /mnt >> /mnt/etc/fstab
echo -e "${COLOR2}Completed${NC}"

#Copy Zsh
echo "${COLOR1}Starting Copy ZSH setting file to new Archlinux${NC}"
cp -Rv /etc/zsh /mnt/etc/
echo -e "${COLOR2}Completed${NC}"

# Change root
echo -e "${COLOR1}Change root to new Archlinux${NC}"
arch-chroot /mnt /bin/zsh
#------------------------------------------------------------------------------
#(以下是什麼都弄完了只剩下重開機)
#------------------------------------------------------------------------------
echo -e "${COLOR2}Finished Installation, will reboot, Good luck${NC}"

# Reboot
echo -e "${COLOR2}Rebooting...${NC}"
reboot
