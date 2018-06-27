library(dplyr)

# download the data 
zipURL<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"
if (!file.exists(dataPath)) {
  download.file(zipURL, zipFile, mode="wb")
}

# Load the data into R
# first load the trainig data set
training_subjects <- read.table(file.path(dataPath, "train", "subject_train.txt"))
training_values <- read.table(file.path(dataPath, "train", "X_train.txt"))
training_activity <- read.table (file.path(dataPath, "train", "y_train.txt"))

# then load the test data set
test_subjects <- read.table(file.path(dataPath, "test", "subject_test.txt"))
test_values <- read.table(file.path(dataPath, "test", "X_test.txt"))
test_activity <- read.table (file.path(dataPath, "test", "y_test.txt"))

# load the rest of the data, the features and activity labels
features <- read.table(file.path(dataPath, "features.txt"), as.is = TRUE)

# take a first look at the data with header and str

# merging the data 
dataSubject <- rbind(training_subjects, test_subjects)
dataActivity<- rbind(training_activity, test_activity)
dataFeatures<- rbind(training_values, test_values)

## Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(dataPath, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

## After merging the data of test and train concerning specific data, Merge columnwise to get the data frame Data 
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Extracting only the measurements on the mean and standard deviation for each measurement.
#Subset Name of Features by measurements on the mean and standard deviation

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
# Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)


#Name the activities in the data set
# Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(dataPath, "activity_labels.txt"),header = FALSE)
# Factorize Variale activity 
Data$activity<-factor(Data$activity,labels=activityLabels[,2])
#test
head(Data$activity,30)

# label the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


#Creating a tidy data set

newData<-aggregate(. ~subject + activity, Data, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
