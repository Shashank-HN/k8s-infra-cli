#!/bin/bash

set -e

# import function script
#
source "$(dirname "$0")/functions/cluster_setup.sh"
source "$(dirname "$0")/functions/install_keda.sh"
source "$(dirname "$0")/functions/create_deployment.sh"
source "$(dirname "$0")/functions/health_check.sh"

#help menu
show_help() {
echo "Usage: $0 [command]"
echo ""
echo "Commands:"
echo "  setup                 Connect to cluster and install tools"
echo "  install-keda          Install KEDA using Helm"
echo "  create-deployment     Create a deployment with KEDA scaling"
echo "  check-health          Check health of a given deployment"
echo "  help                  Show this help message"
}

# Command switch
case "$1" in
  setup)
    setup_cluster
    ;;
  install-keda)
    install_keda
    ;;
  create-deployment)
    create_deployment
    ;;
  check-health)
     check_health_status "$2" "$3"
     ;;
  *)
    echo "Usage: $0 {setup|install-keda|create-deployment}"
    ;;
esac
