preprocess_data <- function(dataframe,SPECIES_col ){
  require(plyr)
  dataframe[SPECIES_col] <- mapvalues(dataframe[SPECIES_col][[1]], 
                                      from=c("setosa","versicolor","virginica"), 
                                      to=c("s","c","v"))
  return(dataframe)
}