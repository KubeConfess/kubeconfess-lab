#!/bin/bash
# Runs in background while user reads intro
# Deploys the lab namespaces before step 1

# wait for cluster to be ready
while ! kubectl get nodes | grep -q "Ready"; do
  sleep 2
done

# ── Namespace 1: kubeconfess-audit (listing + security scanning) ──────────────
kubectl create namespace kubeconfess-audit

kubectl create secret generic postgres-credentials \
  --from-literal=username=payments_svc \
  --from-literal=password='Pg$3cur3P4ss2024!' \
  --from-literal=host=postgres.internal:5432 \
  --from-literal=database=payments_prod \
  --from-literal=url='postgresql://payments_svc:Pg$3cur3P4ss2024!@postgres.internal:5432/payments_prod' \
  -n kubeconfess-audit

kubectl create secret generic jwt-signing-key \
  --from-literal=secret=jwt_s1gn1ng_k3y_sup3r_s3cr3t \
  --from-literal=algorithm=HS256 \
  -n kubeconfess-audit

kubectl create secret generic aws-ses-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
  --from-literal=AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
  --from-literal=AWS_REGION=eu-west-1 \
  -n kubeconfess-audit

# service accounts
kubectl create serviceaccount sa-payments-api -n kubeconfess-audit
kubectl create serviceaccount sa-worker -n kubeconfess-audit
kubectl create serviceaccount sa-monitoring -n kubeconfess-audit

# roles
kubectl create role payments-api-role \
  --verb=get,list --resource=secrets \
  -n kubeconfess-audit
kubectl create role worker-role \
  --verb=get,list,patch,update --resource=deployments \
  -n kubeconfess-audit
kubectl create role monitoring-role \
  --verb=get,list --resource=pods,services,deployments \
  -n kubeconfess-audit

# rolebindings
kubectl create rolebinding payments-api-binding \
  --role=payments-api-role \
  --serviceaccount=kubeconfess-audit:sa-payments-api \
  -n kubeconfess-audit
kubectl create rolebinding worker-binding \
  --role=worker-role \
  --serviceaccount=kubeconfess-audit:sa-worker \
  -n kubeconfess-audit
kubectl create rolebinding monitoring-binding \
  --role=monitoring-role \
  --serviceaccount=kubeconfess-audit:sa-monitoring \
  -n kubeconfess-audit

# pods
kubectl apply -n kubeconfess-audit -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: payments-api
  namespace: kubeconfess-audit
  labels:
    app: payments-api
spec:
  serviceAccountName: sa-payments-api
  containers:
  - name: api
    image: alpine:latest
    command: ["/bin/sh", "-c", "sleep 86400"]
    securityContext:
      privileged: true
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgres-credentials
          key: password
    - name: JWT_SECRET
      valueFrom:
        secretKeyRef:
          name: jwt-signing-key
          key: secret
    - name: INTERNAL_API_KEY
      value: "int_api_k3y_hardcoded_in_manifest"
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
YAML

kubectl apply -n kubeconfess-audit -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: monitoring-agent
  namespace: kubeconfess-audit
  labels:
    app: monitoring
spec:
  serviceAccountName: sa-monitoring
  containers:
  - name: agent
    image: alpine:latest
    command: ["/bin/sh", "-c", "sleep 86400"]
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
YAML

kubectl apply -n kubeconfess-audit -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments-api-deploy
  namespace: kubeconfess-audit
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payments-api-deploy
  template:
    metadata:
      labels:
        app: payments-api-deploy
    spec:
      serviceAccountName: sa-payments-api
      containers:
      - name: api
        image: alpine:latest
        command: ["/bin/sh", "-c", "sleep 86400"]
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: password
YAML

# ── Namespace 2: kubeconfess-attack (in-cluster + investigate) ────────────────
kubectl create namespace kubeconfess-attack

kubectl create secret generic prod-database \
  --from-literal=username=prod_admin \
  --from-literal=password='Pr0d_DB_P4ss_2024!' \
  --from-literal=connection_string='postgresql://prod_admin:Pr0d_DB_P4ss_2024!@prod-db.internal:5432/core_platform' \
  -n kubeconfess-attack

kubectl create secret generic github-actions-token \
  --from-literal=token=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal=org=internal-corp \
  -n kubeconfess-attack

kubectl create secret generic stripe-payment-keys \
  --from-literal=secret_key=sk_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal=webhook_secret=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -n kubeconfess-attack

kubectl create secret generic internal-service-tokens \
  --from-literal=admin_api_token=adm_api_t0k3n_dont_share \
  --from-literal=billing_svc_token=bill_svc_t0k3n_s3cr3t \
  -n kubeconfess-attack

# static SA token for token theft demo
kubectl apply -f - <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: deployer-sa-token
  namespace: kubeconfess-attack
  annotations:
    kubernetes.io/service-account.name: sa-deployer
type: kubernetes.io/service-account-token
YAML

# service accounts
kubectl create serviceaccount sa-compromised -n kubeconfess-attack
kubectl create serviceaccount sa-deployer -n kubeconfess-attack
kubectl create serviceaccount sa-ci-runner -n kubeconfess-attack

# roles
kubectl apply -f - <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: compromised-role
  namespace: kubeconfess-attack
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["get", "list", "create"]
- apiGroups: [""]
  resources: ["serviceaccounts", "services", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["roles", "rolebindings"]
  verbs: ["get", "list"]
YAML

kubectl apply -f - <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer-role
  namespace: kubeconfess-attack
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "patch", "update", "create"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
YAML

kubectl apply -f - <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-runner-role
  namespace: kubeconfess-attack
rules:
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["get", "list", "create", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
YAML

kubectl create rolebinding compromised-binding \
  --role=compromised-role \
  --serviceaccount=kubeconfess-attack:sa-compromised \
  -n kubeconfess-attack
kubectl create rolebinding deployer-binding \
  --role=deployer-role \
  --serviceaccount=kubeconfess-attack:sa-deployer \
  -n kubeconfess-attack
kubectl create rolebinding ci-runner-binding \
  --role=ci-runner-role \
  --serviceaccount=kubeconfess-attack:sa-ci-runner \
  -n kubeconfess-attack

# pods
kubectl apply -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: pod-compromised
  namespace: kubeconfess-attack
  labels:
    app: web-app
spec:
  serviceAccountName: sa-compromised
  containers:
  - name: app
    image: python:3.11-slim
    command: ["/bin/sh", "-c", "sleep 86400"]
    env:
    - name: INTERNAL_SECRET
      value: "hardcoded_internal_secret_oops"
    - name: STRIPE_KEY
      valueFrom:
        secretKeyRef:
          name: stripe-payment-keys
          key: secret_key
YAML

kubectl apply -f - <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: pod-ci-runner
  namespace: kubeconfess-attack
  labels:
    app: ci-runner
spec:
  serviceAccountName: sa-ci-runner
  containers:
  - name: runner
    image: alpine:latest
    command: ["/bin/sh", "-c", "sleep 86400"]
    securityContext:
      privileged: true
    env:
    - name: GITHUB_TOKEN
      valueFrom:
        secretKeyRef:
          name: github-actions-token
          key: token
YAML

kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: core-platform-api
  namespace: kubeconfess-attack
spec:
  replicas: 2
  selector:
    matchLabels:
      app: core-platform-api
  template:
    metadata:
      labels:
        app: core-platform-api
    spec:
      serviceAccountName: sa-deployer
      containers:
      - name: api
        image: alpine:latest
        command: ["/bin/sh", "-c", "sleep 86400"]
        env:
        - name: DB_CONNECTION
          valueFrom:
            secretKeyRef:
              name: prod-database
              key: connection_string
        - name: STRIPE_KEY
          valueFrom:
            secretKeyRef:
              name: stripe-payment-keys
              key: secret_key
YAML

#Install python3 venv
apt-get install -y python3-venv

echo "Lab environment ready"
