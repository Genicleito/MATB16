### Pre processor for INEP ENEM MicroData
###
### Description: This code prepare INEP ENEM MicroData for AM methods
###              it generate a lot of files, and display graph for reviews 
###
### Authors:  Genicleito Gonçalves
###           Jeferson Lima
###
### 

# Code style guide based on Google Style Guide for R
# <3 https://google.github.io/styleguide/Rguide.xml

# Check for FactoMineR library and require it 
# https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
if (!'FactoMineR' %in% installed.packages())
  install.packages('FactoMineR')
require('FactoMineR')

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
  
  currentDir <- dirname(rstudioapi::getActiveDocumentContext()$path)
} else {
  currentDir <- dirname(getSrcDirectory()[1])
}

# Configure the current dir
setwd(currentDir)

# Check visually if this is correct
getwd()

# Le os dados
#dados <- read.csv("enem2016_1000linhas.csv", sep = ";")

# Check if sqldf is currently installed 
# https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
if (!'sqldf' %in% installed.packages())
  install.packages('sqldf')

# Filter by 'UF' (Unidade da Federação)
# <3 https://stackoverflow.com/questions/41067275/filter-by-column-values-while-reading-using-read-csv-in-r
require(sqldf)

# Microdados Enem file
urlFilePrefix <- "dados/partes/microdados_enem_2016_utf8_"
urlFileSuffix <- ".csv"

# Microdados Enem file
urlFileOutPrefix <- "dados/result_"
urlFileOutSuffix <- ".csv"

# Numero de interações
numberInterations <- 100

# Boolean format with conversion from 0 1 to T F
# <3 https://stackoverflow.com/questions/33402519/read-csv-column-of-zeros-and-ones-as-logical
setClass("boolean", contains=logical())
setAs("character", "boolean", function(from){ 
  as.logical(as.numeric(from))
})

# Col types
# <3 https://stackoverflow.com/questions/2805357/specifying-colclasses-in-the-read-csv
# <3 http://portal.inep.gov.br/microdados
# <3 https://www.r-bloggers.com/using-colclasses-to-load-data-more-quickly-in-r/
datasetClasses <- c(
  ## DADOS PARTICIPANTE ##
  "NU_INSCRICAO"            = "numeric",
  "NU_ANO"                  = "numeric",
  "CO_MUNICIPIO_RESIDENCIA" = "factor",
  "NO_MUNICIPIO_RESIDENCIA" = "character",
  "CO_UF_RESIDENCIA"        = "factor",
  "SG_UF_RESIDENCIA"        = "factor",
  "NU_IDADE"                = "numeric",
  "TP_SEXO"                 = "factor",
  "TP_ESTADO_CIVIL"         = "factor",
  "TP_COR_RACA"             = "factor",
  "TP_NACIONALIDADE"        = "factor",
  "CO_MUNICIPIO_NASCIMENTO" = "factor",
  "NO_MUNICIPIO_NASCIMENTO" = "character",
  "CO_UF_NASCIMENTO"        = "factor",
  "SG_UF_NASCIMENTO"        = "factor",
  "TP_ST_CONCLUSAO"         = "factor",
  "TP_ANO_CONCLUIU"         = "factor",
  "TP_ESCOLA"               = "factor",
  "TP_ENSINO"               = "factor",
  "IN_TREINEIRO"            = "boolean",
  ## DADOS ATENDIMENTO ##
  "CO_ESCOLA"               = "factor",
  "CO_MUNICIPIO_ESC"        = "factor",
  "NO_MUNICIPIO_ESC"        = "character",
  "CO_UF_ESC"               = "factor",
  "SG_UF_ESC"               = "factor",
  "TP_DEPENDENCIA_ADM_ESC"  = "factor",
  "TP_LOCALIZACAO_ESC"      = "factor",
  "TP_SIT_FUNC_ESC"         = "factor",
  ## DADOS ATENDIMENTO ESPECIALIZADO ##
  "IN_BAIXA_VISAO"          = "boolean",
  "IN_CEGUEIRA"             = "boolean",
  "IN_SURDEZ"               = "boolean",
  "IN_DEFICIENCIA_AUDITIVA" = "boolean",
  "IN_SURDO_CEGUEIRA"       = "boolean",
  "IN_DEFICIENCIA_FISICA"   = "boolean",
  "IN_DEFICIENCIA_MENTAL"   = "boolean",
  "IN_DEFICIT_ATENCAO"      = "boolean",
  "IN_DISLEXIA"             = "boolean",
  "IN_DISCALCULIA"          = "boolean",
  "IN_AUTISMO"              = "boolean",
  "IN_VISAO_MONOCULAR"      = "boolean",
  "IN_OUTRA_DEF"            = "boolean",
  ## ATENDIMENTO ESPECIFICO ##
  "IN_SABATISTA"                = "boolean",
  "IN_GESTANTE"                 = "boolean",
  "IN_LACTANTE"                 = "boolean",
  "IN_IDOSO"                    = "boolean",
  "IN_ESTUDA_CLASSE_HOSPITALAR" = "boolean",
  ## RECURSOS ESPECIALIZADOS ##
  "IN_SEM_RECURSO"           = "boolean",
  "IN_BRAILLE"               = "boolean",
  "IN_AMPLIADA_24"           = "boolean",
  "IN_AMPLIADA_18"           = "boolean",
  "IN_LEDOR"                 = "boolean",
  "IN_ACESSO"                = "boolean",
  "IN_TRANSCRICAO"           = "boolean",
  "IN_LIBRAS"                = "boolean",
  "IN_LEITURA_LABIAL"        = "boolean",
  "IN_MESA_CADEIRA_RODAS"    = "boolean",
  "IN_MESA_CADEIRA_SEPARADA" = "boolean",
  "IN_APOIO_PERNA"           = "boolean",
  "IN_GUIA_INTERPRETE"       = "boolean",
  "IN_MACA"                  = "boolean",
  "IN_COMPUTADOR"            = "boolean",
  "IN_CADEIRA_ESPECIAL"      = "boolean",
  "IN_CADEIRA_CANHOTO"       = "boolean",
  "IN_CADEIRA_ACOLCHOADA"    = "boolean",
  "IN_PROVA_DEITADO"         = "boolean",
  "IN_MOBILIARIO_OBESO"      = "boolean",
  "IN_LAMINA_OVERLAY"        = "boolean",
  "IN_PROTETOR_AURICULAR"    = "boolean",
  "IN_MEDIDOR_GLICOSE"       = "boolean",
  "IN_MAQUINA_BRAILE"        = "boolean",
  "IN_SOROBAN"               = "boolean",
  "IN_MARCA_PASSO"           = "boolean",
  "IN_SONDA"                 = "boolean",
  "IN_MEDICAMENTOS"          = "boolean",
  "IN_SALA_INDIVIDUAL"       = "boolean",
  "IN_SALA_ESPECIAL"         = "boolean",
  "IN_SALA_ACOMPANHANTE"     = "boolean",
  "IN_MOBILIARIO_ESPECIFICO" = "boolean",
  "IN_MATERIAL_ESPECIFICO"   = "boolean",
  "IN_NOME_SOCIAL"           = "boolean",
  ## CERTIFICACAO ENSINO MEDIO ##
  "IN_CERTIFICADO"              = "boolean",
  "NO_ENTIDADE_CERTIFICACAO"    = "character",
  "CO_UF_ENTIDADE_CERTIFICACAO" = "factor",
  "SG_UF_ENTIDADE_CERTIFICACAO" = "factor",
  ## LOCAL APLICACAO ##
  "CO_MUNICIPIO_PROVA"      = "factor",
  "NO_MUNICIPIO_PROVA"      = "character",
  "CO_UF_PROVA"             = "factor",
  "SG_UF_PROVA"             = "factor",
  ## PROVA OBJETIVA ##
  "TP_PRESENCA_CN"          = "factor",
  "TP_PRESENCA_CH"          = "factor",
  "TP_PRESENCA_LC"          = "factor",
  "TP_PRESENCA_MT"          = "factor",
  "CO_PROVA_CN"             = "factor",
  "CO_PROVA_CH"             = "factor",
  "CO_PROVA_LC"             = "factor",
  "CO_PROVA_MT"             = "factor",
  "NU_NOTA_CN"              = "numeric",
  "NU_NOTA_CH"              = "numeric",
  "NU_NOTA_LC"              = "numeric",
  "NU_NOTA_MT"              = "numeric",
  "TX_RESPOSTAS_CN"         = "character",
  "TX_RESPOSTAS_CH"         = "character",
  "TX_RESPOSTAS_LC"         = "character",
  "TX_RESPOSTAS_MT"         = "character",
  "TP_LINGUA"               = "factor",
  "TX_GABARITO_CN"          = "character",
  "TX_GABARITO_CH"          = "character",
  "TX_GABARITO_LC"          = "character",
  "TX_GABARITO_MT"          = "character",
  ## REDAÇÃO ##
  "TP_STATUS_REDACAO"       = "factor",
  "NU_NOTA_COMP1"           = "numeric",
  "NU_NOTA_COMP2"           = "numeric",
  "NU_NOTA_COMP3"           = "numeric",
  "NU_NOTA_COMP4"           = "numeric",
  "NU_NOTA_COMP5"           = "numeric",
  "NU_NOTA_REDACAO"         = "numeric",
  ## QUESTIONARIO SOCIO ECONOMICO ##
  "Q001"                    = "factor",
  "Q002"                    = "factor",
  "Q003"                    = "factor",
  "Q004"                    = "factor",
  "Q005"                    = "factor",
  "Q006"                    = "factor",
  "Q007"                    = "factor",
  "Q008"                    = "factor",
  "Q009"                    = "factor",
  "Q010"                    = "factor",
  "Q011"                    = "factor",
  "Q012"                    = "factor",
  "Q013"                    = "factor",
  "Q014"                    = "factor",
  "Q015"                    = "factor",
  "Q016"                    = "factor",
  "Q017"                    = "factor",
  "Q018"                    = "factor",
  "Q019"                    = "factor",
  "Q020"                    = "factor",
  "Q021"                    = "factor",
  "Q022"                    = "factor",
  "Q023"                    = "factor",
  "Q024"                    = "factor",
  "Q025"                    = "factor",
  "Q026"                    = "factor",
  "Q027"                    = "factor",
  "Q028"                    = "factor",
  "Q029"                    = "factor",
  "Q030"                    = "factor",
  "Q031"                    = "factor",
  "Q032"                    = "factor",
  "Q033"                    = "factor",
  "Q034"                    = "factor",
  "Q035"                    = "factor",
  "Q036"                    = "factor",
  "Q037"                    = "factor",
  "Q038"                    = "factor",
  "Q039"                    = "factor",
  "Q040"                    = "factor",
  "Q041"                    = "factor",
  "Q042"                    = "factor",
  "Q043"                    = "factor",
  "Q044"                    = "factor",
  "Q045"                    = "factor",
  "Q046"                    = "factor",
  "Q047"                    = "factor",
  "Q048"                    = "factor",
  "Q049"                    = "factor",
  "Q050"                    = "factor"
)

# SQL Query
# Moradores da bahia - 7283
# filterSql <- "select * from file where SG_UF_RESIDENCIA = 'BA'"
# Moradores do nordeste (AL BA CE MA PB PE PI RN SE) - 27609 pessoas
filterSql <- paste("select * from file where",
                    "SG_UF_RESIDENCIA = 'AL' or",
                    "SG_UF_RESIDENCIA = 'BA' or",
                    "SG_UF_RESIDENCIA = 'CE' or",
                    "SG_UF_RESIDENCIA = 'MA' or",
                    "SG_UF_RESIDENCIA = 'PB' or",
                    "SG_UF_RESIDENCIA = 'PE' or",
                    "SG_UF_RESIDENCIA = 'PI' or",
                    "SG_UF_RESIDENCIA = 'RN' or",
                    "SG_UF_RESIDENCIA = 'SE'"
)

# As our data is enormous read csv in chunks
# <3 https://stackoverflow.com/questions/23197243/how-do-i-read-only-lines-that-fulfil-a-condition-from-a-csv-into-r

# Clean the final dataset variable if it exist
# <3 https://stackoverflow.com/questions/11761992/remove-objects-data-from-workspace
if(exists("datasetCsv"))
  rm(datasetCsv)

# Read chunks and add the selected chunks to final parsed file
for (i in 0:(numberInterations - 1)){
  # Display iteration number
  cat("Files read ->", i, "\n")
  
  # Filename with leading zeros
  # <3 https://stat.ethz.ch/R-manual/R-devel/library/base/html/paste.html
  # <3 https://stackoverflow.com/questions/8266915/format-number-as-fixed-width-with-leading-zeros
  tmpNumber <- formatC(i, width=2, flag='0')
  tmpFilename <- paste(urlFilePrefix, tmpNumber, urlFileSuffix, sep = '')
  
  cat("Reading file -", tmpFilename, "\n")
  
  # Database read chunk
  tmp <- read.csv.sql(tmpFilename, 
                      filterSql, 
                      sep = ";", 
                      colClasses = datasetClasses,
                      stringsAsFactors = TRUE)
  
  # Merge tmp dataset with final dataset if it exists
  # <3 https://stackoverflow.com/questions/9368900/how-to-check-if-object-variable-is-defined-in-r
  if(exists("datasetCsv"))
    merge(datasetCsv, tmp)
  else
    datasetCsv <- tmp
  
}

# Store CSV parsed and repaired to a single new file
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlOutFilePrefix, 'out1', urlFileOutSuffix, sep = '')
write.csv(datasetCsv, file = outputFilename, row.names = FALSE)



################ PRE PROCCESSING ################



# Make a copy of the dataset read
datasetCsvFiltered <- datasetCsv

# Convert these columns to factor
for(propertyName in names(datasetClasses)){
  
  # If it's one of these class do the correct as operation
  if(datasetClasses[propertyName] == "factor"){
    cat("Converting to factor property -", propertyName, "\n")
    datasetCsvFiltered[, propertyName] <- as.factor(datasetCsvFiltered[, propertyName])
  }
  else if(datasetClasses[propertyName] == "boolean"){
    cat("Converting to logical property -", propertyName, "\n")
    datasetCsvFiltered[, propertyName] <- as.logical(datasetCsvFiltered[, propertyName])
  }
}

# Not In Function
# <3 https://stackoverflow.com/questions/9845929/removing-a-list-of-columns-from-a-data-frame-using-subset
`%ni%` <- Negate(`%in%`)

# Remove responses and labels from filtered CSV
# <3 https://stat.ethz.ch/pipermail/r-help/2010-January/225523.html

# These are only label classes (code, dates, and other unused data)
datasetCsvFiltered <- subset(datasetCsvFiltered, select = -c(
  NU_INSCRICAO,
  NU_ANO,
  CO_MUNICIPIO_RESIDENCIA,
  CO_UF_RESIDENCIA,
  CO_MUNICIPIO_NASCIMENTO,
  CO_UF_NASCIMENTO,
  CO_MUNICIPIO_ESC,
  CO_UF_ESC,
  NO_ENTIDADE_CERTIFICACAO,
  CO_UF_ENTIDADE_CERTIFICACAO,
  CO_MUNICIPIO_PROVA,
  CO_UF_PROVA
))

# These are unused responses classes
datasetCsvFiltered <- subset(datasetCsvFiltered, select = -c(
  TX_RESPOSTAS_CN,
  TX_RESPOSTAS_CH,
  TX_RESPOSTAS_LC,
  TX_RESPOSTAS_MT,
  TX_GABARITO_CN,
  TX_GABARITO_CH,
  TX_GABARITO_LC,
  TX_GABARITO_MT,
  NU_NOTA_COMP1,
  NU_NOTA_COMP2,
  NU_NOTA_COMP3,
  NU_NOTA_COMP4,
  NU_NOTA_COMP5
))

# These are probrably responses to be used or discovered
usedResponses <- c(
  "TP_PRESENCA_CN",
  "TP_PRESENCA_CH",
  "TP_PRESENCA_LC",
  "TP_PRESENCA_MT",
  "NU_NOTA_REDACAO"
)

# Store CSV parsed with removed unused columns 
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'out2', urlFileOutSuffix, sep = '')
write.csv(datasetCsvFiltered, file = outputFilename, row.names = FALSE)

# Remove people that hadn't done the test or had a problem on essay
datasetCsvFiltered <- datasetCsvFiltered[which(
    datasetCsvFiltered$TP_PRESENCA_CN == '1' &
    datasetCsvFiltered$TP_PRESENCA_CH == '1' &
    datasetCsvFiltered$TP_PRESENCA_LC == '1' &
    datasetCsvFiltered$TP_PRESENCA_MT == '1' &
    datasetCsvFiltered$TP_STATUS_REDACAO == '1'
), ]

# These are constants columns after filter applyed
datasetCsvFiltered <- subset(datasetCsvFiltered, select = -c(
  TP_PRESENCA_CN,
  TP_PRESENCA_CH,
  TP_PRESENCA_LC,
  TP_PRESENCA_MT,
  TP_STATUS_REDACAO
))

# List of removed cols
removedCols <- c(
  "NU_INSCRICAO",
  "NU_ANO",
  "CO_MUNICIPIO_RESIDENCIA",
  "CO_UF_RESIDENCIA",
  "CO_MUNICIPIO_NASCIMENTO",
  "CO_UF_NASCIMENTO",
  "CO_MUNICIPIO_ESC",
  "CO_UF_ESC",
  "NO_ENTIDADE_CERTIFICACAO",
  "CO_UF_ENTIDADE_CERTIFICACAO",
  "CO_MUNICIPIO_PROVA",
  "CO_UF_PROVA",
  "TX_RESPOSTAS_CN",
  "TX_RESPOSTAS_CH",
  "TX_RESPOSTAS_LC",
  "TX_RESPOSTAS_MT",
  "TX_GABARITO_CN",
  "TX_GABARITO_CH",
  "TX_GABARITO_LC",
  "TX_GABARITO_MT",
  "NU_NOTA_COMP1",
  "NU_NOTA_COMP2",
  "NU_NOTA_COMP3",
  "NU_NOTA_COMP4",
  "NU_NOTA_COMP5",
  "TP_PRESENCA_CN",
  "TP_PRESENCA_CH",
  "TP_PRESENCA_LC",
  "TP_PRESENCA_MT",
  "TP_STATUS_REDACAO"
)

# Store CSV parsed with removed constant columns
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'out3', urlFileOutSuffix, sep = '')
write.csv(datasetCsvFiltered, file = outputFilename, row.names = FALSE)

# Check for the presence of NA in our data frame
# <3 https://stackoverflow.com/questions/8317231/elegant-way-to-report-missing-values-in-a-data-frame

# Store the name of columns with null data
if(exists("columnsWithNull"))
  rm(columnsWithNull)
for(csvCol in names(datasetCsvFiltered)){
  
  # Count nulls
  csvColNullCounter <- length(which(datasetCsvFiltered[, csvCol] == '' |
                       is.null(datasetCsvFiltered[, csvCol])))
  
  # Count NA
  csvColNACounter <- length(which(is.na(datasetCsvFiltered[csvCol])))
  
  # Print presence of Null's and NA's
  if(csvColNullCounter > 0){
    cat("Column -", csvCol, "has", csvColNullCounter, "null\n")
    if(exists("columnsWithNull"))
      columnsWithNull <- append(columnsWithNull, csvCol)
    else
      columnsWithNull <- c(csvCol)
  }
  if(csvColNACounter > 0)
    cat("Column -", csvCol, "has", csvColNACounter, "NA\n")
}

# Remove columns with null data
datasetCsvFiltered <- subset(datasetCsvFiltered,select = names(datasetCsvFiltered) %ni% columnsWithNull)

# Add this to the list of cols deleted
removedCols <- append(removedCols, columnsWithNull)

# OBSOLETE! Check for presence of NA
#naCounterTable <- apply(datasetCsvFiltered, 2, function(x) sum())
#naCounter <- sum(naCounterTable)
#cat("NA founds in table >", naCounter, "\n")

# OBSOLETE! Check for presence of NULL
#nullCounterTable <- apply(datasetCsvFiltered, 2, function(x) sum(x, is.null(x) || x == ''))
#nullCounter <- sum(nullCounterTable)
#cat("Null founds in table >", nullCounter, "\n")

# Normalize numeric data 
datasetCsvNormalized <- datasetCsvFiltered
for(propertyName in names(datasetClasses)[which(names(datasetClasses) %ni% removedCols)]){
  
  # If it's numeric col
  if(datasetClasses[propertyName] == "numeric"){
    cat("Normalizing col -", propertyName, "\n")
    cat("Col", propertyName, "Type ->", class(datasetCsvNormalized[, propertyName]), "\n")
    
    # Get max and min values of this col
    maxValueCol <- max(datasetCsvNormalized[, propertyName])
    minValueCol <- min(datasetCsvNormalized[, propertyName])
    
    # Check if the value is not constant
    if(maxValueCol - minValueCol != 0){
      datasetCsvNormalized[, propertyName] <-
        (datasetCsvNormalized[, propertyName] - minValueCol) / abs(maxValueCol - minValueCol)
    }
    else{
      cat("Column", propertyName, "is constant\n")
    }
  }
}

# Store Final CSV after normalized data
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'final', urlFileOutSuffix, sep = '')
write.csv(datasetCsvNormalized, file = outputFilename, row.names = FALSE)

# Since normalized data don't have the exact result value we store the
# max and the min of result to after recover the aproximate value
datasetResultConstraint <- c('MaxRes' = max(datasetCsvFiltered$NU_NOTA_REDACAO),
                             'MinRes' = min(datasetCsvFiltered$NU_NOTA_REDACAO))
outputFilename <- paste(urlFileOutPrefix, 'constraints', urlFileOutSuffix, sep = '')
write.csv(datasetCsvNormalized, file = outputFilename, row.names = FALSE)

# Produce a only numeric data table
datasetCsvNumeric <- datasetCsvNormalized
for(propertyName in names(datasetClasses)[which(names(datasetClasses) %ni% removedCols)]){
  
  # If it's not numeric nor character col
  if(datasetClasses[propertyName] != "numeric" &&
     datasetClasses[propertyName] != "character"){
    cat("Converting col -", propertyName, "to numeric\n")
    cat("Col", propertyName, "Type ->", class(datasetCsvNumeric[, propertyName]), "\n")
    
    # Convert this col to numeric
    datasetCsvNumeric[,propertyName] <- as.numeric(datasetCsvNumeric[,propertyName])
  }
}

# Remove col with character content
datasetCsvNumeric <- subset(datasetCsvNumeric, select = -c(
  NO_MUNICIPIO_RESIDENCIA,
  NO_MUNICIPIO_PROVA
))

# Store Numeric CSV after normalized data
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'numeric', urlFileOutSuffix, sep = '')
write.csv(datasetCsvNumeric, file = outputFilename, row.names = FALSE)

# Normalize all colums with numeric data again (this is to ensure the range of 0 .. 1)
datasetCsvNumericNormalized <- datasetCsvNumeric
for(propertyName in names(datasetClasses)[which(names(datasetClasses) %in% names(datasetCsvNumeric))]){
  
  # If it's numeric col
  if(max(datasetCsvNumericNormalized[propertyName]) > 1){
    cat("Normalizing col -", propertyName, 'with range',
        min(datasetCsvNumericNormalized[propertyName]), '-',
        max(datasetCsvNumericNormalized[propertyName]), "\n")
    cat("Col", propertyName, "Type ->", class(datasetCsvNumericNormalized[, propertyName]), "\n")
    
    # Get max and min values of this col
    maxValueCol <- max(datasetCsvNumericNormalized[, propertyName])
    minValueCol <- min(datasetCsvNumericNormalized[, propertyName])
    
    # Check if the value is not constant
    if(maxValueCol - minValueCol != 0){
      datasetCsvNumericNormalized[, propertyName] <-
        (datasetCsvNumericNormalized[, propertyName] - minValueCol) / abs(maxValueCol - minValueCol)
    }
    else{
      cat("Column", propertyName, "is constant\n")
    }
  }
}

# Store Numeric CSV Normalized
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'numeric_normalized', urlFileOutSuffix, sep = '')
write.csv(datasetCsvNumericNormalized, file = outputFilename, row.names = FALSE)

# This dataset has no numeric data, only factors
datasetCsvFactor <- datasetCsvNormalized

# Select only factors which is on database
if(exists("nonFactorCols"))
  rm(nonFactorCols)
for(csvCol in names(datasetClasses)){
  
  # Delete properties whose aren't factor
  if(csvCol != 'NU_NOTA_REDACAO' &&
     datasetClasses[csvCol] != 'factor' &&
     csvCol %in% names(datasetCsvFactor)){
      cat('Deleting property -', csvCol,'\n')
      if(exists("nonFactorCols"))
        nonFactorCols <- append(nonFactorCols, csvCol)
      else
        nonFactorCols <- c(csvCol)
  }
}

# Remove columns which isn't factors
datasetCsvFactor <- subset(datasetCsvFactor,select = names(datasetCsvFactor) %ni% nonFactorCols)

# Change content of response to factor with two digits
nDigitsFactorResult <- 2
datasetCsvNormalized$NU_NOTA_REDACAO <- factor(round(datasetCsvNormalized$NU_NOTA_REDACAO,
                                                     digits = nDigitsFactorResult))

# Store Numeric CSV after normalized data
# <3 http://rprogramming.net/write-csv-in-r/
outputFilename <- paste(urlFileOutPrefix, 'factor', urlFileOutSuffix, sep = '')
write.csv(datasetCsvFactor, file = outputFilename, row.names = FALSE)



################ DATA REVIEW ################



# Bargraph blotter
plotBargraph <- function (plotData, 
                          mainTitle, 
                          colColors, 
                          legendData, 
                          labelX, 
                          labelY, 
                          limitY){
  # Plot Bargraph with some style and text above column.
  #
  # Args:
  #   plotData: Data to be ploted. Must be a summary of data.
  #   mainTitle: Title of this graph.
  #   colColors: Colors for each column
  #   legendData: Legend of this graph
  #   labelX: Legend of X coordinates.
  #   labelY: Legend of Y coordinates.
  #   limitY: Data limit with some error
  #
  # Returns:
  #   The graph object.
  
  # Place the bar values above the bars
  # Note that I set 'ylim' to make room for 
  # the text labels above the bars
  # <3 https://stat.ethz.ch/pipermail/r-help/2005-September/079886.html
  tmpGraph <- barplot(plotData,
                      main = mainTitle,
                      col = colColors,
                      legend = legendData,
                      xlab = labelX,
                      ylab = labelY,
                      ylim = limitY + (round(limitY / 5)))
  tmpGraphValues <- text(tmpGraph,
                         plotData,
                         labels = plotData,
                         pos = 3)
  
}

# Some important Graphs to review

# Number of candidates by sex
candidatesSexSummary <- summary(datasetCsvFiltered$TP_SEXO)
candidatesSexGraph <- plotBargraph(candidatesSexSummary,
                                   "Candidatos por sexo",
                                   c("red", "blue"),
                                   c("Feminino", "Masculino"),
                                   "Sexo",
                                   "Número de Candidatos",
                                   c(0, max(candidatesSexSummary)))

# Number of candidates by state
candidatesStateSummary <- summary(datasetCsvFiltered$SG_UF_RESIDENCIA)
candidatesSexGraph <- plotBargraph(candidatesStateSummary,
                                   "Candidatos por estado",
                                   c("red", "brown", "purple", "violet",
                                     "darkgreen", "green", "orange",
                                     "chocolate1", "blue"),
                                   c("AL", "BA", "CE", "MA", "PB", "PE",
                                     "PI", "RN", "SE"),
                                   "Estado",
                                   "Número de Candidatos",
                                   c(0, max(candidatesStateSummary)))

# Number of invalid candidates
invalidCandidatesNum <- abs(length(datasetCsvFiltered$NO_MUNICIPIO_RESIDENCIA) - length(datasetCsv$NU_INSCRICAO))
validCandidatesNum <- abs(length(datasetCsv$NU_INSCRICAO) - invalidCandidatesNum)
invalidCandidatesSummary <- c("Candidatos Válidos" = validCandidatesNum,
                              "Candidatos Inválidos" = invalidCandidatesNum)
invalidCandidatesGraph <- plotBargraph(invalidCandidatesSummary,
                                   "Candidatos Inválidos",
                                   c("green", "red"),
                                   c("Candidatos Válidos", "Candidatos Inválidos"),
                                   "Tipo de Candidato",
                                   "Número de Candidatos",
                                   c(0, max(invalidCandidatesSummary)))

# Age of candidates
boxplot(datasetCsvFiltered$NU_IDADE,
        main = "Idade dos candidatos",
        ylab = "Anos")

# Age of candidates without ages greater than the outliners
maxRegularAge <- max(boxplot.stats(datasetCsvFiltered$NU_IDADE)$stats)
boxplot(datasetCsvFiltered$NU_IDADE[which(datasetCsvFiltered$NU_IDADE <= maxRegularAge)],
        main = "Idade dos candidatos",
        ylab = "Anos")