#!/usr/bin/env bash
# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
  exit
fi

# Make sure $IMG_PATH env is set
if [ -z "$IMG_PATH" ]; then
	echo "IMG_PATH is not set!"
	exit
fi

clear

cat <<"EOF"
  ,----..     ,---,
 /   /   \  ,--.' |                 .--.,
|   :     : |  |  :               ,--.'  \
.   |  ;. / :  :  :               |  | /\/
.   ; /--`  :  |  |,--.  ,--.--.  :  : :
;   | ;  __ |  :  '   | /       \ :  | |-,
|   : |.' .'|  |   /' :.--.  .-. ||  : :/|
.   | '_.' :'  :  | | | \__\/: . .|  |  .'
'   ; : \  ||  |  ' | : ," .--.; |'  : '
'   | '/  .'|  :  :_:,'/  /  ,.  ||  | |
|   :    /  |  | ,'   ;  :   .'   \  : \
 \   \ .'   `--''     |  ,     .-./  |,'
  `---`                `--`---'   `--'
EOF

echo "Welcome to Ghaf installer!"

echo "To install image choose path to the device on which image will be installed."

hwinfo --disk --short

while true; do
	read -r -p "Device name [e.g. /dev/nvme0n1]: " DEVICE_NAME

	if [ ! -d "/sys/block/$(basename "$DEVICE_NAME")" ]; then
		echo "Device not found!"
		continue
	fi

	# Check if removable
	if [ "$(cat "/sys/block/$(basename "$DEVICE_NAME")/removable")" != "0" ]; then
		read -r -p "Device provided is removable, do you want to continue? [y/N] " response
		case "$response" in
			[yY][eE][sS]|[yY])
				break
				;;
			*)
				continue
				;;
		esac
	fi

	break
done

echo "Installing Ghaf on $DEVICE_NAME"
read -r -p 'Do you want to continue? [y/N] ' response

case "$response" in
	[yY][eE][sS]|[yY]);;
	*)
		echo "Exiting..."
		exit
		;;
esac

echo "Installing..."
zstdcat "$IMG_PATH" | dd of="${DEVICE_NAME}" bs=32M status=progress

echo "Installation done. Please remove the installation media and reboot"
