# aikeysforenterprise# 

# 🛡️ Project Shield: Zero-Trust AI Development#

This repository contains the infrastructure-as-code required to securely govern AI API keys (Claude/OpenAI) on Red Hat OpenShift using External Secrets and Dev Spaces.

## 🚀 Set up as a Cluster Admin user playing the ANTHROPIC keys Owner

### Admin - 1. Initialize the Vault
Create the restricted namespace and add your master keys.
```bash
oc new-project project-shield-hub
oc create secret generic ai-shield-master-creds --from-literal=ANTHROPIC_API_KEY=sk-ant-xxx -n project-shield-hub
```
### Admin - 2. Deploy the Governance Layer
```bash
oc apply -f 01-shield-sa.yaml
oc apply -f 02-shield-rbac.yaml
oc apply -f 03-cluster-store.yaml
```
## 👨‍💻 Developer Onboarding (user1)
As a developer create the devworkspace. This will create a namespace like users-devspaces
```
https://devspaces.apps.<CLUSTER_ID>.<CLUSTER_DOMAIN>/#https://github.com/jmaira-redhat/aicodersheild.git?name=ai-shield-alpha
```
### Admin - 3. Deploy the User Bridge
Target the user's runtime namespace
```bash
oc get namespaces | grep user1-devspaces
# (Let's assume it is user1-devspaces for the commands below).
oc apply -f 04-external-secret.yaml - user1-devspaces
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
watch oc get devworkspace ai-shield-alpha -n project-shield-userws
oc get pods -n project-shield-userws -w
```

### 6. Delegate access to projec to a developer user user1
Provide Namespace access to the developer
```bash
# 1. Grant 'edit' to the project namespace (where the workspace lives)
oc adm policy add-role-to-user edit user1 -n project-shield-userws

# 2. Verify the 'Shield' is holding (should return 'no')
oc auth can-i get secrets -n project-shield-hub --as user1
```
## 👨‍💻 Developer Onboarding (user1)
Once the Admin has provisioned the environment, follow these steps to access your secure AI workspace.
### 1. Access the Workspace
The Project Lead will provide a unique URL for your pre-provisioned workspace. 
* **URL Format:** `https://<devspaces-host>/#/workspaces/project-shield-userws/ai-shield-alpha`
### 2. Login & Authenticate
1. Open the URL in an **Incognito/Private window**.
2. Log in with your OpenShift credentials (Username: `user1`).
3. If prompted, click **Allow** to authorize the Dev Spaces client.

### 3. Verify the AI Shield
Open a terminal inside the IDE (Terminal -> New Terminal) and run the verification suite:

```bash
# Check if the Claude CLI is ready
claude --version

# Check if the Anthropic API Key is securely injected
if [[ -n "$ANTHROPIC_API_KEY" ]]; then
  echo "✅ Project Shield Active. Ready to code."
else
  echo "❌ Shield Error: API Key missing. Contact your Admin."
fi

