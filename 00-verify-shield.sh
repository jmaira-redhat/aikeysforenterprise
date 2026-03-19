#!/bin/bash

# Configuration - Update these to match your setup
HUB_NS="project-shield-hub"
USER_NS="user1-devspaces"
STORE_NAME="project-shield-vault"
SECRET_NAME="ai-creds"

echo "🔍 Starting Project Shield Pre-Flight Check..."
echo "-----------------------------------------------"

# 1. Check Hub Namespace & Master Secret
echo "✅  Developer Workspace Generated Namespace is $USER_NS"
if oc get secret ai-shield-master-creds -n $HUB_NS &> /dev/null; then
    echo "✅ [HUB] Master Secret found in $HUB_NS"
else
    echo "❌ [HUB] Master Secret MISSING in $HUB_NS"
    exit 1
fi

# 2. Check ClusterSecretStore Status
STORE_STATUS=$(oc get clustersecretstore $STORE_NAME -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
if [ "$STORE_STATUS" == "True" ]; then
    echo "✅ [BRIDGE] ClusterSecretStore '$STORE_NAME' is READY"
else
    echo "❌ [BRIDGE] ClusterSecretStore '$STORE_NAME' is NOT READY or MISSING"
    exit 1
fi

# 3. Check ExternalSecret & Local Secret in User Workspace
if oc get secret $SECRET_NAME -n $USER_NS &> /dev/null; then
    echo "✅ [USER] Local Secret '$SECRET_NAME' has been synchronized"
else
    echo "⏳ [USER] Waiting for ExternalSecret to sync... (Check operator logs if this persists)"
    exit 1
fi

# 4. Verify Labels (The "Magic" for Dev Spaces)
MOUNT_LABEL=$(oc get secret $SECRET_NAME -n $USER_NS -o jsonpath='{.metadata.labels.controller\.devfile\.io/mount-to-devworkspace}')
WATCH_LABEL=$(oc get secret $SECRET_NAME -n $USER_NS -o jsonpath='{.metadata.labels.controller\.devfile\.io/watch-secret}')

if [ "$MOUNT_LABEL" == "true" ] && [ "$WATCH_LABEL" == "true" ]; then
    echo "✅ [METADATA] Injection Labels are CORRECT"
else
    echo "❌ [METADATA] Injection Labels are MISSING or WRONG"
    exit 1
fi

# 5. Verify Annotations (The Environment Variable Injection)
MOUNT_ANN=$(oc get secret $SECRET_NAME -n $USER_NS -o jsonpath='{.metadata.annotations.controller\.devfile\.io/mount-as}')
if [ "$MOUNT_ANN" == "env" ]; then
    echo "✅ [METADATA] Injection Annotation is CORRECT"
else
    echo "❌ [METADATA] Injection Annotation is MISSING (Keys won't be Env Vars)"
    exit 1
fi

echo "-----------------------------------------------"
echo "🚀 SHIELD VERIFIED: Safe to launch 05-dev-workspace.yaml"