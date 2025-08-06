### Safely rolling nodes
There are a number of processes that will force all the nodes in a cluster to roll over, including pgrading node kubernetes versions, other changes to the Node group, such as changing the Instance Type or any changes whatsoever to the User Data block.

#### Pre-work
1. Put the [cluster monitor group](https://www.site24x7.com/app/client#/home/monitor-groups/195989000086800154/summary) in maintenance mode on Site24x7. Go to the monitor group, select the hamburger menu next to the name, and select a duration under "Schedule maintenance" (most likely 60 minutes).
1. Check the application monitor groups, and make sure they are green.
1. Pull up the [Rancher / Cluster (Nodes) monitor](https://r.notch8.cloud/k8s/clusters/c-6zfxc/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-grafana:80/proxy/d/rancher-cluster-nodes-1/rancher-cluster-nodes?orgId=1) and check the current behavior. Once you start rolling over the nodes, some of the graphs will get pretty erratic for a little bit as old nodes go down and new nodes go up, but what you're looking for is that the new nodes seem to actually be taking over the load from the old nodes (not just coming up and not getting any traffic).
1. You can also pull up the [Cluster Nodes view in Rancher](https://r.notch8.cloud/dashboard/c/c-6zfxc/explorer/node). This is where you'll see nodes cordoned and drained, and new nodes coming up.

#### Roll the nodes
<!-- More to come here -->

#### Post-work
1. Go to the monitors listed in pre-work and ensure that the nodes have stabilized, and that they appear to be getting traffic. 
1. Pull up all the [pods on the cluster](https://r.notch8.cloud/dashboard/c/c-6zfxc/explorer/pod) and ensure it is showing All Namespaces. Sort by "Restarts" and ensure there are no pods continually re-starting (restarts indicate a potential problem), and sort by "State" and make sure that there aren't any in "crashloopback" or other bad states.
1. View the logs of a few production rails pods and make sure they appear to be getting traffic (if the log just shows they've come up successfully, but nothing else, most likely no traffic is coming through to the logs)
1. Delete Site24x7 monitors for nodes that have been scaled down. First check that the new nodes are showing green in the [GCCluster monitor group](https://www.site24x7.com/app/client#/home/monitor-groups/195989000086800154/summary). Then go to [Bulk action -> Delete monitors](https://www.site24x7.com/app/client#/admin/inventory/bulk-action/8/filter) and add filters for "Monitor Group is GCCluster" and "Monitor Status is Maintenance" (the new nodes should show as "Active" in this list, not "Maintenance"), hit search, then do a sanity check of the number of monitors it wants to delete, and if it seems correct, delete the old monitors. Then you can take the monitor out of maintenance.
![Filters for deleting monitors](image.png)
