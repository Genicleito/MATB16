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

# Hash do arquivo baixado esperado
SHA256_ESPERADO="a9159fb81a0dd5b47bb8c7834dde2a347a9caedafcbfcf43492d5cd5be7fd623"

# Arquivo lockfile do download
LOCKFILE_WGET="dados/.wget_continue"

# Checa se o arquivo existe 
if [ ! -f "$LOCKFILE_WGET" ] && [ -f "$OUTPUT_FILE" ]; then

	# Checa se o mesmo não está corrompido	
	SHA256_BAIXADO=$(sha256sum $OUTPUT_FILE | awk '{print $1}')
	if [ "$SHA256_ESPERADO" != "$SHA256_BAIXADO" ]; then
		echo "Arquivo corrompido, reiniciando o download..."
		rm $OUTPUT_FILE
	else
		echo "Arquivo baixado e intégro, executar outros scripts ou descompactar novamente"
		exit
	fi
fi

# Download com continuação para possíveis paradas
echo "Iniciando o download da base de dados"

# Mostra que o download está sendo continuado ao invés de iniciado novamente
if [ -f $LOCKFILE_WGET ]; then
	echo "!!! CONTINUANDO DOWNLOAD !!!"
fi

# Cria arquivo para indicar que o download pode continuar em caso de falha
touch $LOCKFILE_WGET

# Baixa o Download
wget -O $OUTPUT_FILE \
     --continue \
     $LINK_MICRODADOS_ENEM

# Remove o lockfile do wget quanto ao download
rm $LOCKFILE_WGET

# Descompactar o arquivo baixado
echo "Descompactando o arquivo de dados"
unzip $OUTPUT_FILE
