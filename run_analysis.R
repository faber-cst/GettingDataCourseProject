# Step 1
library(data.table)

# read Data
test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE)
train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE)
names <- read.table("UCI HAR Dataset/features.txt", header=FALSE)
data <- rbind(test,train)
# create valid names for the data
feat<-make.names(names$V2)
names(data) <- feat


# Step 2
# create a logical index to subset only the columns with "mean" and "std"
indexmean <- grepl("mean()",names$V2, fixed=TRUE)
indexstd <- grepl("std()",names$V2)
colindex <- indexmean | indexstd
data2 <- data[,colindex]

#Step 3
# Get information on Subject. Uses the same order of the measurements data
subjtest <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE)
subjtrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE)
subject <- rbind(subjtest,subjtrain)
# Get information on Activity. Uses the same order of the measurements data
activtest <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE)
activtrain <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE)
activity <- rbind(activtest,activtrain)
# Rename variables and bind with Data
names(subject) <- "subject"
names(activity) <- "activity"
data3 <- cbind(data2,subject,activity)
# Get activity labels and create a factor variable for activity
act_label<- read.table("UCI HAR Dataset/activity_labels.txt", header=FALSE)
data3$activity <- factor(data3$activity,levels=act_label$V1,labels=act_label$V2)

# Step 4
names(data3) <- tolower(gsub("\\.","",names(data3)))

# Step 5
library(reshape2)
data_melt <- melt(data3,id=c("activity","subject"))
finaldata <- dcast(data_melt, activity + subject ~ variable, mean)
            
write.table(finaldata,file="HAR_Tidy.txt",row.names=FALSE)
