set export
PROJECT_ID := "jetstack-paul"
GSA := "gsa-infra-mgr"
IP := `curl ifconfig.me`

lint:
    just terraform/lint

deploy-local:
    gcloud alpha infra-manager deployments apply \
        projects/{{PROJECT_ID}}/locations/us-central1/deployments/fleetops \
        --service-account projects/{{PROJECT_ID}}/serviceAccounts/{{GSA}}@{{PROJECT_ID}}.iam.gserviceaccount.com \
        --ignore-file=".gcloudignore" \
        --local-source="terraform" \
        --input-values=resource_prefix=local,region=europe-west2,zone=europe-west2-a,master_authorized_range={{IP}}/32 \
        --verbosity=debug

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

plan:
    docker run -it --rm \
        -v ~/.config/gcloud/application_default_credentials.json:/root/.config/gcloud/application_default_credentials.json \
        "gcr.io/cloud-config-sdk/config-sdk-tf:v0.0.96" \
        /usr/local/bin/config-sdk tf plan \
            --backend=im \
            --backend-bucket=gs://993897508389-us-central1-blueprint-config/fleetops/state \
            --deployment=//config.googleapis.com/v1alpha2/projects/jetstack-paul/locations/us-central1/deployments/fleetops  \
            --inputs='{"resource_prefix":"fleetops","region":"europe-west2","zone":"europe-west2-a","master_authorized_range":"{{IP}}/32"}' \
            --output-bucket=gs://993897508389-us-central1-blueprint-config/fleetops/r-999/apply_results \
            --source-git=https://github.com/paulwilljones/fleetops-infra-manager \
            --source-subdir=terraform/ \
            --working-dir=/workspace/plan
