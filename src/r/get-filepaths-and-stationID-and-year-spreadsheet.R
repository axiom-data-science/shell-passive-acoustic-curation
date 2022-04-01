##Using R to do Shell Data curation
#Last updated: March 2022
#git repo for folder with script, etc
#using new repo on gitlab http://git.axiom/adrienne/R-over-shell-drives

#Making a spreadsheet that has columns holding the values for the station it gets sorted into and the year it gets sorted into

#requires an environment to load the 186858 long DF as 'df' of the filepaths ending in wav

library(tidyverse) # the main library used in this notebook
library(stringi)

#get my lists for sorting
setwd("~/Documents/R-over-shell-drives")

stationIDS <- read_lines("./stationids.txt") #thenew-and-improved, 103 stationIDs with particularly sort to go through more general matches then more specific matches

  
periodIDS <- read_lines("./periodIDS.txt", ) #10 distinct periods of deployments, no need to de-dupe
yearIDS <- c("2007", "2014", "2015", "2009", "2010", "2011", "2013", "2012", "2008")

#shortcut to stations dataframe
#sdf <- read_csv("./outputs/adrienne/stationIDS-sorted-csv-with-station-year-columns.csv", col_names=TRUE)

#testing regex------------------------------------
thing <- all_wav_fls[[1]]
length(thing$file_path) #32365
x <- "CL20"
paste(x,"\\","/",sep="") #"CL20\\/" -escaping the slash
paste(x,"/",sep="") #"CL20/" -not escaping the slash

length(str_which(thing$file_path, regex(paste(x,"\\","/",sep=""), ignore_case = TRUE))) #returns 4856
length(str_which(thing$file_path, regex(paste(x,"/",sep=""), ignore_case = TRUE))) #4859 #so no need for escaping the slash

sum(str_detect(thing$file_path, regex(paste(x,"/",sep=""), ignore_case = TRUE))) #4859

length(str_subset(thing$file_path, pattern=regex(paste(x,"/",sep=""), ignore_case = TRUE))) #4859
length(str_subset(thing$file_path, pattern=regex(paste(x,"\\","/",sep=""), ignore_case = TRUE))) #4859


#Make the filepaths ending in wav into list of identified stationids number -1.64 million expected
#find file paths with only stations, regex includes ending /,prioritized list, this makes 'station_sort_not_unique'-----------------------
val_match <-  NULL
total_len <- 0
i <- 1
for(x in stationIDS){
  print(i)
  #look for regex match to '{stationid}'
  val <- str_subset(df$file_path, pattern=regex(paste(x,"/",sep=""), ignore_case = TRUE))
  #if there are matches, keep the results:
  
  if(length(val)>0){
    val <- unique(val) #dedupe it against itself
    len <-  length(val) #get length for counting
    print(c("so, station",x,"has length:", len, "like this", val[1])) #checking via print statement
    
    #write_lines(val, file=paste("outputs/adrienne/","stations-buckets_",x,"_located-wavs.txt", sep="")) #write lines out
    
    val_match <- append(val_match, val) #keep big dataframe of only station-located filepaths
    total_len <- total_len + len
  } else print(c("this station found no matches?",x))
  i <- i+1
  
}
station_sort_not_unique <-  val_match
length(unique(val_match)) #1598214
stat_sort <- unique(val_match)

#same files?
sum(stat_sort == sdf$value)

#compare things as sets------------------
library(sets)
long <- as.set(sdf$value) #store t <- he longer station sort list (1.64 million)
short <- as.set(stat_sort) #store the shorter station sort from the prioritized stations list) 1.59 million

#nmake a variable and compare the sets and store the difference in the variable 
t <- NULL
t <-  set_intersection(long,short) # get the things that are the same
y <- set_symdiff(long,short) #get the things that are different, in theory the ones long has that short does not

#look at those things
write_lines(y, file="./outputs/adrienne/set-difference.txt")

#take the located with / stations wavs (stat_sort), then looking for year , looking at all the .wav ending files----------------------------
stat_year_sort <-  NULL
i <-  1
total_len <- 0
fin_match <-  NULL
for(t in yearIDS){
  print(i)
  #look for regex match to '{period}' in the val_match vector, a subset that is stationIDs in filepaths
  #note removing the slash from the search term, just looking for the search term ANYWHERE
  val <- str_subset(stat_sort, pattern=regex(paste(t,"-|-",t,sep=""), ignore_case = TRUE))
  #if there are matches, keep the results:
  
  if(length(val)>0){
    val <- unique(val) #dedupe it
    len <-  length(val) #get length for counting
    print(c("so,year",t,"has length:", len, "like this", val[1])) #checking via print statement
    
    write_lines(val, file=paste("outputs/adrienne/byYear/",t,"_located-wavs.txt", sep="")) #write lines out
    
    stat_year_sort <- append(stat_year_sort, val) #keep big dataframe of only station-located filepaths
    total_len <- total_len + len
  } else print(c("this yearfound no matches?",x))
  i <- i+1
  
}
total_len #1645659
length(stat_year_sort) == total_len
length(unique(stat_year_sort)) #15978902


#make a dataframe that will have the station as assigned and the year as assigned in the wav_located text files-------------------------
sdf <-  unique(stat_year_sort)
sdf <- as_tibble(sdf)
length(sdf$value) #1597892
head(sdf)


#test mutate function to make the thing
x <-  stationIDS[6]

sdf <- sdf %>% 
  mutate(station= case_when(str_detect(sdf$value, pattern=regex(paste(x,"/",sep=""), ignore_case = TRUE)) == TRUE ~ paste(x))
  )

sdf %>% filter(sdf$station == "WN20") %>% 
  view()
#works, 25K ish entries

#Loop it?

i <- 1
for(x in stationIDS){
  print(i)
  tmp_index <- str_which(sdf$value, pattern=regex(paste(x,"/",sep=""), ignore_case = TRUE))
  l <- length(tmp_index)
  if(l>0){
    print(c(x,l))
    sdf[tmp_index,]$station <- paste(x)
  }
  i <- i+1
}

sum(is.na(sdf$station)) #0
length(unique(sdf$station)) #99, better than yesterday

#total counts by station
sdf %>% group_by(sdf$station) %>% 
  summarise(count=n()) %>% 
  print(n=99)

#let's do the same for year, with missing value of 0000
i <- 1
sdf <-  sdf %>% 
  mutate(year="0000")

for(x in yearIDS){
  print(c(x,i))
  tmp_index <- str_which(sdf$value, pattern=regex(paste(x,"-|-",x,sep=""), ignore_case = TRUE))
  l <- length(tmp_index)
  if(l>0){
    sdf[tmp_index,]$year <- x
  }
  i <- i+1
}

sum(is.na(sdf$year)) #0

sdf %>% group_by(sdf$year) %>% 
  summarise(count=n()) %>% 
  print()

length(sdf$year) #1597892
#any 0000?
sdf[sdf$year=="0000",] #0 this time???

#let's write that out and see if it's anything useful at all
write_csv(sdf, file = "./outputs/stationIDS-sorted-csv-with-station-year-columns.csv")


#Now let's write out those text files, with the titles including details as assigned in the DataFrame, instead of the details as found during the regex search-------------------
#loop variables

stat_options <- unique(sdf$station)
time_options <- unique(sdf$year) #I could really just use yearIDS again

i <- 1

#loop through the dataframe, and write a value from one column, based on match in two other columns------------

#let's try dplyr

for(x in stat_options){ 
  print(i)
  thing <- sdf %>% 
    filter(station == x)
  
  if(length(thing$value)>0){
    for(t in time_options){
      target <- thing %>% 
        filter(year == t)
      if(length(target$value)>0){
        print(c("found",x,t,"looks like",target$value[1]))
        write_lines(target$value, paste("outputs/adrienne/nextTest/",x,"_",t,"_located-wavs.txt", sep=""))
      }else(print(c("found",x,"but not",t)))
    }
  }else (print(c("WEIRDNESS no match to",x)))
  }
#it worked, cat *.txt | wc -l gave me 1597892

#Get a set of the difference from 1868585 and this 1597892
#Compare as sets again --------------------------
library(sets)
long <- as.set(df$file_path) #store the longer station sort list (1.868.585)
short <- as.set(sdf$value) #store the shorter station sort from the prioritized stations list) 1.59 million

#nmake a variable and compare the sets and store the difference in the variable 
t <- NULL
t  <- set_symdiff(long,short) #get the things that are different, in theory the ones long has that short does not

#look at those things
write_lines(t, file="./outputs/adrienne/set_diff_all-wav_and_latest-sort.txt")
