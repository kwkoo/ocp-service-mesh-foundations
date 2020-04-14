#!/bin/bash

curl -w '%{http_code}\n' $(oc get route/istio-ingressgateway -n istio-system -o jsonpath='{"http://"}{.spec.host}')
