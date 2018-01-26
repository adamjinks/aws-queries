#!/bin/bash

# Create the 'admin' user
useradd -m -p Str0ngPassw0rd admin

# Add the 'admin' user to sudoers
cat <<EOT >> /etc/sudoers


# Admin User
admin	ALL=(ALL)	ALL

EOT
