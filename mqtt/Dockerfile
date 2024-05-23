FROM eclipse-mosquitto:2.0.15

ENV MQTT_USERNAME=mqtt-user
ENV MQTT_PASSWORD=mqtt-pwd

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 1883

ENTRYPOINT []

CMD ["/entrypoint.sh"]
