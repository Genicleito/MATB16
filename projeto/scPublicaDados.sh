#!/bin/bash

##
#
# Este script copia os resultados gerados para uma pasta que pode ser comitada
# e assim disponibilizado os dados gerados pelos algoritmos para outros usuários.
#
##


# Pasta publicada
PASTA_PUBLICADA="dados_preprocessados_nordeste"

# Cria pasta publicada se a mesma ainda não existir
mkdir -p $PASTA_PUBLICADA

# Copia os dados para a pasta a ser publicada

# Resultado final pre processamento
cp dados/result_final.csv $PASTA_PUBLICADA

# Resultado final pre processamento todos dados numericos
cp dados/result_numeric.csv $PASTA_PUBLICADA

# Resultado final pre processamento todos dados numericos e normalizados
cp dados/result_numeric_normalized.csv $PASTA_PUBLICADA

# Resultado final pre processamento todos dados categóricos
cp dados/result_factor.csv $PASTA_PUBLICADA

# Resultado final constraints da label resultado
cp dados/result_constraints.csv $PASTA_PUBLICADA

