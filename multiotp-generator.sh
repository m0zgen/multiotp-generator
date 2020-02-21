#!/bin/bash
# Created by Yevgeniy Goncharov - https://sys-adm.in
#
# Script for generate Keys and system commands for MultiOTP Windows software
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Need components (CentOS)
# yum install xxd vim-common perl-MIME-Base32 -y

# Retreive user name
echo -n "Enter User name and press [ENTER]: "
read user_name

# Check user name
if [[ -z "$user_name" ]]; then
  echo "Please determine user name!"
  exit 1
else
  # Generate hex key
  SYSTEMKEY=$(for i in $(seq 1 20); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo)
  # Convert to Base32
  # USERKEY=$(echo $SYSTEMKEY | xxd -r -p | base32)
  USERKEY=$(echo -n $SYSTEMKEY | xxd -r -p | $SCRIPT_PATH/base32.pl)
  # Generate Windows user password
  USERPASS=$(date +%s | sha256sum | base64 | head -c 8 ; echo)

  # Show info
  # echo -e "User name is: \e[92m$user_name\e[0m\nMultiOTP system key - \e[92m$SYSTEMKEY\e[0m \nUser GA key - \e[92m${USERKEY,,}\e[0m"
  USERKEY,,}\e[0m"
  # Save info to file
  echo -e "User name is: \e[92m$user_name\e[0m\nMultiOTP system key - \e[92m$SYSTEMKEY\e[0m \nUser GA key - \e[92m${USERKEY,,}\e[0m" >> $SCRIPT_PATH/log.txt

  # Generate work command for implement user to Windows OS
  echo -e "\nYou can create user in Windows: \e[92mnet user /add $user_name $USERPASS\e[0m"
  echo -e "You can reset created user pass: \e[92mnet user $user_name new_password\e[0m"

  # Generate MultiOTP commands
  echo -e "\nMultiOTP command:\nmultiotp.exe -debug -create $user_name TOTP $SYSTEMKEY 6\n"
  echo -e "\nMultiOTP additional commands:\nmultiotp.exe -display-log $user_name GOOGLE-AUTH-KEY"
  echo -e "multiotp -qrcode $user_name > c:\MultiOTP\users\\$user_name.png"
  exit 0
fi
