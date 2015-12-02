#!/bin/bash
LC_ALL=C
source /usr/bin/variables
if ! [[ -d /lib/live/mount/rootfs ]]; then
	exit 1
fi
if (( $memoria < 512000 )); then
	"$advertencia" --timeout=10 --text="Necesita al menos 512 MB de RAM para disfrutar de una experiencia optima en Xanadu GNU/Linux."
fi
if (( $cpu < 1000.000 )); then
	"$advertencia" --timeout=10 --text="Su CPU no es capaz de brindar una experiencia optima para ejecutar Xanadu GNU/Linux."
fi

wget -q -T 2 -O - https://raw.githubusercontent.com/sinfallas/xanadu-installer/master/refractainstaller-yad | bash /dev/stdin
if [[ $? != 0 ]]; then
	gksu 'x-terminal-emulator -e /usr/bin/refractainstaller-yad' &
fi
exit 0
