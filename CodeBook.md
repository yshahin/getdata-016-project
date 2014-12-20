Getting and Cleaning Data (Coursera). Course Project Codebook
=======================


## Original Data

There original data comes from the smartphone accelerometer and gyroscope 3-axial raw signals, 
which have been processed using various signal processing techniques to measurement vector consisting
of 561 features. For detailed description of the original dataset, please see `features_info.txt` in
the zipped dataset file.

- [source](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 
- [description](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

## Steps

### Loading feature headers

When Loading feature headers with R is seems to think there are duplicates so to disambiguate feature names by (steps are combined in 1 call)

Steps are encapsulates in `header.phone.data` function

1. Adding sequance number at the begingin of the name using `paste0` and `seq_along(feature_header)`
2. Fixing names using `make.names` to remove special characters and replce them with `.`
3. Normalize names by doing `tolower` on them
4. Found bug in title name one of them has `bodybody` so using `gsub` to replace them with `body`

```
feature_header <- mapply(paste0, seq_along(feature_header), ".",
    sapply(feature_header, function(x) {
        sub("bodybody", "body", gsub("\\.+", ".", make.names(tolower(x))))
}))
```
### Loading train and test data

Data file is stored in a fixed width file, so function read.fwf was used to load train and test data.

Seps are encapsulated in `phone.data` function

1. `feature_header` contains feature header names and is loaded using the function `header.phone.data`
2. To speed up loading variables `colClasses` is preset to numeric since all data values are numeric
3. Set width for each column to 16, using function `rep` to set this value with the size for the feature_header

```
data <- read.fwf(
    paste0(directory, "/", type,
      paste0("/X_", type, ".txt")),
    rep(16, length(feature_header)),
    colClasses=rep("numeric", length(feature_header)),
    header = F, comment.char = "")
```

### Loading Subject and Activity data

Subject and Activity loaded in using seperate files

Loading in Subject is straight forward using `read.table`

Loading in Activity data is same as Subject using `read.table` but since Activity data is loaded as ids, Activity names need to be loaded as well and merged to get readable data.

1. Load in activity ids

    ```
    activityids <- read.table(
      paste0(directory, "/", type,
        paste0("/y_", type, ".txt")),
      header = F, sep = " ", quote = "", comment.char = "")
    ```

2. load activity names

    ```
    ##load activity names
    activitynames <- read.table(
      paste0(directory, "/activity_labels.txt"),
      header = F, sep = " ", quote = "", 
      stringsAsFactors = F, comment.char = "")[,2]
    ```
3 . convert ids to activity names

    ```
    data <- sapply(activityids, function(x) activitynames[x])
    colnames(data) <- "activity"
    ```

Output of this step will have the subject column as well as the activity coulmn ready for use

### Merging loaded data

All data are available from the previous three steps with the correct order all that needs to be done is 

1. `rbind` (TrainData, TestData) then
2. `cbind` (Subject, Data, Activity)  
3. Only Mean and Std columns are required for the project so using tidyr and dplyr coumns that contains `.mean.` or `.std.` are left in the data set.

    ```
    data <- rbind( # Merge training and test data
    select(phone.data(directory, "train"), 
           contains(".mean."), contains(".std.")),
    select(phone.data(directory, "test"), 
           contains(".mean."), contains(".std.")))
    ```
    
    since after name cleaning all "-", "(", ")" have been converted to "." using the `make.names` function using ".std." and ".mean." makes sure that only "-mean()" and "-std()" pass throught while something like "meanFreq()" won't pass in.

## Tidy data set

### Data Set Structure

All variables were moved into rows with new columns,

| subject | activity         | domain | aggregation | axis | mean       |
|:-------:|------------------|--------|-------------|------|------------|
| 1       | LAYING           | t      | bodyacc     | x    | -0.8336256 |
| 1       | WALKING          | f      | bodyaccjerk | y    | -0.9641607 |
| 1       | WALKING_UPSTAIRS | t      | bodyacc     | z    | -0.8128916 |
| ...     | ...              | ...    | ...         | ...  | ...        |


| Column      | Description                                                      |
|:-----------:|------------------------------------------------------------------|
| subject     | User id that generated the experement values                     |    
| activity    | What activity was the subject doing                              |
| domain      | Values are given in 2 domains either time or frequency           |
| aggregation | What aggregation was applied to generate the value, mean or std  |
| axis        | Which axis was this measure taken x, y, z or ""(Not Applicable)  |
| mean        | Numeric value representing the mean of the values                |
