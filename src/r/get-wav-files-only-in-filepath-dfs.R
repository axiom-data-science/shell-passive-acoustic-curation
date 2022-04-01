##Using R to do Shell Data curation -----
#Last updated: March 2022
#git repo for folder with script, etc
#using new repo on gitlab http://git.axiom/adrienne/R-over-shell-drives


library(tidyverse) # the main library used in this notebook
library(stringi)

#loading existing environnment, labelled "shortcut-to-all-wavs-dfs.Rdata"
rm(list=as.character(wav_dfs_lst))

#testing regex------------------------------------
thing <- new_path_dfs_lst[[21]]
length(thing$file_path) #83952

length(str_which(thing$file_path, regex(pattern=".wav$", ignore_case = TRUE))) #returns 32365, 
length(str_which(thing$file_path, pattern="\\.wav$")) #returns 32365
length(str_which(thing$file_path, pattern=regex("\\.wav$"))) #returns 32365

length(str_which(thing$file_path, pattern="\\.wav")) #returns 55883
length(str_which(thing$file_path, pattern=".wav")) #returns 55883
length(str_which(thing$file_path, pattern=".WAV")) #returns 0 (so yes, it is case sensitive)

length(str_which(thing$file_path, pattern=".wav"))

sum(str_detect(thing$file_path, pattern=".WAV")) #returns 0, has to be sum for this one because it returns BOOLEAN
sum(str_detect(thing$file_path, pattern=".wav")) #returns 55883
sum(str_detect(thing$file_path, pattern="\\.wav")) #returns 55883
sum(str_detect(thing$file_path, pattern=".wav$")) #returns 32365
sum(str_detect(thing$file_path, pattern=regex(".wav$"))) #returns 32365


sum(str_detect(thing$file_path, pattern="System")) #returns 1

str_split(thing$file_path, pattern="\\.")

# loop through all files and make only wav file s-----------------------
i <- 1
wav_dfs_lst <- NULL
for(thing in new_path_dfs_lst){
  #look at only wav files
  wav_index <-str_which(thing$file_path, regex(".wav$", ignore_case=TRUE))
  #subset the df by the wav only index numbers
  thing <- thing[wav_index,]
  #name it and pull it into another list
  nam <- paste("wavs_",testlst[i], sep="")
  print(nam)
  assign(nam, thing)
  wav_dfs_lst[[i]] <- nam
  #iterate
  i <- i+1
}
all_wav_fls <- lapply(wav_dfs_lst, get)

val <- 0
#Testing where some file counts came from---------------
for(thing in new_path_dfs_lst){
  len <- length(thing$file_path)
  print(len)
  val <- val + len
  print(c("so,",val))
}
#total file count of 14622485

val <-  0
#testing length of all wavs-------------------
for(thing in all_wav_fls){
  len <- length(thing$file_path)
  val <- val+len
  print(c("so,",val))
}

#total wav file count "1868585"
thing <- NULL
#getting all wav files written out--------------------
for(thing in all_wav_fls){
  thing <- unique(thing)
  write_lines(thing$file_path, file="outputs/new_wav_filpaths_unique.txt", append = TRUE)
}

#using what we know about regex now, a case insensitive count, with .wav at the end of the line, total wav count across all the drives except 90 and 91, loop - Go:
len <- 0
val <- 0
for(thing in new_path_dfs_lst){
  len  <- length(str_which(thing$file_path, regex(pattern=".wav$", ignore_case = TRUE))) 
  val <- val +len
  
}
val #1868585

#get a df of all wav file paths---------------------------
df <- as_tibble(NULL)
for(thing in all_wav_fls){
  df <-rbind(df, thing)
}#1868585

#get a column of just file names-----------------------
df$file_name <- NULL
df$file_name <- sub(".*/","",df$file_path)

test <- unique(df$file_name)
length(test) # 1 746 318


#If I were to start doing sorting for stations and periods, those lists are here ----------------
setwd("~/Documents/R-over-shell-drives")

stationIDS <- read_lines("./stationids.txt") #120 station IDS
stationIDS <- stationIDS %>% 
  stri_trans_toupper() %>% 
  stri_unique() #103 stationIDS after de-duping

periodIDS <- read_lines("./periodIDS.txt", ) #10 distinct periods of deployments, no need to de-dupe

#find file paths with only stations-----------------------
val_match <-  NULL
total_len <- 0
i <- 1
for(x in stationIDS){
    print(i)
    #look for regex match to '/{stationid}'
    val <- str_subset(df$file_path, pattern=regex(paste("\\","/",x,sep=""), ignore_case = TRUE))
    #if there are matches, keep the results:
    
    if(length(val)>0){
      val <- unique(val) #dedupe it
      len <-  length(val) #get length for counting
      print(c("so, station",x,"has length:", len, "like this", val[1])) #checking via print statement
      
      #write_lines(val, file=paste("outputs/adrienne/","stations-only-bucket_",x,"_located-wavs.txt", sep="")) #write lines out
      
      val_match <- append(val_match, val) #keep big dataframe of only station-located filepaths
      total_len <- total_len + len
    } else print(c("this station found no matches?",x))
    i <- i+1
  
}

length(val_match) #1774145
length(unique(val_match)) #1602216

station_sort_not_unique <-  val_match
#Look for just periodIDS and get those numbers------------------
val_match <-  NULL
total_len <- 0
i <- 1
for(x in periodIDS){
  print(i)
  #look for regex match to '/{stationid}'
  val <- str_subset(df$file_path, pattern=regex(paste("\\","/",x,sep=""), ignore_case = TRUE))
  #if there are matches, keep the results:
  
  if(length(val)>0){
    val <- unique(val) #dedupe it
    len <-  length(val) #get length for counting
    print(c("so, period",x,"has length:", len, "like this", val[1])) #checking via print statement
    
    write_lines(val, file=paste("outputs/adrienne/","period-only-bucket_",x,"_located-wavs.txt", sep="")) #write lines out
    
    val_match <- append(val_match, val) #keep big dataframe of only station-located filepaths
    total_len <- total_len + len
  } else print(c("this deployment period found no matches?",x))
  i <- i+1
  
}

unique(val_match)
length(unique(val_match))

#Now sorting through for first stationIDS, then periodIDS --------------------
# to do this I'm going to run the loop above that creates a character vector of all the filepaths that matched some station id (val_match output)

#Then I'm going to just run that through the periodIDS loop - doin it in a straight line-------------
total_len <- 0
i <- 1
stat_period_sort <-  NULL
for(x in periodIDS){
  print(i)
  #look for regex match to '{period}' in the val_match vector, a subset that is stationIDs in filepaths
  #note removing the slash from the search term, just looking for the search term ANYWHERE
  val <- str_subset(station_sort_not_unique, pattern=regex(paste(x,sep=""), ignore_case = TRUE))
  #if there are matches, keep the results:
  
  if(length(val)>0){
    val <- unique(val) #dedupe it
    len <-  length(val) #get length for counting
    print(c("so, period",x,"has length:", len, "like this", val[1])) #checking via print statement
    
    write_lines(val, file=paste("outputs/adrienne/","stat-then-per-bucket_",x,"_located-wavs.txt", sep="")) #write lines out
    
    stat_period_sort <- append(stat_period_sort, val) #keep big dataframe of only station-located filepaths
    total_len <- total_len + len
  } else print(c("this deployment period found no matches?",x))
  i <- i+1
  
}

length(stat_period_sort) == total_len
length(unique(stat_period_sort))

###

#Let's take a look at these by drive-----------
bucketed_wavs <- station_sort_not_unique %>% 
  as_tibble() %>% 
  separate(value, columnNames, "/")

bucketed_wavs %>% 
  group_by(directory) %>% 
  count() %>% print(n=39)

## A different Approach -----------------------------
#finding the number of filepaths without a '/' in the regex search
#find file paths with only stations, this makes 'station_sort_not_unique'-----------------------
val_match <-  NULL
total_len <- 0
i <- 1
for(x in stationIDS){
  print(i)
  #look for regex match to '{stationid}'
  val <- str_subset(df$file_path, pattern=regex(paste(x,"\\","/",sep=""), ignore_case = TRUE))
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
length(unique(val_match)) #1643966
periodIDS
yearIDS <- c("2007", "2014", "2015", "2009", "2010", "2011", "2013", "2012", "2008")

#looking for just years in the file_path somewhere where stations have already been identified------
stat_year_sort <-  NULL
i <-  1
total_len <- 0
for(x in yearIDS){
  print(i)
  #look for regex match to '{period}' in the val_match vector, a subset that is stationIDs in filepaths
  #note removing the slash from the search term, just looking for the search term ANYWHERE
  val <- str_subset(station_sort_not_unique, pattern=regex(paste(x,sep=""), ignore_case = TRUE))
  #if there are matches, keep the results:
  
  if(length(val)>0){
    val <- unique(val) #dedupe it
    len <-  length(val) #get length for counting
    print(c("so,year",x,"has length:", len, "like this", val[1])) #checking via print statement
    
    #write_lines(val, file=paste("outputs/adrienne/byYear/",x,"_located-wavs.txt", sep="")) #write lines out
    
    stat_year_sort <- append(stat_year_sort, val) #keep big dataframe of only station-located filepaths
    total_len <- total_len + len
  } else print(c("this yearfound no matches?",x))
  i <- i+1
  
}
total_len
length(stat_year_sort) == total_len
length(unique(stat_year_sort)) #1643966


#Let's try to get both statinIDS and a year sort, at once, wihtout / in the regex search for either-------------------
fin_match <-  NULL
tmp_match <- NULL
new_val <-  NULL
total_len <- 0
i <- 1
for(x in stationIDS){
    val <- str_subset(df$file_path, pattern=regex(paste(x,sep=""), ignore_case = TRUE))
    
    #if there are matches, find period
    
    if(length(val)>0){
      val <- unique(val) #dedupe it
      print(c(x,val[1])) #checking via print statement
      if(dir.exists(paste("./outputs/adrienne/test/",x,sep=""))){}else
        dir.create(paste("./outputs/adrienne/test/",x,sep="")) #make a folder for the outputs
      tmp_match <- append(tmp_match, val)
      for(t in yearIDS){
        new_val <- str_subset(val, pattern=regex(paste(t,"-|-",t,sep=""), ignore_case =TRUE))
        len <- length(new_val)
        
        if(len>0){
          new_val <- unique(new_val) #de-dupe it
          print(c(t,new_val[1])) #checking via print statement
          #if there are file matches,write out a text file in the outputs directory, sub dir by station
          write_lines(new_val, file=paste("outputs/adrienne/test/",x,"/",x,"_",t,"_located-wavs.txt", sep=""))
          print(c(x,t,"found this many wav",len))
          total_len <- total_len + len
          #make a long list of all the matches
          fin_match <- append(fin_match, new_val)
          
        }else print(c("but there were no matches for deployment period",x,t))
      }
    }
    
}



length(fin_match) #2553836
length(fin_match) == total_len
length(unique(fin_match))


## Let's try a loop that gets the sort by StationID then Year, but stores the found values in a column of the dataframe-------------

sdf <- unique(stat_year_sort) %>% 
  as_tibble()
length(sdf$value) #1643966
head(sdf)

x <-  stationIDS[1]

sdf <- sdf %>% 
  mutate(station= case_when(str_detect(sdf$value, pattern=regex(x, ignore_case = TRUE)) == TRUE ~ paste(x)
    )
  )
#test works, 51K ish
#loop it?
i <- 1
for(x in stationIDS){
  print(i)
  tmp_index <- str_which(sdf$value, pattern=regex(x, ignore_case = TRUE))
  l <- length(tmp_index)
  if(l>0){
    sdf[tmp_index,]$station <- x
  }
  i <- i+1
}


#look and see if there are 103 matches (or actually 100, based on some earlier work Chris and I did)
sum(is.na(sdf$station)) #0
length(unique(sdf$station)) #88 ????????
# [1] "PLN40"     "A1"        "PL50"      "A3"        "A2"        "PLN60"     "W50"       "A5"        "WN20"      "PLN20"     "B5"       
# [12] "B50"       "B15"       "CL50"      "CL5"       "WN40"      "WN40C"     "CLN40"     "CLN90B"    "CLN120B"   "PLN80B"    "PLN80"    
# [23] "PL30"      "B20"       "KL01"      "CL05"      "CL10"      "CL15B"     "CL20"      "CL35"      "PL20"      "PL35"      "W05"      
# [34] "W20"       "W35"       "B10"       "B35"       "B35R"      "BG02"      "B05"       "B30"       "HS-PLN100" "HS-PLN120" "HS-PBN40" 
# [45] "A4"        "BG01"      "BG03"      "BG04"      "BG05"      "BG06"      "BG07"      "BG11"      "BG12"      "KL02"      "KL03"     
# [56] "KL04"      "KL05"      "KL06"      "KL07"      "KL09"      "KL10"      "KL11"      "KL12"      "CL15_2"    "CL15"      "W10"      
# [67] "BGF"       "AH"        "BGA"       "BGB"       "BGC"       "BGD"       "PL10"      "BGE"       "W30"       "WN60"      "WN80"     
# [78] "HS-PBN20"  "WN40B"     "HSW1"      "HSW3"      "HSW2"      "HSW4"      "HS-WN60"   "HS-WN80"   "BG08"      "BG10"      "PL05"    
#weird. And probably not good. Possibly an indication of repetitions, maybe this is a thing with the CL5 and CL50 type situation

sdf %>% filter(sdf$station == "CL5") %>% 
  view()

thing <- sdf %>% filter(sdf$station == "CL5")
sum(str_detect(thing$value, pattern=regex("CL50", ignore_case = T)))
#0?
thing <- sdf %>% filter(sdf$station == "CL50")
sum(str_detect(thing$value, pattern=regex("CL5", ignore_case = T)))
#29523?

#total counts by station
sdf %>% group_by(sdf$station) %>% 
  summarise(count=n()) %>% 
  view()

#let's press on and get year in theere----------------
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
length(unique(sdf$year)) #10 *checkmark*

#let's write that out and see if it's anything useful at all-------------------------
write_csv(sdf, file = "./outputs/stationIDS-sorted-csv-with-station-year-columns.csv")


sdf %>% group_by(sdf$year) %>% 
  summarise(count=n()) %>% 
  view()
view(sdf[sdf$year=="0000",])
distinct(sdf)
unique(sdf[c("station","year")])
