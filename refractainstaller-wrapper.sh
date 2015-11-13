#!/bin/bash
LC_ALL=C
error='sleep 10 | zenity --timeout=10 --error'
source /usr/bin/variables
if ! [[ -d /lib/live/mount/rootfs ]]; then
	exit 1
fi
if (( $memoria < 512000 )); then
	"$error" --text="Necesita al menos 512 MB de RAM para disfrutar de una experiencia optima en Xanadu GNU/Linux."
fi
if (( $cpu < 1000.000 )); then
	"$error" --text="Su CPU no es capaz de brindar una experiencia optima al ejecutar Xanadu GNU/Linux."
fi
if [[ -f /usr/bin/yad ]]; then
	gksu 'x-terminal-emulator -e /usr/bin/refractainstaller-yad' &
else
	xterm -hold -fa monaco -fs 14 -geometry 80x20+0+0 -e echo "
  Yad no esta instalado. Puede usar 'installer'
  desde un terminal para instalar el sistema con la version CLI.
  " &
fi
exit 0
