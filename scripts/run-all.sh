#!/bin/bash

OCP_TUTORIAL_PROJECT=sm-demo
GATEWAY_HOST="$(oc get -n istio-system route/sm-demo-gateway -o jsonpath='{.spec.host}' 2>/dev/null)"
if [ -z "$GATEWAY_HOST" ]; then
  GATEWAY_URL=http://$(oc get route gateway -n $OCP_TUTORIAL_PROJECT -o template --template='{{.spec.host}}')
else
  GATEWAY_URL="$(oc get route/istio-ingressgateway -n istio-system -o jsonpath='{"http://"}{.spec.host}')"
fi

while true; do 
  if [ -z "$GATEWAY_HOST" ]; then
    curl "$GATEWAY_URL"
  else
    curl -H "Host: $GATEWAY_HOST" "$GATEWAY_URL"
  fi
done
