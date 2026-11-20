#!/bin/bash
# Seul script à lancer à la main, une fois, sur la VM : sudo ./bootstrap.sh
# Il installe Docker, crée le réseau infra_soc et démarre CT-manager.
# Ensuite tout le reste se fait avec Ansible depuis CT-manager.

set -e   # on s'arrête à la première erreur

if [ "$(id -u)" -ne 0 ]; then
    echo "Il faut lancer le script avec sudo"
    exit 1
fi

# dossier où se trouve le projet (là où est ce script)
PROJET=$(cd "$(dirname "$0")" && pwd)

echo "== 1/5 Installation de Docker et du serveur SSH"
apt-get update -q
apt-get install -y -q docker.io openssh-server
systemctl enable --now docker ssh

echo "== 2/5 Réseau infra_soc"
# on ne le crée que s'il n'existe pas déjà
if ! docker network inspect infra_soc > /dev/null 2>&1; then
    docker network create --subnet 192.168.70.0/24 --gateway 192.168.70.1 infra_soc
fi

echo "== 3/5 Clé SSH pour qu'Ansible puisse se connecter à la VM"
# la clé reste dans ssh_keys/ qui est dans le .gitignore
mkdir -p "$PROJET/ssh_keys"
if [ ! -f "$PROJET/ssh_keys/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$PROJET/ssh_keys/id_ed25519" -C ansible-manager
fi
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
# on ajoute la clé publique seulement si elle n'y est pas déjà
if ! grep -qF -f "$PROJET/ssh_keys/id_ed25519.pub" /root/.ssh/authorized_keys; then
    cat "$PROJET/ssh_keys/id_ed25519.pub" >> /root/.ssh/authorized_keys
fi
chmod 600 /root/.ssh/authorized_keys

echo "== 4/5 Construction de l'image de CT-manager"
docker build -t soc-manager "$PROJET/docker/manager"

echo "== 5/5 Démarrage de CT-manager (192.168.70.10)"
# on supprime l'ancien CT-manager s'il existe, pour qu'il reparte sur la dernière image.
# Rien n'est perdu : le projet est sur la VM, monté dans /projet.
docker rm -f CT-manager > /dev/null 2>&1 || true

# --restart unless-stopped : le conteneur redémarre tout seul quand on rallume la VM
docker run -d --name CT-manager --hostname CT-manager \
    --restart unless-stopped \
    --network infra_soc --ip 192.168.70.10 \
    -v "$PROJET":/projet \
    soc-manager

echo
echo "C'est prêt. Pour lancer le déploiement :"
echo "  sudo docker exec -it CT-manager ansible-playbook deploy_soc.yml --ask-vault-pass"
