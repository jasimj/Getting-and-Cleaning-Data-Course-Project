#1. Get the Data
library(plyr)
library(data.table)

setwd("E:/DataScience/Coursera/Getting and Cleaning Data Course Project")


filename <- "SamSung.zip"
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if (!file.exists(filename)){
  download.file(fileUrl, destfile = filename, method = "curl")}


if(!file.exists("UCI HAR Dataset")){
  unzip(filename)
}


path <- file.path("UCI HAR Dataset")
file_list <- list.files(path, recursive = TRUE)
file_list





#2. Read the Data

activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featureTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featureTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

#3. Merge the Data
Subject <- rbind(subjectTest,subjectTrain)
Activity <- rbind(activityTest, activityTrain)
Feature <- rbind(featureTest, featureTrain)

names(Subject) <- c("Subject")
names(Activity) <- c("Activity")
FeatureNames <- read.table("UCI HAR Dataset/features.txt", head = FALSE)
names(Feature) <- FeatureNames$V2

all <- cbind(Subject, Activity, Feature)

#4. Extracts only the measurements on the mean and standard deviation for each measurement

WantedFeatureNames <- FeatureNames$V2[grep('-(mean|std)\\(\\)', FeatureNames$V2)]

selectedNames <- c(as.character(WantedFeatureNames), "Subject", "Activity")
selected_data <- subset(all, select = selectedNames)
View(head(selected_data))

#5 Appropriately label the variables
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
selected_data$Activity <- factor(selected_data$Activity, levels = activityLabels$V1, 
                                 labels = activityLabels$V2)
selected_data$Subject <- as.factor(selected_data$Subject)

names(selected_data) <- gsub("^t", "time", names(selected_data))
names(selected_data) <- gsub("^f", "frequency", names(selected_data))
names(selected_data) <- gsub("Acc", "Accelerometer", names(selected_data))
names(selected_data) <- gsub("Gyro", "Gyroscope", names(selected_data))
names(selected_data) <- gsub("Mag", "Magnitutde", names(selected_data))
names(selected_data) <- gsub("BodyBody", "Body", names(selected_data))
View(head(selected_data))

#6. Create a second,independent tidy data set and ouput it, 
#with the average of each variable for each activity and each subject

tidydata <- aggregate(.~Subject + Activity, selected_data, mean)
tidydata <- tidydata[order(tidydata$Subject, tidydata$Activity), ]
write.table(tidydata, file = "tidydata.txt", row.name = FALSE)
