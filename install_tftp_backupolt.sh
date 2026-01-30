#!/bin/bash

set -e

echo "==> Atualizando pacotes"
apt update -y

echo "==> Instalando tftpd-hpa"
apt install -y tftpd-hpa

echo "==> Criando usuário backupolt"
if ! id backupolt >/dev/null 2>&1; then
    useradd -m -s /bin/bash backupolt
    echo 'backupolt:B3ni0808@#$' | chpasswd
fi

echo "==> Criando diretório do TFTP"
mkdir -p /srv/tftp

echo "==> Ajustando permissões"
chown -R backupolt:backupolt /srv/tftp
chmod -R 775 /srv/tftp

echo "==> Configurando tftpd-hpa"
cat <<EOF >/etc/default/tftpd-hpa
TFTP_USERNAME="backupolt"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure --create"
EOF

echo "==> Reiniciando serviço TFTP"
systemctl daemon-reexec
systemctl enable tftpd-hpa
systemctl restart tftpd-hpa

echo "==> Status do serviço:"
systemctl status tftpd-hpa --no-pager

echo "==> TFTP instalado e funcionando em 10.50.50.1"
