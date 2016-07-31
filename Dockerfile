FROM java

ADD ./unifi_keystore.sh /usr/local/bin/

VOLUME /data

ENTRYPOINT ["/usr/local/bin/unifi_keystore.sh"]
