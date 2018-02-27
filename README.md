# P9 Instance Monitor

Cachet-based montoring script for Platform9 Kubernetes and Openstack Deployment Units.

## Sample Config File (for Kubernetes Instance)
instanceGroup=Autodesk K8 Cluster-1|P9 Kubernetes Instance
instance=kube-apiserver|P9 Kubernetes Platform Component
instance=kube-scheduler|P9 Kubernetes Platform Component
instance=kube-controller|P9 Kubernetes Platform Component
instance=kube-etcd|P9 Kubernetes Platform Component

## Cachet REST API Usage Notes
**1. get all components**
* curl http://10.238.0.11/api/v1/components | python -m json.tool

**2. create a component group**
* curl -i -H "X-Cachet-Token: GXW5ryAH9n2CEytjpXDw" -H "Content-Type: application/json" -X POST -d '{"name":"Instance Name","description":"My Kubernetes Instance","status":1}' http://10.238.0.11/api/v1/components/groups

**3. update a component**
* curl -i -H "X-Cachet-Token: GXW5ryAH9n2CEytjpXDw" -H "Content-Type: application/json" -X PUT -d '{"description":"We are experiencing an outage","status":4}' http://10.238.0.11/api/v1/components/7

* curl -i -H "X-Cachet-Token: GXW5ryAH9n2CEytjpXDw" -H "Content-Type: application/json" -X PUT -d '{"description":"We are experiencing an outage","status":4}' http://10.238.0.11/api/v1/components/2

* curl -i -H "X-Cachet-Token: GXW5ryAH9n2CEytjpXDw" -H "Content-Type: application/json" -X POST -d '{"name":"Component-1","description":"My Description","status":1, "group_id":1}' http://10.238.0.11/api/v1/components

**4. delete a component**
* curl -i -H "X-Cachet-Token: GXW5ryAH9n2CEytjpXDw" -H "Content-Type: application/json" -X DELETE http://10.238.0.11/api/v1/components/1
