#SET Project Name
export NetProject=prj-example-1
gcloud config set project $NetProject

gcloud compute health-checks create http hc-df-webhook --region=us-east1 --use-serving-port --request-path="/" --project=$NetProject
gcloud compute backend-services create be-service-webhook --load-balancing-scheme=INTERNAL_MANAGED --protocol=HTTP --health-checks=hc-df-webhook --health-checks-region=us-east1 --region=us-east1
gcloud compute backend-services add-backend be-service-webhook --network-endpoint-group=df-webhook-neg --network-endpoint-group-zone=us-east1-b  --region=us-east1 --balancing-mode=RATE --max-rate-per-endpoint=10
gcloud compute url-maps create url-map-webhook --default-service=be-service-webhook --region=us-east1  --project=$NetProject

export LB_CERT=./combine.pem
export LB_PRIVATE_KEY=./myPrivate.key

gcloud compute ssl-certificates create ssl-cert-webhook --certificate=$LB_CERT --private-key=$LB_PRIVATE_KEY --region=us-east1   --project=$NetProject
gcloud compute target-https-proxies create target-proxy-df-webhook --url-map=url-map-webhook --region=us-east1 --ssl-certificates=ssl-cert-webhook --project=$NetProject

gcloud beta compute forwarding-rules create fdw-rule-df-webhook --load-balancing-scheme=INTERNAL_MANAGED --network=vpc-eng-1 \
    --subnet=subnet-nodes --address=10.10.1.200 --ports=443 --region=us-east1 --target-https-proxy=target-proxy-df-webhook \
    --target-https-proxy-region=us-east1  --service-directory-registration=projects/$NetProject/locations/us-east1/namespaces/df-example/services/load-balancer  \
    --project=$NetProject

gcloud compute firewall-rules create fw-allow-health-check \
    --network=vpc-eng-1 \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=dev-cluster \
    --rules=tcp \
    --project=$NetProject

gcloud compute firewall-rules create fw-allow-proxies-3000 \
     --network=vpc-eng-1 \
     --action=allow \
     --direction=ingress \
     --source-ranges=10.100.0.0/24 \
     --target-tags=dev-cluster \
     --rules=tcp:3000 \
     --project=$NetProject

gcloud service-directory endpoints create lb-direct --location=us-east1 --namespace=df-example --service=load-balancer  --network=projects/$NetProjectID/locations/global/networks/vpc-eng-1 --address=10.10.1.200 --port=443

