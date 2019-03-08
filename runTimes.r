########################################################
#
# Compare speed between loop, apply and  colSums
#       Simulation script
#
# Simon Benateau 05.03.2019
#
######################################################

# package to compare execution time
library(microbenchmark)
library(tibble)

# Parameters
#---------------------

# number of test for the benshmarking function
repetition = 1000
# column number to be tested
col = c(1e1, 1e2, 1e3, 1e4)
# row number to be tested
row = c(1e1, 1e2, 1e3, 1e4)
# type of object to be tested (only matrix, data.frame, tibble)
type = c("matrix", "data.frame")

# Pre simulation
# ------------------------

# combine parameters for simulations
combineParameters <- data.frame(type = rep(type, length(row) * length(col)),
                                ncol = rep(rep(col, each = length(type)), length(row)),
                                nrow = rep(row, each =  length(col) * length(type))
)

# function to calculate the sum of each column in the matrix
colsums1Loop <- function (x) {
  #preallocate memory:
  vect <- numeric(ncol(x))
  # loop to sum all columns
  for (i in 1:ncol(x)) {
    #store the sum in the vector
    vect[i] <- sum(x[, i])
  }
  return(vect)
}

# Dataframe to collect data
dataTime <- data.frame(matrix(NA,nrow = length(col) * length(row) * length(type) * repetition * 3, ncol = 5))
# give names to colums
colnames(dataTime) <- c("Time", "Function", "Ncol", "Nrow", "Type")

# loop to get all the combinaisons
#----------------------------
for (i in 1:nrow(combineParameters)){
  
  # generate test data
  dataInit <- matrix(rnorm(combineParameters$ncol[i] * combineParameters$nrow[i],100,2), 
                     nrow = combineParameters$nrow[i])
  
  if (combineParameters$type[i] == "data.frame" | combineParameters$type[i] == "tibble") dataInit <- data.frame(dataInit)
  if (combineParameters$type[i] == "tibble") dataInit <- as_tibble(dataInit)
  
  # function to compare the execution time
  mbm = microbenchmark(loop     = colsums1Loop(dataInit),
                       apply    = apply(dataInit, 2, sum),
                       colSums  = colSums(dataInit),
                       times = repetition,
                       unit = "ms"
  )
  
  # save data
  maxValue <- i * repetition * 3
  interval <- (maxValue - (repetition * 3 - 1)):maxValue
  dataTime[interval, "Time"] <- mbm$time
  dataTime[interval, "Function"] <- as.character(mbm$expr)
  dataTime[interval, "Nrow"] <- combineParameters$nrow[i]
  dataTime[interval, "Ncol"] <- combineParameters$ncol[i]
  dataTime[interval, "Type"] <- as.character(combineParameters$type[i])
}

# Save data
# ---------------------
write.table(dataTime, "runTimes.tsv", sep = "\t", row.names = FALSE)


