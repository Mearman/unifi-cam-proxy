#!/bin/bash

# function to generate and return a random colon separated mac address
gen_mac() {
	# generate a random mac address
	MAC=$(printf '%02X:%02X:%02X:%02X:%02X:%02X' $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))
	# return the mac address
	echo $MAC
}

# function to accept a path parameter and generate a pem
create_cert() {
	if [ -z "$1" ]; then
		echo "No path specified"
		exit 1
	fi
	if [ -f "$1" ]; then
		echo "File already exists"
		exit 1
	fi
	# openssl req -x509 -newkey rsa:2048 -keyout $1 -out $1 -days 365 -nodes -subj "/CN=${HOSTNAME}"

	# get parent directory of the cert arg
	CERT_DIR=$(dirname $1)
	# create parent directories if they don't exist
	mkdir -p $CERT_DIR

	openssl ecparam -out $CERT_DIR/private.key -name prime256v1 -genkey -noout
	openssl req -new -sha256 -key $CERT_DIR/private.key -out $CERT_DIR/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
	openssl x509 -req -sha256 -days 36500 -in $CERT_DIR/server.csr -signkey $CERT_DIR/private.key -out $CERT_DIR/public.key
	cat $CERT_DIR/private.key $CERT_DIR/public.key >$1
	rm -f $CERT_DIR/private.key $CERT_DIR/public.key $CERT_DIR/server.csr
}

# if RTSP_URL or CAM_CONFIG is set
if [ -n "$RTSP_URL" ] || [ -n "$CAM_CONFIG" ]; then
	echo "Starting with RTSP_URL or CAM_CONFIG"
	# if CERT is unset, if not, set to /client.pem
	if [ -z "$CERT" ]; then
		echo "CERT is unset, setting to /client.pem"
		CERT="/client.pem"
		# if no file exists at /client.pem, generate it
		if [ ! -f "$CERT" ]; then
			# set CERT to /config/clients.pem
			CERT="/config/clients.pem"
			echo "Creating $CERT"
			# call create cert function with destination path
			create_cert "$CERT"
		fi
	fi
	# if MAC is unset, if not, set to random mac
	if [ -z "$MAC" ]; then
		echo "MAC is unset, setting to random mac"
		# MAC=$(gen_mac 02)
		MAC=$(gen_mac)
		echo "MAC: $MAC"
	fi
	# if name is unset
	if [ -z "$NAME" ]; then
		# default name to unifi-cam-proxy appended by a shortened version of the mac address with the colons removed
		echo "NAME is unset, setting to random name"
		# NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
		NAME="unifi-cam-proxy-$(echo $MAC | cut -d: -f4-6 | tr -d ':')"
	fi

	# check if HOST and TOKEN are set
	if [ -n "$HOST" ] && [ -n "$TOKEN" ]; then
		#   check that only one of RTSP_URL and CAM_CONFIG is set
		if [ -n "$RTSP_URL" ] && [ -n "$CAM_CONFIG" ]; then
			echo "Only one of RTSP_URL and CAM_CONFIG can be set"
			exit 1
		else
			if [ -n "$RTSP_URL" ]; then
				echo "Starting with RTSP_URL"
				exec unifi-cam-proxy --host "$HOST" --name "$NAME" --mac "$MAC" --cert "$CERT" --token "$TOKEN" rtsp -s "$RTSP_URL"
			# else if CAM_CONFIG is set
			elif [ -n "$CAM_CONFIG" ]; then
				# decalre an array containing the cam types
				declare -a CAM_TYPES=("rtsp" "frigate" "amcrest" "dahua" "hikvision" "reolink" "reolink_nvr")
				# exit if the first wortd of CAM_CONFIG is not one of CAM_TYPES
				if [[ ! " ${CAM_TYPES[@]} " =~ " ${CAM_CONFIG%% *} " ]]; then
					echo "Invalid CAM_CONFIG"
					exit 1
				else
					echo "Starting with CAM_CONFIG"
					exec unifi-cam-proxy --host "$HOST" --name "$NAME" --mac "$MAC" --cert "$CERT" --token "$TOKEN" ${CAM_CONFIG}
				fi
			fi
		fi
	else
		echo "HOST and TOKEN must be set"
		exit 1
	fi
# else check if more than one arg was passed in
elif [ "$#" -gt 1 ]; then
	# elif [ "$#" -gt 0 ]; then
	# print provided args
	echo "No RTSP_URL or CAM_CONFIG set"
	echo "Directly executing post args"
	echo "$@"
	# exec but print error message if crash and then exit 1
	exec "$@" || {
		echo "Failed to execute $@"
		echo "For help see https://unifi-cam-proxy.com"
		exit 1
	}
else # no args passed in
	echo "No args passed in and no RTSP_URL or CAM_CONFIG set"
	echo "For help see https://unifi-cam-proxy.com"
	exit 1
fi
