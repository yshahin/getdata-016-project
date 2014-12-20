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

###Loading feature headers

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
###Loading train and test data

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

###Loading Subject and Activity data

Subject and Activity loaded in using seperate files

###Merging loaded data

The raw dataset was created using the following regular expression to filter out required
features, eg. the measurements on the mean and standard deviation for each measurement
from the original feature vector set 

`-(mean|std)\\(`

This regular expression selects 66 features from the original data set.
Combined with subject identifiers `subject` and activity labels `label`, this makes up the
68 variables of the processed raw data set.

The training and test subsets of the original dataset were combined to produce final raw dataset.

### Tidy data set

Tidy data set contains the average of all feature standard deviation and mean values of the raw dataset. 
Original variable names were modified in the follonwing way:

 1. Replaced `-mean` with `Mean`
 2. Replaced `-std` with `Std`
 3. Removed parenthesis `-()`
 4. Replaced `BodyBody` with `Body`

It should be noted that the variable names are formatted in camelCase, as described in 
[Google R Styde Guide](http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml). 

#### Sample of renamed variables compared to original variable name

 Raw data            | Tidy data 
 --------------------|--------------
 `subject`           | `subject`
 `label`             | `label`
 `tBodyAcc-mean()-X` | `tBodyAccMeanX`
 `tBodyAcc-mean()-Y` | `tBodyAccMeanY`
 `tBodyAcc-mean()-Z` | `tBodyAccMeanZ`
 `tBodyAcc-std()-X`  | `tBodyAccStdX`
 `tBodyAcc-std()-Y`  | `tBodyAccStdY`
 `tBodyAcc-std()-Z`  | `tBodyAccStdZ`
