library(tidyr)
library(dplyr)

header.phone.data <- function(directory) {
  ## read feature headers from features file
  ## and select only the feature names
  feature_header <- read.table(
    paste0(directory, "/features.txt"),
    header = F, sep = " ", quote = "", comment.char = "")[,2]
  ## Append feature count due to duplicated feature names
  feature_header <- mapply(paste0, seq_along(feature_header), ".",
    sapply(feature_header, function(x) {
      sub("bodybody", "body", gsub("\\.+", ".", make.names(tolower(x))))
    }))
  feature_header
}

## load data assuming they are in a subfolder
## in your working directory
phone.data <- function(directory, type) {
  feature_header <- header.phone.data(directory)
  ## read data
  data <- read.fwf(
    paste0(directory, "/", type,
      paste0("/X_", type, ".txt")),
    rep(16, length(feature_header)), colClasses=rep("numeric", length(feature_header)),
    header = F, comment.char = "")
  names(data) <- feature_header
  data
}

subject.phone.data <- function(directory, type) {
  ## read subject id
  data <- read.table(
    paste0(directory, "/", type,
           paste0("/subject_", type, ".txt")),
    header = F, sep = " ", quote = "", comment.char = "")
  names(data) <- "subject"
  data
}

activity.phone.data <- function(directory, type) {
  ## read activity ids
  activityids <- read.table(
    paste0(directory, "/", type,
           paste0("/y_", type, ".txt")),
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
  ## select only the needed columns which are the columns that
  ## contain mean, std and the activity names
  data <- rbind( # Merge training and test data
    select(phone.data(directory, "train"), 
           contains(".mean."), contains(".std.")),
    select(phone.data(directory, "test"), 
           contains(".mean."), contains(".std.")))
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
raw_data <- tbl_df(prepare.phone.data("UCI HAR Dataset"))

tidy_data <- raw_data %>%
  gather(key, value, -activity, -subject) %>%
  separate(key, c("featureid", "measurement", "aggregation", "axis")) %>%
  select(-featureid) %>% separate(measurement, c("domain", "measurment"), sep = 1)

write.table(tidy_data, "data_table.txt", row.names=F)
