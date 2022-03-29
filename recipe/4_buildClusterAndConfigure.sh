#SET Project Name
export NetProject=prj-example-1
gcloud config set project $NetProject
export NetProjectID=$(gcloud projects list | grep $NetProject | awk '{print $NF}')


gcloud beta container --project $NetProject clusters create "dev-cluster" --zone "us-east1-b" --no-enable-basic-auth --cluster-version "1.21.9-gke.1002" --release-channel "regular" --machine-type "e2-micro" \
     --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true \
     --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
     --max-pods-per-node "110" --num-nodes "2" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-private-nodes --master-ipv4-cidr "10.0.0.0/28" --enable-master-global-access --enable-ip-alias \
     --network vpc-eng-1 --subnetwork subnet-nodes --cluster-secondary-range-name subnet-pods --services-secondary-range-name subnet-services \
     --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
     --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --tags "dev-cluster" --node-locations "us-east1-b"


gcloud container clusters get-credentials dev-cluster --zone us-east1-b --project $NetProject
kubectl config set-context --current --namespace=odyssey
kubectl apply -f namespace.json
kubectl apply -f ../df-webhook/config/deployment.yaml
kubectl apply -f ../df-webhook/config/service.yaml
kubectl apply -f ../nginxproxy/config/dfbridge-deployment.yaml
kubectl apply -f ../nginxproxy/config/dfbridge-service.yaml
kubectl apply -f ../nginxproxy/config/dfbridge-service-np.yaml

gcloud service-directory namespaces create df-example --location=us-east1
gcloud service-directory services create load-balancer --location=us-east1 --namespace=df-example
gcloud service-directory services create node-port --location=us-east1 --namespace=df-example
gcloud service-directory services create pod-direct --location=us-east1 --namespace=df-example
gcloud service-directory services create svc-direct --location=us-east1 --namespace=df-example

echo ####run this FOR each IP ADDRESS LISTED
echo gcloud service-directory endpoints create node1 --location=us-east1 --namespace=df-example --service=node-port  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.10.1.2 --port=32513
kubectl get nodes -o yaml | grep 'address'

gcloud service-directory endpoints create node1 --location=us-east1 --namespace=df-example --service=node-port  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.10.1.2 --port=32513
gcloud service-directory endpoints create node2 --location=us-east1 --namespace=df-example --service=node-port  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.10.1.3 --port=32513
gcloud service-directory endpoints create pod-direct --location=us-east1 --namespace=df-example --service=pod-direct  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.20.0.8 --port=443
gcloud service-directory endpoints create svc-direct --location=us-east1 --namespace=df-example --service=svc-direct  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.30.2.35 --port=443

gcloud compute firewall-rules create fw-allow-node-port-32513 \
     --network=vpc-eng-1 \
     --action=allow \
     --direction=ingress \
     --source-ranges=35.199.192.0/19 \
     --target-tags=dev-cluster \
     --rules=tcp:32513 \
     --priority=200 \
     --project=$NetProject

gcloud compute firewall-rules create fw-allow-node-port-443 \
     --network=vpc-eng-1 \
     --action=allow \
     --direction=ingress \
     --source-ranges=35.199.192.0/19 \
     --target-tags=dev-cluster \
     --rules=tcp:443 \
     --priority=200 \
     --project=$NetProject

gcloud compute firewall-rules create fw-allow-3000-from-google \
     --network=vpc-eng-1 \
     --action=allow \
     --direction=ingress \
     --source-ranges=35.199.192.0/19 \
     --target-tags=dev-cluster \
     --rules=tcp:3000 \
     --project=$NetProject