fileloc <- "C:\\Dev\\Study\\Hadoop\\big_data_capstone_datasets_and_scripts\\"
folders <- paste0(c("chat", "combined", "flamingo"), "-data")
files <- list()
paths <- character(0)

for (folder in folders) {
  files[[folder]] <- dir(paste0(fileloc, folder))
}
for (i in seq_along(folders)) {
  paths[i] <- paste0(fileloc, folder)
}

listing <- character(0)
fullpathlisting <- character(0)
for (i in seq_along(folders)) {
  listing <- c(listing, files[[folders[i]]])
  fullpathlisting <- c(fullpathlisting
                       , paste0(fileloc
                                , folders[i]
                                , "\\"
                                , files[[folders[i]]]))
}

for (i in seq_along(listing)) {
  print(paste("assiging", listing[i]))
  assign(listing[i], read.csv(fullpathlisting[i], stringsAsFactors = FALSE))
}