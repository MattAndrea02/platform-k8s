#!/usr/bin/env bash
# Explicit `sh setupenv.sh` ignores the shebang; switch before using Bash syntax.
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

# Run with Bash (WSL or Git Bash), from any working directory.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

MINIKUBE_PROFILE="${MINIKUBE_PROFILE:-minikube}"
HELM_TIMEOUT="${HELM_TIMEOUT:-5m}"

printf 'Avvio del cluster Minikube con il profilo %q...\n' "$MINIKUBE_PROFILE"
minikube start

for command in minikube helm; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Errore: %s non disponibile nel PATH.\n' "$command" >&2
    exit 1
  fi
done

if ! minikube -p "$MINIKUBE_PROFILE" status; then
  printf 'Avvia il cluster con: minikube start -p %q\n' "$MINIKUBE_PROFILE" >&2
  exit 1
fi

shopt -s nullglob
jars=(target/*.jar)
if (( ${#jars[@]} != 1 )); then
  printf 'Serve un solo JAR in target/. Esegui prima: ./mvnw clean package\n' >&2
  exit 1
fi

# Keep this tag aligned with platform-k8s/templates/platform-api.yaml.
printf 'Costruzione immagine Docker per il chart Helm...\n'
minikube -p "$MINIKUBE_PROFILE" image build --all -t platform-api-k8s:1.0 .

helm repo add metallb https://metallb.github.io/metallb
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update metallb emberstack

# Use the same cluster as the image build, regardless of the current context.
helm upgrade --install metallb metallb/metallb \
  --kube-context "$MINIKUBE_PROFILE" \
  --namespace metallb-system --create-namespace \
  --wait --timeout "$HELM_TIMEOUT"

helm upgrade --install reflector emberstack/reflector \
  --kube-context "$MINIKUBE_PROFILE" \
  --namespace reflector-system --create-namespace \
  --wait --timeout "$HELM_TIMEOUT"

printf '\nAbilita addon ingress di Minikube:\n'
minikube addons enable ingress

printf '\nAmbiente pronto. Installa il chart con il nome della tua release:\n'
printf 'helm upgrade --install <release> ./platform-k8s --kube-context %q\n' "$MINIKUBE_PROFILE"
