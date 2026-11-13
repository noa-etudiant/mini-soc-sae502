# Mini-SOC automatisé avec Ansible — SAÉ 5.02

Déploiement **100 % automatisé** (Ansible) d'une petite infrastructure de détection
d'intrusions : un serveur web cible, un attaquant simulé, un agent de collecte de logs
(Filebeat) et une stack de centralisation (Elasticsearch + Kibana, sans Logstash).

## Architecture

Une seule VM hôte (VMware, Linux) avec Docker. Les 5 conteneurs tournent "à plat"
sur l'hôte (pas de Docker-in-Docker), sur le réseau bridge `infra_soc` (`192.168.70.0/24`).

| Conteneur          | IP              | Rôle                                        |
|--------------------|-----------------|---------------------------------------------|
| `CT-manager`       | 192.168.70.10   | Nœud de contrôle Ansible (+ doc Sphinx)     |
| `CT-elasticsearch` | 192.168.70.20   | Stockage / indexation des logs (port 9200)  |
| `CT-kibana`        | 192.168.70.25   | Interface web et alertes (port 5601)        |
| `CT-target`        | 192.168.70.30   | Apache + agent Filebeat                     |
| `CT-attacker`      | 192.168.70.40   | Génère du trafic malveillant (curl, nmap)   |

Flux : `CT-attacker` → HTTP → `CT-target` (Apache) → logs → Filebeat → `CT-elasticsearch` → `CT-kibana`

## Prérequis

- Une VM Linux (Debian/Ubuntu) avec au moins 4 Go de RAM
- Un accès Internet (téléchargement des images Docker)
- `git`

## Lancer le déploiement

> En cours de développement — cette section sera complétée au fil du projet.

```bash
git clone <url-du-depot>
cd mini-soc
./bootstrap.sh                      # installe Docker et démarre CT-manager
ansible-playbook deploy_soc.yml --ask-vault-pass
```

## Structure du dépôt

```
mini-soc/
├── deploy_soc.yml        # playbook principal
├── inventory/            # liste des machines gérées par Ansible
├── group_vars/all/       # variables (vars.yml) et secrets chiffrés (vault.yml)
├── roles/
│   ├── vm_prep/          # prépare la VM hôte (Docker, réseau, sysctl, conteneurs)
│   ├── siem/             # Elasticsearch + Kibana
│   ├── target/           # Apache + Filebeat
│   ├── attacker/         # script d'attaque + cron
│   └── soc_config/       # Data View, dashboard et règles via l'API Kibana
└── docs/                 # documentation technique (Sphinx)
```

## Sécurité

Aucun mot de passe en clair dans le dépôt : les secrets sont chiffrés avec `ansible-vault`
et le fichier de mot de passe du vault est exclu par le `.gitignore`.

## Suivi du projet

L'avancement est suivi dans l'onglet **Issues** (une tâche par étape) et les **Milestones**
(une par rôle Ansible).
