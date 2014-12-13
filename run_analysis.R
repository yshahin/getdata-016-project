library(tidyr)
library(dplyr)


header.phone.data <- function(directory, type) {
  ## read feature headers from features file
  ## and select only the feature names
  feature_header <- read.table(
    paste0(directory, "/features.txt"), 
    header = F, sep = " ", quote = "", comment.char = "")[,2]
  ## Append feature count due to duplicated feature names
  feature_header <- mapply(paste0, seq_along(feature_header), ".",
    sapply(feature_header, function(x) gsub("\\.+", ".", make.names(tolower(x)))))
  feature_header
}

## load data assuming they are in a subfolder
## in your working directory
phone.data <- function(directory, type) {
  feature_header <- header.phone.data(directory, type)
  ## read data
  data <- read.fwf(
    paste0(directory, "/", type,
      paste0("/X_", type, ".txt.sample")), 
    rep(16, length(feature_header)), 
    header = F, comment.char = "")
  names(data) <- feature_header
  data
}

subject.phone.data <- function(directory, type) {
  ## read subject id
  data <- read.table(
    paste0(directory, "/", type,
           paste0("/subject_", type, ".txt.sample")), 
    header = F, sep = " ", quote = "", comment.char = "")
  names(data) <- "subject"
  data
}

activity.phone.data <- function(directory, type) {
  ## read activity ids
  activityids <- read.table(
    paste0(directory, "/", type, 
           paste0("/y_", type, ".txt.sample")),
    header = F, sep = " ", quote = "", comment.char = "")

  ##load activity names
  activitynames <- read.table(
    paste0(directory, "/activity_labels.txt"), 
    header = F, sep = " ", quote = "", stringsAsFactors = F, comment.char = "")[,2]
  
  data <- sapply(activityids, function(x) activitynames[x])
  colnames(data) <- "activity"
  data
}

prepare.phone.data <- function(directory) {
  # x data with appropriate labels
  data <- rbind( # Merge training and test data
      phone.data("sample", "train"), 
      phone.data("sample", "test"))
  # subject column with appropriate label
  data <- cbind(
    rbind(subject.phone.data(directory, "train"),
          subject.phone.data(directory, "test")), data)
  # activity column with discriptive names
  data <- cbind(data,
    rbind(activity.phone.data(directory, "train"),
          activity.phone.data(directory, "test")))
  data
}
## convert to table data.frame for use with dplyr and tidyr
data <- tbl_df(prepare.phone.data("sample"))

## select only the needed columns which are the columns that
## contain mean, std and the activity names
data <- select(data, subject, contains(".mean."), contains(".std."), activity)

#write.table(data, "data_table.txt", row.names=F)
temp <- data %>% 
  gather(key, value, -activity, -subject)

