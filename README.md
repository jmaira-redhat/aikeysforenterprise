# aikeysforenterprise# 

# 🛡️ Project Shield: Zero-Trust AI Development#

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
oc new-project project-shield-userws
oc apply -f 04-external-secret.yaml
```
### 4. The Pre-Flight Gatekeeper
This script checks the Hub, the Store, and the User Workspace to ensure every "link" in the chain is secure.
```
./00-verify-shield.sh
Expected Output
🔍 Starting Project Shield Pre-Flight Check...
-----------------------------------------------
✅ [HUB] Master Secret found in project-shield-hub
✅ [BRIDGE] ClusterSecretStore 'project-shield-vault' is READY
✅ [USER] Local Secret 'ai-creds' has been synchronized
✅ [METADATA] Injection Labels are CORRECT
✅ [METADATA] Injection Annotation is CORRECT
-----------------------------------------------
🚀 SHIELD VERIFIED: Safe to launch 05-dev-workspace.yaml
```
### 5. The Final Launch.
Create a workspace named ai-shield-alpha in this namespace, and use the configuration found in this Git repo.
```bash
oc project project-shield-userws
oc apply -f 05-dev-workspace.yaml
```
