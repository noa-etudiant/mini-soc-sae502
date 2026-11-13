# mini-soc-sae502

## Objectif

Déployer automatiquement avec Ansible un mini-SOC sur une VM avec Docker :
un serveur Apache cible avec Filebeat, un conteneur attaquant, et Elasticsearch + Kibana
pour centraliser les logs et générer des alertes.

## Prérequis

- Une VM Linux (Debian/Ubuntu) avec 4 Go de RAM minimum
- Un accès Internet
- git

## Lancer le déploiement

```bash
git clone https://github.com/noa-etudiant/mini-soc-sae502.git
cd mini-soc-sae502
./bootstrap.sh
ansible-playbook deploy_soc.yml --ask-vault-pass
```
