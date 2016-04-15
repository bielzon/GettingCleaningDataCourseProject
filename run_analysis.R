library(reshape2)
# Preprocessing stuff like downloading and creating directories
if (!file.exists("getdata_dataset.zip")){
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ",
                  "getdata_dataset.zip", mode = "wb")}
if(!file.exists("UCI HAR Dataset")){unzip("getdata_dataset.zip")}

# Reading labels
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
allfeatures <- read.table("UCI HAR Dataset/features.txt")
activities[,2] <- as.character(activities[,2])
allfeatures[,2] <- as.character(features[,2])

# 2. Extracts only the measurements on the mean and standard deviation for
# each measurement.
features <- grep(".*mean.*|.*std.*", allfeatures[,2])

# 0. Read separate datasets
# 1. Merges the training and the test sets to create one data set.
# 4. Appropriately labels the data set with descriptive variable names.
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features]
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features]
trainSbj <- read.table("UCI HAR Dataset/train/subject_train.txt")
testSbj <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainAct <- read.table("UCI HAR Dataset/train/Y_train.txt")
testAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
train <- cbind(trainSbj, trainAct, train)
test <- cbind(testSbj, testAct, test)
merged <- rbind(train, test)

# 3. Uses descriptive activity names to name the activities in the data set
featuresVals <- allfeatures[features,2]
featuresVals <- gsub('-mean', 'Mean', featuresVals)
featuresVals <- gsub('-std', 'Std', featuresVals)
featuresVals <- gsub('[-()]', '', featuresVals)
colnames(merged) <- c("subject", "activity", featuresVals)
merged$activity <- factor(merged$activity, levels = activities[,1], labels = activities[,2])
merged$subject <- as.factor(merged$subject)

# 5. From the data set in step 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.
meltMerged <- melt(merged, id = c("subject", "activity"))
mergedAvg <- dcast(meltMerged, subject + activity ~ variable, mean)
write.table(mergedAvg, "tidydataset.txt", row.names = FALSE, quote = FALSE)
