#!/bin/bash

# Function to check health status of a given deployment
check_health_status() {
  local deployment="$1"
  local namespace="$2"

  if [[ -z "$deployment" || -z "$namespace" ]]; then
    echo "❌ Usage: check_health_status <deployment_name> <namespace>"
    exit 1
  fi

  echo "🔍 Checking status for deployment '$deployment' in namespace '$namespace'..."

  echo -e "\n📦 Deployment status:"
  kubectl get deployment "$deployment" -n "$namespace" || {
    echo "❌ Deployment not found."
    exit 1
  }

  echo -e "\n📦 Pod status:"
  kubectl get pods -n "$namespace" -l app="$deployment" --no-headers || {
    echo "❌ No pods found for deployment."
    exit 1
  }

  echo -e "\n📊 Resource usage (CPU/Memory):"
  if kubectl top pods -n "$namespace" &>/dev/null; then
    kubectl top pods -n "$namespace" --selector=app="$deployment"
  else
    echo "⚠️ Metrics server not available. Skipping resource usage."
  fi

  echo -e "\n⚠️ Recent pod events (failures/warnings):"
  for pod in $(kubectl get pods -n "$namespace" -l app="$deployment" -o jsonpath='{.items[*].metadata.name}'); do
    echo -e "\n🔸 Events for pod: $pod"
    kubectl describe pod "$pod" -n "$namespace" | awk '/Events:/,/^$/' | sed '1d'
  done

  echo -e "\n✅ Health check complete."
}
