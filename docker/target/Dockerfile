# Image de CT-target : Debian avec SSH et python, pour qu'Ansible puisse s'y connecter.
# Apache et Filebeat seront installés ensuite par le rôle target.
FROM debian:13

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# la clé publique de CT-manager, copiée ici par Ansible avant le build
COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

# sshd au premier plan pour que le conteneur reste allumé
CMD ["/usr/sbin/sshd", "-D"]
