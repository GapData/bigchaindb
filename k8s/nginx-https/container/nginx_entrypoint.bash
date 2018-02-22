#!/bin/bash
set -euo pipefail

# Cluster vars
cluster_fqdn=`printenv CLUSTER_FQDN`
cluster_frontend_port=`printenv CLUSTER_FRONTEND_PORT`


# NGINX vars
dns_server=`printenv DNS_SERVER`
health_check_port=`printenv HEALTH_CHECK_PORT`
authorization_mode=`printenv AUTHORIZATION_MODE`


# MongoDB vars
mongo_frontend_port=`printenv MONGODB_FRONTEND_PORT`
mongo_backend_host=`printenv MONGODB_BACKEND_HOST`
mongo_backend_port=`printenv MONGODB_BACKEND_PORT`


# OpenResty vars
openresty_backend_host=`printenv OPENRESTY_BACKEND_HOST`
openresty_backend_port=`printenv OPENRESTY_BACKEND_PORT`


# BigchainDB vars
bdb_backend_host=`printenv BIGCHAINDB_BACKEND_HOST`
bdb_api_port=`printenv BIGCHAINDB_API_PORT`
bdb_ws_port=`printenv BIGCHAINDB_WS_PORT`

# Tendermint vars
tm_pub_key_access_port=`printenv TM_PUB_KEY_ACCESS_PORT`
tm_backend_host=`printenv TM_BACKEND_HOST`
tm_p2p_port=`printenv TM_P2P_PORT`

# sanity check
if [[ -z "${cluster_frontend_port:?CLUSTER_FRONTEND_PORT not specified. Exiting!}" || \
      -z "${mongo_frontend_port:?MONGODB_FRONTEND_PORT not specified. Exiting!}" || \
      -z "${mongo_backend_host:?MONGODB_BACKEND_HOST not specified. Exiting!}" || \
      -z "${mongo_backend_port:?MONGODB_BACKEND_PORT not specified. Exiting!}" || \
      -z "${openresty_backend_port:?OPENRESTY_BACKEND_PORT not specified. Exiting!}" || \
      -z "${openresty_backend_host:?OPENRESTY_BACKEND_HOST not specified. Exiting!}" || \
      -z "${bdb_backend_host:?BIGCHAINDB_BACKEND_HOST not specified. Exiting!}" || \
      -z "${bdb_api_port:?BIGCHAINDB_API_PORT not specified. Exiting!}" || \
      -z "${bdb_ws_port:?BIGCHAINDB_WS_PORT not specified. Exiting!}" || \
      -z "${dns_server:?DNS_SERVER not specified. Exiting!}" || \
      -z "${health_check_port:?HEALTH_CHECK_PORT not specified. Exiting!}" || \
      -z "${cluster_fqdn:?CLUSTER_FQDN not specified. Exiting!}" || \
      -z "${tm_pub_key_access_port:?TM_PUB_KEY_ACCESS_PORT not specified. Exiting!}" || \
      -z "${tm_backend_host:?TM_BACKEND_HOST not specified. Exiting!}" || \
      -z "${tm_p2p_port:?TM_P2P_PORT not specified. Exiting!}" || \
      -z "${authorization_mode:-threescale}" ]]; then
  echo "Missing required environment variables. Exiting!"
  exit 1
else
  echo CLUSTER_FQDN="$cluster_fqdn"
  echo CLUSTER_FRONTEND_PORT="$cluster_frontend_port"
  echo DNS_SERVER="$dns_server"
  echo HEALTH_CHECK_PORT="$health_check_port"
  echo MONGODB_FRONTEND_PORT="$mongo_frontend_port"
  echo MONGODB_BACKEND_HOST="$mongo_backend_host"
  echo MONGODB_BACKEND_PORT="$mongo_backend_port"
  echo OPENRESTY_BACKEND_HOST="$openresty_backend_host"
  echo OPENRESTY_BACKEND_PORT="$openresty_backend_port"
  echo BIGCHAINDB_BACKEND_HOST="$bdb_backend_host"
  echo BIGCHAINDB_API_PORT="$bdb_api_port"
  echo BIGCHAINDB_WS_PORT="$bdb_ws_port"
  echo TM_PUB_KEY_ACCESS_PORT="$tm_pub_key_access_port"
  echo TM_BACKEND_HOST="$tm_backend_host"
  echo TM_P2P_PORT="$tm_p2p_port"
fi

# Set Default nginx config file
NGINX_CONF_FILE=/etc/nginx/nginx-threescale.conf

if [[ ${authorization_mode} == "secret-header" ]]; then
  NGINX_CONF_FILE=/etc/nginx/nginx.conf
  secret_access_token=`printenv SECRET_ACCESS_TOKEN`
  sed -i "s|SECRET_ACCESS_TOKEN|${secret_token_header}|g"
fi

# configure the nginx.conf file with env variables
sed -i "s|CLUSTER_FQDN|${cluster_fqdn}|g" ${NGINX_CONF_FILE}
sed -i "s|CLUSTER_FRONTEND_PORT|${cluster_frontend_port}|g" ${NGINX_CONF_FILE}
sed -i "s|MONGODB_FRONTEND_PORT|${mongo_frontend_port}|g" ${NGINX_CONF_FILE}
sed -i "s|MONGODB_BACKEND_HOST|${mongo_backend_host}|g" ${NGINX_CONF_FILE}
sed -i "s|MONGODB_BACKEND_PORT|${mongo_backend_port}|g" ${NGINX_CONF_FILE}
sed -i "s|OPENRESTY_BACKEND_PORT|${openresty_backend_port}|g" ${NGINX_CONF_FILE}
sed -i "s|OPENRESTY_BACKEND_HOST|${openresty_backend_host}|g" ${NGINX_CONF_FILE}
sed -i "s|BIGCHAINDB_BACKEND_HOST|${bdb_backend_host}|g" ${NGINX_CONF_FILE}
sed -i "s|BIGCHAINDB_API_PORT|${bdb_api_port}|g" ${NGINX_CONF_FILE}
sed -i "s|BIGCHAINDB_WS_PORT|${bdb_ws_port}|g" ${NGINX_CONF_FILE}
sed -i "s|DNS_SERVER|${dns_server}|g" ${NGINX_CONF_FILE}
sed -i "s|HEALTH_CHECK_PORT|${health_check_port}|g" ${NGINX_CONF_FILE}
sed -i "s|TM_PUB_KEY_ACCESS_PORT|${tm_pub_key_access_port}|g" ${NGINX_CONF_FILE}
sed -i "s|TM_BACKEND_HOST|${tm_backend_host}|g" ${NGINX_CONF_FILE}
sed -i "s|TM_P2P_PORT|${tm_p2p_port}|g" ${NGINX_CONF_FILE}

# start nginx
echo "INFO: starting nginx..."
exec nginx -c ${NGINX_CONF_FILE}
