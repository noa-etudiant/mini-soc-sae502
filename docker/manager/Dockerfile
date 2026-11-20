# Image de CT-manager : juste Debian avec Ansible et un client SSH
# Debian 13 comme la VM : avec Debian 12, le module docker d'Ansible est trop vieux
# et ne marche pas avec la librairie python requests de la VM
FROM debian:13

# le paquet ansible de Debian contient déjà la collection community.docker
RUN apt-get update \
    && apt-get install -y --no-install-recommends ansible openssh-client python3 curl \
    && rm -rf /var/lib/apt/lists/*

# le dossier du projet est monté ici par bootstrap.sh
WORKDIR /projet

# on garde le conteneur allumé pour pouvoir lancer ansible dedans
CMD ["sleep", "infinity"]
