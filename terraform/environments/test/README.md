
# EKS Testing Environment

This Terraform configuration creates a cost-optimized EKS cluster for testing purposes.

## Architecture

- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **EKS Cluster**: Kubernetes 1.29 with managed node groups
- **Node Groups**: t3.small spot instances (1-2 nodes)
- **Networking**: Single NAT Gateway for cost optimization

## Cost Optimization Features

1. **Spot Instances**: Uses t3.small spot instances for significant cost savings
2. **Single NAT Gateway**: Shared across all private subnets
3. **Minimal Logging**: Only audit logs with 7-day retention
4. **Small Disk Size**: 20GB GP3 volumes
5. **Two AZs Only**: Reduces NAT Gateway costs
6. **Minimal Node Count**: 1-2 nodes for basic testing

## Quick Start

1. **Initialize Terraform**:
   ```bash
   cd infra/environments/test
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name eks-test-cluster
   ```

5. **Verify the cluster**:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Demo Application

A simple nginx hello-world demo app is included to test your cluster:

### Deploy Demo App

```bash
# Make scripts executable
chmod +x scripts/deploy-demo-app.sh scripts/cleanup-demo-app.sh

# Deploy the demo application
./scripts/deploy-demo-app.sh
```

The script will:
- Deploy a 2-replica nginx hello-world application
- Create an AWS Application Load Balancer (~$0.0225/hour additional cost)
- Provide you with a public URL to test your application
- Show cluster status and useful kubectl commands

### Access Your Demo App

Once deployed, you'll get a URL like:
```
http://your-loadbalancer-url.us-east-1.elb.amazonaws.com
```

The demo app shows:
- Cluster information and status
- Cost breakdown
- Kubernetes deployment details

### Clean Up Demo App

```bash
# Remove just the demo app (keeps EKS cluster running)
./scripts/cleanup-demo-app.sh
```

This removes the demo app and LoadBalancer but keeps your EKS cluster for other testing.

## Easy Teardown

To completely destroy the infrastructure:

```bash
terraform destroy
```

All resources are tagged with `TeardownGroup=eks-test-infrastructure` for easy identification.

## Estimated Monthly Cost

- **EKS Control Plane**: ~$73/month
- **t3.small Spot Instance**: ~$5-7/month (depending on spot pricing)
- **NAT Gateway**: ~$32/month
- **EBS Storage**: ~$2/month (20GB)
- **Data Transfer**: Variable

**Total Estimated Cost**: ~$112-114/month

## Security Considerations

⚠️ **This is a testing environment with relaxed security settings:**

- Public API endpoint is enabled
- Public access from 0.0.0.0/0 (should be restricted in production)
- Spot instances may be terminated unexpectedly

## Customization

You can customize the configuration by modifying the `locals` block in `main.tf`:

- Change instance types
- Adjust node counts
- Modify CIDR blocks
- Update Kubernetes version

## Troubleshooting

1. **Node group creation fails**: Check if you have sufficient spot capacity in the selected AZs
2. **kubectl access denied**: Ensure your AWS credentials match the ones used to create the cluster
3. **High costs**: Verify spot instances are being used and single NAT Gateway is configured

## Clean Up Checklist

Before destroying, ensure:
- [ ] No important workloads are running
- [ ] Persistent volumes are backed up if needed
- [ ] Load balancers created by services are deleted
- [ ] Run `terraform destroy` to clean up all resources
