###train_set :  7352x563 data.table form, training set contains subject_id, actual action, some statistic
# more information about statistic is in 'feautures_info.txt'
# id is 1:30 vector, 30 people in this experiment.
# action is 6 category  1: walk 2: walk_upstairs 3: walk_donwstairs 4: sit 5: stand 6: lay

###test_set : The same description with train_set 2947x563 data.table

######variable name transformation
#all letters are lower case

# f : fft (Fast Fourier Transform)
# t : time
# Acc : acceleration
# Mag : magnitude
# std() : sd()
# mean() : same
# Gyro : gyro
# Body : body
# Jerk : jerk
# - : _

#each type is seperated with under score. (In my experience, maybe because English is
#not native language, many coders use underscore instead of capital letter)
#actually I did not understand what the variable means. so just changed it noticable words
#following list is variable name.

# time_body_acceleration_xyz
# time_gravityacceleration_xyz
# time_body_acceleration_jerk_xyz
# time_body_gyro_xyz
# time_body_gyro_jerk_xyz
# time_body_acceleration_magnitude
# time_gravityacceleration_magnitude
# time_body_acceleration_jerk_magnitude
# time_body_gyro_magnitude
# time_body_gyro_jerk_magnitude
# fft_body_acceleration_xyz
# fft_body_acceleration_jerk_xyz
# fft_body_gyro_xyz
# fft_body_acceleration_magnitude
# fft_body_acceleration_jerk_magnitude
# fft_body_gyro_magnitude
# fft_body_gyros_jerk_magnitude  




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

#at first, I read readme.txt, but really confused what it saying, anyway I think
#what we need are X_train/X_test. Thus, I merge c(subject id, X_test, y_test)

                         
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
# each set data is completed set now.
# Also saved as 'train_set.rds' in your working directory.






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


