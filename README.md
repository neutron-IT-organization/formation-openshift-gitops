# Formation OpenShift - Infrastructure GitOps

Ce dépôt contient toute l'infrastructure GitOps pour la formation OpenShift. Il gère :
- L'authentification HTPasswd des étudiants
- Les namespaces avec quotas, limites et network policies
- Les prérequis déployés avant chaque exercice via ArgoCD

## Cluster de Formation

| Ressource | URL |
|-----------|-----|
| Console OpenShift | https://console-openshift-console.apps.neutron-sno-office.neutron-it.fr |
| API OpenShift | https://api.neutron-sno-office.neutron-it.fr:6443 |
| ArgoCD | https://argocd-server-openshift-gitops.apps.neutron-sno-office.neutron-it.fr |

---

## Identifiants des Étudiants

**Mot de passe commun pour tous les utilisateurs :** `OpenShift4formation!`

| Étudiant | Username | Namespace |
|----------|----------|-----------|
| Tokyo | `tokyo-user` | `tokyo-user-ns` |
| Paris | `paris-user` | `paris-user-ns` |
| Londres | `londres-user` | `londres-user-ns` |
| Rome | `rome-user` | `rome-user-ns` |
| Sydney | `sydney-user` | `sydney-user-ns` |
| Rio | `rio-user` | `rio-user-ns` |
| Istanbul | `istanbul-user` | `istanbul-user-ns` |
| Berlin | `berlin-user` | `berlin-user-ns` |
| Nairobi | `nairobi-user` | `nairobi-user-ns` |
| Madrid | `madrid-user` | `madrid-user-ns` |
| Toronto | `toronto-user` | `toronto-user-ns` |
| Singapour | `singapour-user` | `singapour-user-ns` |
| Stockholm | `stockholm-user` | `stockholm-user-ns` |
| Athènes | `athenes-user` | `athenes-user-ns` |
| Varsovie | `varsovie-user` | `varsovie-user-ns` |
| Oslo | `oslo-user` | `oslo-user-ns` |
| Helsinki | `helsinki-user` | `helsinki-user-ns` |
| Lisbonne | `lisbonne-user` | `lisbonne-user-ns` |
| Vienne | `vienne-user` | `vienne-user-ns` |
| Brasilia | `brasilia-user` | `brasilia-user-ns` |
| Canberra | `canberra-user` | `canberra-user-ns` |
| Ottawa | `ottawa-user` | `ottawa-user-ns` |
| Séoul | `seoul-user` | `seoul-user-ns` |
| Le Cap | `cap-user` | `cap-user-ns` |
| Budapest | `budapest-user` | `budapest-user-ns` |
| Dublin | `dublin-user` | `dublin-user-ns` |
| Zurich | `zurich-user` | `zurich-user-ns` |
| Cardiff | `cardiff-user` | `cardiff-user-ns` |
| Nicosie | `nicosie-user` | `nicosie-user-ns` |
| Sofia | `sofia-user` | `sofia-user-ns` |
| Suva | `suva-user` | `suva-user-ns` |
| Riga | `riga-user` | `riga-user-ns` |
| Vilnius | `vilnius-user` | `vilnius-user-ns` |
| Alger | `alger-user` | `alger-user-ns` |
| Abou Dabi | `abou-dabi-user` | `abou-dabi-user-ns` |
| Bagdad | `bagdad-user` | `bagdad-user-ns` |
| Bangkok | `bangkok-user` | `bangkok-user-ns` |
| Le Caire | `le-caire-user` | `le-caire-user-ns` |
| Freetown | `freetown-user` | `freetown-user-ns` |
| Kaboul | `kaboul-user` | `kaboul-user-ns` |
| Kinshasa | `kinshasa-user` | `kinshasa-user-ns` |
| Libreville | `libreville-user` | `libreville-user-ns` |
| Mexico | `mexico-user` | `mexico-user-ns` |
| Reykjavik | `reykjavik-user` | `reykjavik-user-ns` |
| Prague | `prague-user` | `prague-user-ns` |

**Compte admin ArgoCD :** `admin` / `OpenShift4formation!`

---

## Sécurité par Namespace

Chaque namespace étudiant est configuré automatiquement avec :

### ResourceQuota
- CPU requests : 4 cores max | Memory requests : 4 Gi max
- CPU limits : 8 cores max | Memory limits : 8 Gi max
- Pods : 20 max | Services : 10 max | PVCs : 5 max | Storage : 20 Gi max

### LimitRange (valeurs par défaut si non spécifiées par l'étudiant)
- CPU : request 100m / limit 500m
- Memory : request 128Mi / limit 512Mi

### NetworkPolicies
- `allow-same-namespace` : trafic autorisé entre pods du même namespace
- `allow-from-openshift-ingress` : accès depuis l'ingress controller (Routes)
- `allow-from-openshift-monitoring` : accès depuis Prometheus/monitoring

### RBAC
- `admin` sur son propre namespace
- `view` sur le namespace partagé `l03p02` (exercice 2.2)
- `self-provisioner` (ClusterRoleBinding)

---

## Structure du Dépôt

```
├── prereq/                    # Bootstrap (une seule fois)
│   ├── ns.yaml                # Namespaces
│   ├── sub.yaml               # Subscriptions opérateurs
│   ├── argoCd.yaml            # Configuration ArgoCD
│   └── consoleLink.yaml       # Lien console
├── gitops/
│   ├── project.yaml           # AppProject ArgoCD
│   ├── auth/                  # Auth + RBAC + quotas + network policies
│   ├── l03p02/                # Prérequis Exercice 2.2 (namespace partagé)
│   ├── l04p01/                # Prérequis Exercice 4 (Olympic Medals App)
│   ├── l05p01/                # Prérequis Exercice 5.1 (Welcome App)
│   ├── l05p02/                # Prérequis Exercice 5.2 (Postgres + Todo App)
│   └── l06p01/                # Prérequis Exercice 6.1 (Probes App)
```

---

## Déploiement Initial (Bootstrap)

### 1. Prérequis cluster

```bash
oc apply -f prereq/ns.yaml
oc apply -f prereq/sub.yaml
# Attendre que l'opérateur GitOps soit prêt (~2 min)
sleep 120
oc apply -f prereq/argoCd.yaml
oc apply -f prereq/consoleLink.yaml
```

### 2. Configuration ArgoCD

```bash
oc patch argocd openshift-gitops -n openshift-gitops \
  -p '{"spec":{"server":{"insecure":true,"route":{"enabled":true,"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}}}' \
  --type=merge

oc adm policy add-cluster-role-to-user cluster-admin \
  system:serviceaccount:openshift-gitops:argocd-argocd-application-controller
```

### 3. Déployer l'authentification et la config de base

```bash
oc apply -f gitops/project.yaml
oc apply -f gitops/auth/argocd/application.yaml
oc apply -f gitops/l03p02/application.yaml
```

---

## Déploiement des Prérequis par Exercice

Activez les prérequis **avant chaque module** correspondant :

```bash
# Exercice Module 4 - Réseaux (Olympic Medals App dans chaque namespace)
oc apply -f gitops/l04p01/appset.yaml

# Exercice Module 5.1 - ConfigMaps & Secrets (Welcome App)
oc apply -f gitops/l05p01/appset.yaml

# Exercice Module 5.2 - PV/PVC/Storage (Postgres + Todo App)
oc apply -f gitops/l05p02/appset.yaml

# Exercice Module 6.1 - Probes (Probes App)
oc apply -f gitops/l06p01/appset.yaml
```

**Tout déployer d'un coup :**
```bash
oc apply -f gitops/l04p01/appset.yaml \
         -f gitops/l05p01/appset.yaml \
         -f gitops/l05p02/appset.yaml \
         -f gitops/l06p01/appset.yaml
```

**Vérifier que tout est Running :**
```bash
# Vérifier les ApplicationSets dans ArgoCD
oc get applicationset -n openshift-gitops

# Vérifier les pods dans un namespace étudiant
oc get pods -n prague-user-ns
```

---

## Cleanup Complet

### 1. Supprimer les prérequis d'exercices

```bash
oc delete applicationset l04p01-olympic-medals -n openshift-gitops --ignore-not-found
oc delete applicationset l05p01-welcome-app -n openshift-gitops --ignore-not-found
oc delete applicationset l05p02-postgres-todo -n openshift-gitops --ignore-not-found
oc delete applicationset l06p01-probes-app -n openshift-gitops --ignore-not-found
```

### 2. Supprimer les applications ArgoCD

```bash
oc delete application auth -n openshift-gitops --ignore-not-found
oc delete application l03p02 -n openshift-gitops --ignore-not-found
oc delete -f gitops/project.yaml --ignore-not-found
```

### 3. Supprimer l'authentification HTPasswd

```bash
# Retirer le provider de l'OAuth
oc patch oauth cluster --type=json \
  -p='[{"op":"remove","path":"/spec/identityProviders/0"}]'

# Supprimer le secret
oc delete secret htpasswd-formation -n openshift-config --ignore-not-found

# Supprimer les utilisateurs et identités
for city in tokyo paris londres rome sydney rio istanbul berlin nairobi madrid toronto singapour stockholm athenes varsovie oslo helsinki lisbonne vienne brasilia canberra ottawa seoul cap budapest dublin zurich cardiff nicosie sofia suva riga vilnius alger abou-dabi bagdad bangkok le-caire freetown kaboul kinshasa libreville mexico reykjavik prague; do
  oc delete user ${city}-user --ignore-not-found 2>/dev/null
  oc delete identity "Neutron Guest Identity Management:${city}-user" --ignore-not-found 2>/dev/null
done
oc delete user admin --ignore-not-found 2>/dev/null
```

### 4. Supprimer les ClusterRoleBindings

```bash
for city in tokyo paris londres rome sydney rio istanbul berlin nairobi madrid toronto singapour stockholm athenes varsovie oslo helsinki lisbonne vienne brasilia canberra ottawa seoul cap budapest dublin zurich cardiff nicosie sofia suva riga vilnius alger abou-dabi bagdad bangkok le-caire freetown kaboul kinshasa libreville mexico reykjavik prague; do
  oc delete clusterrolebinding ${city}-user-self-provisioner --ignore-not-found 2>/dev/null
done
```

### 5. Supprimer les namespaces

```bash
oc delete -f prereq/ns.yaml --ignore-not-found
```

### 6. (Optionnel) Supprimer les opérateurs

```bash
oc delete -f prereq/sub.yaml --ignore-not-found
oc delete -f prereq/argoCd.yaml --ignore-not-found
oc delete -f prereq/consoleLink.yaml --ignore-not-found
```

---

## Modifier le mot de passe

Dans `gitops/auth/chart/values.yaml`, modifiez :
```yaml
openshift:
  defaultPassword: "NouveauMotDePasse!"
```

Puis `git commit && git push` — ArgoCD synchronise automatiquement.

## Troubleshooting

| Problème | Solution |
|----------|----------|
| Étudiant ne peut pas se connecter | `oc get secret htpasswd-formation -n openshift-config` et vérifier les pods `openshift-authentication` |
| Pod ne démarre pas (quota) | `oc describe resourcequota formation-quota -n <city>-user-ns` |
| ArgoCD ne sync pas | Forcer : `oc get application -n openshift-gitops` puis sync dans l'UI |
| Accès refusé entre namespaces | Normal : les NetworkPolicies bloquent le trafic cross-namespace |
