#!/bin/bash

GW_HOST="$(oc get -n istio-system route/sm-demo-gateway -o jsonpath='{.spec.host}' 2>/dev/null)"
INGRESS_URL="$(oc get route/istio-ingressgateway -n istio-system -o jsonpath='{"http://"}{.spec.host}')"

while true; do
  if [ -z "$GW_HOST" ]; then
    curl -w '%{http_code}\n' "$INGRESS_URL"
  else
    curl -H "Host: $GW_HOST" -w '%{http_code}\n' "$INGRESS_URL"
  fi
  sleep 1
done