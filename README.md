# DumpHCX Script

This script, **DumpHCX**, is a Bash script designed for educational and testing purposes. It captures wireless packets, converts them into hash files, and optionally cracks the hashes using `hashcat`.

## Author

- **Ahmed Noaman**
- **Email:** an758592@gmail.com
- **GitHub:** [an758592](https://github.com/an758592/)

## Disclaimer

By using this script, you agree to the following terms:

- **Usage:** The script is for educational and testing purposes only, and users must have the necessary permissions for security testing on wireless networks.
- **Responsibility:** Users are solely responsible for their actions using the script, including compliance with laws and regulations.
- **No Warranty:** The script is provided as is, without any warranties.
- **No Liability:** The author of the script is not liable for damages arising from its use.
- **Ethical Use:** Users agree to use the script ethically and responsibly, obtaining proper authorization before testing networks.
- **Compliance:** Users agree to comply with all applicable laws, regulations, and ethical guidelines.
- **Indemnification:** Users agree to indemnify the author from any claims arising from their use of the script.
- **Modification:** Users may modify the script for personal use but may not distribute modified versions without permission.
- **Termination:** The author reserves the right to terminate or suspend access to the script without notice.
- **Acceptance:** By using the script, users acknowledge and agree to these terms and conditions.

## Prerequisites

Ensure that you have the following tools installed on your system:

- `hcxdumptool`
- `hcxpcapngtool`
- `ifconfig`
- `wget`
- `gzip`
- `hashcat`

## Usage

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/yourusername/dumphcx.git
   cd dumphcx
   ```

2. **Run the Script:**

   ```sh
   sudo ./dumphcx.sh
   ```

3. **Accept the Terms:**

   You will be prompted to accept the terms and conditions. Enter `y` to continue.

4. **Install Required Tools:**

   The script will check for the required tools and prompt to install them if they are not already installed.

5. **Configure Wireless Interface:**

   Enter the wireless interface to use (default is `wlan0`).

6. **Capture Packets:**

   Enter the path and name to save the captured packets (default is the current directory with a timestamp).

7. **Crack Password (Optional):**

   You will be prompted to start password cracking with `hashcat`. You can choose to download a wordlist, use an existing wordlist, or specify another wordlist.

## Example

```sh
sudo ./dumphcx.sh
```

Follow the prompts to configure the interface, capture packets, and optionally crack the hash.

## License

This script is provided under the terms specified in the disclaimer. Use it ethically and responsibly.

## Support

If you encounter any issues or have questions, please contact:

- **Email:** an758592@gmail.com
- **GitHub Issues:** [Issues](https://github.com/an758592/dumphcx/issues)

---

**Disclaimer:** The use of this script must comply with all applicable laws and regulations. Unauthorized use of this script for malicious purposes is strictly prohibited.
```
