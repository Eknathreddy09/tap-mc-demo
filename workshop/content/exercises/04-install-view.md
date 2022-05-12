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

```execute
cat $HOME/multi-cluster-demo/tap-values-view.yaml
```

<p style="color:blue"><strong> Install Tanzu package using View profile </strong></p>

```execute
tanzu package install tap -p tap.tanzu.vmware.com -v 1.1.0 --values-file $HOME/tap-multi-cluster/tap-values-view.yaml -n tap-install
```

<p style="color:blue"><strong> List the Installed packages </strong></p>

```execute
tanzu package installed list -A
```
