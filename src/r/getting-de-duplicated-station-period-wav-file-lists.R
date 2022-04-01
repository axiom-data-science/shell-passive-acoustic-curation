##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: March 2022
#git repo for folder with script, etc
#using new repo on gitlab http://git.axiom/adrienne/R-over-shell-drives

#can I get de-duped big buckets?

library(tidyverse) # the main library used
library(stringi) # string manipulation later on
print("let's get started")


#loading existing environnment, labelled "shortcut-to-all-wav files-dfs.Rdata"
#this environment has the allfiles txt loaded, a list of tibbles listing each drive's df, and a list of the names of those dfs.

#Environment should include: all_wav_fls (tibbles trimmed to only .wav), new_path_dfs_lst (tibbles with all files on each drive), testlst (all the names of the new_path_dfs_lst dfs), columnNames, wav_dfs_lst(all the names of the wav-only filepaths dfs, in all_wavs_fls), plas the named wav files per drive (wav_df_ax29, wav_df_ax32, etc).

# > ls()
# [1] "all_wav_fls"      "columnNames"      "new_path_dfs_lst" "testlst"          "wav_dfs_lst"      "wavs_df_ax29"     "wavs_df_ax30"     "wavs_df_ax31"     "wavs_df_ax32"    
#etc on to 62 objects


# Load patterns to use in curating wav files --------------------------------------
getwd()
setwd("~/Documents/R-over-shell-drives")

stationIDS <- read_lines("./stationids.txt") #120 station IDS
stationIDS <- stationIDS %>% 
  stri_trans_toupper() %>% 
  stri_unique() #103 stationIDS after de-duping

periodIDS <- read_lines("./periodIDS.txt", ) #10 distinct periods of deployments, no need to de-dupe

# REGEX exploration--------------------------------
#looking for any station with "CL" at the start, I am looking for 13?
str_extract(stationIDS, pattern=regex("[CL]*")) #returns 13
str_extract(stationIDS, pattern=regex("CL*")) #returns 14 and 1 partial
str_extract(stationIDS, pattern=regex("CL+", ignore_case = TRUE)) #returns 13
str_extract(stationIDS, pattern=regex("[CL]*", ignore_case = TRUE)) #returns 13

str_detect(stationIDS, pattern=regex("CL+", ignore_case = TRUE)) #returns 13

str_subset(stationIDS, pattern=regex("CL+", ignore_case = TRUE)) #retutrns 13 patterns, like so:
#" [1] "CL5"     "CLN40"   "CLN90B"  "CLN120B" "CL50"    "CL05"    "CL10"    "CL15"    "CL15B"   "CL15_2"  "CL20"    "CL35"    "CLN80" 


# iterate over the dfs for period then station ----------------------------------

#rm empty dataframes from th elist
all_wav_fls <- all_wav_fls[-c(26, 42, 48)]

# 54 dfs to go through

#create empty objects
len <-  NULL
tot_val <- NULL
val_match <-  NULL
i <-  1
#loop through for both station and period at once  -------------------

for(thing in all_wav_fls){
  cat(thing[[1,1]])
  #look for matches to station ids
  for(x in stationIDS){
    val <- str_subset(thing$file_path, pattern=regex(paste("\\","/",x,sep=""), ignore_case = TRUE))
    
    #if there are matches, find period
    
    if(length(val)>0){
      val <- unique(val) #dedupe it
      print(c(x,val[1])) #checking via print statement
      dir.create(paste("./outputs/adrienne/",x,sep=""))
      for(t in periodIDS){
        new_val <- str_subset(val, pattern=regex(paste("\\","/",t,sep=""), ignore_case =TRUE))
        len <- length(new_val)
        
        if(length(new_val)>0){
          new_val <- unique(new_val) #de-dupe it
          print(c(t,new_val[1])) #checking via print statement
          #if there are file matches,write out a text file in the outputs directory, sub dir by station
          write_lines(new_val, file=paste("outputs/adrienne/",x,"/",x,"_",t,"_located-wavs.txt", sep=""))
          print(c(x,t,"found this many wav",len))
          tot_val <- tot_val + len
          #make a long list of all the matches
          val_match <- append(val_match, new_val)
          
        }else print("but there were no matches for deployment period")
      }
    }
    
  }
}


#Looks like I got more or less the same situation here, trying for reversing the order, and better regex
length(val_match) #1197637



#loop through path dataframes to match ONLY stations--------------------
for(thing in all_wav_fls){ #make sure it's looking at 54 things, the 0 row tables throw errors
  print(c("and here is:",testlst[i]))
  cat(thing[[1,1]])
  #look for matches to station ids
  for(x in stationIDS){
    
    #look for regex match to '/{stationid}'
    val <- str_subset(thing$file_path, pattern=regex(paste("\\","/",x,sep=""), ignore_case = TRUE))
    #if there are matches, keep the results:
    
    if(length(val)>0){
      val <- unique(val) #dedupe it
      print(c(x,val[1])) #checking via print statement
      len <-  length(val)
      print(c("so,",x,"has length:", len))
      write_lines(val, file=paste("outputs/adrienne/",testlst[i],"_",x,"_located-wavs.txt", sep=""))
      val_match <- append(val_match, val)
    }
  }
  i <- i+1
}
   
      
#Look for ONLY period   ---------------------------
i <- 1
for(thing in all_wav_fls){ #make sure it's looking at 54 things, the 0 row tables throw errors
  print(testlst[i])
  cat(thing[[1,1]])
  #look for matches to station ids
  for(t in periodIDS){
    
    #look for regex match to '/{stationid}'
    val <- str_subset(thing$file_path, pattern=regex(paste("\\","/",t,sep=""), ignore_case = TRUE))
    #if there are matches, keep the results:
    
    if(length(val)>0){
      val <- unique(val) #dedupe it
      print(c(x,val[1])) #checking via print statement
      len <-  length(val)
      print(c("so,",t,"has length:", len))
      write_lines(val, file=paste("outputs/adrienne/",testlst[i],"_",t,"_located-wavs.txt", sep=""))
      val_match <- append(val_match, val)
    }
  }
  i <- i+1
}

tot_val <- unique(val_match)

val <- 0
write_lines(val_match, file="outputs/adrienne/all-the-located-wav.txt") #
write_lines(stationIDS, file="./de-duped-station-ids.txt")


#break the identified station-period loicated wav list back up into organizations by drive--------------------
bucketed_wavs <- unique(val_match) %>% 
  as_tibble() %>% 
  separate(value, columnNames, "/")

#now 1064946
#what does that look like

bucketed_wavs %>% 
  group_by(subdirectory3, subdirectory4, subdirectory5) %>% 
  count() %>% 
  view()


bucketed_wavs %>% 
  filter(subdirectory3=="2007-overwinter") %>% 
  summarise(n=n())
  
