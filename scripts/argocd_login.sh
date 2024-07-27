#!/bin/bash
# Check if ArgoCD server is up
echo "Waiting for ArgoCD server to be ready..."
for i in {1..20}; do
ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname')
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  if curl -k -s --head --request GET https://$ARGOCD_SERVER | grep "200 OK" > /dev/null; then
    echo "ArgoCD server is ready."
    argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure
    break
  else
    echo "ArgoCD server not ready yet, retrying in 10 seconds..."
    sleep 20
  fi
done

# Output the variables
echo "ARGOCD_SERVER=$ARGOCD_SERVER"
echo "ARGO_PWD=$ARGO_PWD"
