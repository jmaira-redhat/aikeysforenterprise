# aikeysforenterprise# 🛡️ Project Shield: Zero-Trust AI Development

This repository contains the infrastructure-as-code required to securely govern AI API keys (Claude/OpenAI) on Red Hat OpenShift using External Secrets and Dev Spaces.

## 🚀 Quick Start (Admin)

### 1. Initialize the Vault
Create the restricted namespace and add your master keys.
```bash
oc new-project project-shield-hub
oc create secret generic ai-shield-master-creds --from-literal=ANTHROPIC_API_KEY=sk-ant-xxx -n project-shield-hub