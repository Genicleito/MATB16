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