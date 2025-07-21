# infra
devops infrastructure with fleet and crossplane

## Secrets
If you need to add or change external secrets you need to do the following steps:

### Prerequisites
- AWS CLI
- Correct AWS_PROFILE AND AWS_REGION set in the ENV vars
- 1password cli installed and configured (optional for op commands)

### Download the secret file (or use the 1password GUI)

```bash
export PROJECT_NAME=---NAME---
op read --account scientist.1password.com "op://Software Services Group/$PROJECT_NAME-main.json/$PROJECT_NAME-main.json" > $PROJECT_NAME-main.json
```


### Make any edits

### Update the secret

```bash
aws secretsmanager update-secret --region us-west-2 --secret-id main --secret-string file://$PROJECT_NAME-main.json
```

## Selectors

env
 - production
 - staging

name - will match the specific name of a cluster


provider.cattle.io
  - eks
