#!/bin/sh

# Install ingress-controller
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml | kubectl apply -f -  

# Patch hostnetwork  
cat << EOF > patch.yml
spec:
  template:
    spec:
      hostNetwork: true
EOF

kubectl patch deployment ingress-nginx-controller --patch-file patch.yml -n ingress-nginx

# Install storage class as default
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Generate registry certs

cp kubeadm/certs/* /etc/pki/ca-trust/source/anchors/
update-ca-trust

echo "${master_ip}  docker.kw01" >> /etc/hosts

# Create secret certs
kubectl create ns registry
kubectl create secret tls docker-tls -n registry --cert=kubeadm/certs/registry.crt --key=kubeadm/certs/registry.key

# Create registry values
cat << EOF > values.yaml
ingress:
  enabled: true
  className: nginx
  path: /
  hosts:
    - docker.kw01
  tls:
    - secretName: docker-tls
      hosts:
        - docker.kw01
  annotations: 
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
persistence:
  accessMode: 'ReadWriteOnce'
  enabled: true
  size: 5Gi
EOF
# Install registry 
helm repo add twuni https://helm.twun.io
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
helm upgrade -i docker-registry twuni/docker-registry -n registry -f values.yaml 