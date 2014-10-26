library(data.table)
library(reshape2)

path <- getwd()
path_data <- file.path(path, "UCI HAR Dataset")


dt_sub_train <- fread(file.path(path_data, "train", "subject_train.txt"))
dt_sub_test  <- fread(file.path(path_data, "test" , "subject_test.txt" ))

dt_act_train <- fread(file.path(path_data, "train", "Y_train.txt"))
dt_act_test  <- fread(file.path(path_data, "test" , "Y_test.txt" ))

df_train <- read.table(file.path(path_data, "train", "X_train.txt"))
dt_train <- data.table(df_train)

df_test <- read.table(file.path(path_data, "test", "X_test.txt"))
dt_test <- data.table(df_test)


dt <- rbind(dt_train, dt_test)

dt_sub <- rbind(dt_sub_train, dt_sub_test)
setnames(dt_sub, "V1", "subject")
dt_act <- rbind(dt_act_train, dt_act_test)
setnames(dt_act, "V1", "activity_num")



dt_sub <- cbind(dt_sub, dt_act)

dt <- cbind(dt_sub, dt)

setkey(dt, subject, activity_num)



dt_feat <- fread(file.path(path_data, "features.txt"))
setnames(dt_feat, names(dt_feat), c("feature_num", "feature_name"))

dt_feat <- dt_feat[grepl("mean\\(\\)|std\\(\\)", feature_name)]

dt_feat$feature_id <- dt_feat[, paste0("V", feature_num)]

select <- c(key(dt), dt_feat$feature_id)
dt <- dt[, select, with=FALSE]


dt_act_names <- fread(file.path(path_data, "activity_labels.txt"))
setnames(dt_act_names, names(dt_act_names), c("activity_num", "activity_name"))

dt <- merge(dt, dt_act_names, by="activity_num", all.x=TRUE)

setkey(dt, subject, activity_num, activity_name)


dt <- data.table(melt(dt, key(dt), variable.name="feature_id"))

dt <- merge(dt, dt_feat[, list(feature_id, feature_name)], by="feature_id", all.x=TRUE)
setcolorder(dt, c("feature_id", "feature_name", "subject","activity_num","activity_name","value"))


tidy <- dt[,list(mean=mean(value)),by=list(feature_name,activity_name,subject)]


write.table(tidy, file = "tidy.txt",row.names = FALSE)
