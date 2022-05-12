
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
