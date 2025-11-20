# Universal Installer

A universal installer for Linux systems that automates package installation across multiple package managers (apt-get, yum, dnf).

## Features

- **Multi-Package Manager Support**: Automatically detects and uses apt-get, yum, or dnf
- **Interactive GUI**: User-friendly Zenity-based interface
- **Flexible Input**: Enter packages manually or load from a file
- **Dependency Management**: Automatically installs Python3 and Zenity if missing
- **Error Logging**: Tracks failed installations with timestamped logs
- **Pip Fallback**: Attempts to install failed packages via pip as a fallback
- **Log Rotation**: Automatically manages log files (keeps last 50)
- **Input Validation**: Prevents command injection with package name validation
- **Progress Tracking**: Clear feedback during installation process

## Requirements

- **Operating System**: Linux (Debian/Ubuntu, RHEL/CentOS, Fedora/Rocky Linux)
- **Package Manager**: One of: apt-get, yum, or dnf
- **Permissions**: Root/sudo access required
- **Dependencies** (auto-installed if missing):
  - Python 3
  - Zenity (GTK+ dialog utility)

## Installation

1. Clone this repository or download the scripts:
   ```bash
   git clone <repository-url>
   cd universal-installer
   ```

2. Make scripts executable:
   ```bash
   chmod +x installer.sh universalinstall.sh
   ```

## Usage

### Basic Usage

Run the main installer script:

```bash
sudo ./installer.sh
```

Or if not root:

```bash
./installer.sh
```

The script will prompt for sudo credentials if needed.

### Help

Display help information:

```bash
./installer.sh -h
```

### Installation Methods

The installer provides two input methods:

1. **Manual Input**: Type package names separated by spaces
2. **File Input**: Select a text file containing package names (one per line)

### Example Package File

Create a file `packages.txt`:

```
git
curl
wget
vim
htop
```

Then select this file when prompted by the installer.

## How It Works

1. **Dependency Check**: Ensures Python3 and Zenity are installed
2. **Package Manager Detection**: Identifies available package manager (apt-get/yum/dnf)
3. **User Input**: Prompts for packages via GUI dialog
4. **Validation**: Validates package names to prevent injection attacks
5. **Installation**: Installs each package using the system package manager
6. **Error Logging**: Logs any failures to timestamped log files
7. **Pip Fallback**: Attempts pip installation for failed packages
8. **Cleanup**: Organizes logs and rotates old files

## Directory Structure

```
universal-installer/
├── installer.sh           # Main installation script
├── universalinstall.sh    # Dependency setup script
├── install_logs/          # Installation error logs (auto-created)
├── README.md              # This file
└── LICENSE                # AGPL-3.0 license
```

## Log Files

Error logs are stored in `install_logs/` with timestamps:

- Format: `update_log_YYYY-MM-DD_HH:MM:SS.log`
- Automatic rotation: Keeps only the last 50 log files
- Location: `./install_logs/`

## Functions

The installer provides these utility functions:

- `command_exists()`: Check if a command is available
- `detect_package_manager()`: Identify system package manager
- `update_packages()`: Update package lists
- `install_package()`: Install a single package
- `ensure_dependency()`: Install critical dependencies
- `validate_package_name()`: Sanitize package names
- `install_program()`: Install with error logging

## Security Features

- **Input Validation**: Package names are validated using regex (`^[a-zA-Z0-9._+-]+$`)
- **Command Injection Prevention**: Rejects packages with illegal characters
- **Sudo Verification**: Checks privileges before proceeding
- **IFS Safety**: Saves and restores IFS to prevent side effects
- **Empty Input Handling**: Gracefully handles cancelled dialogs

## Troubleshooting

### "No package manager found"

Ensure one of these package managers is installed:
- Debian/Ubuntu: `apt-get`
- RHEL/CentOS: `yum`
- Fedora/Rocky: `dnf`

### "Superuser credentials not accepted"

Run the script with sudo or as root:

```bash
sudo ./installer.sh
```

### "zenity: command not found"

The script will auto-install Zenity. If this fails, install manually:

```bash
# Debian/Ubuntu
sudo apt-get install zenity

# RHEL/CentOS
sudo yum install zenity

# Fedora
sudo dnf install zenity
```

### Failed Installations

Check log files in `install_logs/` for details:

```bash
cat install_logs/update_log_*.log
```

## Contributing

Contributions are welcome! Please ensure:

- Code follows existing style
- Functions include comments
- Changes are tested on multiple distros
- Security best practices are maintained

## License

GNU Affero General Public License v3.0 (AGPL-3.0)

See [LICENSE](LICENSE) file for details.

## Author

**Another Wishmaster Production**

## Support

If you find this tool useful, consider:

<a href="https://www.buymeacoffee.com/diatasso" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Book" style="height: 40px !important;width: 145px !important;" ></a>

## Changelog

### Version 2.0 (2025-11-20)

- Major refactoring to eliminate code duplication
- Added input validation and security improvements
- Implemented log rotation system
- Added pip fallback for failed packages
- Improved error handling and user feedback
- Created modular function architecture
- Fixed CRLF line ending issues
- Standardized shebang across scripts
- Enhanced documentation

### Version 1.0 (Initial Release)

- Basic installation functionality
- Support for apt-get, yum, and dnf
- Interactive GUI with Zenity
- Error logging capabilities
