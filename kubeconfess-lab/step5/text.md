# Step 5 — Investigate Mode

Investigate Mode runs a fixed sequence of checks against a target — permissions, RBAC, secrets, security misconfigs — then sends everything to the AI in one shot to produce a structured attack path report.

## Investigate a namespace

```
investigate namespace/kubeconfess-audit
```

This will take 30-60 seconds. KubeConfess is:
1. Running ~10 tool calls to collect all data
2. Sending everything to the AI in one message
3. Producing a structured report with findings, attack paths, blast radius, and fixes

---

## Read the report

The report has four sections:

- **STARTING POINT** — what the target is and its baseline access
- **FINDINGS** — everything discovered, CRITICAL first
- **ATTACK PATHS** — numbered, step-by-step attack chains with exact commands
- **BLAST RADIUS** — worst-case impact in plain English
- **RECOMMENDED FIXES** — prioritised remediations

---

## Ask follow-up questions

After the report you stay in the chat — the findings are in memory:

```
give me the exact kubectl command to exec into the compromised pod
```

```
what YAML do I apply to remove the secret read permission from sa-payments-api?
```

---

## Investigate a specific pod

```
investigate pod/payments-api -n kubeconfess-audit
```

This scopes the investigation to just that pod — useful when you want to understand the blast radius from a specific entry point.

---

## Investigate the attack namespace

```
investigate namespace/kubeconfess-attack
```

This namespace has static SA tokens, privileged pods, and deployment patch permissions — the report should surface all three as attack paths.

---

## Generate an attack graph

```
investigate namespace/kubeconfess-attack --graph
```

This generates an interactive D3.js attack graph alongside the text report. The graph is saved to `/tmp` as a zip bundle.

Retrieve it after the lab:
```
ls /tmp/kubeconfess-*.zip
```{{exec}}
