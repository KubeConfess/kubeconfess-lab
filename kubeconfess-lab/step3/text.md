# Step 3 — Listing and Security Scanning

## Check for privileged containers

```
are there any privileged containers in kubeconfess-audit?
```

`payments-api` is running in privileged mode. This means it has full host access and can escape the container boundary.

---

## Check for root containers

```
check for root containers in kubeconfess-audit
```

Notice the contrast:
- `payments-api` — no securityContext, running as root
- `monitoring-agent` — `runAsNonRoot: true`, hardened

---

## Check for host path mounts

```
check for hostpath mounts in kubeconfess-audit
```

`payments-api` has the Docker socket mounted at `/var/run/docker.sock`. This is a critical finding — anyone who can exec into that pod can control the Docker daemon on the host.

---

## List secrets

```
list secrets in kubeconfess-audit
```

Observe how many secrets exist and which pods reference them. Then ask a more specific question:

```
what secrets does the payments-api pod use?
```

---

## Check patchable deployments

```
what deployments can I patch in kubeconfess-audit?
```

This checks whether your current identity has `patch` permission on deployments — a prerequisite for deployment injection attacks.

---

## Contrast with the hardened pod

```
check for privileged containers in monitoring-agent in kubeconfess-audit
```

The monitoring agent should pass all security checks. This contrast — one pod failing everything, one passing — is what a real audit looks like.
