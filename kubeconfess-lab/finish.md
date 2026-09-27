
<br>

# Lab Complete

You have worked through the full KubeConfess workflow — from basic listing to in-cluster post-exploitation reconnaissance.

## What you covered

| Step | Capability |
|---|---|
| Install | `pip3 install .` and connect via kubeconfig |
| Listing | Pods, deployments, services, secrets, service accounts |
| Security scanning | Privileged containers, root containers, host path mounts |
| RBAC analysis | Roles, bindings, cluster-wide access mapping |
| Investigate mode | Automated attack path report with blast radius |
| In-cluster mode | Post-exploitation recon from inside a compromised pod |
| Attack capabilities | Token theft, secret harvesting, pod exec |

## Key takeaways

**The conversational interface removes friction.** You asked questions in plain English and got structured security findings backed by live cluster data — no flags, no `jq` pipes.

**Investigate mode chains tools automatically.** Instead of running ten separate `kubectl` commands and mentally joining the output, one `investigate` command produced a full attack path report.

**In-cluster mode is the offensive use case.** Landing in a pod with no kubeconfig, running KubeConfess with `--incluster`, and mapping the blast radius in under two minutes — that is the scenario the tool was designed for.

## Next steps

- ⭐ [Star the repo](https://github.com/KubeConfess/KubeConfess) if you found this useful
- 🔧 [Open a good first issue](https://github.com/KubeConfess/KubeConfess/issues) — adding a new tool is one file and two lines
- 📖 Read the [contributing guide](https://github.com/KubeConfess/KubeConfess#contributing) to build your own security checks

## Clean up

The lab environment is ephemeral — everything is deleted when you close the session.
