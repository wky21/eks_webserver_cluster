
#!/bin/bash

set -e

echo "🧹 Cleaning up Demo App from EKS Cluster..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if kubectl is configured
echo -e "${BLUE}Checking kubectl configuration...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ kubectl is not configured or cluster is not accessible${NC}"
    exit 1
fi

echo -e "${GREEN}✅ kubectl is configured${NC}"

# Delete the demo application
echo -e "${BLUE}Removing demo application...${NC}"
kubectl delete -f k8s/demo-app.yaml --ignore-not-found=true

# Wait for resources to be cleaned up
echo -e "${BLUE}Waiting for resources to be cleaned up...${NC}"
sleep 10

# Verify cleanup
echo -e "${BLUE}Verifying cleanup...${NC}"
remaining_pods=$(kubectl get pods -l app=nginx-hello-world --no-headers 2>/dev/null | wc -l)
remaining_services=$(kubectl get services nginx-hello-world-service --no-headers 2>/dev/null | wc -l)

if [ "$remaining_pods" -eq 0 ] && [ "$remaining_services" -eq 0 ]; then
    echo -e "${GREEN}✅ Demo app successfully removed!${NC}"
else
    echo -e "${YELLOW}⚠️  Some resources may still be terminating...${NC}"
    kubectl get pods,services -l app=nginx-hello-world
fi

echo ""
echo -e "${GREEN}🎉 Cleanup complete!${NC}"
echo -e "${BLUE}The LoadBalancer has been deleted, so you're no longer paying for it.${NC}"
echo ""
echo -e "${RED}💰 Don't forget to run 'terraform destroy' to clean up the entire EKS cluster!${NC}"
