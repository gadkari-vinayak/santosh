steps:
  # build the container image
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/santosh', '.']
  # push the container image to Container Registry
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/santosh:$SHORT_SHA']

# This step generates the new manifest
- name: 'gcr.io/cloud-builders/gcloud'
  id: Generate manifest
  entrypoint: /bin/sh
  args:
  - '-c'
  - |
     sed "s/GOOGLE_CLOUD_PROJECT/${PROJECT_ID}/g" cloudrun/cloudbuild.yaml.tpl | \
     sed "s/latest/${SHORT_SHA}/g" > cloudrun/cloudbuild.yaml

# Deploy container image to Cloud Run
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'run', 'deploy', '--image', 'gcr.io/$PROJECT_ID/santosh:latest', '--region', 'us-central1', '--platform', 'managed']
images:
- 'gcr.io/$PROJECT_ID/santosh:latest'
