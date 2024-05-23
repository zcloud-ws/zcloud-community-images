#!/usr/bin/env sh

export MQTT_USERNAME=${MQTT_USERNAME:-"mqtt-user"}
export MQTT_PASSWORD=${MQTT_PASSWORD:-"mqtt-pwd"}

if [ ! -d /etc/mosquito ]; then
    mkdir -p /etc/mosquitto/conf.d
fi

if [ ! -f /etc/mosquito/passwd ]; then
  touch /etc/mosquitto/passwd
fi

if ! grep "${MQTT_USERNAME}" /etc/mosquitto/passwd > /dev/null 2>&1; then
    mosquitto_passwd -H sha512 -b /etc/mosquitto/passwd "${MQTT_USERNAME}" "${MQTT_PASSWORD}"
fi

cat <<EOF > /etc/mosquitto/mosquitto.conf
listener 1883
password_file /etc/mosquitto/passwd
persistence false
log_dest stdout
connection_messages true
log_dest stdout

include_dir /etc/mosquitto/conf.d

EOF

mosquitto -c /etc/mosquitto/mosquitto.conf
