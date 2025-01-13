gcloud builds submit service-a --tag gcr.io/search-cdo/service-a
gcloud builds submit service-b --tag gcr.io/search-cdo/service-b

# Get Service B URL
SERVICE_B_URL=$(gcloud run services describe service-b --region=europe-west1 --format="value(status.url)")
SERVICE_A_URL=$(gcloud run services describe service-a --region=europe-west1 --format="value(status.url)")

service-a: https://service-a-m7t2o2ljoa-ew.a.run.app
service-b: https://service-b-m7t2o2ljoa-ew.a.run.app

# Deploy Service A
gcloud run deploy service-a \
    --image gcr.io/search-cdo/service-a \
    --platform managed \
    --allow-unauthenticated \
    --region europe-west1 \
    --set-env-vars SERVICE_B_URL=$SERVICE_B_URL

# Deploy Service B
gcloud run deploy service-b \
    --image gcr.io/search-cdo/service-b \
    --platform managed \
    --allow-unauthenticated \
    --region europe-west1 \
    --set-env-vars SERVICE_A_URL=$SERVICE_A_URL


# Get ID token
TOKEN=$(gcloud auth print-identity-token)

# Test Service A
curl -X POST \
   https://service-a-13142871829.europe-west1.run.app/send-to-b \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Test from curl"}'

# Test Service B
curl -X POST \
  https://service-b-13142871829.europe-west1.run.app/send-to-a \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Test from curl"}'
