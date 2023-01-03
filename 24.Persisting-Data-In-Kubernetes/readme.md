# Persisting Data In Kubernetes

### Use AWS EBS

- Create an EBS volume
- Create a deployment manifest file as shown below to mount the volume

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-volume
          mountPath: /usr/share/nginx
      volumes:
      - name: nginx-volume
        awsElasticBlockStore:
          volumeID: <volume-ID>
		  fsType: ext4
```

- Apply the deployment
- Port forward the running pod

![first](PBL-23/first.png)

![run404](PBL-23/run404.jpg)

![404](PBL-23/404.png)

### Persist Volume Claim

- Create a manifest file for PVC
- Apply the manifest file

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-volume-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: gp2
```

- Modify the deployment to use the created pvc
- Apply the manifest file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-volume-claim
          mountPath: "/tmp/dare"
      volumes:
      - name: nginx-volume-claim
        persistentVolumeClaim:
          claimName: nginx-volume-claim
```

![pvc](PBL-23/pvc.png)

![vol](PBL-23/vol.png)

- Create a configmap manifest file as shown below
- Apply the manifest

### Configmap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: website-index-file
data:
  index: | 
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to DAREY.IO!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to DAREY.IO!</h1>
    <p>If you see this page, It means you have successfully updated the configMap data in Kubernetes.</p>

    <p>For online documentation and support please refer to
    <a href="http://DAREY.IO/">DAREY.IO</a>.<br/>
    Commercial support is available at
    <a href="http://DAREY.IO/">DAREY.IO</a>.</p>

    <p><em>Thank you and make sure you are on Darey's Masterclass Program.</em></p>
    </body>
    </html>
```

- Modify the deployment to use the created configmap
- Apply the manifest file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /usr/share/nginx/html
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: website-index-file
          items:
          - key: index
            path: index.html
```

- Port faorward the pod to an external port to test

![config](PBL-23/config.png)

![check](PBL-23/check.png)

![darey](PBL-23/darey.png)
