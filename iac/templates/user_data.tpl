#!/bin/bash
# Script executado ao ligar a EC2 pela primeira vez para instalar dependências e rodar a API.

set -o errexit
set -o pipefail
set -o nounset

# Atualiza pacotes e instala cliente MySQL, Nginx e Python
apt update

apt -y install \
    net-tools \
    mysql-client \
    python3-pip \
    python3-venv \
    pkg-config \
    default-libmysqlclient-dev \
    nginx

# Cria o diretório da aplicação e configura ambiente virtual
mkdir -p /home/ubuntu/myapp
cd /home/ubuntu/myapp
python3 -m venv .
source ./bin/activate

# Concede permissão ao usuário ubuntu para os deploys via GitHub Actions (SCP)
chown -R ubuntu:ubuntu /home/ubuntu/myapp
chown -R ubuntu:ubuntu /var/www/html
chmod -R 775 /var/www/html

# Instala as dependências do Flask
pip install \
    flask \
    flask-mysqldb \
    flask-cors

# Cria o serviço systemd para manter a API online em background
cat <<EOF > /etc/systemd/system/myapp.service
[Unit]
Description=Aplicativo Flask em ambiente de testes
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/myapp
Environment="PATH=/home/ubuntu/myapp/bin"
ExecStart=/home/ubuntu/myapp/bin/python3 myapi.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Habilita o serviço para rodar sempre que a máquina ligar
systemctl enable myapp.service
systemctl start myapp.service