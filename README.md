# ocp-service-mesh-foundations

## Deployment

* Install the service mesh by executing `scripts/install_service_mesh.sh`.
* Alternatively,
	* Install the service mesh by following the instructions in the [documentation](https://docs.openshift.com/container-platform/4.3/service_mesh/service_mesh_install/installing-ossm.html).
	* Specify the `sm-demo` namespace as a `member` in the `ServiceMeshMemberRoll`.
* Login to the OpenShift cluster as a cluster-admin using the `oc` CLI.
* Deploy the demo app by executing:

    ```
    make deploy
    ```
