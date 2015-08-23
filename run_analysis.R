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
