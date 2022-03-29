#SET Project Name
export NetProject=prj-example-1
gcloud config set project $NetProject

echo "GENERATE THE CA KEY"
openssl genrsa -des3 -out CAPrivate.key 2048
echo "SIGN the Root CA Certificate (create the cert)"
openssl req -x509 -new -nodes -key CAPrivate.key -sha256 -days 3650 -out CAPrivate.pem -subj "/C=US/ST=OH/L=Brunswick/O=Dialogflow Testing/OU=Engineering/CN=*.df-webhook.org"
echo "GENERATE private key for server"
openssl genrsa -out myPrivate.key 2048
echo "Generate Certificate Request"
openssl req -new -sha256 -nodes -key myPrivate.key -subj "/C=US/ST=OH/L=Brunswick/O=Dialogflow Testing/OU=Engineering/CN=api.df-webhook.org" -out myCert.csr -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:api.df-webhook.org")) 
echo "SIGN the Certificate using the root CA  (Create the certificate)"
openssl x509 -req -days 3650 -in myCert.csr -CA CAPrivate.pem -CAkey CAPrivate.key -CAcreateserial -out myCert.pem -sha256  -extfile <(printf "\nsubjectAltName='DNS:api.df-webhook.org'")
echo "Verify Cert Contents"
openssl x509 -in myCert.pem -text -noout
echo "Create Combined Cert"
cat myCert.pem CAPrivate.pem  > combine.pem
echo "Verify Cert Contents"
openssl x509 -in combine.pem -text -noout
echo "Create a DER version of the Certificate"
openssl x509  -inform PEM -in myCert.pem -out myCert.der -outform DER
echo "create a DER version of the CA Cert"
openssl x509  -inform PEM -in CAPrivate.pem -out CAPrivate.der -outform DER

echo "Copying Certs to Bridge"
rm ../nginxproxy/nginx/ssl/*
cp *.pem ../nginxproxy/nginx/ssl
cp *.key ../nginxproxy/nginx/ssl
cp *.der ../nginxproxy/ca

echo "NPM Installing df-webhook"
cd ../df-webhook/server
npm install
cd ../../recipe

echo "Docker Building df-webhook"
docker build -t df-webhook:1.3 -f ../df-webhook/ci/Dockerfile ../df-webhook
echo "Docker Building df-bridge"
docker build -t df-bridge:1.12 -f ../nginxproxy/ci/Dockerfile ../nginxproxy
echo "Docker Tag and push"
gcloud auth configure-docker

docker tag df-webhook:1.3 us.gcr.io/$NetProject/df-webhook:1.3
docker push us.gcr.io/$NetProject/df-webhook:1.3
docker tag df-bridge:1.12 us.gcr.io/$NetProject/df-bridge:1.12
docker push us.gcr.io/$NetProject/df-bridge:1.12