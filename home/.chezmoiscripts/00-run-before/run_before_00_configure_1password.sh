#!/usr/bin/env bash

set -e
set -u
set -o pipefail

echo ""
echo "-----------------------------------------------------------------------"
echo " Configure 1Password"
echo "-----------------------------------------------------------------------"
echo ""

if command -v op >/dev/null 2>&1; then
  if [ -z "$(op account list)" ]; then
    echo "No 1Password account found. Let's add one."

    # Prompt for user input
    # read -p "Enter your sign-in address (e.g., my.1password.com): " address
    read -p "Enter your email address: " email
    read -s -p "Enter your Secret Key: " secret_key
    echo # Add a newline after secret key input

    # Use the collected information to add the account
    echo "Adding 1Password account..."
    # op account add --address "my.1password.com" --email "$email" --secret-key "$secret_key" <<<"$password"
    op account add --address "my.1password.com" --email "$email" --secret-key "$secret_key"

    echo "1Password account added successfully."
  fi
else
  echo "1Password CLI (op) is not installed or not in PATH."
fi
