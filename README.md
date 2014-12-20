Getting and Cleaning Data - Course Project
==========================================

This repository hosts the R code and documentation files for the Data Science's track course "Getting and Cleaning data", available on coursera.

The dataset being used is: [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

## Files

The code assumes that all data is present in the working direcotry under the folder "UCI HAR Dataset", un-compressed and without names altered. A copy of the data is checked into the github repository.

`CodeBook.md` describes the variables, the data, and any transformations or work that was performed to clean up the data.

`run_analysis.R` contains all the code cleaning required by the project. The script can be run using RStudio but because RStudio uses alot of memory it is recommended to use command line, Open a terminal and navigate to the directory and type `R --no-save < run_analysis.R`.

The output of the script is called `data_table.txt`, which is the required output from step 5 of the project. The file can also be found in the root direcotry of the repository.