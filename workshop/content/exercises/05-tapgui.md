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





<p style="color:blue"><strong> Connect to TAP GUI </strong></p>

```dashboard:open-url
url: http://tanzu-java-web-app.tap-install.captainvirtualization.in
```

###### In Tap GUI, navigate to Supply Chain > Workloads > click on workload tanzu-java-web-app

![Local host](images/supply-1.png)

###### click on various stages in supply chain to understand better

![Local host](images/supply-2.png)


###### In Tap GUI, Naviate to Home > Your Organization > All > tanzu-java-web-app

![Local host](images/tap-gui-2.png)

###### Runtime Resources > Resources > click on tanzu-java-web-app

![Local host](images/Applive-1.png)

###### Scroll down to the bottom and click on pod deployment

![Local host](images/Applive-2.png)

###### Live view of application can be seen as shown below: 

![Local host](images/Applive-3.png)

###### Change the information Category to Memory, to view the memory stats if application. 

![Local host](images/Applive-4.png)

<p style="color:blue"><strong> Access AppLive view page directly: </strong></p>

```dashboard:open-url
url: http://tanzu-java-web-app.tap-install.captainvirtualization.in/app-live-view
```
