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

## Visibility

```sh
$ gcloud alpha infra-manager revisions list --deployment fleetops --location us-central1
NAME  STATE    CREATE_TIME                     UPDATE_TIME
r-0   FAILED   2023-09-21T07:53:00.216255677Z  2023-09-21T07:53:42.603819435Z
r-1   APPLIED  2023-09-21T08:41:14.495558437Z  2023-09-21T08:48:43.072067538Z
```

```sh
$ gcloud alpha infra-manager revisions describe r-9 --deployment fleetops --location us-central1
action: UPDATE
applyResults:
  artifacts: gs://993897508389-us-central1-blueprint-config/fleetops/r-9/apply_results/artifacts
  content: gs://993897508389-us-central1-blueprint-config/fleetops/r-9/apply_results/content
build: cfd8b51a-1f41-4cc3-8f80-ae00fca5cb51
createTime: '2023-09-21T15:16:43.227724235Z'
logs: gs://993897508389-us-central1-blueprint-config/fleetops/r-9/logs
name: projects/jetstack-paul/locations/us-central1/deployments/fleetops/revisions/r-9
serviceAccount: projects/jetstack-paul/serviceAccounts/gsa-infra-mgr@jetstack-paul.iam.gserviceaccount.com
state: APPLIED
stateDetail: revision applied
terraformBlueprint:
  gitSource:
    directory: terraform
    ref: develop
    repo: https://github.com/paulwilljones/fleetops-infra-manager
  inputValues:
    master_authorized_range:
      inputValue: 77.100.71.101/32
    region:
      inputValue: europe-west2
    resource_prefix:
      inputValue: fleetops
    zone:
      inputValue: europe-west2-a
updateTime: '2023-09-21T15:24:03.541779142Z'
```

```sh
$ gcloud alpha infra-manager resources list --deployment fleetops --location us-central1 --revision r-9
NAME                         STATE
compute-network-opbryzi1     RECONCILED
compute-subnetwork-a4thlfgh  RECONCILED
compute-subnetwork-dhwpvw5q  RECONCILED
container-cluster-69ewvznp   RECONCILED
```

```sh
$ gcloud alpha infra-manager resources describe container-cluster-69ewvznp --deployment fleetops --location us-central1 --revision r-9
caiAssets:
  container.googleapis.com/Cluster:
    fullResourceName: //container.googleapis.com/projects/jetstack-paul/locations/europe-west2-a/clusters/gke-fleetops-kcc-euw2
intent: CREATE
name: projects/jetstack-paul/locations/us-central1/deployments/fleetops/revisions/r-9/resources/container-cluster-69ewvznp
state: RECONCILED
terraformInfo:
  address: google_container_cluster.cluster
  id: projects/jetstack-paul/locations/europe-west2-a/clusters/gke-fleetops-kcc-euw2
  type: google_container_cluster
```
