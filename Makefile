ci:
	docker build --pull --no-cache -t registry.gitlab.com/luzifer/unifi-keystore .
	docker push registry.gitlab.com/luzifer/unifi-keystore
