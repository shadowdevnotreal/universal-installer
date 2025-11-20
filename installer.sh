#!/usr/bin/env bash

# ============================================================================
# Function Declarations
# ============================================================================

# Check if a command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Detect available package manager
detect_package_manager() {
  if command_exists apt-get; then
    echo "apt-get"
  elif command_exists yum; then
    echo "yum"
  elif command_exists dnf; then
    echo "dnf"
  else
    echo ""
  fi
}

# Update package lists for a given package manager
update_packages() {
  local pm="$1"
  echo "Updating package lists"
  case "$pm" in
    apt-get)
      sudo apt-get update || return 1
      ;;
    yum)
      sudo yum update || return 1
      ;;
    dnf)
      sudo dnf update || return 1
      ;;
    *)
      return 1
      ;;
  esac
}

# Install a single package using the specified package manager
install_package() {
  local pm="$1"
  local package="$2"

  echo "Installing $package"
  case "$pm" in
    apt-get)
      sudo apt-get install -y "$package"
      ;;
    yum)
      sudo yum install -y "$package"
      ;;
    dnf)
      sudo dnf install -y "$package"
      ;;
    *)
      return 1
      ;;
  esac
}

# Ensure a dependency is installed, install if missing
ensure_dependency() {
  local dep_name="$1"

  if command_exists "$dep_name"; then
    echo "$dep_name already installed"
    return 0
  fi

  echo "$dep_name is not installed, installing now"
  local pm
  pm=$(detect_package_manager)

  if [ -z "$pm" ]; then
    echo "Error: Could not find a package manager. Please install $dep_name manually."
    exit 1
  fi

  update_packages "$pm" || { echo "Error: Failed to update package lists" ; exit 1; }
  install_package "$pm" "$dep_name" || { echo "Error: Failed to install $dep_name" ; exit 1; }
}

# Validate package name (alphanumeric, hyphens, underscores, dots only)
validate_package_name() {
  local package="$1"

  # Check if empty
  if [ -z "$package" ]; then
    return 1
  fi

  # Check for valid characters (alphanumeric, hyphen, underscore, dot, plus)
  if [[ ! "$package" =~ ^[a-zA-Z0-9._+-]+$ ]]; then
    echo "Warning: Invalid package name '$package' - contains illegal characters"
    return 1
  fi

  return 0
}

# Install a program with error logging
install_program() {
  local pm="$1"
  local program="$2"
  local log_file="update_log_$(date +%F_%T).log"

  # Validate package name to prevent command injection
  if ! validate_package_name "$program"; then
    echo "Skipping invalid package name: $program"
    return 1
  fi

  # Check if the program is already installed
  if command_exists "$program"; then
    echo "$program already installed"
    return 0
  fi

  echo "Installing $program"

  # Update package lists (log errors but don't exit)
  update_packages "$pm" || echo "Error: Failed to update package lists" >> "$log_file"

  # Install the program (log errors but don't exit)
  install_package "$pm" "$program" || echo "Error: Failed to install $program" >> "$log_file"
}

# ============================================================================
# Main Script
# ============================================================================

echo -e "\033[1;31m_  _ _  _ _ _  _ ____ ____ ____ ____ _       _ _  _ ____ ___ ____ _    _    ____ ____\033[0m"
echo -e "\033[1;31m|  | |\ | | |  | |___ |__/ [__  |__| |       | |\ | [__   |  |__| |    |    |___ |__/\033[0m"
echo -e "\033[1;31m|__| | \| |  \/  |___ |  \ ___] |  | |___    | | \| ___]  |  |  | |___ |___ |___ |  \ \033[0m" 
echo -e "\033[1;33m                         Another Wishmaster Production \033[0m"
echo -e "\033[1;34m            Let me give you a sample to get you in the spirit of the game! \033[0m"

echo -e "\033[1;35m                      Someone give me a bottle of rum! \033[0m"

echo -e "\033[1;36m                                   Here we go! \033[0m"

set -eu


# Display Help
Help() {
  printf "Simple script that can take needed programs manually\nOr you can select them from a file.\nIt will then do the rest for you.\nSit back and grab a beer or coffee.\n"
  echo ""
  echo "Usage: $0 [-h]"
  echo "Options:"
  echo "  -h  Show this help message and exit."
  echo ""
}

while getopts ":h" option; do
   case $option in
      h) # Display Help
         Help
         exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done


echo -e "\033[1;37m Welcome to Universal Installer. Checking for super user permissions, and initial dependencies. \033[0m"

# Check if user has permission
if [ "$EUID" -ne 0 ]; then
    echo "Please enter the superuser credentials."
    sudo -v
    if [ "$?" -ne 0 ]; then
        echo "Error: Superuser credentials not accepted."
        exit 1
    else
        # If the credentials are accepted, run the code as superuser
        sudo "$0" "$@"
        exit 0
    fi
fi

# Create logs directory with error checking
mkdir -p install_logs || { echo "Error: Failed to create logs directory"; exit 1; }

# Ensure required dependencies are installed
ensure_dependency "python3"
ensure_dependency "zenity"

# Detect package manager
pm=$(detect_package_manager)
if [ -z "$pm" ]; then
    echo "No package manager was found. Please install either apt-get, yum or dnf and try again."
    exit 1
fi

# Add menu option to ask the user how they would like to specify their requirements
options=$(zenity --list --title="Input Method" --text="How would you like to specify your requirements?" --radiolist --column "Pick" --column "Option" \
    TRUE "Input via typing" \
    FALSE "Select a file")

# Check if user cancelled the dialog
if [ -z "$options" ]; then
  echo "Operation cancelled by user"
  exit 0
fi

if [ "$options" = "Input via typing" ]; then
  # Ask the user to enter the programs they need to install
  programs=$(zenity --entry --title="Input Programs" --text="Enter the programs you would like to install, separated by a space:" --width=500)

  # Check if user cancelled or entered nothing
  if [ -z "$programs" ]; then
    echo "No programs specified, exiting"
    exit 0
  fi

  # Split the input into an array and install the programs
  # Save and restore IFS to avoid side effects
  local OLD_IFS="$IFS"
  IFS=' ' read -ra programs_array <<< "$programs"
  IFS="$OLD_IFS"

  for program in "${programs_array[@]}"; do
    install_program "$pm" "$program"
  done

elif [ "$options" = "Select a file" ]; then
  # Open file explorer to select the file
  file=$(zenity --file-selection)

  # Check if file is selected
  if [ -z "$file" ]; then
    echo "No file selected, exiting"
    exit 1
  fi

  # Read the file and install the programs
  while read -r program; do
    install_program "$pm" "$program"
  done < "$file"
fi

# Move log files to logs directory and rotate old logs (keep only last 50 files)
mv update_log_* install_logs/ 2>/dev/null || true

# Log rotation: remove old logs if more than 50 files exist
log_count=$(find install_logs/ -name "update_log_*" 2>/dev/null | wc -l)
if [ "$log_count" -gt 50 ]; then
  echo "Rotating old log files..."
  find install_logs/ -name "update_log_*" -type f | sort | head -n -50 | xargs rm -f 2>/dev/null || true
fi

# Try to install failed packages using pip as fallback
if [ -f install_logs/update_log_* ]; then
  cat install_logs/update_log_* > combined_log.txt 2>/dev/null || true
  sed 's/Error: Failed to install //g' combined_log.txt > cleaned_log.txt 2>/dev/null || true
  sort -u cleaned_log.txt | awk '{gsub(/[<>=~].*$/, "", $0); print $0}' | sort -u > clean_log_final.txt
  if [ -s clean_log_final.txt ]; then
    echo "Attempting to install failed packages using pip..."
    pip install --ignore-installed --no-deps -r clean_log_final.txt 2>/dev/null || echo "Some packages could not be installed via pip"
    rm -f combined_log.txt cleaned_log.txt clean_log_final.txt
  fi
fi

echo -e "\033[1;36m All specified programs are now installed \033[0m"

echo -e "\033[1;31m Press [Enter] key to continue or [CTRL + C] to exit \033[0m"
read

echo -e "\033[1;31m Exiting the program now...\033[0m"
exit 0

