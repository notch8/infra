If you do not have limits and requests set for your kubernetes resources, it will be difficult for the scheduler to schedule them onto nodes appropriately.

In order to set requests and limits:

### Ensure you are in the correct cluster
Run `kubectx` and the returned value should have `r2-gc` highlighted

### Find helm-managed resources where the limits and requests are not set
This searches for pods, filtered by resources managed by Helm, where the cpu limits are <none>
```bash
kubectl get pods -A -l app.kubernetes.io/managed-by=Helm -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,CONTAINER:.spec.containers[*].name,CPU_LIMITS:.spec.containers[*].resources.limits.cpu" | grep '<none>'
```
### Find the fleet.yaml for that resource
e.g., if the output for above includes
```bash
cert-manager               cert-manager-7fd8b46994-gbxtj                            cert-manager-controller   <none>
cert-manager               cert-manager-cainjector-8c449f76b-kgcxv                  cert-manager-cainjector   <none>
cert-manager               cert-manager-webhook-84b5fb9847-vfv5g                    cert-manager-webhook      <none>
```
see if you can find a fleet.yaml in this repository that includes `cert-manager` - in this case fleet-default/cert-manager/fleet.yaml looks like the right file to check.
### Get the helm chart for that resource
The fleet-default/cert-manager/fleet.yaml includes a helm stanza that includes the chart name and repo url
```yaml
helm:
  repo: https://charts.jetstack.io
  chart: cert-manager
  takeOwnership: true
  releaseName: cert-manager
```
To add this helm chart to our local repos, run
```bash
helm repo add <chart-name> <repo-url>
# that is, in this case
helm repo add cert-manager https://charts.jetstack.io
```
### Look at the values and see where the appropriate "resources" should be set - it might not be at the top level of the values file
In order to see the values that you can set for this chart, you can run
```bash
helm show values <repo-name>/<path-to-chart>
```
Some of them are *very* long, so I found it helpful to push it into a file to look at it:
```bash
helm show values jetstack/cert-manager > cert_manager_values.yaml
```

In this case, there is a top-level `resources` stanza, so we can put this in our fleet.yaml in the helm.values section.
```yaml
helm:
  [...]
  values:
    installCRDs: true
    resources:
      requests:
        cpu:
        memory:
      limits:
        cpu:
        memory:
```

In some cases, the values will be in a separate file - in that case the fleet.yaml's `helm` stanza will include `valuesFiles` which will say where to find the values, usually as relative paths to the fleet.yaml's directory.


### Determine the appropriate requests and limits for the resource
#### CPU
ninety_five_percentile_cpu = quantile_over_time(0.95, rate(container_cpu_usage_seconds_total{container=~"cert-manager.*"}[5m])[7d:5m])

cpu_request (in millicores) = ninety_five_percentile_cpu * 1.5 * 1,000 

ninety_nine_percentile_cpu = quantile_over_time(0.99, rate(container_cpu_usage_seconds_total{container=~"cert-manager.*"}[5m])[7d:5m])

cpu_limit (in millicores) = ninety_nine_percentile_cpu * 2 * 1,000

#### Memory
ninety_five_percentile_mem = quantile_over_time(0.95, container_memory_working_set_bytes{container=~"cert-manager.*"}[7d:5m])
ninety_nine_percentile_mem = quantile_over_time(0.99, container_memory_working_set_bytes{container=~"cert-manager.*"}[7d:5m])

memory_request =  ninety_five_percentile_mem * 1.1

memory_limit = ninety_nine_percentile_mem * 1.5

Prometheus returns memory in bytes, so you'll need to convert to either Gi or Mi (I just use a Google converter search)
