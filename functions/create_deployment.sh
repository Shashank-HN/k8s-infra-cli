#!/bin/bash

# Function to create deployment, service, and KEDA scaling
create_deployment() {
 local app_name="demo-app"
 local namespace="demo"
 local image="nginx:1.25"
 local port="80"

 echo "🚀 Creating namespace $namespace (if not exists)..."
 kubectl get ns "$namespace" >/dev/null 2>&1 || kubectl create ns "$namespace"

 # Creating deployment.yaml
 echo "📦 Creating deployment for $app_name..."
 cat <<EOF | kubectl apply -n "$namespace" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $app_name
  template:
    metadata:
      labels:
        app: $app_name
    spec:
      containers:
      - name: $app_name
        image: $image
        ports:
        - containerPort: $port
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
EOF

# Creating service.yaml
  echo "🔗 Creating service for $app_name..."
  cat <<EOF | kubectl apply -n "$namespace" -f -
apiVersion: v1
kind: Service
metadata:
  name: ${app_name}-svc
spec:
  selector:
    app: $app_name
  ports:
  - protocol: TCP
    port: 80
    targetPort: $port
  type: ClusterIP
EOF

# Creating KEDA scaled object
  echo "📈 Creating KEDA ScaledObject (sample CPU scaler)..."
  cat <<EOF | kubectl apply -n "$namespace" -f -
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ${app_name}-scaler
spec:
  scaleTargetRef:
    name: $app_name
  minReplicaCount: 1
  maxReplicaCount: 5
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "50"
EOF

  echo "✅ Deployment created:"
kubectl get deployment -n "$namespace" "$app_name"
kubectl get service -n "$namespace" "${app_name}-svc"
kubectl get scaledobject.keda.sh -n "$namespace"
}
