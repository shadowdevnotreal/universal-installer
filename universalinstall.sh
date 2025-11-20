#!/bin/bash
set -e
set -u

echo "Welcome to Time Cop, checking for dependencies"

# Check if user has permission
if [ "$EUID" -ne 0 ]; then
    echo "Please enter the super user credentials"
    sudo -v
    if [ "$?" -ne 0 ]; then
        echo "Error: Superuser credentials not accepted"
        exit 1
    fi
fi

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

echo "Checking for required modules for Time Cop"

# Check if apt-get is installed
if command -v apt-get > /dev/null 2>&1; then
    # Update package lists
    echo "Updating package lists"
    sudo apt-get update || { echo "Error: Failed to update package lists" ; exit 1; }
    # Install required libraries
    echo "Installing required modules"
    sudo apt-get install -y python3-secrets python3-time python3-pyotp python3-hashlib python3-logging python3-crypto || { echo "Error: Failed to install required modules" ; exit 1; }

# Check if yum is installed
elif command -v yum > /dev/null 2>&1; then
    # Update package lists
    echo "Updating package lists"
    sudo yum update || { echo "Error: Failed to update package lists" ; exit 1; }
    # Install required libraries
    echo "Installing required modules"
    sudo yum install -y python3-secrets python3-time python3-pyotp python3-hashlib python3-logging python3-crypto || { echo "Error: Failed to install required modules" ; exit 1; }

# Check if dnf is installed
elif command -v dnf > /dev/null 2>&1; then
    # Update package lists
    echo "Updating package lists"
    sudo dnf update || { echo "Error: Failed to update package lists" ; exit 1; }
    # Install required libraries
    echo "Installing required modules"
    sudo dnf install -y python3-secrets python3-time python3-pyotp python3-hashlib python3-logging python3-crypto || { echo "Error: Failed to install required modules" ; exit 1; }
else
    echo "Error: Could not find a package manager. Please install the required modules manually."
    exit 1
fi

echo "All required modules are now installed"
