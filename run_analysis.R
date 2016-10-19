

###############code used for getting and cleaning data##################
library(tidyr)
library(data.table)
library(dplyr)
library(stringr)



download.file(
"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
destfile = "Human Activity Recognition Using Smartphones Data Set.zip",
mode = "wb", cacheOK = FALSE)
# get data first, name=Human Activity Recognition Using Smartphones Data Set.zip
# in current working directory



unzip("Human Activity Recognition Using Smartphones Data Set.zip")
#UCI HAR Dataset created


#at first, what we need is X_train/X_test. Thus, I merge c(subject id, X_test, y_test)

                         
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "subject_id")
#it is subject_id which tells you who data come from. there are 1:30 in id, and
#no common between training and test.
#see unique(subject_test[,1]) %in% unique(subject_train[,1])

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "action")


#y_test is action data which means what person actually doing. I named it action.


subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", 
                            col.names = "subject_id")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "action")

#same as test set, just read data and set names for id and action.


variable_explain <- read.table("./UCI HAR Dataset/features.txt",
                               row.names = 1, col.names = c("","explain"))
# in files x_test and x_train, no descriptive column names. 'features.txt' has
#exact meaning of each column, so I load that file and paste it to our data column name.



names(x_train) <- variable_explain[,1]
names(x_test) <- variable_explain[,1]

# all column has its name now. However, this name is not enought to understand, so
#need more process. I'm so sad I have no idea to deal with it. I will do it later
#after variable reduction. (in run_analysis.R, STEP 2 & 4)



x <- as.character(1:6)
y <- c("walk","walk_upstairs","walk_donwstairs","sit","stand","lay")

for (i in 1:6) {
      y_train$action <- str_replace_all(y_train$action,x[i],y[i])
      y_test$action <- str_replace_all(y_test$action,x[i],y[i])
}
#y_test was numeric, so alter to string directly meaning the action
# 1: walk 2: walk_upstairs 3: walk_donwstairs 4: sit 5: stand 6: lay


train_set <- data.table(subject_train, y_train, x_train)
test_set <- data.table(subject_test, y_test, x_test)

saveRDS(train_set,"train_set.rds")
saveRDS(test_set, "test_set.rds")
# combine all related data, and take data.table form (it is fast and easy manipulation.) 
# each set data is completed set now. Also saved as 'train_set.rds' in your working directory. 
# the reason why I saved data is both interim check and getiing tidy test/train data set.


# now regular step start.

###STEP 1. merge test set and training set

train_set <- readRDS("train_set.rds")
test_set <- readRDS("test_set.rds")
# load data first (data were manipulated using 'R Code Book.R')

#train_set[test_set, on = "subject_id"] is unavailable. (maybe no common key column I guess)


origin_data <- rbind(train_set,test_set)
# test/train data is distinguished with subject_id.
# Because these 2 data sets have no common subject_id at all, merge data with rbind. 
# so rbind can perfectly gather data from all subject.




### STEP 2. Extracts only the measurements on the mean and standard deviation for each measurement.



idx <- grep( "mean()", names(origin_data), fixed = TRUE )
idx2 <- grep( "std()", names(origin_data), fixed = TRUE )
# origin_data has all data, so I found mean and std on variable name list of origin_data
# results are saved in idx, idx2

data <- origin_data[, c(1,2,idx,idx2), with = FALSE]
# it calls only variable contains mean or std. This 'data' is almost close with
#our goal.




#STEP 3. Uses descriptive activity names to name the activities in the data set

unique(data$action)
#already set acitiviy names when loading data. (on R Code Book.R, line 102. )
#1: walk 2: walk_upstairs 3: walk_donwstairs 4: sit 5: stand 6: lay




### STEP 4. Appropriately labels the data set with descriptive variable names.

#this work is most hard for me, anyway I determined my way to express those variables
#For example, tBodyAcc-iqr()-X is divided into
# t, Body, Acc, iqr(), X . Transform t->time, Body-> body, Acc->acceleration
#each one is connected with underscore. and lowered string.
# it might be tBodyAcc-iqr()-X becomes time_body_acceleration_iqr_x

tmp <- names(data)[-c(1,2)]
tmp <- gsub("^t","time_",tmp)
tmp <- gsub("^f","fft_",tmp)
(tmp <- gsub("Acc","acceleration_",tmp))
(tmp <- gsub("Mag","magnitude_",tmp))
(tmp <- gsub("-std()","sd",tmp, fixed = TRUE))
(tmp <- gsub("-mean()","mean",tmp, fixed = TRUE))
(tmp <- gsub("Gyro","gyro_",tmp))
(tmp <- gsub("Body","body_",tmp))
(tmp <- gsub("Jerk","jerk_",tmp))
(tmp <- gsub("-","_",tmp))
tmp <- tolower(tmp)
names(data)[-c(1,2)] <- tmp

# one by one editing, all letters are lowered and each type is seperated with under score.
# Through many process, it become more readable and understandable





# STEP 5. creates a second, independent tidy data set with the average of each 
# variable for each activity and each subject.

by_id_act <- group_by(data, subject_id, action) %>%
summarise_all(mean)
#with dplyr, calculate group mean by subject_id, action.

write.table(by_id_act,"by_id_act.txt", row.names = FALSE)
#by_id_act.txt is final data set.




# > by_id_act
# Source: local data frame [180 x 68]
# Groups: subject_id [?]
# 
# subject_id          action time_body_acceleration_mean_x time_body_acceleration_mean_y
# <int>           <chr>                         <dbl>                         <dbl>
#       1           1             lay                     0.2215982                  -0.040513953
# 2           1             sit                     0.2612376                  -0.001308288
# 3           1           stand                     0.2789176                  -0.016137590
# 4           1            walk                     0.2773308                  -0.017383819
# 5           1 walk_donwstairs                     0.2891883                  -0.009918505
# 6           1   walk_upstairs                     0.2554617                  -0.023953149
# 7           2             lay                     0.2813734                  -0.018158740
# 8           2             sit                     0.2770874                  -0.015687994
# 9           2           stand                     0.2779115                  -0.018420827
# 10          2            walk                     0.2764266                  -0.018594920








############################################### Extra works : Inertial Signals      

#Im gonna deal with Inertial Signals data inside of test/train set
#as I understood that X_test is statistic data of Inertial Signals, treat it as
#a raw data.

(files_test <- list.files("./UCI HAR Dataset/test/Inertial Signals/",
                          full.names = T))
#there are aparted files on directory. seperating rule is about x-y-z axis and
#where data come from.
#Thus I defined those 2 variables, axis and variable_name and also included subject_id

#columns on each file (body_acc_x_test.txt, etc) are time interval record, 
#specifically 128 windows means 128 records in 2.56 seconds
#row has almost same meaning (129 window indicates 2row 1col), so I determined to express time and window.
#row is time varying. combining time and window column, I made time column indicating
#overall time during action.


tmp_var_name <- list.files("./UCI HAR Dataset/test/Inertial Signals/")
# get all file names in Indertial Signals
tmp_var_name <- gsub("_test.txt","",tmp_var_name)
#edit file name to use variable name. body_acc_x_test.txt -> body_acc_x_test

var_name1 <- str_sub(tmp_var_name, 1, -3)
var_name2 <- str_sub(tmp_var_name,-1)
#strings are divided into 2 parts, one is variable name, 'body_acc'
#the other is 'x' used for axis column

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                           col.names = "subject_id")
# load subject_id. id is used for merging train data and test data


raw_test <- data.table()      
suppressWarnings(
      for(i in 1:9){
            temp_1 <- var_name1[i]
            temp_2 <- var_name2[i]
            dat <- read.table(files_test[i])      
            tmp <- data.table(dat) %>% select(window = everything())
            tmp[,variable_name:=temp_1]
            tmp[,axis:=temp_2]
            tmp[,subject_id:=subject_test$subject_id ]
            raw_test <- rbind(raw_test, tmp)
      })


# load all files in Indertial Signals, and join all in raw_test


raw_test[, time := 1:.N, by = subject_id]
raw_test <- gather(raw_test, key = window, value = record, window1:window128)
raw_test <- mutate(raw_test, window = str_sub(raw_test$window, start = 7))
raw_test <- mutate(raw_test, time = (time-1)*128+as.numeric(window))
raw_test <- select(raw_test, c(3,1,2,4,6))
raw_test <- data.table(raw_test)
# give raw_test some required variable. first is subject_id, next is variable_name.
# then axis, time, record. record is numeric data and the target we want to analyze.

saveRDS(raw_test[order(subject_id,time)], file = "Inertial Signals_test.rds")
# finished. data is saved as "Inertial Signals_test.rds" in your working directory.
#after data cleaning, open file with 
#readRDS("Inertial Signals_test.rds")
      
      
#This code is same with above, but for training set.

files_train <- list.files("./UCI HAR Dataset/train/Inertial Signals/",
                          full.names = T)
tmp_var_name <- list.files("./UCI HAR Dataset/train/Inertial Signals/")
tmp_var_name <- gsub("_train.txt","",tmp_var_name)      
      
var_name1 <- str_sub(tmp_var_name, 1, -3)
var_name2 <- str_sub(tmp_var_name,-1)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                           col.names = "subject_id")


raw_train <- data.table()      
suppressWarnings(
      for(i in 1:9){
            temp_1 <- var_name1[i]
            temp_2 <- var_name2[i]
            dat <- read.table(files_train[i])      
            tmp <- data.table(dat) %>% select(window = everything())
            tmp[,variable_name:=temp_1]
            tmp[,axis:=temp_2]
            tmp[,subject_id:=subject_train$subject_id ]
            raw_train <- rbind(raw_train, tmp)
      })


raw_train[, time := 1:.N, by = subject_id]
raw_train <- gather(raw_train, key = window, value = record, window1:window128)
raw_train <- mutate(raw_train, window = str_sub(raw_train$window, start = 7))
raw_train <- mutate(raw_train, time = (time-1)*128+as.numeric(window))
raw_train <- select(raw_train, c(3,1,2,4,6))
raw_train <- data.table(raw_train)

saveRDS(raw_train[order(subject_id,time)], file = "Inertial Signals_train.rds")

