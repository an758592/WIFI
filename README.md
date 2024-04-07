WIFI
Wireless Network Security Testing Script

Author: Ahmed Noaman  
Email: an758592@gmail.com

Description:
WIFI.sh is a Bash script designed for educational and testing purposes related to wireless network security. The script provides a suite of functionalities for scanning wireless networks, capturing packets, and performing password cracking. It allows users to conduct security testing on wireless networks, provided they have the necessary permissions and comply with all applicable laws and regulations.

Features:
- Terms of Use Agreement: Users are required to agree to the terms and conditions before using the script, ensuring responsible and ethical usage.
- Root Access Check: Ensures the script is run with root privileges for proper execution.
- Tool Dependency Check: Verifies the presence of required tools such as `aircrack-ng`, `airodump-ng`, `airmon-ng`, and `reaver`, prompting installation if necessary.
- Monitor Mode Initialization: Starts monitor mode on the specified wireless interface for network scanning and packet capturing.
- Mode Selection: Offers three modes of operation - scanning for a specific access point (AP), scanning for all available APs, or performing a WPS attack on a specific AP.
- Data Capture: Captures relevant data using `airodump-ng` based on the selected mode.
- Password Cracking: Optionally allows users to initiate password cracking using `aircrack-ng` after data capture.
- Cleanup: Stops monitor mode and restarts the network manager service to restore system state post-operation.

Usage:
1. Clone the repository.
2. Ensure you have root privileges or run the script using `sudo`.
3. Run `WIFI.sh` and follow the on-screen prompts to select mode, specify interfaces, paths, etc.
4. Agree to the terms of use and proceed with the desired operation.

Disclaimer:
This script is provided for educational and testing purposes only. Users are responsible for ensuring compliance with all applicable laws and regulations while using the script. The author disclaims any liability for misuse or unauthorized access resulting from the use of this script.
