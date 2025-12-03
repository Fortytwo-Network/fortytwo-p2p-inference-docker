.PHONY: get-drop create-wallet download-llm

ifneq (,$(wildcard .env))
    include .env
    export
endif

DOCKER_IMAGE_NAME=fortytwo-utils
DOCKER_IMAGE_TAG=latest

build-docker-utils:
	docker build \
	-f Dockerfile.protocol \
	--build-arg PATH_EXEC="/workspace/utils" \
	--build-arg MODULE_NAME="utilities" \
	-t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .

get-drop: build-docker-utils
	@if [ -z "$(WALLET)" ]; then echo "No WALLET provided. Use: make get-drop WALLET=... CODE=..."; exit 1; fi
	@if [ -z "$(CODE)" ]; then echo "No CODE provided. Use: make get-drop WALLET=... CODE=..."; exit 1; fi
	@echo "⨳ Requesting drop..."
	@docker run --rm \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		/workspace/utils --drop-wallet "$(WALLET)" --drop-code "$(CODE)"

create-wallet: build-docker-utils
	@if [ -z "$(PRIVATE_KEY_PATH)" ]; then echo "No PRIVATE_KEY_PATH provided. Use: make create-wallet PRIVATE_KEY_PATH=... CODE=..."; exit 1; fi
	@if [ -z "$(CODE)" ]; then echo "No CODE provided. Use: make create-wallet PRIVATE_KEY_PATH=... CODE=..."; exit 1; fi
	@docker run --rm \
		-v $$(pwd):/data \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		/workspace/utils --create-wallet "/data/$(PRIVATE_KEY_PATH)" --drop-code "$(CODE)"

download-llm:
	@if [ -z "$(LLM_HF_REPO)" ]; then echo "No LLM_HF_REPO provided. Use: make download-llm LLM_HF_REPO=... LLM_HF_MODEL_NAME=..."; exit 1; fi
	@if [ -z "$(LLM_HF_MODEL_NAME)" ]; then echo "No LLM_HF_MODEL_NAME provided. Use: make download-llm LLM_HF_REPO=... LLM_HF_MODEL_NAME=..."; exit 1; fi
	@echo "Downloading model $(LLM_HF_MODEL_NAME) from $(LLM_HF_REPO) to $(INPUT_MODEL_CACHE) (you can set the path to the model cache in the .env INPUT_MODEL_CACHE=)"
	@docker run --rm -it \
		-v $(INPUT_MODEL_CACHE):/cache \
		$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		/workspace/utils --hf-repo "$(LLM_HF_REPO)" --hf-model-name "$(LLM_HF_MODEL_NAME)" --model-cache "/cache"
