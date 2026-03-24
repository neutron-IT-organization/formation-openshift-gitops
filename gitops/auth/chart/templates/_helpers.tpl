{{/* vim: set filetype=mustache: */}}

{{/* Génère la liste complète des utilisateurs (admin + city-user) */}}
{{- define "openshift-users" -}}
{{- $stash := dict "result" (list "admin")  -}}
{{- range $user := .Values.openshift.users }}
{{- $_ := printf "%s-user" $user | append $stash.result | set $stash "result" -}}
{{- end -}}
{{- toJson $stash.result -}}
{{- end -}}

{{/* Génère le fichier htpasswd avec le mot de passe commun pour tous les utilisateurs */}}
{{- define "openshift-htpasswd" -}}
{{- range (include "openshift-users" . | fromJsonArray) }}
{{ htpasswd . $.Values.openshift.defaultPassword }}
{{- end -}}
{{- end -}}

{{/* Génère le fichier users.txt (username:password en clair) pour référence */}}
{{- define "openshift-users-txt" -}}
{{- range (include "openshift-users" . | fromJsonArray) }}
{{ . }}:{{ $.Values.openshift.defaultPassword }}
{{- end -}}
{{- end -}}

{{/* Retourne le nom du namespace pour un utilisateur city */}}
{{- define "user-namespace" -}}
{{- printf "%s-user-ns" . -}}
{{- end -}}
