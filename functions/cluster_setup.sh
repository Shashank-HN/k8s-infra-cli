#!/bin/bash

# Function to set up the cluster environment and verify basic tooling
setup_cluster() {
  echo "🔧 Checking kubectl connectivity..."

  # Check if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl and try again."
    exit 1
  fi

  # Try accessing the cluster to verify context is valid
  if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Failed to connect to the Kubernetes cluster. Check your kubeconfig."
    exit 1
  fi

  echo "✅ kubectl is connected to the cluster."

  echo "🔧 Checking Helm installation..."
  if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm and try again."
    exit 1
  fi

  echo "✅ Helm is installed."

  echo "📋 Cluster Summary:"
  echo "--------------------"
  kubectl config current-context       # Show current kube context
  kubectl get nodes -o wide            # List all nodes
  kubectl version --short              # Show client/server versions
  helm version --short                 # Show Helm version
}
