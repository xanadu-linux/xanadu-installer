#!/bin/bash
# Made by Sinfallas <sinfallas@yahoo.com>
# Licence: GPL-2
LC_ALL=C
advertencia='yad --skip-taskbar --button="ACEPTAR":1 --fixed --center --text-align=fill --borders=6 --title="ADVERTENCIA"'
memoria=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
cpu=$(lscpu | grep "MHz" | awk '{print $3}')
cpu2=${cpu%.*}
if ! [[ -d /lib/live/mount/rootfs ]]; then
	exit 1
fi
if (( $memoria < 512000 )); then
	$advertencia --timeout=10 --text="Necesita al menos 512 MB de RAM para disfrutar de una experiencia optima en Xanadu GNU/Linux."
fi
if (( $cpu2 < 1000 )); then
	$advertencia --timeout=10 --text="Su CPU no es capaz de brindar una experiencia optima para ejecutar Xanadu GNU/Linux."
fi
gksu 'x-terminal-emulator -e /usr/bin/xanaduinstaller-yad' &
exit 0