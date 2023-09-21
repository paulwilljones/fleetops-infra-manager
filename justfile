set export
PROJECT_ID := "jetstack-paul"
GSA := "gsa-infra-mgr"
IP := `curl ifconfig.me`

plan:
    just terraform/plan

lint:
    just terraform/lint

apply:
    just terraform/apply

deploy-local:
    gcloud alpha infra-manager deployments apply \
        projects/{{PROJECT_ID}}/locations/us-central1/deployments/fleetops \
        --service-account projects/{{PROJECT_ID}}/serviceAccounts/{{GSA}}@{{PROJECT_ID}}.iam.gserviceaccount.com \
        --ignore-file=".gcloudignore" --local-source="terraform" \
        --input-values=resource_prefix=local,region=europe-west2,zone=europe-west2-a,master_authorized_range={{IP}}/32

deploy:
    gcloud alpha infra-manager deployments apply \
        projects/{{PROJECT_ID}}/locations/us-central1/deployments/fleetops \
        --service-account=projects/{{PROJECT_ID}}/serviceAccounts/{{GSA}}@{{PROJECT_ID}}.iam.gserviceaccount.com \
        --git-source-repo=https://github.com/paulwilljones/fleetops-infra-manager \
        --git-source-directory=terraform \
        --git-source-ref=develop \
        --input-values=resource_prefix=fleetops,region=europe-west2,zone=europe-west2-a,master_authorized_range={{IP}}/32

delete:
    gcloud alpha infra-manager deployments delete projects/{{PROJECT_ID}}/locations/us-central1/deployments/fleetops
