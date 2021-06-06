
{{/*
Effective App version (now: docker image version)
*/}}
{{- define "app.version" -}}
{{- .Chart.AppVersion }}
{{- end }}

{{/*
Effective Chart version (supposed to change whenever the templates/dependencies or the App version changes)
*/}}
{{- define "chart.version" -}}
{{- .Chart.Version }}
{{- end }}

{{/*
Selector labels (for Deployment/Pods, Service/Pods, etc)
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.appName }}
{{- end }}

{{/*
Chart name with version
*/}}
{{- define "app.chartNameVersion" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
All standard labels
*/}}
{{- define "app.allLabels" -}}
{{ include "app.selectorLabels" . }}
helm.sh/chart: {{ include "app.chartNameVersion" . }}
app.kubernetes.io/version: {{ include "chart.version" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Helm-Test-Pod labels
*/}}
{{- define "helm-test.labels" -}}
app.kubernetes.io/name: helm-test-{{ .Values.appName }}
helm.sh/chart: {{ include "app.chartNameVersion" . }}
app.kubernetes.io/version: {{ include "chart.version" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
