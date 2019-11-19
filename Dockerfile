FROM docker.io/grafana/grafana
USER root
WORKDIR /usr/share/ca-certificates/<your org>
COPY <private_ca_file>.crt .
RUN echo "<your org>/<private_ca_file>.crt" >> /etc/ca-certificates.conf && update-ca-certificates
