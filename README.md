# aikeysforenterprise# 

🛡️ Project Shield: Zero-Trust AI Development

This repository contains the infrastructure-as-code required to securely govern AI API keys (Claude/OpenAI) on Red Hat OpenShift using External Secrets and Dev Spaces.

## 🚀 Quick Start (Admin)

### 1. Initialize the Vault
Create the restricted namespace and add your master keys.
```bash
oc new-project project-shield-hub
oc create secret generic ai-shield-master-creds --from-literal=ANTHROPIC_API_KEY=sk-ant-xxx -n project-shield-hub
```
### 2. Deploy the Governance Layer
```bash
oc apply -f 01-shield-sa.yaml
oc apply -f 02-shield-rbac.yaml
oc apply -f 03-cluster-store.yaml
```

### 3. Deploy the User Bridge
Target the user's runtime namespace
```bash
oc new-project roject-shield-userws
oc apply -f 04-external-secret.yaml
oc apply -f 05-dev-workspace.yaml
```