# Delete Rook Ceph Cluster

Removing metadata:
```sh
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: disk-clean-001
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-001
  volumes:
  - name: rook-data-dir
    hostPath:
      path: /var/lib/rook
  containers:
  - name: disk-clean
    image: busybox
    securityContext:
      privileged: true
    volumeMounts:
    - name: rook-data-dir
      mountPath: /node/rook-data
    command: ["/bin/sh", "-c", "rm -rf /node/rook-data/*"]
---
apiVersion: v1
kind: Pod
metadata:
  name: disk-clean-002
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-002
  volumes:
  - name: rook-data-dir
    hostPath:
      path: /var/lib/rook
  containers:
  - name: disk-clean
    image: busybox
    securityContext:
      privileged: true
    volumeMounts:
    - name: rook-data-dir
      mountPath: /node/rook-data
    command: ["/bin/sh", "-c", "rm -rf /node/rook-data/*"]
---
apiVersion: v1
kind: Pod
metadata:
  name: disk-clean-003
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-003
  volumes:
  - name: rook-data-dir
    hostPath:
      path: /var/lib/rook
  containers:
  - name: disk-clean
    image: busybox
    securityContext:
      privileged: true
    volumeMounts:
    - name: rook-data-dir
      mountPath: /node/rook-data
    command: ["/bin/sh", "-c", "rm -rf /node/rook-data/*"]
EOF

kubectl -n storage wait --timeout=900s --for=jsonpath='{.status.phase}=Succeeded' pod disk-clean-001 disk-clean-002 disk-clean-003
kubectl -n storage delete pod disk-clean-001 disk-clean-002 disk-clean-003
```

Disk wipes:

```sh
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: disk-wipe-001
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-001
  containers:
  - name: disk-wipe
    image: busybox
    securityContext:
      privileged: true
    command: ["/bin/sh", "-c", "dd if=/dev/zero bs=1M count=100 oflag=direct of=/dev/nvme0n1"]
---
apiVersion: v1
kind: Pod
metadata:
  name: disk-wipe-002
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-002
  containers:
  - name: disk-wipe
    image: busybox
    securityContext:
      privileged: true
    command: ["/bin/sh", "-c", "dd if=/dev/zero bs=1M count=100 oflag=direct of=/dev/nvme0n1"]
---
apiVersion: v1
kind: Pod
metadata:
  name: disk-wipe-003
  namespace: storage
spec:
  restartPolicy: Never
  nodeName: zhopp-003
  containers:
  - name: disk-wipe
    image: busybox
    securityContext:
      privileged: true
    command: ["/bin/sh", "-c", "dd if=/dev/zero bs=1M count=100 oflag=direct of=/dev/nvme0n1"]
EOF

kubectl -n storage wait --timeout=900s --for=jsonpath='{.status.phase}=Succeeded' pod disk-wipe-001 disk-wipe-002 disk-wipe-003
kubectl -n storage delete pod disk-wipe-001 disk-wipe-002 disk-wipe-003
```
