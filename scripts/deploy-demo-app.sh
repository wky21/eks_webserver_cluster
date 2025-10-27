
#!/bin/bash

set -e

echo "🚀 Deploying Demo App to EKS Cluster..."

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
    echo -e "${YELLOW}Please run: aws eks update-kubeconfig --region us-east-1 --name eks-test-cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ kubectl is configured${NC}"

# Check cluster status
echo -e "${BLUE}Checking cluster status...${NC}"
kubectl get nodes

# Deploy the demo application
echo -e "${BLUE}Deploying demo application...${NC}"
kubectl apply -f k8s/demo-app.yaml

# Wait for deployment to be ready
echo -e "${BLUE}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/nginx-hello-world --timeout=300s

# Get service information
echo -e "${BLUE}Getting service information...${NC}"
kubectl get services nginx-hello-world-service

# Wait for LoadBalancer to get external IP
echo -e "${BLUE}Waiting for LoadBalancer to get external IP (this may take 2-3 minutes)...${NC}"
echo -e "${YELLOW}Note: This creates an AWS Application Load Balancer which costs ~$0.0225/hour${NC}"

# Function to get external IP
get_external_ip() {
    kubectl get service nginx-hello-world-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo ""
}

# Wait up to 5 minutes for external IP
timeout=300
elapsed=0
while [ $elapsed -lt $timeout ]; do
    external_ip=$(get_external_ip)
    if [ -n "$external_ip" ] && [ "$external_ip" != "null" ]; then
        echo -e "${GREEN}✅ LoadBalancer is ready!${NC}"
        echo -e "${GREEN}🌐 Your demo app is available at: http://$external_ip${NC}"
        echo ""
        echo -e "${BLUE}Testing the endpoint...${NC}"
        if curl -s "http://$external_ip" > /dev/null; then
            echo -e "${GREEN}✅ Demo app is responding successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️  LoadBalancer is ready but app might still be starting up${NC}"
            echo -e "${YELLOW}   Try accessing http://$external_ip in a few moments${NC}"
        fi
        break
    fi
    echo -e "${YELLOW}⏳ Still waiting for external IP... (${elapsed}s/${timeout}s)${NC}"
    sleep 10
    elapsed=$((elapsed + 10))
done

if [ $elapsed -ge $timeout ]; then
    echo -e "${RED}❌ Timeout waiting for LoadBalancer external IP${NC}"
    echo -e "${YELLOW}You can check the status with: kubectl get service nginx-hello-world-service${NC}"
fi

echo ""
echo -e "${BLUE}📊 Cluster Resources:${NC}"
kubectl get pods,services,deployments

echo ""
echo -e "${GREEN}🎉 Demo app deployment complete!${NC}"
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  View pods: ${YELLOW}kubectl get pods${NC}"
echo -e "  View services: ${YELLOW}kubectl get services${NC}"
echo -e "  View logs: ${YELLOW}kubectl logs -l app=nginx-hello-world${NC}"
echo -e "  Scale app: ${YELLOW}kubectl scale deployment nginx-hello-world --replicas=3${NC}"
echo ""
echo -e "${RED}💰 Cost Reminder: Don't forget to run 'terraform destroy' when done testing!${NC}"
