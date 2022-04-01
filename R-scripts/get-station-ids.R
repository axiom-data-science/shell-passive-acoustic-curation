#Get station IDS, November 2021
#setup environment
library("tidyverse")
#add ax82 clean deployment infos

cleandeployax82_DF <-  read.csv(file="./Documents/R-over-shell-drives/ax_81_deploy1.csv")
cleandeployax82_DF2 <-  read.csv(file="./Documents/R-over-shell-drives/ax_81_deploy2.csv")
cleandeployax82_DF3 <-  read.csv(file="./Documents/R-over-shell-drives/ax_81_deploy3.csv")

#make a full list of all the dfs
cleandeplydflst <- NULL

cleandeplydflst <- c("cleandeployax82_DF","cleandeployax82_DF2","cleandeployax82_DF3","cleandeployDF_1", "cleandeployDF_2")

cleandeplydflst <- lapply(cleandeplydflst, get)

#get all the station ids

pattrns<-  NULL

for (thing in cleandeplydflst){
  
  val <-unique(thing[,8]) #get unique value out of 4thh  column, period
  pattrns <-  append(pattrns, val) #add to list
  #pattrns <-  unique(pattrns)
}
station_ids <-pattrns

#write it out as lines on a file
write_lines(station_ids, file="./Documents/ax72-ax81-station-ids.txt", sep="\n", append=FALSE)
