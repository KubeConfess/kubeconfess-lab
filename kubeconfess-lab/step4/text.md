# Step 4 — RBAC Analysis

RBAC is the most common source of privilege escalation in Kubernetes. This step maps out who has what access.

## List roles

```
list roles in kubeconfess-audit
```

Notice `payments-api-role` grants `get` and `list` on secrets — a service account reading secrets it doesn't need is a common finding.

---

## List role bindings

```
list rolebindings in kubeconfess-audit
```

Each binding shows which SA is granted which role.

---

## List cluster role bindings

```
list clusterrolebindings
```

Look for any bindings to `cluster-admin` — those are CRITICAL findings. In this lab the namespaces are scoped so you should not see cluster-admin bindings.

---

## Dig into a specific service account

```
list service accounts in kubeconfess-attack
```

Notice `sa-deployer` — it has `patch` and `update` on deployments. This means any pod running as `sa-deployer` can inject a malicious image into any deployment in the namespace.

---

## Check what the current identity can do

```
what can I do in kubeconfess-attack?
```

This fires `SelfSubjectAccessReview` for every dangerous verb/resource combination and returns exactly what your current identity is allowed to do — the same as `kubectl auth can-i --list` but for a curated security-relevant list.

---

## Think about the attack chain

Based on what you have seen so far:

1. `sa-payments-api` can read secrets → credential theft possible
2. `payments-api` pod is privileged with docker socket → node escape possible
3. `sa-deployer` can patch deployments → deployment injection possible

This is the kind of reasoning that Investigate Mode automates in the next step.
