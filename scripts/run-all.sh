#!/bin/bash

OCP_TUTORIAL_PROJECT=sm-demo
GATEWAY_URL=http://$(oc get route gateway -n $OCP_TUTORIAL_PROJECT -o template --template='{{.spec.host}}')

while true; do 
  curl $GATEWAY_URL		
done
