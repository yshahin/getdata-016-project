## load train and test data
load_data <- function(path) {
  feature_header <- read.table(
    "sample/features.txt", 
    header = F, sep = " ", quote = "", comment.char = "")[,2]
  feature_header <- mapply(paste0, seq_along(feature_header), "_", feature_header)
  subject_train <- read.table(
    paste0("sample/", path,
      paste0("/subject_", path, ".txt.sample")), 
    header = F, sep = " ", quote = "", comment.char = "")[,1]
  x_train <- read.fwf(
    paste0("sample/",path,
      paste0("/X_", path, ".txt.sample")), 
    rep(16, length(feature_header)), 
    header = F, comment.char = "")
  names(x_train) <- feature_header
  y_train <- read.table(
    paste0("sample/", path, 
      paste0("/y_", path, ".txt.sample")),
    header = F, sep = " ", quote = "", comment.char = "")
  names(y_train) <- c("label")
  cbind(x_train, y_train)
}

library(tidyr)
library(dplyr)

label_names <- read.table("sample//activity_labels.txt", header = F, sep = " ", quote = "", stringsAsFactors = F, comment.char = "")[,2]
data <- tbl_df(rbind(load_data("train"), load_data("test")))
remove("load_data")
data <- mutate(data, label_names=label_names[label]) 
remove("label_names")
data <- select(data, contains("mean"), contains("std"), contains("label_names"))

