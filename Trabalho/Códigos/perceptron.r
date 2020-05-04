perceptron <- function(x, y, eta, niter) {
  
  # initialize weight vector
  weight <- rep(0, dim(x)[2] + 1)
  errors <- rep(0, niter)
  
  
  # loop over number of epochs niter
  for (jj in 1:niter) {
    
    # loop through training data set
    for (ii in 1:length(y)) {
      
      # Predict binary label using Heaviside activation 
      # function
      z <- sum(weight[2:length(weight)] * 
                 as.numeric(x[ii, ])) + weight[1]
      if(z < 0) {
        ypred <- -1
      } else {
        ypred <- 1
      }
      
      # Change weight - the formula doesn't do anything 
      # if the predicted value is correct
      weightdiff <- eta * (y[ii] - ypred) * 
        c(1, as.numeric(x[ii, ]))
      weight <- weight + weightdiff
      
      # Update error function
      if ((y[ii] - ypred) != 0.0) {
        errors[jj] <- errors[jj] + 1
      }
      
    }
  }
  
  # weight to decide between the two species 
  print(weight)
  return(errors)
}

err <- perceptron(x, y, 1, 10)

plot(1:10, err, type="l", lwd=2, col="red", xlab="epoch #", ylab="errors")
title("Errors vs epoch - learning rate eta = 1")