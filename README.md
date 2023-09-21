# fleetops-infra-manager

## Init

```sh
export PROJECT_ID=jetstack-paul
export GSA=gsa-infra-mgr
gcloud services enable config.googleapis.com
gcloud iam service-accounts create ${GSA}
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${GSA}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role=roles/config.agent \
    --condition=None
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${GSA}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/compute.networkAdmin \
    --condition=None
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${GSA}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/container.admin \
    --condition=None
```

## Local Apply

```sh
gcloud alpha infra-manager deployments apply \
    projects/${PROJECT_ID}/locations/us-central1/deployments/fleetops \
    --service-account=projects/${PROJECT_ID}/serviceAccounts/${GSA}@${PROJECT_ID}.iam.gserviceaccount.com \
    --ignore-file=".gcloudignore" \
    --local-source=terraform \
    --input-values=resource_prefix=local,region=europe-west2,zone=europe-west2-a
```

## Remote Apply

```sh
gcloud alpha infra-manager deployments apply \
    projects/${PROJECT_ID}/locations/us-central1/deployments/fleetops \
    --service-account=projects/${PROJECT_ID}/serviceAccounts/${GSA}@${PROJECT_ID}.iam.gserviceaccount.com \
    --git-source-repo=https://github.com/paulwilljones/fleetops-infra-manager \
    --git-source-directory=terraform \
    --git-source-ref=develop \
    --input-values=resource_prefix=fleetops,region=europe-west2,zone=europe-west2-a
```
