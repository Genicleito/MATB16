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

# Read preprocessaded data numeric normalized
pathDataPreProcessed <- 'dados_preprocessados_nordeste/result_numeric_normalized.csv'
datasetCsvNumericNormalized <- read.csv(pathDataPreProcessed)

# Check if DMwR is currently installed 
# https://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages
if (!'DMwR' %in% installed.packages())
  install.packages('DMwR')
require('DMwR')

# Factor split
splitFactor <- 0.7

# Split data in train and test
trainIds <- sample(1:nrow(datasetCsvNumericNormalized),
                   as.integer(splitFactor * nrow(datasetCsvNumericNormalized)))

# Train dataset
trainDataset <- datasetCsvNumericNormalized[trainIds,]

# Test dataset
testDataset <- datasetCsvNumericNormalized[-trainIds,]

# A 3-nearest neighbour model with normalization
nn3 <- kNN(NU_NOTA_REDACAO ~ ., trainDataset, testDataset, norm = FALSE, k = 3)

