tf_aws_ecs_application_reverse_proxy
====================================

This nginx image is used to act as a reverse proxy as sidecar container on an AWS ECS application.

# Requirements
The environment variable `NGINX_PROXY_URL` must be set to the application URL and port in oder to get the reverse proxy running.