#!/bin/bash
LC_ALL=C
miswap1=$(fdisk -l | grep "swap" | awk '{print $1}')
source /usr/bin/variables

function finalizando_1 () {
rmdir /live-build/
rm -f /target/etc/apt/preferences.d/exclude.pref
rm -f /target/etc/apt/preferences		
rm -f /target/etc/inittab
rm -rf /target/tmp/*
rm -rf /target/var/tmp/*
rm -rf /target/var/cache/polipo/*
rm -rf /target/root/.local/share/Trash/*
rm -rf /target/home/*/.local/share/Trash/*
rm -rf /target/home/*/.mozilla/firefox/*/*Cache*
find /target/var/log/ -type f -exec rm -f {} \;
if ! [[ -z "$miswap1" ]]; then
	rm -f /target/swapfile
	sed -i 's_/swapfile_#/swapfile_g' /target/etc/fstab
fi
sed -i 's_autologin-user=user_#autologin-user=user_g' /target/etc/lightdm/lightdm.conf
sed -i 's_autologin-user-timeout=0_#autologin-user-timeout=0_g' /target/etc/lightdm/lightdm.conf
sed -i 's_#greeter-hide-users=false_greeter-hide-users=false_g' /target/etc/lightdm/lightdm.conf
sed -i 's_#session-cleanup-script=_session-cleanup-script=/usr/bin/fin_g' /target/etc/lightdm/lightdm.conf
sed -i 's_show-indicators=~language;~session;~power_show-indicators=~session;~power_g' /target/etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's_#show-clock=_show-clock=true_g' /target/etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's_#clock-format=_clock-format=%a, %d %b %I:%M_g' /target/etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's_umask 022_umask 027_g' /target/etc/init.d/rc
sed -i 's_UMASK		022_UMASK	027_g' /target/etc/login.defs
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="acpi_osi=Linux swapaccount=1 cgroup_enable=memory security=apparmor apparmor=1 panic=10 quiet"/g' /target/etc/default/grub
sed -i 's_/bin/bash_/usr/bin/fish_g' /target/etc/passwd
echo "default-user-image=/usr/share/images/desktop-base/logo1.png" >> /target/etc/lightdm/lightdm-gtk-greeter.conf
echo "user ALL=(ALL) ALL" > /target/etc/sudoers.d/live
echo "umask 027" >> /target/etc/profile
echo "auth required pam_succeed_if.so user != root quiet" >> /target/etc/pam.d/lightdm
echo "proc /proc proc defaults,hidepid=2 0 0" >> /target/etc/fstab
echo "tmpfs /run tmpfs rw,nosuid,async,noexec,nodev,noatime,mode=755 0 0" >> /target/etc/fstab
echo "tmpfs /tmp tmpfs noatime,async,nosuid,noexec,nodev,rw 0 0" >> /target/etc/fstab
echo 'DPkg::Post-Invoke {"echo Ejecutando prelink, espere...;/etc/cron.daily/prelink";}' > /target/etc/apt/apt.conf
if [[ $(cat /target/etc/hostname) = xanadu ]]; then
	echo xanadu-$(date | md5sum | cut -c 1-10) > /target/etc/hostname
	sed -i 's_xanadu_'$(cat /target/etc/hostname)'_g' /target/etc/hosts
fi
if [[ -n "$(lspci | grep -E 'VGA|Display' | head -n1 | cut -d ':' -f3 | grep -F 'Intel')" ]]; then
	echo 'Section "Device"' > /target/etc/X11/xorg.conf
	echo ' Identifier "intel"' >> /target/etc/X11/xorg.conf
	echo ' Driver "intel"' >> /target/etc/X11/xorg.conf
	echo ' BusID  "PCI:0:2:0"' >> /target/etc/X11/xorg.conf
	echo ' Option "AccelMethod" "SNA"' >> /target/etc/X11/xorg.conf
	echo ' Option "SwapbuffersWait" "false"' >> /target/etc/X11/xorg.conf
	echo ' Option "Tiling" "true"' >> /target/etc/X11/xorg.conf
	echo ' Option "BackingStore" "True"' >> /target/etc/X11/xorg.conf
	echo ' Option "XvMC" "on"' >> /target/etc/X11/xorg.conf
	echo ' Option "TripleBuffer" "true"' >> /target/etc/X11/xorg.conf
	echo ' Option "DRI" "true"' >> /target/etc/X11/xorg.conf
	echo 'EndSection' >> /target/etc/X11/xorg.conf
fi
if (( $memoria > 4096000 )); then
	echo "tmpfs /var/cache/apt/archives tmpfs noatime,async,nodev 0 0" >> /etc/fstab
fi
chmod 600 /target/etc/sudoers
chmod 644 /target/usr/bin/lxpolkit
chmod -R g=-r-x,o=-r-x /home/user/
chroot /target groupadd -r fuse
chroot /target update-grub2
chroot /target systemctl enable systemd-readahead-collect 
chroot /target systemctl enable systemd-readahead-replay
chroot /target systemctl enable swapspace
chroot /target systemctl disable clamav-freshclam
chroot /target systemctl disable fail2ban
chroot /target systemctl disable i2p
chroot /target systemctl disable memlockd
chroot /target systemctl disable ntp
chroot /target systemctl disable polipo
chroot /target systemctl disable privoxy
chroot /target systemctl disable psad
chroot /target systemctl disable ssh
chroot /target systemctl disable tor
chroot /target iucode_tool --scan-system
chroot /target update-initramfs -u
chroot /target chage -M 365 root
chroot /target yes "" | sensors-detect
chroot /target apt -y remove xanadu-installer sysvinit xanadu-grubdoctor
}

finalizando | "$progreso" --progress-text="Optimizando el sistema, por favor espere..." --title="Finalizando"

if (( $memoria > 4096000 )); then
	if yad --skip-taskbar --fixed --center --text-align=fill --borders=6 --title="Finalizando" --text="¿Desea activar fail2ban y psad?"; then
		chroot /target systemctl enable ntp
		chroot /target systemctl enable fail2ban
		chroot /target systemctl enable psad
	else
		echo 1 > /dev/null
	fi
fi
