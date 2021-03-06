#!/bin/bash

# Dicas de como ler os dados do INEP
# <3 https://pt.stackoverflow.com/questions/154724/como-ler-os-microdados-do-enem-no-r

# Nome do arquivo
# <3 https://stackoverflow.com/questions/13055889/sed-with-literal-string-not-input-file
ARQUIVO="dados/Microdados_enem_2016/DADOS/microdados_enem_2016.csv"
ARQUIVO_FINAL=$(echo "$ARQUIVO" | sed -n "s/\./_utf8\./p")

# Checa pelo arquivo resultante e para execução caso não exista
# <3 https://stackoverflow.com/questions/638975/how-do-i-tell-if-a-regular-file-does-not-exist-in-bash
if [ ! -f $ARQUIVO ]; then
    echo "Arquivo $ARQUIVO não existe"
    echo "Abortando a execução"
    exit
fi

# Converte de ISO-8859-1 para UTF8
echo "Convertendo ISO-8859 para UTF8"
iconv -f ISO-8859-1 -t UTF-8 $ARQUIVO > $ARQUIVO_FINAL

# Remove caracteres especiais do csv (' e ^M) para evitar erros na leitura desdes
echo "Removendo caracteres especiais (', ^M e \\r) do arquivo para evitar erros de leitura"
sed -i \
    -e "s/'//g" \
    -e "s/^M//g" \
    -e "s/\r//g" \
    $ARQUIVO_FINAL

# Limpeza finalizada
echo "Limpeza Concluida"
