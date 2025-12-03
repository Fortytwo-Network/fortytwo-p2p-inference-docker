# fortytwo-node-setup

## System Requirements
- Nvidia graphic card
- Cpu x86_64

## Requirements
1. Docker and docker compose 
2. [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Run instructions
1. Copy and update environment variables:
```bash
cp .env.example .env
```
2. Build the Docker Compose services:
```bash
docker compose build
```
3. Run the services in the background:
```bash
docker compose up -d
```

## Multi-Node Setup Instructions

### Objective
This guide explains how to run 3 different nodes on 4 GPUs on a single machine.

### LLM Models
The following models will be deployed:
1. `FT_CAPSULE_LLM_HF_REPO=mradermacher/VibeThinker-1.5B-GGUF` with `FT_CAPSULE_LLM_HF_MODEL_NAME=VibeThinker-1.5B.Q4_K_M.gguf`
2. `FT_CAPSULE_LLM_HF_REPO=Fortytwo-Network/Strand-Rust-Coder-14B-v1-GGUF` with `FT_CAPSULE_LLM_HF_MODEL_NAME=Fortytwo_Strand-Rust-Coder-14B-v1-Q4_K_M.gguf`
3. `FT_CAPSULE_LLM_HF_REPO=unsloth/Qwen3-1.7B-GGUF` with `FT_CAPSULE_LLM_HF_MODEL_NAME=Qwen3-1.7B-Q4_K_M.gguf`

### Step 1: Check Available GPUs

First, verify your GPU configuration using the `nvidia-smi` command:

```bash
nvidia-smi
```

Expected output example:
```text
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.195.03             Driver Version: 570.195.03     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA A10G                    Off |   00000000:00:1B.0 Off |                    0 |
|  0%   29C    P0             58W /  300W |       0MiB /  23028MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA A10G                    Off |   00000000:00:1C.0 Off |                    0 |
|  0%   28C    P0             56W /  300W |       0MiB /  23028MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   2  NVIDIA A10G                    Off |   00000000:00:1D.0 Off |                    0 |
|  0%   28C    P0             58W /  300W |       0MiB /  23028MiB |      3%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   3  NVIDIA A10G                    Off |   00000000:00:1E.0 Off |                    0 |
|  0%   28C    P0             56W /  300W |       0MiB /  23028MiB |      2%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

You should have 4 GPUs with IDs 0, 1, 2, and 3 (shown in the first GPU column).
### Step 2: Pre-download Models

Download all required models beforehand to save time:

```bash
make download-llm LLM_HF_REPO=mradermacher/VibeThinker-1.5B-GGUF LLM_HF_MODEL_NAME=VibeThinker-1.5B.Q4_K_M.gguf 
make download-llm LLM_HF_REPO=Fortytwo-Network/Strand-Rust-Coder-14B-v1-GGUF LLM_HF_MODEL_NAME=Fortytwo_Strand-Rust-Coder-14B-v1-Q4_K_M.gguf
make download-llm LLM_HF_REPO=unsloth/Qwen3-1.7B-GGUF LLM_HF_MODEL_NAME=Qwen3-1.7B-Q4_K_M.gguf
```

### Step 3: Prepare Environment Files

Create separate environment files for each node:

```bash
cp .env.example .env.vibethinker
cp .env.example .env.rust_coder
cp .env.example .env.qwen
```

**Important**: Each node requires:
- A unique `FT_ACCOUNT_PRIVATE_KEY`
- A unique `FT_NODE_LISTENER_PORT`
- The appropriate `FT_CAPSULE_LLM_HF_REPO` and `FT_CAPSULE_LLM_HF_MODEL_NAME` values

### Step 4: Create Docker Compose Files

Create separate compose files for each node:

```bash
cp docker-compose.yml docker-compose-vibethinker.yml
cp docker-compose.yml docker-compose-rust_coder.yml
cp docker-compose.yml docker-compose-qwen.yml
```

### Step 5: Assign GPUs to Each Node

Edit each Docker Compose file to assign specific GPU(s) by their ID.

*docker-compose-vibethinker.yml*
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          device_ids: ['0']  # Assign to GPU 0
          capabilities:
            - gpu
```

*docker-compose-rust_coder.yml*
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          device_ids: ['1', '2']  # Assign to GPUs 1 and 2
          capabilities:
            - gpu
```

*docker-compose-qwen.yml*
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          device_ids: ['3']  # Assign to GPU 3
          capabilities:
            - gpu
```
**Note**: Using `device_ids: ['all']` will utilize all available GPUs for that node.

### Step 6: Launch the Nodes

Start each node using its respective compose file and environment file:

```bash
docker compose -f docker-compose-vibethinker.yml --env-file .env.vibethinker -p vibethinker up -d
docker compose -f docker-compose-rust_coder.yml --env-file .env.rust_coder -p rust_coder up -d
docker compose -f docker-compose-qwen.yml --env-file .env.qwen -p qwen up -d
```

### Verification

After launching, you can verify that the nodes are running correctly:

```bash
docker ps
```

Each node should be running in its own container with the assigned GPU resources.

---
## Utilities
### Get a drop for an existing wallet
```bash
make get-drop WALLET=... CODE=... 
```
### Create a wallet and get a drop
```bash
make get-drop PRIVATE_KEY_PATH=... CODE=... 
```
### Download a LLM 
```bash
make download-llm LLM_HF_REPO=... LLM_HF_MODEL_NAME=... 
```
### View logs
```bash
docker compose logs -f -t --tail 100
```
### Export logs
```bash
docker compose logs -t > "ft_node_logs_$(date +'%Y%m%d_%H%M%S').txt"
```