### Introduction

This code was made to meet Coursera's "Getting and Cleaning Data" Course
Project. The goal of the project was to prepare a tidy dataset, from data
provided for this purpose. 

Data used was collected from the accelerometers from the Samsung Galaxy S
smartphone, in an experience with 30 volunteers, during different activities.

Using this data the project requires the students to create an R script to
do the following:
1 Merges the training and the test sets to create one data set.
2 Extracts only the measurements on the mean and standard deviation for each
 measurement. 
3 Uses descriptive activity names to name the activities in the data set
4 Appropriately labels the data set with descriptive variable names. 
5 From the data set in step 4, creates a second, independent tidy data set 
with the average of each variable for each activity and each subject.

Code used for that purpose will be discussed for each step.

### Step 1: Merge Data Sets to create one Data Set

Data was providede divided in two data sets (train and test). We should
read both data sets and create a single one. Variables names were also
in a separate file.

The get data the code uses the `data.table` library with the `read.table`
function. Since the two data sets were in the same format, code uses `rbind`
to combine them in one data.

Also we got variable names and use `make.names` to eliminate characters that
can't be used for variable names. Using `names` function, included the valid
names in the Data Base

Code for Step 1 is as follows

<!-- -->

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
    


### Step 2: Extract only variables with Mean and Std

To meet Step 2 requirement, I created an index vector to allow the code to
subset only the desired columns.
The function chosen to create the index vector was `grepl`. With this 
function the code creates two vectors: one with the indexes for variables
containing the string "Mean()", and another one with the indexes for "Std()".
The two were combined using the logical operator and (`|`).

New data was creating by subsetting data from step 1, using the vector indexes
to subset only the desired columns.

Code for Step 2 is as follows

    # Step 2
    # create a logical index to subset only the columns with "mean" and "std"
    indexmean <- grepl("mean()",names$V2, fixed=TRUE)
    indexstd <- grepl("std()",names$V2)
    colindex <- indexmean | indexstd
    data2 <- data[,colindex]
    

### Step 3: Uses descriptive activity names in the data set


Activities the were monitored in that originated the measures of each row were 
in a separate file, also split in "train" and "test" datasets. Activities were
number coded and each row corresponded to the measurement row in the same position.

The subject that was being monitored is also in a separate file, just like
activities, and is also split in two datasets.

To get all that data and put it together, code uses `read.table` to read data and
`rbind` to put "train" and "test" data in the same vector, one for activities and
one for subjects.

After that, vectors are renamed and included in the previous dataset  using `cbind`.

To complete step 3, code gets Activity Labels, also from a separate file, and creates
a factor variable.

Code for step 3 follows

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
    


### Step 4: Appropriately labels the data set with descriptive variable names.

Since the variable names were already descriptive enough, what the code does is 
only apply some general "good practice" rules presented in Slide 16 of the lecture
"Editing Text Variables" from Week 4: keep all lower case and avoid underscores,
dots and white spaces.

All was done in one single line of command.

    # Step 4
    names(data3) <- tolower(gsub("\\.","",names(data3)))
    

### Step 5: creates a second data set with the average of each variable for each activity and each subject.

For the final step, code uses library `reshape2` and the functions `melt` and
`dcast` to assign "activity" and "subject" as the ID variables, and then apply 
the mean to all other variables.

Last code command exports the dataset to a .txt file.

    # Step 5
    library(reshape2)
    data_melt <- melt(data3,id=c("activity","subject"))
    finaldata <- dcast(data_melt, activity + subject ~ variable, mean)
            
    write.table(finaldata,file="HAR_Tidy.txt",row.names=FALSE)

