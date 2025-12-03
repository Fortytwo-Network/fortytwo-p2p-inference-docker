.PHONY: get-drop create-wallet

DOCKER_IMAGE_NAME=fortytwo-utils
DOCKER_IMAGE_TAG=latest

build-docker-utils:
	docker build \
	-f Dockerfile.protocol \
	--build-arg PATH_EXEC="/workspace/utils " \
	--build-arg MODULE_NAME="utilities" \
	-t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

get-drop: build-docker-utils
	@if [ -z "$(WALLET)" ]; then echo "No WALLET provided. Use: make get-drop WALLET=... CODE=..."; exit 1; fi
	@if [ -z "$(CODE)" ]; then echo "No CODE provided. Use: make get-drop WALLET=... CODE=..."; exit 1; fi
	@echo "⨳ Requesting drop..."
	@docker run --rm \
		--entrypoint /workspace/utils \ 
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		--drop-wallet "$(WALLET)" --drop-code "$(CODE)"

create-wallet: build-docker-utils
	@if [ -z "$(PRIVATE_KEY_PATH)" ]; then echo "No PRIVATE_KEY_PATH provided. Use: make create-wallet PRIVATE_KEY_PATH=... CODE=..."; exit 1; fi
	@if [ -z "$(CODE)" ]; then echo "No CODE provided. Use: make create-wallet PRIVATE_KEY_PATH=... CODE=..."; exit 1; fi
	@docker run --rm \
		-v $(PWD):/data $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		--entrypoint /workspace/utils \ 
		--create-wallet "/data/$(PRIVATE_KEY_PATH)" --drop-code "$(CODE)"
