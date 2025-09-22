#!/bin/sh

# Create a user and set a password.
addgroup --gid $USER "sshuser"
useradd --gid "sshuser" --uid $USER "sshuser" --create-home
echo "sshuser:$PASSWORD" | chpasswd

# Start SSH server.
/usr/sbin/sshd -D
