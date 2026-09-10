#!/usr/bin/env bash
# Script executado pelo Render a cada deploy.
# set -o errexit faz o build parar no primeiro erro, em vez de seguir
# e publicar uma versao quebrada.
set -o errexit

echo "==> Instalando gems"
bundle install

echo "==> Rodando migrations"
bundle exec rails db:migrate

# Popula o banco apenas quando a variavel RODAR_SEEDS estiver definida.
# Assim os dados de exemplo entram no primeiro deploy sem serem recriados
# a cada push seguinte.
if [ -n "$RODAR_SEEDS" ]; then
  echo "==> Populando o banco com dados de exemplo"
  bundle exec rails db:seed
fi

echo "==> Build concluido"
