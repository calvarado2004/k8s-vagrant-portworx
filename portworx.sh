kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f 'https://install.portworx.com/2.6?comp=pxoperator'

sleep 30s

kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f /tmp/portworx-enterprise.yaml
