1. VPC and subnets creation

2. Update service with network
# Update service-a to use VPC
gcloud run services update service-a \
    --region=europe-west1 \
    --network=vpc-sos-dashboard \
    --subnet=vpc-sos-dashboard-subnet \
    --ingress=internal \
    --platform=managed \
    --project=search-cdo

gcloud run services update service-b \
    --region=europe-west1 \
    --network=vpc-sos-dashboard \
    --subnet=vpc-sos-dashboard-subnet \
    --ingress=internal \
    --platform=managed \
    --project=search-cdo

3. Allow service-a to invoke service-b (already the case for existing SA)
gcloud run services add-iam-policy-binding service-b \
    --region=REGION \
    --member="serviceAccount:service-a@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

4. Grant permissions to use network (in this case only the default SA)
gcloud projects add-iam-policy-binding search-cdo \
    --member="serviceAccount:13142871829-compute@developer.gserviceaccount.com" \
    --role="roles/compute.networkUser"

5. Explicit internal address - http://service-a.internal and http://service-b.internal