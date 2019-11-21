# Note: You have to be logged in as a user that has the abilty to become
# system:admin

OCP_TUTORIAL_PROJECT=sm-demo

usage:
	@echo "Usage:"
	@echo
	@echo "deploy"
	@echo "\tinstall demo app into the $(OCP_TUTORIAL_PROJECT) project"
	@echo "curlgw"
	@echo "\tsend single request to the gateway"
	@echo "runall"
	@echo "\tsend multiple requests to the gateway"
	@echo "routev2"
	@echo "\troute requests to catalog v2"
	@echo "routev1"
	@echo "\troute requests to catalog v1"
	@echo "routedefault"
	@echo "\troute requests to both catalog v1 and v2"

deploy: createproj updatescc deploycatalog deploypartner deploygateway deploycatalogv2
	@echo "Deployment complete"

createproj:
	oc new-project $(OCP_TUTORIAL_PROJECT) || oc project $(OCP_TUTORIAL_PROJECT)

updatescc:
	@echo "Update SCCs"
	oc adm policy add-scc-to-user anyuid -z default -n $(OCP_TUTORIAL_PROJECT) --as=system:admin
	oc adm policy add-scc-to-user privileged -z default -n $(OCP_TUTORIAL_PROJECT) --as=system:admin

deploycatalog:
	@echo "Deploying the catalog service"
	oc create \
	  -f catalog/kubernetes/catalog-service-template.yml \
	  -n $(OCP_TUTORIAL_PROJECT)
	oc create \
	  -f catalog/kubernetes/Service.yml \
	  -n $(OCP_TUTORIAL_PROJECT)

deploypartner:
	@echo "Deploying the partner service"
	oc create \
	  -f partner/kubernetes/partner-service-template.yml \
	  -n $(OCP_TUTORIAL_PROJECT)
	oc create \
	  -f partner/kubernetes/Service.yml \
	  -n $(OCP_TUTORIAL_PROJECT)

deploygateway:
	@echo "Deploying the gateway service"
	oc create \
	  -f gateway/kubernetes/gateway-service-template.yml \
	  -n $(OCP_TUTORIAL_PROJECT)
	oc create \
	  -f gateway/kubernetes/Service.yml \
	  -n $(OCP_TUTORIAL_PROJECT)
	oc expose service gateway

deploycatalogv2:
	@echo "Deploying the catalog v2 service"
	oc create \
	 -f catalog-v2/kubernetes/catalog-service-template.yml \
	 -n $(OCP_TUTORIAL_PROJECT)

curlgw:
	curl http://`oc get route gateway -n $(OCP_TUTORIAL_PROJECT) -o template --template='{{.spec.host}}'`

runall:
	@scripts/run-all.sh

routev2:
	@echo "Sending traffic to v2"
	-oc create -f istiofiles/destination-rule-catalog-v1-v2.yml -n $(OCP_TUTORIAL_PROJECT) --as=system:admin
	oc create -f istiofiles/virtual-service-catalog-v2.yml -n $(OCP_TUTORIAL_PROJECT) --as=system:admin

routev1:
	@echo "Sending traffic to v1"
	-oc create -f istiofiles/destination-rule-catalog-v1-v2.yml -n $(OCP_TUTORIAL_PROJECT) --as=system:admin
	oc replace -f istiofiles/virtual-service-catalog-v1.yml -n $(OCP_TUTORIAL_PROJECT) --as=system:admin

routedefault:
	@echo "Round-robin traffic"
	-oc delete -f istiofiles/virtual-service-catalog-v1.yml -n $(OCP_TUTORIAL_PROJECT) --as=system:admin