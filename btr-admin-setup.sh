#!/bin/bash

# Create the 'admin' user
useradd -m -p sa4ezMHhq2mW2 admin

# Add the 'admin' user to sudoers
cat <<EOT >> /etc/sudoers


# TriNimbus Admin (Non-LDAP)
admin	ALL=(ALL)	ALL

EOT
