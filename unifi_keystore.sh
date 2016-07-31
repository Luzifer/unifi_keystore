#!/usr/bin/env bash

# unifi_ssl_import.sh
# UniFi Controller SSL Certificate Import Script for Unix/Linux Systems
# by Steve Jenkins <http://www.stevejenkins.com/>
# Incorporates ideas from https://source.sosdg.org/brielle/lets-encrypt-scripts
# Version 2.2
# Last Updated June 26, 2016

# REQUIREMENTS
# 1) Assumes you have a UniFi Controller installed and running on your system.
# 2) Assumes you have a valid private key, signed certificate, and certificate
#    authority chain file. See http://wp.me/p1iGgP-2wU for detailed instructions
#    on how to generate these files and use them with this script.

# KEYSTORE BACKUP
# Even though this script attempts to be clever and careful in how it backs up your existing keystore,
# it's never a bad idea to manually back up your keystore (located at $UNIFI_DIR/data/keystore)
# to a separate directory before running this script. If anything goes wrong, you can restore from your
# backup, restart the UniFi Controller service, and be back online immediately.

# CONFIGURATION OPTIONS
UNIFI_DIR=/data

PRIV_KEY=${PRIV_KEY:-unifi.key}
SIGNED_CRT=${SIGNED_CRT:-unifi.crt}
CHAIN_FILE=${CHAIN_FILE:-chain.crt}

# CONFIGURATION OPTIONS YOU PROBABLY SHOULDN'T CHANGE
KEYSTORE=${UNIFI_DIR}/keystore
ALIAS=unifi
PASSWORD=aircontrolenterprise

#### SHOULDN'T HAVE TO TOUCH ANYTHING PAST THIS POINT ####

printf "\nStarting UniFi Controller SSL Keystore Generation...\n"

# Check to see whether Let's Encrypt Mode (LE_MODE) is enabled

# Verify required files exist
if [ ! -f ${PRIV_KEY} ] || [ ! -f ${SIGNED_CRT} ] || [ ! -f ${CHAIN_FILE} ]; then
	printf "\nMissing one or more required files. Check your settings.\n"
	exit 1
else
	# Everything looks OK to proceed
	printf "\nImporting the following files:\n"
	printf "Private Key: %s\n" "$PRIV_KEY"
	printf "Signed Certificate: %s\n" "$SIGNED_CRT"
	printf "CA File: %s\n" "$CHAIN_FILE"
fi

# Create temp files
P12_TEMP=$(mktemp)
CA_TEMP=$(mktemp)

# Create double-safe keystore backup
if [ -s "${KEYSTORE}.orig" ]; then
	printf "\nBackup of original keystore exists!\n"
	printf "\nCreating non-destructive backup as keystore.bak...\n"
	cp ${KEYSTORE} ${KEYSTORE}.bak
else
	cp ${KEYSTORE} ${KEYSTORE}.orig
	printf "\nNo original keystore backup found.\n"
	printf "\nCreating backup as keystore.orig...\n"
fi
	 
# Export your existing SSL key, cert, and CA data to a PKCS12 file
printf "\nExporting SSL certificate and key data into temporary PKCS12 file...\n"
openssl pkcs12 -export \
-in ${SIGNED_CRT} \
-inkey ${PRIV_KEY} \
-CAfile ${CHAIN_FILE} \
-out ${P12_TEMP} -passout pass:${PASSWORD} \
-caname root -name ${ALIAS}
	
# Delete the previous certificate data from keystore to avoid "already exists" message
printf "\nRemoving previous certificate data from UniFi keystore...\n"
keytool -delete -alias ${ALIAS} -keystore ${KEYSTORE} -deststorepass ${PASSWORD}
	
# Import the temp PKCS12 file into the UniFi keystore
printf "\nImporting SSL certificate into UniFi keystore...\n"
keytool -importkeystore \
-srckeystore ${P12_TEMP} -srcstoretype PKCS12 \
-srcstorepass ${PASSWORD} \
-destkeystore ${KEYSTORE} \
-deststorepass ${PASSWORD} \
-destkeypass ${PASSWORD} \
-alias ${ALIAS} -trustcacerts
	
# Clean up temp files
printf "\nRemoving temporary files...\n"
rm -f ${P12_TEMP}
rm -f ${CA_TEMP}
	
# That's all, folks!
printf "\nDone!\n"

exit 0
