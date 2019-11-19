How to use grafana with OpenID Connect

getting the grafana image from the registry

# podman pull grafana/grafana

now start the container to copy the grafana.ini file

# podman run -d --name=grafana -p 3000:3000 grafana/grafana

now copy the grafana.ini file to your working directory
(or just use my)
# podman cp --pause=false 03e05fb048dd:/etc/grafana/grafana.ini ./

now add the following values:

<code>
[auth.generic_oauth]
enabled = true
name = OAuth
allow_sign_up = true
client_id = <some_id>
client_secret = <some_secret>
scopes = openid profile email
email_attribute_name = sub
auth_url = https://foo.bar/login/oauth/authorize
token_url = https://foo.bar/login/oauth/access_token
api_url = https://foo.bar/user
allow_sign_up = true
</code>

make sure you redirect to your openid connect realm

now create a new Dockerfile
(or use my)
#cat > Dockerfile << EOF
FROM docker.io/grafana/grafana
USER root
WORKDIR /usr/share/ca-certificates/<your org>
COPY <private_ca_file>.crt .
RUN echo "<your org>/<private_ca_file>.crt" >> /etc/ca-certificates.conf && update-ca-certificates
EOF

now rebuild the container
# buildah 

in order to run it in OpenShift I will recommand to add a ConfigMap
for the grafana.ini

#oc create configmap grafana-main --from-file=grafana.ini

now we will update the DC YAML to add the ConfigMap
with the following values :

#oc edit dc/grafana
<code>
       terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/grafana/grafana.ini
          name: grafana-main
          subPath: grafana.ini
      volumes:
      - configMap:
          defaultMode: 420
          name: grafana-main
        name: grafana-main
...
</code>

you are ready to use grafana with OpenID Connect

