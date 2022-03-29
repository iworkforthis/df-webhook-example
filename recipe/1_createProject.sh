#SET Project Name
export NetProject=prj-example-1


#####PROJECT CREATION#############
#Create Project
#gcloud projects create $NetProject --name="example df prj"
#Set Project
gcloud config set project $NetProject
#BILLING MUST BE ENABLED

export NetProjectID=$(gcloud projects list | grep $NetProject | awk '{print $NF}')

ECHO Enabling Services
gcloud services enable containerregistry.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicedirectory.googleapis.com
gcloud services enable dialogflow.googleapis.com

####################################

gcloud projects add-iam-policy-binding $NetProjectID --member=serviceAccount:service-1072955330992@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.pscAuthorizedService 
gcloud projects add-iam-policy-binding $NetProjectID --member=serviceAccount:service-1072955330992@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.networkAttacher 
gcloud projects add-iam-policy-binding $NetProjectID --member=serviceAccount:service-1072955330992@gcp-sa-dialogflow.iam.gserviceaccount.com --role=roles/servicedirectory.viewer 

gcloud projects get-iam-policy $NetProjectID --format=yaml 
