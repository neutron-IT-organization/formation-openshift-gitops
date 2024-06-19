# Formation openshift Gitops

This repo contains the material to deploy the argoCD applications.

## Deploy ArgoCD, cluster-wide subscriptions and create namespaces (in the gitops version we have now, we can't add labels when they are created by ArgoCD)

```shell
oc apply -f prereq/sub.yaml
oc apply -f prereq/argoCd.yaml
```

## OpenShift GitOps

```sh
oc patch argocd openshift-gitops -n openshift-gitops -p '{"spec":{"server":{"insecure":true,"route":{"enabled": true,"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}}}' --type=merge
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops-operator:argocd-argocd-application-controller
```

## Configure the infrastructure for the workshop

Create the argoCD headquarter project

```shell
oc apply -f opp/argocd/project.yaml
```

Create the argoCD Application

```shell
oc apply -f opp/argocd/application.yaml
```

## Cleanup

```shell
oc delete -f opp/argocd/application.yaml
oc delete -f gitops/sub.yaml
oc delete -f gitops/ns.yaml
```

