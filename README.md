Cloud Build CI/CD setup steps.
Source: https://cloud.google.com/build/docs/deploy-containerized-application-cloud-run

1.
PROJECT_ID=$(gcloud config list --format='value(core.project)')
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

2.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
    --role=roles/run.admin

3. gcloud iam service-accounts add-iam-policy-binding \
    $PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

4.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/storage.admin"

5.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/artifactregistry.writer"

6.
gcloud iam service-accounts add-iam-policy-binding $(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/iam.serviceAccountUser" \
    --project=$PROJECT_ID

7. Add substitution variables manually on gcloud build trigger or via:

gcloud beta builds triggers update cicd-trigger-test-cr-connection \
    --substitutions=_SERVICE_B_URL="https://service-b-13142871829.europe-west1.run.app"

gcloud beta builds triggers update cicd-trigger-test-cr-connection \
    --substitutions=_SERVICE_A_URL="https://service-a-13142871829.europe-west1.run.app"

8.
gcloud beta builds triggers update cicd-trigger-test-cr-connection --include-github-status-checks


[![Build Status](https://storage.googleapis.com/cloud-build-badges/search-cdo/cicd-trigger-test-cr-connection.svg)](https://console.cloud.google.com/cloud-build/builds?project=search-cdo)