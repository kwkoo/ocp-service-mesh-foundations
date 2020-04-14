#!/bin/bash

PROJ=sm-demo

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
  - '*'
  http:
  - route:
    - destination:
        host: gateway
        port:
          number: 8080
      weight: 100
EOF
