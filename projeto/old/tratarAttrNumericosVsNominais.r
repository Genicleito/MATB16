#setwd("../../genic/Documents/GitHub/MATB16/Trabalho/Códigos/")
dados <- read.table("microdados_enem2016_semNA_16attr.data", sep = ",")

#dados

dados <- dados[which(dados$V1 == "BA"), ]
write.table(x = dados, file = "enem_BA.data", sep = ",")

tmp <- dados$V16
#tmp <- sort(tmp)
#tmp

#min(tmp)
#max(tmp)

#intervalo <- ((max(tmp) - min(tmp))/3)

minInter <- min(tmp)

for(j in c(2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16)){
  tmp <- dados[, j]
  
  for(i in 1:length(tmp)){
    
  #inter_min <- (i * intervalo) + minInter - intervalo
    #print(inter_min)
  #inter_max <- (i * intervalo) + minInter
    #print(inter_max)
  #indices <- which(tmp >= inter_min & tmp <= inter_max)
    #print(which(tmp <= 32 & tmp >= 10))
    #print(length(indices))
  #classes <- c("menor","mediano", "maior")
    #tmp[indices] <- classes[i]
    tmp[i] = toString(paste("labIA",i))
    print(i)
    
  }
  dados[, j] <- tmp
}
