#SET Project Name
export NetProject=prj-example-1
gcloud config set project $NetProject



gcloud compute networks create vpc-eng-1 --project=$NetProject --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

gcloud compute networks subnets create subnet-nodes --project=$NetProject --range=10.10.1.0/24 --network=vpc-eng-1 --region=us-east1 --secondary-range=subnet-pods=10.20.0.0/20,subnet-services=10.30.0.0/22

gcloud compute networks subnets create proxy-only-subnet \
    --project=$NetProject \
    --purpose=INTERNAL_HTTPS_LOAD_BALANCER \
    --role=ACTIVE \
    --region=us-east1 \
    --network=vpc-eng-1 \
    --range=10.100.0.0/24


gcloud compute --project=$NetProject firewall-rules create allow-ssh --direction=INGRESS --priority=1000 --network=vpc-eng-1 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0 --priority=100 --target-tags=dev-cluster