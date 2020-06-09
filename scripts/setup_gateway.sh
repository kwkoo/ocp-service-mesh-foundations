#!/bin/bash

PROJ=sm-demo

apiserver=$(oc whoami --show-server)
if [[ $apiserver =~ ".example.opentlc.com" ]]; then
  suffix=$(echo $apiserver | sed -e 's|https://api\.\([^:]*\).*|apps.\1|')
else
  echo "error - not running on RHPDS"
  exit 1
fi

echo "Routing suffix $suffix"

echo "Creating route..."
cat <<EOF | sed -e "s|ROUTING_SUFFIX|$suffix|" | oc apply -n istio-system -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: sm-demo-gateway
spec:
  host: gateway.ROUTING_SUFFIX
  port:
    targetPort: 8080
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None
EOF


echo "Creating gateway and virtualservice..."
cat <<EOF | sed -e "s|ROUTING_SUFFIX|$suffix|" | oc apply -n ${PROJ} -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - 'gateway.ROUTING_SUFFIX'
    port:
      name: http
      number: 80
      protocol: HTTP
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: gateway
spec:
  gateways:
  - gateway
  hosts:
  - gateway.ROUTING_SUFFIX
  http:
  - route:
    - destination:
        host: gateway
        port:
          number: 8080
      weight: 100
EOF
