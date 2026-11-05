#!/usr/bin/env bash
set -euo pipefail
REG=kind-registry
kind create cluster --config "$(dirname "$0")/kind-config.yaml"

# Tell every node's containerd that localhost:5001 is the registry container
for node in $(kind get nodes --name lab); do
  docker exec "$node" mkdir -p "/etc/containerd/certs.d/localhost:5001"
  cat <<EOT | docker exec -i "$node" cp /dev/stdin "/etc/containerd/certs.d/localhost:5001/hosts.toml"
[host."http://${REG}:5000"]
EOT
done

# Let the nodes reach the registry container by name
docker network connect kind "$REG" 2>/dev/null || true
