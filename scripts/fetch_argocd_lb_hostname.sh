#!/bin/bash

MAX_TRIES=5
TRY_COUNT=0
SLEEP_INTERVAL=20

# Wait for the LoadBalancer to get an external hostname
while [[ $TRY_COUNT -lt $MAX_TRIES ]]; do
  LB_HOSTNAME=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$LB_HOSTNAME" ]; then
    echo "{\"argocd_lb_hostname\": \"$LB_HOSTNAME\"}"  # Only this line outputs to stdout
    exit 0
  else
    >&2 echo "Attempt $((TRY_COUNT+1))/$MAX_TRIES: LoadBalancer hostname not yet available. Retrying in $SLEEP_INTERVAL seconds..."
    TRY_COUNT=$((TRY_COUNT + 1))
    sleep $SLEEP_INTERVAL
  fi
done

echo "{\"argocd_lb_hostname\": \"\"}"  # Only this line outputs to stdout
>&2 echo "Failed to retrieve LoadBalancer hostname after $MAX_TRIES attempts."
exit 1