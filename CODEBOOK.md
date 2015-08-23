---
title: "Codebook"
author: "DianaSP"
date: "23 de agosto de 2015"
output: html_document
---

CODEBOOK.md
Diana SP

Sunday, August 23, 2015

Getting and Cleaning Data Course Project
Instructions for project The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
The goal is to prepare tidy data that can be used for later analysis. 

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. 
These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. and the acceleration signal was then separated into body and gravity acceleration signals 
(tBodyAcc-XYZ and tGravityAcc-XYZ) - both using a low pass Butterworth filter.

The body linear acceleration and angular velocity were derived in time to obtain Jerk signals 
(tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean 
norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

A Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. 
(Note the 'f' to indicate frequency domain signals).

Description of abbreviations of measurements

leading t or f is based on time or frequency measurements.
Body = related to body movement.
Gravity = acceleration of gravity
Acc = accelerometer measurement
Gyro = gyroscopic measurements
Jerk = sudden movement acceleration
Mag = magnitude of movement

mean and SD are calculated for each subject for each activity for each mean and SD measurements.
The units given are g's for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions. They total 33 measurements including the 3 dimensions - the X,Y, and Z axes.

tBodyAcc-XYZ
tGravityAcc-XYZ
tBodyAccJerk-XYZ
tBodyGyro-XYZ
tBodyGyroJerk-XYZ
tBodyAccMag
tGravityAccMag
tBodyAccJerkMag
tBodyGyroMag
tBodyGyroJerkMag
fBodyAcc-XYZ
fBodyAccJerk-XYZ
fBodyGyro-XYZ
fBodyAccMag
fBodyAccJerkMag
fBodyGyroMag
fBodyGyroJerkMag
The set of variables that were estimated from these signals are:

mean(): Mean value
std(): Standard deviation
Data Set Information:
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. 
Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz.
The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets,
where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows. 
From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.

```{r}
library(curl)
#Download the Data
filesPath <- "E:/7 ESPECIALIZACION/3 Curso Getting and Cleaning Data/3 Week 3/Proyecto/UCI HAR Dataset"
setwd(filesPath)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

###Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")


###Load required packages
library(dplyr)
library(data.table)
library(tidyr)

#Read the above files and create data tables.

filesPath <- "E:/7 ESPECIALIZACION/3 Curso Getting and Cleaning Data/3 Week 3/Proyecto/UCI HAR Dataset/data/UCI HAR Dataset"
# Read subject files
data_subject_train <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
data_subject_test  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

# Read activity files
data_labels_train <- tbl_df(read.table(file.path(filesPath, "train", "y_train.txt")))
data_labels_test  <- tbl_df(read.table(file.path(filesPath, "test" , "y_test.txt" )))

#Read data files.
data_set_train <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
data_set_test  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))


#1. Merges the training and the test sets to create one data set.
# for both Activity and Subject files this will merge the training and the test sets by row binding 
#and rename variables "subject" and "activityNum"
alldataSubject <- rbind(data_subject_train, data_subject_test)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(data_labels_train, data_labels_test)
setnames(alldataActivity, "V1", "activityNum")

#combine the DATA training and test files
dataTable <- rbind(data_set_train, data_set_test)

# name variables according to feature e.g.(V1 = "tBodyAcc-mean()-X")
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("feature_Num", "feature_Name"))
colnames(dataTable) <- dataFeatures$feature_Name

#column names for activity labels
activityLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activity_Name"))

# Merge columns
alldataSubjAct<- cbind(alldataSubject, alldataActivity)
dataTable <- cbind(alldataSubjAct, dataTable)


#2. Extracts only the measurements on the mean and standard deviation for each measurement.
# Reading "features.txt" and extracting only the mean and standard deviation
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$feature_Name,value=TRUE) 

# Taking only measurements for the mean and standard deviation and add "subject","activityNum"

dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
dataTable<- subset(dataTable,select=dataFeaturesMeanStd) 



#3. Uses descriptive activity names to name the activities in the data set
##enter name of activity into dataTable
dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
#dataTable$activity_Name <- as.character(dataTable$activity_Name)


## create dataTable with variable means sorted by subject and Activity
dataTable$activity_Name <- as.character(dataTable$activity_Name)
dataAggr<- aggregate(. ~ subject - activity_Name, data = dataTable, mean) 
dataTable<- tbl_df(arrange(dataAggr,subject,activity_Name))


#4. Appropriately labels the data set with descriptive variable names.
#Names before
head(str(dataTable),2) 

names(dataTable)<-gsub("std()", "SD", names(dataTable))
names(dataTable)<-gsub("mean()", "MEAN", names(dataTable))
names(dataTable)<-gsub("^t", "time", names(dataTable))
names(dataTable)<-gsub("^f", "frequency", names(dataTable))
names(dataTable)<-gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable)<-gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable)<-gsub("Mag", "Magnitude", names(dataTable))
names(dataTable)<-gsub("BodyBody", "Body", names(dataTable))
# Names after
names(dataTable)
head(str(dataTable),6)

#5. From the data set in step 4, creates a second, independent tidy data set with the average of 
#each variable for each activity and each subject.
##write to text file on disk

file.exists("E:/7 ESPECIALIZACION/3 Curso Getting and Cleaning Data/3 Week 3/Proyecto/UCI HAR Dataset/data/UCI HAR Dataset")
output_dir<-"E:/7 ESPECIALIZACION/3 Curso Getting and Cleaning Data/3 Week 3/Proyecto/UCI HAR Dataset/data/UCI HAR Dataset"
f.nm <- paste0(output_dir, Sys.Date(), "Tidy_data.txt")
#f.nm <- paste0(output_dir, Sys.Date(), "Tidy_data.csv")

# break it down into finer steps
file.create(f.nm)
f <- file(f.nm, open="w") # or open="a" if appending

write.table(dataTable, file = f, sep = ",", append=FALSE, row.names = FALSE, col.names=TRUE)

close(f)
```








