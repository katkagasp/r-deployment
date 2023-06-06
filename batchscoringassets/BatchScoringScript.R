library("ibmWatsonStudioLib")
wslib <- access_project_or_space()
print("watsonlib loaded")

library(nnet)

# get environment variables for input and output file names
input_file <- Sys.getenv('input_file_name','/userfs/assets/data_asset/input_data.csv') 
output_file <- Sys.getenv('output_file_name','output_data.csv')
print(input_file)

#input_file <- gsub("\"", "", input_file)
#print(input_file)

# read data
#df <-  read.csv('/userfs/assets/data_asset/input_data.csv', header=TRUE)
df <-  read.csv(input_file, header=TRUE)
head(df)

# load data prep script if needed

source("/userfs/assets/data_asset/preprocess_data.r")

# call the function from the script
df_processed <- preprocess_data(df, "Species")

head(df_processed)

# load the model

load_model <- readRDS("/userfs/assets/data_asset/model.rds")

load_model

colnames(df_processed) <- c('Sepal.L.','Sepal.W.','Petal.L.','Petal.W.','species')

# get predictions from the model
final_predictions <- predict(load_model, df_processed[1:5,])

# prepare for export
df <- as.data.frame(final_predictions)
df$prediction <- colnames(df)[apply(df,1,which.max)]
df$probability <- pmax(df$c, df$s, df$v)

final_predictions <- cbind(df_processed[1:5,], df$prediction, df$probability)

csv <- capture.output(write.csv(final_predictions, row.names=FALSE), type="output")
csv_raw <- charToRaw(paste0(csv, collapse='\n'))
output_file <- gsub("\"", "", output_file)

wslib$save_data(output_file, csv_raw, overwrite=TRUE)
