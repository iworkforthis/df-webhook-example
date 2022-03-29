#SET Project Name
export NetProject=prj-example-1
gcloud config set project $NetProject

export NetProjectID=$(gcloud projects list | grep $NetProject | awk '{print $NF}')



gcloud service-directory endpoints delete lb-direct --location=us-east1 --namespace=df-example --service=load-balancer -q
gcloud compute firewall-rules delete fw-allow-proxies-3000 --project=$NetProject -q
gcloud compute firewall-rules delete fw-allow-health-check --project=$NetProject -q
gcloud beta compute forwarding-rules delete fdw-rule-df-webhook --region=us-east1 -q
gcloud compute target-https-proxies delete target-proxy-df-webhook --region=us-east1 -q
gcloud compute ssl-certificates delete ssl-cert-webhook --region=us-east1 -q
gcloud compute url-maps delete url-map-webhook  --region=us-east1  --project=$NetProject -q
gcloud compute backend-services remove-backend be-service-webhook --network-endpoint-group=df-webhook-neg --network-endpoint-group-zone=us-east1-b  --region=us-east1 -q
gcloud compute backend-services delete be-service-webhook --region=us-east1 -q
gcloud compute health-checks delete hc-df-webhook  --region=us-east1 --project=$NetProject -q
gcloud compute firewall-rules delete fw-allow-3000-from-google --project=$NetProject -q
gcloud compute firewall-rules delete fw-allow-node-port-443 --project=$NetProject -q 
gcloud compute firewall-rules delete fw-allow-node-port-32513 --project=$NetProject -q
gcloud service-directory endpoints delete svc-direct --location=us-east1 --namespace=df-example --service=svc-direct -q
gcloud service-directory endpoints delete pod-direct --location=us-east1 --namespace=df-example --service=pod-direct  -q
gcloud service-directory endpoints delete node2 --location=us-east1 --namespace=df-example --service=node-port -q
gcloud service-directory endpoints delete node1 --location=us-east1 --namespace=df-example --service=node-port -q
gcloud service-directory services delete load-balancer --location=us-east1 --namespace=df-example -q
gcloud service-directory services delete node-port --location=us-east1 --namespace=df-example -q 
gcloud service-directory services delete pod-direct --location=us-east1 --namespace=df-example -q
gcloud service-directory services delete svc-direct --location=us-east1 --namespace=df-example -q
gcloud service-directory namespaces delete df-example --location=us-east1 -q

gcloud beta container --project $NetProject clusters delete "dev-cluster" --zone "us-east1-b" -q

gcloud compute --project=$NetProject firewall-rules delete allow-ssh -q
gcloud compute networks subnets delete proxy-only-subnet --region=us-east1 --project=$NetProject -q
gcloud compute networks subnets delete subnet-nodes --region=us-east1 --project=$NetProject -q
gcloud compute networks delete vpc-eng-1 --project=$NetProject -q


gcloud projects remove-iam-policy-binding $NetProjectID --member=serviceAccount:service-$NetProjectID@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.pscAuthorizedService 
gcloud projects remove-iam-policy-binding $NetProjectID --member=serviceAccount:service-$NetProjectID@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.networkAttacher 
gcloud projects remove-iam-policy-binding $NetProjectID --member=serviceAccount:service-$NetProjectID@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.viewer 

gcloud projects get-iam-policy $NetProjectID --format=yaml 

gcloud services disable dialogflow.googleapis.com
gcloud services disable servicedirectory.googleapis.com
gcloud services disable container.googleapis.com
gcloud services disable compute.googleapis.com
gcloud services disable containerregistry.googleapis.com
