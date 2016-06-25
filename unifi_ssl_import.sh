#!/bin/sh

# unifi_ssl_import.sh
# UniFi Controller SSL Certificate Import Script for Unix/Linux Systems
# by Steve Jenkins (stevejenkins.com)
# Last Updated June 25, 2016

# REQUIREMENTS
# 1) Assumes you have a UniFi Controller installed and running on your system.
# 2) Assumes the default UniFi keystore is located at /opt/UniFi/data/keystore.
# 3) Assumes you have a signed SSL certificate (.crt), private key (.key), and associated
#    Certificate Authority (CA) file from the certificate issuer.

# KEYSTORE BACKUP
# Even though this script attempts to be clever and careful in how it backs up your existing keystore,
# it's never a bad idea to manually back up your keystore (likely located at /opt/UniFi/data/keystore)
# to a separate directory before running this script. The only file this script modifies is the keystore
# file, so if anything goes wrong, you can restore from your backup, restart the UniFi Controller service,
# and be back online immediately.

# CONFIGURATION OPTIONS
keystore_file=/opt/UniFi/data/keystore
in_key=/etc/ssl/private/hostname.example.com.key
in_crt=/etc/ssl/certs/hostname.example.com.crt
ca_file=/etc/ssl/certs/root_bundle.crt
friendly_name=unifi
password=aircontrolenterprise

#### SHOULDN'T HAVE TO MODIFY PAST THIS POINT ####

# Create double-safe keystore backup
if [ -s "$keystore_file.orig" ]; then
	printf "\nBackup of original keystore exists!\n"
	printf "Creating non-destructive backup as keystore.bak...\n"
	cp $keystore_file $keystore_file.bak
elseif [ ! -s "$keystore_file.orig" ]; then
  cp $keystore_file $keystore_file.orig
  printf "\nNo original keystore backup found.\n"
	printf "Creating backup as keystore.orig...\n"
fi

# Export your existing SSL key, cert, and CA data to a PKCS12 file
printf "\nExporting SSL certificate and key data into PKCS12 file...\n"
openssl pkcs12 -export -in $in_crt -inkey $in_key -certfile $ca_file \
-out /tmp/unifi.p12 -name $friendly_name -password pass:$password

# Import the newly created PKCS12 file into the UniFi keystore
printf "\nImporting PKCS12 file into UniFi keystore...\n"
keytool -importkeystore -srckeystore /tmp/unifi.p12 -srcstoretype PKCS12 \
-srcstorepass $password -destkeystore $keystore_file -storepass $password

# Clean up intermediate PKCS12 file
rm -rf /tmp/unifi.p12

# Restart the UniFi Controller to pick up the updated keystore
service UniFi restart

exit