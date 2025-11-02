tf_aws_ecs_application_reverse_proxy
====================================

This nginx image is used to act as a reverse proxy as sidecar container on an AWS ECS application.

# Requirements
The environment variable `NGINX_PROXY_URL` must be set to the application URL and port in oder to get the reverse proxy running.


# Environment Variables
| Variable | Description | Default Value |
|----------|-------------|---------------|
| `NGINX_PROXY_URL` | (Required) the target url where the requests are proxied to | |
| `NGINX_RATE_LIMIT_PER_SECOND` | (Optional) Sets the Rate Limit per second for IP based rate limiting | `10` | 
| `NGINX_RATE_LIMIT_BURST` | (Optional) Sets the burst limit for the application proxy | `10` |
