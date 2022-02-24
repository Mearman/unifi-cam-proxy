#!/bin/bash
set -e

# get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# cd to script directory
cd $SCRIPT_DIR

docker build -t unifi-cam-proxy-for-dummies .

# ask user if they would like to run the container
read -p "Would you like to run the container? [y/N] " -n 1 -r
# if user enteres nothing or no, exit
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	exit 0
fi

# stop and remove unifi-cam-proxy-test container if necessary
echo "Stopping and removing unifi-cam-proxy-test container if necessary"
docker stop unifi-cam-proxy-test || true
docker rm unifi-cam-proxy-test || true

ADOPTION_TOKEN=""
NVR_IP=""
CAM_CONFIG=""

source .env || true

# if adoption token is empty
if [ -z "$ADOPTION_TOKEN" ]; then
	read -p "Please enter your adoption token: " -r ADOPTION_TOKEN
fi

# if nvr ip is empty
if [ -z "$NVR_IP" ]; then
	read -p "Please enter the IP address of your NVR: " -r NVR_IP
fi

# if cam config is empty
if [ -z "$CAM_CONFIG" ]; then
	read -p "Please enter the camera configuration: " -r CAM_CONFIG
fi

echo "Initializing unifi-cam-proxy-test container"
docker run --name='unifi-cam-proxy-test' --net='host' -e TZ="Europe/London" -e HOST_OS="Unraid" -e 'HOST'=${NVR_IP} -e 'MAC'='' -e 'TOKEN'="${ADOPTION_TOKEN}" -e 'CAM_CONFIG'="${CAM_CONFIG}" -e 'CERT'='/config/client.pem' -v '/mnt/user/appdata/unifi-cam-proxy-test':'/config':'rw' --restart unless-stopped 'unifi-cam-proxy-for-dummies' &
