
<p style="color:blue"><strong> Click here to test the execution in terminal</strong></p>

```execute-1
echo "Hello, Welcome to Partner workshop session"
```

<p style="color:blue"><strong> Click here to check the Tanzu version</strong></p>

```execute
tanzu version
```

<p style="color:blue"><strong> Click here to check the AZ version</strong></p>

```execute
az --version
```

<p style="color:blue"><strong> Click here to check the kubectl version</strong></p>

```execute
kubectl version
```

<p style="color:blue"><strong> Set environment variable </strong></p>

```execute-all
export SESSION_NAME={{ session_namespace }}
```

###### Login to github and fork the below repo, give the repository name as {{ session_namespace }}-mc

```dashboard:open-url
url: https://github.com/Eknathreddy09/tanzu-java-web-app
```

###### SE will provide the AZ Credentials, edit and execute in terminal

```copy-and-edit
az login --service-principal -u <App ID> -p <Password> --tenant <Tenent ID> 
```
###### SE will provide the Subscription ID, edit and execute in terminal

```copy-and-edit
az account set --subscription <subscriptionid>
```

###### SE will provide the AWS Credentials, execute in terminal and enter the values as instructed

```execute
aws configure
```

<p style="color:blue"><strong> Provide ACR repo password. "This will be given by SE" </strong></p>

```copy-and-edit
export DOCKER_REGISTRY_PASSWORD=<ACR Repo password>
```

```execute
az aks get-credentials --resource-group tap-partner-demo --name {{ session_namespace }}-build
```

```execute
az aks get-credentials --resource-group tap-partner-demo --name {{ session_namespace }}-run
```

###### Edit the region and execute the command on terminal-1

```copy-and-edit
aws eks update-kubeconfig --region <region> --name {{ session_namespace }}-view
```

<p style="color:blue"><strong> Check if you can see all the 3 clusters i.e., {{ session_namespace }}-Build, {{ session_namespace }}-Run, {{ session_namespace }}-View </strong></p>

```execute
kubectl config get-contexts
```

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

#### RUN

<p style="color:blue"><strong> Change the context to RUN cluster </strong></p>

```execute
kubectl config use-context {{ session_namespace }}-run
```

<p style="color:blue"><strong> Create a namespace </strong></p>

```execute
kubectl create ns tap-install
```

```execute
kubectl create -f $HOME/multi-cluster-demo/tap-gui-viewer-service-account-rbac.yaml
```

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

<p style="color:blue"><strong> Get the available packages </strong></p>

```execute
sudo tanzu package repository get tanzu-tap-repository --namespace tap-install
```

```execute
sudo tanzu package available list --namespace tap-install
```

tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/tap-multi-cluster/tap-values-run.yaml -n tap-install
tanzu package installed list -A
kubectl apply -f developer.yaml -n tap-install
echo "############## Get the package install status #################"
tanzu package installed get tap -n tap-install
tanzu package installed list -A

kubectl apply -f deliverable.yaml --namespace tap-install
kubectl get deliverables --namespace tap-install
kubectl get httpproxy --namespace tap-install
kubectl config get-contexts

##### View

```execute
kubectl config use-context {{ session_namespace }}-view
```

<p style="color:blue"><strong> Create a namespace </strong></p>

```execute
kubectl create ns tap-install
```

<p style="color:blue"><strong> Create secret registry-credentials </strong></p>

```copy-and-edit
kubectl create secret docker-registry registry-credentials --docker-server=tappartnerdemoacr.azurecr.io --docker-username=tappartnerdemoacr --docker-password=$DOCKER_REGISTRY_PASSWORD -n tap-install
```

<p style="color:blue"><strong> Install  </strong></p>

cd $HOME/tanzu-cluster-essentials

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

<p style="color:blue"><strong> Get the available packages </strong></p>

```execute
sudo tanzu package repository get tanzu-tap-repository --namespace tap-install
```

```execute
sudo tanzu package available list --namespace tap-install
```

tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/tap-multi-cluster/tap-values-view.yaml -n tap-install

tanzu package installed list -A


##### Extra

<p style="color:blue"><strong> Copy the output and same should be updated in tap-values </strong></p>

```execute-1
echo $DOCKER_REGISTRY_PASSWORD
```
<p style="color:blue"><strong> Provide ACR repo password collected in previous step </strong></p>

```editor:open-file
file: ~/tap-values.yaml
line: 6
```
<p style="color:blue"><strong> Provide your VMware Tanzu network username </strong></p>

```editor:open-file
file: ~/tap-values.yaml
line: 7
```
<p style="color:blue"><strong> Provide your VMware Tanzu network password </strong></p>

```editor:open-file
file: ~/tap-values.yaml
line: 8
```
<p style="color:blue"><strong> Provide your github token </strong></p>

```editor:open-file
file: ~/tap-values.yaml
line: 40
```
<p style="color:blue"><strong> Provide the Git account and repo name. Replace gitname with your account name and reponame with {{ session_namespace }} </strong></p>

```editor:open-file
file: ~/tap-values.yaml
line: 44
```

<p style="color:blue"><strong> Install Tanzu package </strong></p>

```execute
sudo tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/tap-values.yaml -n tap-install
```
<p style="color:blue"><strong> List the packages installed </strong></p>

```execute
tanzu package installed list -A
```

image: expected

<p style="color:blue"><strong> Check the reconcile status of tap package </strong></p>

```execute
tanzu package installed get tap -n tap-install
```

<p style="color:blue"><strong> List the supply chain list </strong></p>

```execute
tanzu apps cluster-supply-chain list
```

<p style="color:blue"><strong> Collect the load balancer IP </strong></p>

```execute
kubectl get svc envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

###### Add an entry in local host /etc/hosts path pointing the above collected load balancer IP with tap-gui.{{ session_namespace }}.demo.captainvirtualization.in

Example for ref: 
![Local host](images/tap-svc-localhost-1.png)

<p style="color:blue"><strong> Access TAP GUI </strong></p>

```dashboard:open-url
url: https://tap-gui.{{ session_namespace }}.demo.captainvirtualization.in
```

Example for ref: 
![TAP GUI](images/tap-gui-1.png)

<p style="color:blue"><strong> Setup developer namespace </strong></p>

```execute
kubectl apply -f $HOME/developer.yaml -n tap-install
```

<p style="color:blue"><strong> Deploy Tekton pipeline </strong></p>

```execute
kubectl apply -f $HOME/tekton-pipeline.yaml -n tap-install
```

<p style="color:blue"><strong> Deploy Scanpolicy </strong></p>

```execute
kubectl apply -f $HOME/scanpolicy.yaml -n tap-install
```

<p style="color:blue"><strong> Install grype scanner package </strong></p>

```execute
sudo tanzu package install grype-scanner --package-name grype.scanning.apps.tanzu.vmware.com --version 1.0.0  --namespace tap-install -f $HOME/ootb-supply-chain-basic-values.yaml
```

<p style="color:blue"><strong> List the packages installed </strong></p>

```execute
tanzu package installed list -A
```

###### If all the packages are installed successfully, now its time to deploy an application on TAP. Provide the gitrepo that you have forked in the beginning. 


```copy-and-edit
sudo tanzu apps workload create tanzu-java-web-app  --git-repo <replace me with your git repo path> --git-branch main --type web --label apps.tanzu.vmware.com/has-tests=true --label app.kubernetes.io/part-of=tanzu-java-web-app -n tap-install --yes
```

<p style="color:blue"><strong> Get the status of deployed application </strong></p>

```execute
sudo tanzu apps workload get tanzu-java-web-app -n tap-install
```

<p style="color:blue"><strong> Check the live progress </strong></p>

```execute-2
sudo tanzu apps workload tail tanzu-java-web-app --since 10m --timestamp -n tap-install
```

<p style="color:blue"><strong> Check all the installed applications </strong></p>

```execute
sudo tanzu apps workload list -n tap-install
```

<p style="color:blue"><strong> Get the status of deployed application, status should be ready with an url as shown in screenshot below </strong></p>

```execute
sudo tanzu apps workload get tanzu-java-web-app -n tap-install
```

![Local host](images/tap-workload-2.png)

<p style="color:blue"><strong> Get the pods in tap-install namespace </strong></p>

```execute
kubectl get pods -n tap-install
```

###### Note: Workload creation takes 5 mins to complete, proceed further once you see ready status

```execute
sudo tanzu apps workload get tanzu-java-web-app -n tap-install
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
