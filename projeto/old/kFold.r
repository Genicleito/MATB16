# Set random seed. Don't remove this line.
set.seed(1)

# Initialize the accs vector
accs <- rep(0,10)

for (i in 1:10) {
  # These indices indicate the interval of the test set
  indices <- (((i-1) * round((1/10)*nrow(iris))) + 1):((i*round((1/10) * nrow(iris))))
  
  # Exclude them from the train set
  train <- iris[-indices,]
  # Include them in the test set
  test <- iris[indices,]
}