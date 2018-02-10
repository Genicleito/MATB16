#!/bin/bash

# Pasta com os datasets
export PASTA_CORTE="dados/Microdados_enem_2016/DADOS"

# Arquivo a ser cortado
export ARQUIVO_CORTE="microdados_enem_2016_utf8.csv"
# export ARQUIVO_CORTE="haha.csv" ; teste

# Prefixo do arquivo resultante
PREFIXO_RESULTANTE="$(echo "$ARQUIVO_CORTE" | cut -d '.' -f 1)_"

# Sufixo do arquivo resultante
SUFIXO_RESULTANTE=".$(echo "$ARQUIVO_CORTE" | cut -d '.' -f 2)"

# Pasta resultante
PASTA_RESULTANTE="dados/partes"

# Funcao cabecalho
export CABECALHO_CSV=$(head -n 1 "$PASTA_CORTE/$ARQUIVO_CORTE")
CABECALHO='tee > "$FILE" ; sed -i "1i$CABECALHO_CSV" "$FILE"'

# Especificar número de cortes, isso será utilizado para cortar o arquivo em diversas partes
# E.G. 100 partes = 5GB / 100 => 50 MB
N_CORTES=100

# Checa pelo arquivo resultante e para execução caso não exista
# <3 https://stackoverflow.com/questions/638975/how-do-i-tell-if-a-regular-file-does-not-exist-in-bash
if [ ! -f "$PASTA_CORTE/$ARQUIVO_CORTE" ]; then
    echo "Arquivo $ARQUIVO_CORTE não existe"
    echo "Abortando a execução"
    exit
fi

# Corta o arquivo no número de partes especificadas
# <3 https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-dir-does-not-already-exist
# <3 https://stackoverflow.com/questions/2016894/how-to-split-a-large-text-file-into-smaller-files-with-equal-number-of-lines 
# <3 https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-dir-does-not-already-exist
# <3 https://askubuntu.com/questions/151674/how-do-i-insert-a-line-at-the-top-of-a-text-file-using-the-command-line
# <3 https://stackoverflow.com/questions/76700/whats-a-simple-method-to-dump-pipe-input-to-a-file-linux
# <3 https://www.gnu.org/software/coreutils/manual/html_node/split-invocation.html
# <3 https://www.cyberciti.biz/faq/howto-linux-unix-bash-append-textto-variables/
# <3 https://stackoverflow.com/questions/339483/how-can-i-remove-the-first-line-of-a-text-file-using-bash-sed-script
echo "Cortando o arquivo em $N_CORTES partes"
mkdir -p $PASTA_RESULTANTE
split 	--verbose \
	--filter "$CABECALHO" \
	--number "l/$N_CORTES" \
	--numeric-suffixes \
	--additional-suffix "$SUFIXO_RESULTANTE" \
	"$PASTA_CORTE/$ARQUIVO_CORTE" \
	"$PASTA_RESULTANTE/$PREFIXO_RESULTANTE"
sed -i -e '1d' "$PASTA_RESULTANTE/${PREFIXO_RESULTANTE}00$SUFIXO_RESULTANTE"
echo "Arquivo finalizado resultado na pasta $PASTA_RESULTANTE"
