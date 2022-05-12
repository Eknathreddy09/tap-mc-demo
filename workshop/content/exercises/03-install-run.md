<p style="color:blue"><strong> Change the context to RUN cluster </strong></p>

```execute
kubectl config use-context {{ session_namespace }}-run
```

```execute
kubectl config get-contexts
```

<p style="color:blue"><strong> Create a namespace </strong></p>

```execute
kubectl create ns tap-install
```

<p style="color:blue"><strong> Set up a Service Account to view resources on a cluster </strong></p>

```execute
kubectl create -f $HOME/multi-cluster-demo/tap-gui-viewer-service-account-rbac.yaml
```

<p style="color:blue"><strong> Collect CLUSTER_URL and CLUSTER_TOKEN values by running below commands </strong></p>

```execute
CLUSTER_URL_RUN=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```

```execute
CLUSTER_TOKEN_RUN=$(kubectl -n tap-gui get secret $(kubectl -n tap-gui get sa tap-gui-viewer -o=json | jq -r '.secrets[0].name') -o=json | jq -r '.data["token"]' | base64 --decode)
```

<p style="color:blue"><strong> Create secret registry-credentials </strong></p>

```copy-and-edit
kubectl create secret docker-registry registry-credentials --docker-server=tappartnerdemoacr.azurecr.io --docker-username=tappartnerdemoacr --docker-password=$DOCKER_REGISTRY_PASSWORD -n tap-install
```

<p style="color:blue"><strong> Install  </strong></p>

```execute
cd $HOME/tanzu-cluster-essentials
```

```execute
./install.sh -y
```

<p style="color:blue"><strong> Create tap-registry secret  </strong></p>


```execute
sudo tanzu secret registry add tap-registry --username tappartnerdemoacr --password $DOCKER_REGISTRY_PASSWORD --server tappartnerdemoacr.azurecr.io --export-to-all-namespaces --yes --namespace tap-install
```

<p style="color:blue"><strong> Add the package repository </strong></p>

```execute
sudo tanzu package repository add tanzu-tap-repository --url tappartnerdemoacr.azurecr.io/tap-demo/tap-packages:1.1.0 --namespace tap-install
```

<p style="color:blue"><strong> Get the package status</strong></p>

```execute
sudo tanzu package repository get tanzu-tap-repository --namespace tap-install
```

<p style="color:blue"><strong> List the available packages </strong></p>


```execute
sudo tanzu package available list --namespace tap-install
```

<p style="color:blue"><strong> Install Tanzu package - Run profile </strong></p>

```execute
tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/tap-multi-cluster/tap-values-run.yaml -n tap-install
```

<p style="color:blue"><strong> List the installed packages </strong></p>

```execute
tanzu package installed list -A
```

<p style="color:blue"><strong> Set up developer namespace in RUN cluster </strong></p>

```execute
kubectl apply -f developer.yaml -n tap-install
```

<p style="color:blue"><strong> Apply the Deliverable in this Run profile cluster </strong></p>

```execute
kubectl apply -f deliverable.yaml --namespace tap-install
```

<p style="color:blue"><strong> Verify the Deliverable is started and Ready </strong></p>

```execute
kubectl get deliverables --namespace tap-install
```
<p style="color:blue"><strong> Query the URL of application </strong></p>

```execute
kubectl get httpproxy --namespace tap-install
```

![Local host](images/workload-create.png)

<p style="color:blue"><strong> Collect the load balancer IP </strong></p>

```execute
kubectl get svc envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

###### Add an entry in local host /etc/hosts path pointing the above collected load balancer IP with tanzu-java-web-app.tap-install.captainvirtualization.in

![Local host](images/tap-workload-4.png)

<p style="color:blue"><strong> Access the deployed application </strong></p>

```dashboard:open-url
url: http://tanzu-java-web-app.tap-install.captainvirtualization.in
```

![Local host](images/tap-workload-3.png)

