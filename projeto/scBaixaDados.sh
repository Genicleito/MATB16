#!/bin/bash

##
#
# Este script faz o dowload dos dados das bases de dados disponibilizadas
# pelo INEP, todos estes dados são públicos e podem ser encontrados em
# Microdados Disponivéis em http://portal.inep.gov.br/microdados
#
##

# Link ENEM INEP
LINK_MICRODADOS_ENEM="http://download.inep.gov.br/microdados/microdados_enem2016.zip"

# Nome do arquivo final
OUTPUT_FILE="dados/dados.zip"

# Download com continuação para possíveis paradas
echo "Iniciando o download da base de dados"
wget -O $OUTPUT_FILE \
     --continue \
     $LINK_MICRODADOS_ENEM

# Descompactar o arquivo baixado
echo "Descompactando o arquivo de dados"
unzip $OUTPUT_FILE
