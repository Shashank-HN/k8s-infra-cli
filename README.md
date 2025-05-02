# k8s-infra-cli
A modular CLI tool to automate operations on a bare Kubernetes cluster. It connects to the cluster, installs required tooling (including KEDA for event-driven autoscaling), creates scalable deployments, and provides health checks for any deployment ID. Built with reusable Bash functions to support multiple deployment configurations.


# Kubernetes Infrastructure Automation CLI

## Overview

This modular Bash-based CLI tool automates operations on a bare Kubernetes cluster, including:

- Connecting to a cluster
- Installing Helm and KEDA
- Creating deployments with event-driven autoscaling
- Retrieving health status of a deployment

The scripts are modular, parameterized, and scalable — making them suitable for diverse deployment configurations.

---

## Directory Structure

```
├── deploy.sh                  # Main CLI entry point
├── functions/
│   ├── connect_cluster.sh     # Connects to cluster & verifies access
│   ├── install_tools.sh       # Installs Helm and KEDA
│   ├── create_deployment.sh   # Creates deployment, service, and autoscaler
│   └── health_check.sh        # Checks deployment & pod health
└── README.md                  # This file
```

---

## Prerequisites

Make sure the following tools are installed on your system:

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- [`helm`](https://helm.sh/docs/intro/install/)
- Kubernetes cluster access (via `~/.kube/config`)
- Optional: [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) (for `kubectl top`)

---

##  Usage

###  1. Connect to Kubernetes Cluster

```bash
./deploy.sh connect
```

> Verifies that your `kubectl` context is valid and connected to a live cluster.

---

###  2. Install Helm and KEDA

```bash
./deploy.sh install-tools
```

> Installs `Helm` if not installed, then deploys the latest `KEDA` Helm chart into the cluster.

---

###  3. Create a New Deployment with KEDA Autoscaling

```bash
./deploy.sh deploy \
  <deployment_name> \
  <namespace> \
  <docker_image> \
  <cpu_request> <cpu_limit> \
  <memory_request> <memory_limit> \
  <port>
```

**Example:**
```bash
./deploy.sh deploy \
  demo-app demo \
  nginx:1.25 \
  100m 200m \
  128Mi 256Mi \
  80
```

> Creates:
> - Kubernetes Deployment
> - Service (ClusterIP)
> - KEDA-based `ScaledObject` for CPU autoscaling

---

###  4. Check Health of a Deployment

```bash
./deploy.sh check-health <deployment_name> <namespace>
```

**Example:**
```bash
./deploy.sh check-health demo-app demo
```

> Outputs:
> - Deployment status
> - Pod status
> - CPU and memory usage (if metrics server is enabled)
> - Recent warnings/events per pod

---

##  Design Decisions

- **Modular Architecture:** Each script is isolated by function to improve reuse and testing.
- **Scalable Inputs:** All scripts are parameterized to support various deployment setups.
- **Event-Driven Autoscaling:** KEDA is used for future-ready scaling needs (currently uses CPU-based scaler).
- **Namespace-Aware:** All resources are created and queried in user-defined namespaces.

---

##  Security & Best Practices

- Avoid hardcoding sensitive values — prefer secrets or ConfigMaps for production.
- Use role-based access control (RBAC) in real deployments.
- Validate image sources and restrict service exposure as needed.

---

##  Demo & Output Examples

You may include screenshots of:
- `kubectl get all -n demo`
- KEDA `ScaledObject` YAML
- `kubectl top pods`
- `kubectl describe pod <pod>`

---

##  Optional Enhancements

- Integrate into a CI/CD system (e.g., GitHub Actions, ArgoCD)
- Add Kafka or RabbitMQ KEDA scalers
- Support `Helm Chart` based deployments for better templating
- Logging and structured output (e.g., JSON for API responses)

