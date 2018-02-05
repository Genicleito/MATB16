# Test whether running under RStudio 
# <3 https://stackoverflow.com/questions/12389158/check-if-r-is-running-in-rstudio
isRStudio <- Sys.getenv("RSTUDIO") == "1"

# Set Working Directory to source file folder
# <3 https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location
if(isRStudio){
  
  # Check if RStudioAPI is currently installed 
  # https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
  if (!'rstudioapi' %in% installed.packages())
    install.packages('rstudioapi')
  
  # Load RStudioAPI Library
  require('rstudioapi')
  
  current_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
} else {
  current_dir <- dirname(getSrcDirectory()[1])
}

# Configure the current dir
setwd(current_dir)

# Le os dados
dados <- read.csv("enem2016_1000linhas.csv", sep = ";")

################# Início Funções #################

transformacao <- function(dataset){
  for(i in seq_along(dataset)){
    temp <- as.vector(dataset[, i])
    
    # Se forem estados
    temp[which(temp == "AC")] = "0"
    temp[which(temp == "AL")] = "1"
    temp[which(temp == "AM")] = "2"
    temp[which(temp == "AP")] = "3"
    temp[which(temp == "BA")] = "4"
    temp[which(temp == "CE")] = "5"
    temp[which(temp == "DF")] = "6"
    temp[which(temp == "ES")] = "7"
    temp[which(temp == "GO")] = "8"
    temp[which(temp == "MA")] = "9"
    temp[which(temp == "MG")] = "10"
    temp[which(temp == "MS")] = "11"
    temp[which(temp == "MT")] = "12"
    temp[which(temp == "PA")] = "13"
    temp[which(temp == "PB")] = "14"
    temp[which(temp == "PE")] = "15"
    temp[which(temp == "PI")] = "16"
    temp[which(temp == "PR")] = "17"
    temp[which(temp == "RJ")] = "18"
    temp[which(temp == "RN")] = "19"
    temp[which(temp == "RO")] = "20"
    temp[which(temp == "RR")] = "21"
    temp[which(temp == "RS")] = "22"
    temp[which(temp == "SC")] = "23"
    temp[which(temp == "SE")] = "24"
    temp[which(temp == "SP")] = "25"
    temp[which(temp == "TO")] = "26"
    
    # Se for o sexo
    temp[which(temp == 'F')] = "0"
    temp[which(temp == 'M')] = "1"
    
    # Se for a Q006
    temp[which(temp == 'A')] = "0"
    temp[which(temp == 'B')] = "1"
    temp[which(temp == 'C')] = "2"
    temp[which(temp == 'D')] = "3"
    temp[which(temp == 'E')] = "4"
    temp[which(temp == 'F')] = "5"
    temp[which(temp == 'G')] = "6"
    temp[which(temp == 'H')] = "7"
    temp[which(temp == 'I')] = "8"
    temp[which(temp == 'J')] = "9"
    temp[which(temp == 'K')] = "10"
    temp[which(temp == 'L')] = "11"
    temp[which(temp == 'M')] = "12"
    temp[which(temp == 'N')] = "13"
    temp[which(temp == 'O')] = "14"
    temp[which(temp == 'P')] = "15"
    temp[which(temp == 'Q')] = "16"
    
    # Se for a Q047 (acredito que seja desnecessário porque o código anterior já faz oq essas 5 linhas faz)
    temp[which(temp == 'A')] = "0"
    temp[which(temp == 'B')] = "1"
    temp[which(temp == 'C')] = "2"
    temp[which(temp == 'D')] = "3"
    temp[which(temp == 'E')] = "4"
    
    dataset[, i] <- as.integer(temp)
    
  }
  return(dataset)
}

removeNA <- function(dataSet){
  tam.inicial <- nrow(dataSet)
  
  for(i in seq_along(dataSet)){
    dataSet <- dataSet[!is.na(dataSet[, i]), ]
    
    #dataSet <- dataSet[attrSemNa, ]
    #print(i)
  }
  cat("\t", tam.inicial - nrow(dataSet), " valores NA removidos.\n")
  cat("\tPorcentagem de NAs removidos: ", 100 - (nrow(dataSet) * 100 / tam.inicial),"%\n")
  
  return(dataSet)
}

removeOutliers <- function(dataSet){
  
  inicial <- nrow(dataSet)
  
  for(i in seq_along(dataSet[, -c(ncol(dataSet))])){
    attrSemNa <- dataSet[, i][!is.na(dataSet[, i])]
    
    # Boxplot antes de remover os Outliers
    boxplot(attrSemNa)
    
    dataSet <- dataSet[!attrSemNa %in% boxplot.stats(attrSemNa)$out, ]
    
    # Boxplot depois de remover os Outliers
    boxplot(dataSet[, i])
    
    #print(i)
  }
  
  cat("Outliers Removidos: ", inicial - nrow(dataSet), "\n")
  cat("Total de instancias: ", inicial, "\n")
  cat("Instâncias atuais: ", nrow(dataSet), "\n")
  cat("Numero colunas: ", ncol(dataSet), "\n")
  cat("Porcentagem de outliers removidos: ", nrow(dataSet) * 100 / inicial,"%\n")
  return(dataSet)
  
}

normalizar <- function(dataSet){
  
  for(i in seq_along(dataSet[, -c(ncol(dataSet))])){
    attrSemNA <- dataSet[, i][!is.na(dataSet[, i])]
    minValue <- min(attrSemNA)
    #print(minValue)
    maxValue <- max(attrSemNA)
    #print(maxValue)
    if(maxValue - minValue != 0){
      normAttr <- (attrSemNA - minValue) / (maxValue - minValue)
      
      dataSet[, i] <- normAttr
      cat("Normalizado: ", i, "\n")
    }else{  # Remover atributo que tem valor único
      dataSet[, -c(i)]
      cat("Removido: ", i, "\n")
      i <- i - 1
    }
  }
  return(dataSet)
}

################# Fim Funções #################

# 6 - SG_UF_RESIDENCIA
# 7 - NU_IDADE
# 8 - TP_SEXO
# 9 - TP_ESTADO_CIVIL
# 10 - TP_COR_RACA
# 11 - TP_NACIONALIDADE
# 16 - TP_ST_CONCLUSAO
# 18 - TP_ESCOLA (é necessário?)  [RETIRADO]
# 19 - TP_ENSINO (é necessário?)
# 20 - IN_TREINEIRO
# 97 - NU_NOTA_CN
# 98 - NU_NOTA_CH
# 99 - NU_NOTA_LC
# 100 - NU_NOTA_MT
# 122 - Q006
# 163 - Q047 (é necessário?) (Em que tipo de escola você frequentou o Ensino Médio?)
# 116 - NU_NOTA_REDACAO (classe)

atributos.selecionados <- c(6, 7, 8, 9, 10, 11, 16, 19, 20, 97, 98, 99, 100, 122, 163, 116)

dados <- dados[, atributos.selecionados]

# Transformação dos valores nominais categóricos para númericos categóricos

dados <- transformacao(dados)

# Remoção de valores ausentes (NAs)

dados <- removeNA(dados)

# Remoção de Outliers

#tmp <- removeOutliers(dados) # Verificar se existem realmente Outliers
#dados <- tmp

# Normalização dos Atributos

dados <- normalizar(dados)
dados

# Salvando base de dados pré-processada

write.table(dados, file = "microdados_enem2016_16attr.data", sep = ",")

