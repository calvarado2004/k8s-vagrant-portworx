kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f 'https://install.portworx.com/2.6?comp=pxoperator'

sleep 30s

kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /tmp/portworx-enterprise.yaml
