# I assume that dataset is downloaded and extracted.
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# You can run the code as long as the Samsung data is in Your working directory. 

# ------------ Load data
activity_labels = read.table(file="activity_labels.txt",
                             header=FALSE, sep=" ", col.names=c("num_label", "text_label"))
features = read.table(file="features.txt",
                      header=FALSE, sep=" ", col.names=c("col_number", "col_label"))

subject_train = read.table(file="train/subject_train.txt",
                           header=FALSE, sep=" ", col.names="subject")
subject_test = read.table(file="test/subject_test.txt",
                          header=FALSE, sep=" ", col.names="subject")

y_train = read.table(file="train/y_train.txt", 
                     header=FALSE, sep=" ", col.names="activity")
y_test = read.table(file="test/y_test.txt", 
                    header=FALSE, sep=" ", col.names="activity")

X_train = read.table(file="train/X_train.txt",
                     header=FALSE, col.names=features$col_label)
X_test = read.table(file="test/X_test.txt",
                    header=FALSE, col.names=features$col_label)

#----------------------------------------
#Merge the training and the test sets(X) to create one data set.
merged_test_train=merge(x=X_train, y=X_test, all=TRUE)

#also merge activity(y) and subject vectors
subject_merged=c(subject_train$subject, subject_test$subject)
y_merged=c(y_train$activity, y_test$activity)
#------------------------------------------
#Extract only the measurements on the mean and standard deviation for each measurement.
#
#first find names of columns with mean() or std() expresions
cols2extract = names(merged_test_train)[grepl("mean\\(\\)|std\\(\\)", features$col_label)]
#now extract those columns
merged_test_train=merged_test_train[cols2extract]
#-----------------------------------
# Add subject and activity columns to dataframe
merged_test_train=data.frame(activity=y_merged, merged_test_train)
merged_test_train=data.frame(subject=subject_merged, merged_test_train)
#--------------------------------------
# lable activity variable with desciptive names
merged_test_train$activity=factor(merged_test_train$activity, levels=activity_labels$num_label, labels=activity_labels$text_label)
#-------------------------------------------
# create another dataframe with the average of each variable for each activity and each subject
library("reshape2")
melted=melt(merged_test_train,
            id.vars=names(merged_test_train)[1:2],
            measure.vars=names(merged_test_train[3:68]))
new_tidy=dcast(melted, subject + activity ~ variable, mean)
# write this new data set to file
write.table(new_tidy, file="new_tidy.txt")
