#!/bin/bash -e

function HELP {
  echo "usage: ${BASH_BIN} -e <ENV> -s <service> -v <main_version> -p <pod> -r <region> -m <method>"
  echo "The above switches are required.  The following are optional"
  echo "    -g <ras_go_version> used for ras and cas - defaults to the main_version"
  echo "    -i <ras_socketio_version> used for cas - defaults to the main_version"
  echo "    -n <ras_nginx_version> only used for ras - defaults to the main_version"
  exit 1
}

while getopts :e:s:v:p:r:m:g:i:n:h FLAG; do
  case $FLAG in
    e) echo set env
      ENV=${OPTARG}
      ;;
    s) echo set service
      SERVICE=${OPTARG}
      ;;
    v) echo set version
      MAIN_VERSION=${OPTARG}
      ;;
    p) echo set pod
      POD=${OPTARG}
      ;;
    r) echo set region
      REGION=${OPTARG}
      ;;
    m) echo set method
      DEPLOY_METHOD=${OPTARG}
      ;;
    g) echo set ras_go version
      RAS_GO_VERSION=${OPTARG}
      ;;
    n) echo set ras_nginx version
      RAS_NGINX_VERSION=${OPTARG}
      ;;
    h) echo show help
      HELP
      ;;
    \?) echo option not found
      echo "Option -${OPTARG} not allowed"
      HELP
      ;;
  esac
done
