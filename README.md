# Luzifer / unifi-keystore

This repository contains a Docker image to generate the `keystore` file for an Unifi Controller based on a [Gist from stevejenkins](https://gist.github.com/stevejenkins/639ca3470b28e07b36bacb29efcec37f).

To generate the `keystore` put these three files into one directory:

- `unifi.crt` - The signed certificate
- `unifi.key` - The corresponding private key for that certificate
- `chain.crt` - Root / intermediate certificate which issued the certificate

After you have this just execute the Docker image:

```bash
# docker run --rm -ti -v $(pwd):/data quay.io/luzifer/unifi-keystore

Starting UniFi Controller SSL Keystore Generation...

Importing the following files:
Private Key: unifi.key
Signed Certificate: unifi.crt
CA File: chain.crt

No original keystore backup found.

Creating backup as keystore.orig...

Exporting SSL certificate and key data into temporary PKCS12 file...

Removing previous certificate data from UniFi keystore...

Importing SSL certificate into UniFi keystore...

Removing temporary files...

Done!
```

If you've executed this command inside the controllers directory the old `keystore` file gets backed up and you can restart the controller daemon afterwards. Otherwise you need to copy the `keystore` file over the old one and then restart the controller daemon.
