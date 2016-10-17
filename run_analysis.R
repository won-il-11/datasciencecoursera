

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









#Not a content here, just my trial and error

# tmp <- numeric()
# for (i in var_list){
#       if(sum(grepl("(?=.*mean)",
#             grep(var_list, names(origin_data), 
#                  value = TRUE, fixed = TRUE), 
#             perl = TRUE)) == sum(grepl("(?=.*std)",
#             grep(var_list, names(origin_data), value = TRUE, fixed = TRUE), perl = TRUE))){
#             tmp = append(tmp,i)
#       }
# }
