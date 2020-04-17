#!/bin/bash

PROJ=sm-demo

cat <<EOF | oc apply -n istio-system -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: sm-demo-gateway
spec:
  host: gateway.test.example.com
  port:
    targetPort: 8080
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None
EOF

cat <<EOF | oc apply -n ${PROJ} -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - '*'
    port:
      name: http
      number: 80
      protocol: HTTP
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  annotations:
  name: gateway
spec:
  gateways:
  - gateway
  hosts:
  - gateway.test.example.com
  http:
  - route:
    - destination:
        host: gateway
        port:
          number: 8080
      weight: 100
EOF
