##### Build

<p style="color:blue"><strong> Change the context to build cluster" </strong></p>

```execute
kubectl config use-context {{ session_namespace }}-build
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
CLUSTER_URL_BUILD=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```

```execute
CLUSTER_TOKEN_BUILD=$(kubectl -n tap-gui get secret $(kubectl -n tap-gui get sa tap-gui-viewer -o=json | jq -r '.secrets[0].name') -o=json | jq -r '.data["token"]' | base64 --decode)
```

<p style="color:blue"><strong> Create secret registry-credentials </strong></p>

```execute
kubectl create secret docker-registry registry-credentials --docker-server=tappartnerdemoacr.azurecr.io --docker-username=tappartnerdemoacr --docker-password=$DOCKER_REGISTRY_PASSWORD -n tap-install
```

<p style="color:blue"><strong> Set environment variable </strong></p>

```execute
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:ab0a3539da241a6ea59c75c0743e9058511d7c56312ea3906178ec0f3491f51d
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
```

<p style="color:blue"><strong> Provide the Tanzu network username </strong></p>

```copy-and-edit
export INSTALL_REGISTRY_USERNAME=<Tanzu Network Registry username>
```

<p style="color:blue"><strong> Provide the Tanzu network password </strong></p>

```copy-and-edit
export INSTALL_REGISTRY_PASSWORD=<Tanzu Network password>
```

```execute
cd $HOME/tanzu-cluster-essentials
```

<p style="color:blue"><strong> Install </strong></p>

```execute
./install.sh -y
```

<p style="color:blue"><strong> Docker login to image repo </strong></p>

```execute
docker login tappartnerdemoacr.azurecr.io -u tappartnerdemoacr -p $DOCKER_REGISTRY_PASSWORD
```

<p style="color:blue"><strong> docker login to VMware registry </strong></p>

```execute
docker login registry.tanzu.vmware.com -u $INSTALL_REGISTRY_USERNAME -p $INSTALL_REGISTRY_PASSWORD
```

<p style="color:blue"><strong> Create tap-registry secret  </strong></p>


```execute
sudo tanzu secret registry add tap-registry --username tappartnerdemoacr --password $DOCKER_REGISTRY_PASSWORD --server tappartnerdemoacr.azurecr.io --export-to-all-namespaces --yes --namespace tap-install
```

<p style="color:blue"><strong> Add the package repository </strong></p>

```execute
sudo tanzu package repository add tanzu-tap-repository --url tappartnerdemoacr.azurecr.io/tap-demo/tap-packages:1.1.0 --namespace tap-install
```

<p style="color:blue"><strong> Get the available packages </strong></p>

```execute
sudo tanzu package repository get tanzu-tap-repository --namespace tap-install
```

```execute
cat $HOME/multi-cluster-demo/tap-values-build.yaml
```

<p style="color:blue"><strong> Install Tanzu build package using build profile </strong></p>

```execute
tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/multi-cluster-demo/tap-values-build.yaml -n tap-install
```

<p style="color:blue"><strong> List the Installed packages </strong></p>

```execute
tanzu package installed list -A
```

<p style="color:blue"><strong> Set up developer namespace in build cluster </strong></p>

```execute
kubectl apply -f developer.yaml -n tap-install
```

<p style="color:blue"><strong> Since this workshop includes OOTB - test and scan, deploy the scanpolicy </strong></p>

```execute
kubectl apply -f scanpolicy.yaml -n tap-install
```

<p style="color:blue"><strong> Deploy tekton pipeline </strong></p>

```execute
kubectl apply -f tekton-pipeline.yaml -n tap-install
```

<p style="color:blue"><strong> Install grype scanner </strong></p>

```execute
tanzu package install grype-scanner --package-name grype.scanning.apps.tanzu.vmware.com --version 1.1.0  --namespace tap-install -f ootb-supply-chain-basic-values.yaml
```

<p style="color:blue"><strong> create a workload </strong></p>
###### Provide the github account name and execute the below command

```copy-and-edit
tanzu apps workload create tanzu-java-web-app  --git-repo https://github.com/<github account name>/{{ session_namespace }}-mc --git-branch main --type web --label apps.tanzu.vmware.com/has-tests=true --label app.kubernetes.io/part-of=tanzu-java-web-app  --type web -n tap-install --yes
```

<p style="color:blue"><strong> Monitor the progress of workload creation in terminal-2 </strong></p>

```execute-2
sudo tanzu apps workload tail tanzu-java-web-app --since 10m --timestamp -n tap-install
```

<p style="color:blue"><strong> Get the status of deployed application, status should be ready with an url as shown in screenshot below </strong></p>

```execute
tanzu apps workload get tanzu-java-web-app -n tap-install
```

<p style="color:blue"><strong> Check all the installed applications </strong></p>

```execute
sudo tanzu apps workload list -n tap-install
```

<p style="color:blue"><strong> Get the status of deployed application, status should be ready with an url as shown in screenshot below </strong></p>

```execute
sudo tanzu apps workload get tanzu-java-web-app -n tap-install
```

<p style="color:blue"><strong> Get the pods in tap-install namespace </strong></p>

```execute
kubectl get pods -n tap-install
```

<p style="color:blue"><strong> Get the pods in tap-install namespace </strong></p>

kubectl get deliverable --namespace tap-install



<p style="color:blue"><strong> Create a Deliverable after verifying there’s a Deliver on the build cluster. Copy its content to a file that you can take to the Run profile clusters </strong></p>

```execute
kubectl get deliverable tanzu-java-web-app --namespace tap-install -oyaml > deliverable.yaml
```

<p style="color:blue"><strong> Get the pods in tap-install namespace </strong></p>

```execute
yq 'del(.metadata."ownerReferences")' deliverable.yaml -i
```

<p style="color:blue"><strong> Get the pods in tap-install namespace </strong></p>

```execute
yq 'del(."status")' deliverable.yaml -i
```
