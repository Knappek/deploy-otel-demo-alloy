 #!/bin/bash

: '
This script requires that you have the following values exported:
export ALLOY_CLOUD_OTLP_URL=
export ALLOY_CLOUD_OTLP_USERNAME_BASE64=
export ALLOY_CLOUD_OTLP_PASSSWORD_BASE64=
'

echo "
---
apiVersion: v1
kind: Namespace
metadata:
  name: collector
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: k8s-int-otlp-destinations
  namespace: collector
data:
  # In the k8s-monitoring chart v4, destinations is a MAP keyed by name
  # (it was a list in v2). The map key (otlp-gateway) is the destination name.
  destinations-list: |-
    destinations:
      otlp-gateway:
        type: otlp
        url: $ALLOY_CLOUD_OTLP_URL
        protocol: http
        auth:
          type: basic
          usernameKey: username
          passwordKey: password
        secret:
          create: false
          name: grafanacloud-otlphttp-secret
          namespace: collector
        metrics: {enabled: true}
        logs: {enabled: true}
        traces: {enabled: true}
---
apiVersion: v1
kind: Secret
metadata:
  name: grafanacloud-otlphttp-secret
  namespace: collector
type: Opaque
data:
  username: $ALLOY_CLOUD_OTLP_USERNAME_BASE64
  password: $ALLOY_CLOUD_OTLP_PASSSWORD_BASE64
" | kubectl apply -f -
