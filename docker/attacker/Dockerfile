# Image de CT-attacker : Alpine (léger) avec SSH et python pour Ansible.
# curl et nmap seront installés ensuite par le rôle attacker.
FROM alpine:3.22

RUN apk add --no-cache openssh-server python3 \
    && ssh-keygen -A \
    && sed -i 's/^root:[^:]*:/root:*:/' /etc/shadow
# la ligne sed débloque le compte root : sinon sshd refuse même la connexion par clé

COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

CMD ["/usr/sbin/sshd", "-D"]
