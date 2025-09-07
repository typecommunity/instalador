#!/bin/bash
# 
# system management - CORREÇÕES PRINCIPAIS

#######################################
# delete system - CORRIGIDO
# Arguments:
#   None
#######################################
deletar_tudo() {
  print_banner
  printf "${WHITE} 💻 Vamos deletar o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Parar container Redis
  sudo su - root <<EOF
  docker container rm redis-${empresa_delete} --force
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-backend  
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-backend
EOF

  sleep 2

  # Deletar banco PostgreSQL
  sudo su - postgres <<EOF
  psql <<SQL
DROP DATABASE IF EXISTS ${empresa_delete};
DROP USER IF EXISTS ${empresa_delete};
SQL
EOF

  sleep 2

  # Remover arquivos e processos PM2
  sudo su - deploy <<EOF
  rm -rf /home/deploy/${empresa_delete}
  pm2 delete ${empresa_delete}-frontend ${empresa_delete}-backend
  pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Remoção da Instancia/Empresa ${empresa_delete} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# installs node - CORRIGIDO COM POSTGRESQL
# Arguments:
#   None
#######################################
system_node_install() {
  print_banner
  printf "${WHITE} 💻 Instalando nodejs e PostgreSQL...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  # Instalar Node.js
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt-get install -y nodejs
  
  sleep 2
  
  # Atualizar npm
  npm install -g npm@latest
  
  sleep 2
  
  # Instalar PostgreSQL
  apt-get install -y wget ca-certificates
  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  apt-get update -y 
  apt-get -y install postgresql postgresql-contrib
  
  # Iniciar PostgreSQL
  systemctl start postgresql
  systemctl enable postgresql
  
  sleep 2
  
  # Configurar timezone
  timedatectl set-timezone America/Sao_Paulo
EOF

  sleep 2
}
