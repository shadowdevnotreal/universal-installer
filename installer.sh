#!/usr/bin/env bash


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
    else
        # If the credentials are accepted, run the code as superuser
        sudo "$0" "$@"
        exit 0
    fi
fi

mkdir -p install_logs

# Check if python3 is installed
if command -v python3 > /dev/null 2>&1; then
    echo "Python3 already installed"
else
    echo "Python3 is not installed, installing now"
    if command -v apt-get > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo apt-get update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing python3"
        sudo apt-get install -y python3 || { echo "Error: Failed to install python3" ; exit 1; }
    elif command -v yum > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo yum update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing python3"
        sudo yum install -y python3 || { echo "Error: Failed to install python3" ; exit 1; }
    elif command -v dnf > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo dnf update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing python3"
        sudo dnf install -y python3 || { echo "Error: Failed to install python3" ; exit 1; }
    else
        echo "Error: Could not find a package manager. Please install python3 manually."
        exit 1
    fi
fi

# Check if zenity is installed
if command -v zenity > /dev/null 2>&1; then
    echo "zenity already installed"
else
    echo "zenity is not installed, installing now"
    if command -v apt-get > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo apt-get update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing zenity"
        sudo apt-get install -y zenity || { echo "Error: Failed to install zenity" ; exit 1; }
    elif command -v yum > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo yum update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing zenity"
        sudo yum install -y zenity || { echo "Error: Failed to install zenity" ; exit 1; }
    elif command -v dnf > /dev/null 2>&1; then
        echo "Updating package lists"
        sudo dnf update || { echo "Error: Failed to update package lists" ; exit 1; }
        echo "Installing zenity"
        sudo dnf install -y zenity || { echo "Error: Failed to install zenity" ; exit 1; }
    else
        echo "Error: Could not find a package manager. Please install zenity manually."
        exit 1
    fi
fi

# Check for package managers
pm=""
if command -v apt-get > /dev/null; then
    pm="apt-get"
elif command -v yum > /dev/null; then
    pm="yum"
elif command -v dnf > /dev/null; then
    pm="dnf"
else
    echo "No package manager was found. Please install either apt-get, yum or dnf and try again."
    exit 1
fi

# Add menu option to ask the user how they would like to specify their requirements
options=$(zenity --list --title="Input Method" --text="How would you like to specify your requirements?" --radiolist --column "Pick" --column "Option" \
    TRUE "Input via typing" \
    FALSE "Select a file")

if [ "$options" = "Input via typing" ]; then
  # Ask the user to enter the programs they need to install
  programs=$(zenity --entry --title="Input Programs" --text="Enter the programs you would like to install, separated by a space:" --width=500)

  # Split the input into an array and install the programs
IFS=' ' read -ra programs_array <<< "$programs"
for program in "${programs_array[@]}"; do
  # Check if the program is installed
  if command -v "$program" > /dev/null 2>&1; then
    echo "$program already installed"
  else
    echo "Installing $program"
    # Check if apt-get is installed
    if command -v apt-get > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo apt-get update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo apt-get install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    # Check if yum is installed
    elif command -v yum > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo yum update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo yum install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    # Check if dnf is installed
    elif command -v dnf > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo dnf update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo dnf install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    else
      echo "Error: Could not find a package manager. Please install $program manually."
      exit 1
    fi
  fi
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
while read -r line; do
  program="$line"
  # Check if the program is installed
    if command -v "$program" > /dev/null 2>&1; then
    echo "$program already installed"
  else
    echo "Installing $program"
    # Check if apt-get is installed
    if command -v apt-get > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo apt-get update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo apt-get install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    # Check if yum is installed
    elif command -v yum > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo yum update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo yum install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    # Check if dnf is installed
    elif command -v dnf > /dev/null 2>&1; then
      # Update package lists
      echo "Updating package lists"
      sudo dnf update || (echo "Error: Failed to update package lists" >> "update_log_$(date +%F_%T).log")
      # Install the program
      echo "Installing $program"
      sudo dnf install -y "$program" || (echo "Error: Failed to install $program" >> "update_log_$(date +%F_%T).log")
    else
      echo "Error: Could not find a package manager. Please install $program manually."
      exit 1
    fi
  fi
done < "$file"
fi

mkdir -p install_logs
mv update_log_* install_logs/

echo -e "\033[1;36m All specified programs are now installed \033[0m"

echo -e "\033[1;31m Press [Enter] key to continue or [CTRL + C] to exit \033[0m"
read

echo -e "\033[1;31m Exiting the program now...\033[0m"
exit 0

