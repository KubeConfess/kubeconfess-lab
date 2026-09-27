# Step 1 — Install KubeConfess

## Verify the lab is ready

First confirm both namespaces are running:

```
kubectl get pods -n kubeconfess-audit
kubectl get pods -n kubeconfess-attack
```{{exec}}

You should see pods in both namespaces. If any are still `Pending`, wait 30 seconds and try again.

---

## Install KubeConfess

Clone the repository and install:

```
git clone https://github.com/arnavtripathy/KubeConfess.git
cd KubeConfess
python3 -m venv .venv
source .venv/bin/activate
pip3 install .
```{{exec}}

Verify the install:

```
kubeconfess --help
```{{exec}}

---

## Set your API key

KubeConfess works with any OpenAI-compatible API. Set your Anthropic key:

```
export API_KEY=your-api-key-here
```

Replace `your-api-key-here` with your actual key from [console.anthropic.com](https://console.anthropic.com).

Also set the model:

```
export MODEL_NAME=claude-haiku-4-5
export BASE_URL=https://api.anthropic.com/v1
```{{exec}}

---

## Connect to the cluster

```
kubeconfess --kubeconfig ~/.kube/config
```{{exec}}

You should see the KubeConfess banner and a `you>` prompt. You are now connected to the cluster.

> **Tip:** Type `exit` or press `Ctrl+C` to leave the session at any time and come back to this guide.

Leave KubeConfess running and move to the next step.
