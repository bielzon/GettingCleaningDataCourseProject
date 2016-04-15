library(reshape2)
# Preprocessing stuff like downloading and creating directories
if (!file.exists("getdata_dataset.zip")){
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ",
                  "getdata_dataset.zip", mode = "wb")}
if(!file.exists("UCI HAR Dataset")){unzip("getdata_dataset.zip")}

# Reading labels
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
activities <- as.character(activities[,2])
features[,2] <- as.character(features[,2])

# 2. Extracts only the measurements on the mean and standard deviation for
# each measurement.
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])

# 0. Read separate datasets
# 1. Merges the training and the test sets to create one data set.
# 4. Appropriately labels the data set with descriptive variable names.
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
train <- cbind(trainSubjects, trainActivities, train)
test <- cbind(testSubjects, testActivities, test)
merged <- rbind(train, test)

# 3. Uses descriptive activity names to name the activities in the data set
featuresWantedNames <- features[featuresWanted,2]
featuresWantedNames <- gsub('-mean', 'Mean', featuresWantedNames)
featuresWantedNames <- gsub('-std', 'Std', featuresWantedNames)
featuresWantedNames <- gsub('[-()]', '', featuresWantedNames)
colnames(merged) <- c("subject", "activity", featuresWantedNames)
merged$activity <- factor(merged$activity, levels = activities[,1], labels = activities[,2])
merged$subject <- as.factor(merged$subject)

# 5. From the data set in step 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.
meltMerged <- melt(merged, id = c("subject", "activity"))
mergedAvg <- dcast(meltMerged, subject + activity ~ variable, mean)
write.table(mergedAvg, "tidydataset.txt", row.names = FALSE, quote = FALSE)
