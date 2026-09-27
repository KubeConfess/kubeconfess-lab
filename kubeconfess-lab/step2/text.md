# Step 2 — Explore the Lab Environment

Inside KubeConfess, start by getting an overview of the cluster.

## List namespaces

```
list namespaces
```

You should see `kubeconfess-audit` and `kubeconfess-attack` alongside the system namespaces.

---

## List pods in the audit namespace

```
list pods in kubeconfess-audit
```

Notice:
- `payments-api` — no security context, running as root
- `monitoring-agent` — hardened, non-root, read-only filesystem

---

## List pods in the attack namespace

```
list pods in kubeconfess-attack
```

Notice:
- `pod-compromised` — the pod you will exec into in Step 6
- `pod-ci-runner` — privileged CI runner, high value target

---

## List deployments

```
list deployments in kubeconfess-audit
```

```
list deployments in kubeconfess-attack
```

---

## List service accounts

```
list service accounts in kubeconfess-audit
```

Notice each SA listed with its RBAC bindings. `sa-payments-api` has secret read access — a common misconfiguration in real clusters.

> **Tip:** You can ask follow-up questions. Try: `what secrets does sa-payments-api have access to?`
