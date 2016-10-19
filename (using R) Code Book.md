train_set :  7352x563 data.table form, training set contains subject_id, actual action, some statistic
 more information about statistic is in 'feautures_info.txt'
 id is 1:30 vector, 30 people in this experiment.
 action is 6 category  1: walk 2: walk_upstairs 3: walk_donwstairs 4: sit 5: stand 6: lay

test_set : The same description with train_set 2947x563 data.table

variable name transformation
all letters are lower case

 f : fft (Fast Fourier Transform)
 t : time
 Acc : acceleration
 Mag : magnitude
 std() : sd()
 mean() : same
 Gyro : gyro
 Body : body
 Jerk : jerk
 - : _

each type is seperated with under score, not using capital letters.
variable names are so unreadable, so just changed it noticable words
following list is variable name.

 time_body_acceleration_xyz
 time_gravityacceleration_xyz
 time_body_acceleration_jerk_xyz
 time_body_gyro_xyz
 time_body_gyro_jerk_xyz
 time_body_acceleration_magnitude
 time_gravityacceleration_magnitude
 time_body_acceleration_jerk_magnitude
 time_body_gyro_magnitude
 time_body_gyro_jerk_magnitude
 fft_body_acceleration_xyz
 fft_body_acceleration_jerk_xyz
 fft_body_gyro_xyz
 fft_body_acceleration_magnitude
 fft_body_acceleration_jerk_magnitude
 fft_body_gyro_magnitude
 fft_body_gyros_jerk_magnitude  


 after all, final tidy data 'by_id_act.txt' contain following columns, 
 except subject_id and action, all variables are statistic of Inertial Signals(See below)

 all of those names are derivered from above names (ex:time_body_acceleration_xyz)
 difference is +mean(or sd) and _axis. see paterns below.


"subject_id" 
"action" 
"time_body_acceleration_mean_x" 
"time_body_acceleration_mean_y" 
"time_body_acceleration_mean_z" 
"time_gravityacceleration_mean_x" 
"time_gravityacceleration_mean_y" 
"time_gravityacceleration_mean_z" 
"time_body_acceleration_jerk_mean_x" 
"time_body_acceleration_jerk_mean_y" 
"time_body_acceleration_jerk_mean_z" 
"time_body_gyro_mean_x" 
"time_body_gyro_mean_y" 
"time_body_gyro_mean_z" 
"time_body_gyro_jerk_mean_x" 
"time_body_gyro_jerk_mean_y" 
"time_body_gyro_jerk_mean_z" 
"time_body_acceleration_magnitude_mean" 
"time_gravityacceleration_magnitude_mean" 
"time_body_acceleration_jerk_magnitude_mean" 
"time_body_gyro_magnitude_mean" 
"time_body_gyro_jerk_magnitude_mean" 
"fft_body_acceleration_mean_x" 
"fft_body_acceleration_mean_y" 
"fft_body_acceleration_mean_z" 
"fft_body_acceleration_jerk_mean_x" 
"fft_body_acceleration_jerk_mean_y" 
"fft_body_acceleration_jerk_mean_z" 
"fft_body_gyro_mean_x" 
"fft_body_gyro_mean_y" 
"fft_body_gyro_mean_z" 
"fft_body_acceleration_magnitude_mean" 
"fft_body_body_acceleration_jerk_magnitude_mean" 
"fft_body_body_gyro_magnitude_mean" 
"fft_body_body_gyro_jerk_magnitude_mean" 
"time_body_acceleration_sd_x" 
"time_body_acceleration_sd_y" 
"time_body_acceleration_sd_z" 
"time_gravityacceleration_sd_x" 
"time_gravityacceleration_sd_y" 
"time_gravityacceleration_sd_z" 
"time_body_acceleration_jerk_sd_x" 
"time_body_acceleration_jerk_sd_y" 
"time_body_acceleration_jerk_sd_z" 
"time_body_gyro_sd_x" 
"time_body_gyro_sd_y" 
"time_body_gyro_sd_z" 
"time_body_gyro_jerk_sd_x" 
"time_body_gyro_jerk_sd_y" 
"time_body_gyro_jerk_sd_z" 
"time_body_acceleration_magnitude_sd" 
"time_gravityacceleration_magnitude_sd" 
"time_body_acceleration_jerk_magnitude_sd" 
"time_body_gyro_magnitude_sd" 
"time_body_gyro_jerk_magnitude_sd" 
"fft_body_acceleration_sd_x" 
"fft_body_acceleration_sd_y" 
"fft_body_acceleration_sd_z" 
"fft_body_acceleration_jerk_sd_x" 
"fft_body_acceleration_jerk_sd_y" 
"fft_body_acceleration_jerk_sd_z" 
"fft_body_gyro_sd_x" 
"fft_body_gyro_sd_y" 
"fft_body_gyro_sd_z" 
"fft_body_acceleration_magnitude_sd" 
"fft_body_body_acceleration_jerk_magnitude_sd" 
"fft_body_body_gyro_magnitude_sd" 
"fft_body_body_gyro_jerk_magnitude_sd"



 also, several changes on y, which means actual activity(our prediction target).
 originally, y is numeric vector 1:6, but I transformed y into
 1: walk 2: walk_upstairs 3: walk_donwstairs 4: sit 5: stand 6: lay
