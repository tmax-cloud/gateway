IMAGE_DIR=_images
# docker.io & quay.io & etc..
REGISTRY=docker.io
PRIVATE_REGISTRY=192.169.1.150
TRAEFIK_NAMESPACE=library
TRAEFIK_NAME=traefik
TRAEFIK_TAG=v2.5.3
CONSOLE_NAMESPACE=tmaxcloudck
CONSOLE_NAME=hypercloud-console
CONSOLE_TAG=5.0.34.0
JWT_NAMESPACE=tmaxcloudck
JWT_NAME=jwt-decode
JWT_TAG=5.0.0.0
# commands
PULL=podman pull
SAVE=podman save
LOAD=podman load
TAG=podman tag
PUSH=podman push

TLS_FILE = "./gateway/03.TLS-front/002.certificate.yaml"
LB_IP = $(shell kubectl get svc -n api-gateway-system api-gateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

prepare_online:
	$(PULL) $(REGISTRY)/$(TRAEFIK_NAMESPACE)/$(TRAEFIK_NAME):$(TRAEFIK_TAG)
	$(PULL) $(REGISTRY)/$(CONSOLE_NAMESPACE)/$(CONSOLE_NAME):$(CONSOLE_TAG)
	$(PULL) $(REGISTRY)/$(JWT_NAMESPACE)/$(JWT_NAME):$(JWT_TAG)
	$(SAVE) $(REGISTRY)/$(TRAEFIK_NAMESPACE)/$(TRAEFIK_NAME):$(TRAEFIK_TAG) > $(IMAGE_DIR)/$(TRAEFIK_NAME)_$(TRAEFIK_TAG).tar
	$(SAVE) $(REGISTRY)/$(CONSOLE_NAMESPACE)/$(CONSOLE_NAME):$(CONSOLE_TAG) > $(IMAGE_DIR)/$(CONSOLE_NAME)_$(CONSOLE_TAG).tar
	$(SAVE) $(REGISTRY)/$(JWT_NAMESPACE)/$(JWT_NAME):$(JWT_TAG) > $(IMAGE_DIR)/$(JWT_NAME)_$(JWT_TAG).tar

prepare_offline:
	$(LOAD) < $(IMAGE_DIR)/$(TRAEFIK_NAME)_$(TRAEFIK_TAG).tar
	$(LOAD) < $(IMAGE_DIR)/$(CONSOLE_NAME)_$(CONSOLE_TAG).tar
	$(LOAD) < $(IMAGE_DIR)/$(JWT_NAME)_$(JWT_TAG).tar
	$(TAG) $(REGISTRY)/$(TRAEFIK_NAMESPACE)/$(TRAEFIK_NAME):$(TRAEFIK_TAG) $(PRIVATE_REGISTRY)/$(TRAEFIK_NAMESPACE)/$(TRAEFIK_NAME):$(TRAEFIK_TAG)
	$(TAG) $(REGISTRY)/$(CONSOLE_NAMESPACE)/$(CONSOLE_NAME):$(CONSOLE_TAG) $(PRIVATE_REGISTRY)/$(CONSOLE_NAMESPACE)/$(CONSOLE_NAME):$(CONSOLE_TAG)
	$(TAG) $(REGISTRY)/$(JWT_NAMESPACE)/$(JWT_NAME):$(JWT_TAG) $(PRIVATE_REGISTRY)/$(JWT_NAMESPACE)/$(JWT_NAME):$(JWT_TAG)
	$(PUSH) $(TRAEFIK_TAG) $(PRIVATE_REGISTRY)/$(TRAEFIK_NAMESPACE)/$(TRAEFIK_NAME):$(TRAEFIK_TAG)
	$(PUSH) $(PRIVATE_REGISTRY)/$(CONSOLE_NAMESPACE)/$(CONSOLE_NAME):$(CONSOLE_TAG)
	$(PUSH) $(PRIVATE_REGISTRY)/$(JWT_NAMESPACE)/$(JWT_NAME):$(JWT_TAG)

install:
	kubectl apply -f _kubernetes/

install_nip_io: nip_io
	kubectl apply -f ./nip_io

clean:
	@(rm -rf ./nip_io)

nip_io:
	@(mkdir ./nip_io)
	@(cp -r ./manifests/* ./nip_io/)
#	@(sed "s%{{ LB_IP }}%$(LB_IP)%g" $(TLS_FILE) > ./nip_io/001.certificate.yaml)
#	@(sed "s%tmaxcloud-gateway-tls%tmaxcloud-gateway-nip-io%g" ./gateway/03.TLS-front/002.default-tls.yaml > ./nip_io/002.default-tls.yaml)