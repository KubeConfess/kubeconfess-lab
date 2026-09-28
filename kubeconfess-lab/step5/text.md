# Step 5 — Investigate Mode + Attack Graph

Investigate Mode runs a fixed sequence of checks against a target — permissions, RBAC, secrets, security misconfigs — then sends everything to the AI in one shot to produce a structured attack path report.

## Investigate a namespace

Inside KubeConfess type:

```text
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

```text
give me the exact kubectl command to exec into the compromised pod
```

```text
what YAML do I apply to remove the secret read permission from sa-payments-api?
```

---

## Investigate a specific pod

```text
investigate pod/payments-api -n kubeconfess-audit
```

This scopes the investigation to just that pod — useful when you want to understand the blast radius from a specific entry point.

---

## Investigate the attack namespace

```text
investigate namespace/kubeconfess-attack
```

This namespace has static SA tokens, privileged pods, and deployment patch permissions — the report should surface all three as attack paths. Please note the graph might be a bit overwhelming.

---

## Generate an attack graph

Inside KubeConfess type:

```text
investigate pod/pod-compromised -n kubeconfess-attack --graph
```

This generates an interactive D3.js attack graph saved as a zip bundle in `/tmp`.

---

## View the attack graph in your browser

Open a **new terminal tab** by clicking the `+` button. Then run these commands one by one.

Unzip the bundle:

```bash
cd /tmp
ZIP_FILE=$(ls -t kubeconfess-*.zip | head -1)
unzip -o "$ZIP_FILE"
cp "$(find /tmp -maxdepth 2 -name attack_graph.html -type f | head -1)" /tmp/attack_graph.html
```
{{exec}}

Start a simple HTTP server:

```bash
python3 -m http.server 8888 --directory /tmp &
```
{{exec}}

Verify it is running:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8888/attack_graph.html
```
{{exec}}

You should see `200`. Now open the attack graph by clicking the link below:

[Open Attack Graph]({{TRAFFIC_HOST1_8888}}/attack_graph.html)

> **Note:** If the link shows a connection error, wait 5 seconds and try again — the server may still be starting.

---

## Using the graph

- **Click any node** to inspect its type, severity, and ID in the sidebar
- **Drag nodes** to rearrange the layout
- **Scroll** to zoom in and out
- **Click the canvas** to deselect and reset highlighted edges
- Nodes are **sized and coloured by severity** — CRITICAL nodes glow red and are larger

---

## Stop the server when done

Switch back to the first terminal tab and continue using KubeConfess. To stop the graph server when you are finished:

```bash
kill $(lsof -t -i:8888) 2>/dev/null || pkill -f "http.server 8888"
```
{{exec}}
