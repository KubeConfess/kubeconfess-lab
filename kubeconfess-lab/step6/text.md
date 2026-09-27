# Step 6 — In-Cluster Mode: Attack from Inside a Pod

This step simulates the post-exploitation scenario: you have gained shell access inside `pod-compromised` and want to understand what you can do from there.

## Open a new terminal

Press the `+` button in the terminal to open a second tab. All commands in this step run in the new terminal.

---

## Exec into the compromised pod

```
kubectl exec -it pod-compromised -n kubeconfess-attack -- /bin/bash
```{{exec}}

You are now inside the pod. Notice you are running as root.

---

## Install KubeConfess inside the pod

```
cd /tmp && git clone https://github.com/arnavtripathy/KubeConfess.git && cd KubeConfess && pip install . -q
```{{exec}}

---

## Set your API key

```
export API_KEY=your-api-key-here
export MODEL_NAME=claude-haiku-4-5
export BASE_URL=https://api.anthropic.com/v1
```

---

## Run in-cluster mode

```
kubeconfess --incluster
```{{exec}}

KubeConfess automatically picks up the mounted SA token — no kubeconfig needed.

---

## Scan this pod

```
scan this pod
```

This scans the pod you are running in — capabilities, runtime sockets, host mounts, cloud metadata endpoints, sensitive env vars, and credential files. Notice the hardcoded `INTERNAL_SECRET` in the env vars.

---

## Check what you can do

```
what can I do?
```

This fires `SelfSubjectAccessReview` as `sa-compromised`. You should see:
- `get/list secrets` — credential theft possible
- `create pods/exec` — lateral movement possible

---

## Steal tokens

```
steal tokens from all namespaces
```

KubeConfess finds the static `deployer-sa-token` secret, decodes it, and outputs ready-to-use `kubectl` and `curl` commands to authenticate as `sa-deployer`.

---

## Harvest secrets

```
harvest secrets from kubeconfess-attack
```

Decodes and dumps actual secret values — the production database connection string, Stripe keys, GitHub token, and internal service tokens.

---

## Run a command in another pod

```
run id in pod/pod-ci-runner -n kubeconfess-attack
```

Execs into the CI runner pod via the Kubernetes API — no kubectl needed. You should see `uid=0(root)` confirming it runs as root.

---

## Investigate from inside

```
investigate namespace/kubeconfess-attack
```

The investigation now reflects what `sa-compromised` can actually see — not your kubeconfig identity. The report maps the attack paths available from your current position inside the cluster.

---

## Exit the pod

```
exit
```{{exec}}

You are back in the host terminal.
