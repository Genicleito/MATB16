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

# Check visually if this is correct
getwd()

# Read Microdados
dados <- read.table('microdados_enem2016_semNA_16attr.data', sep=',')

# Check if DMwR is currently installed 
# https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
if (!'DMwR' %in% installed.packages())
  install.packages('DMwR')
require('DMwR')

# Check if DMwR is currently installed 
# https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
if (!'caret' %in% installed.packages())
  install.packages('caret')
require('caret')

################# Inicio Funções #################

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
    png(filename = paste(toString(names(dataSet[i])), ".png") )
    boxplot(attrSemNa)
    dev.off()
    
    dataSet <- dataSet[!attrSemNa %in% boxplot.stats(attrSemNa)$out, ]
    
    boxplot(attrSemNa)
    
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
  attrs <- c()
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
    }else{
      attrs <- c(attrs, i)
    }
  }
  print(attrs)
  dataSet <- dataSet[ , -c(attrs)]
  return(dataSet)
}

dados <- dados[which(dados$V1 == "BA"), ]
dados <- dados[,-c(1)]
dados <- transformacao(dados)
dados <- normalizar(dados)
dados <- dados[order(dados$V16),]

## Split in train + test set
idxs <- sample(1:nrow(dados),as.integer(0.7*nrow(dados)))
trainDados <- dados[idxs,]
testDados <- dados[-idxs,]

## A 3-nearest neighbours model with no normalization
nn3 <- kNN(V16 ~ ., trainDados, testDados, norm=TRUE, k=3)

## The resulting confusion matrix
table(testDados[,'V16'],nn3)

# Get Result
matrix_confusion <- as.matrix(table(Actual = testDados[,'V16'], Predicted = n3))
result <- confusionMatrix(testDados[,'V16'], nn3[which(nn3 %in% unique(testDados[,'V16']))])
print(result)

## Now a 5-nearest neighbours model with normalization
nn5 <- kNN(V16 ~ ., trainDados, testDados, norm=TRUE, k=5)

## The resulting confusion matrix
table(testDados[,'V16'],nn5)
