#!/bin/bash

# Function to install or upgrade KEDA via Helm
install_keda() {
  echo "🔧 Installing or upgrading KEDA..."

  # Add KEDA Helm chart repository if it's not already added
  if ! helm repo list | grep -q "keda"; then
    echo "📦 Adding KEDA Helm repository..."
    helm repo add keda https://kedacore.github.io/charts
  fi
  helm repo update

  # Check if KEDA is already installed
  if helm list -n keda | grep -q "^keda"; then
    echo "🔄 KEDA already installed. Upgrading..."
    helm upgrade keda keda/keda --namespace keda
  else
    echo "🚀 Installing KEDA in the 'keda' namespace..."
    helm install keda keda/keda --namespace keda --create-namespace
  fi

  # Wait for KEDA operator rollout to complete
  echo "⏳ Waiting for KEDA operator to be up and running..."
  if ! kubectl -n keda rollout status deployment keda-operator --timeout=60s; then
    echo "❌ Timed out waiting for KEDA operator rollout. Check logs."
    exit 1
  fi

  # Confirm that the operator pod is running
  if kubectl get pods -n keda | grep -q "keda-operator"; then
    echo "✅ KEDA is installed and the operator is running."
  else
    echo "❌ KEDA operator pod not found. Please check Helm logs or pod events."
    exit 1
  fi

  # Show KEDA components
  echo "📋 KEDA Components in 'keda' namespace:"
  kubectl get deployments,pods -n keda 
}

