##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: October 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#trying to do a different curation spreadsheet, using existing deployment info spreadsheets

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
install.packages('tidyverse')
library("tidyverse")
#cleaning strings is now a thing
library("stringi")

# # create a dataframe of deployments on drives, modelled on the deploymentInfo.csv from ax70.
## test clean deployment dfs ------------------------
    #This works
    drive81Deploys <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    view(drive81Deploys)
    #the challenge is definitely that thats just, ugly.
    #some of that information, matches the folder structure? coincidence?
    
    #make a clean deployment dataframe
    clean81deploy <- drive81Deploys[6:13,2:71]
    view(clean81deploy)
    
    #with nice and useful col names
    freqpoints <- drive81Deploys[5,2:48]
    head(freqpoints)
    x <- clean81deploy[1,1:23]
    x
    x <- c(x,freqpoints)
    ?colnames
    colnames(clean81deploy) <-x
    
    #look at it? it had two headders
    #fill back in some of the information, will this all be necessary to keep? seems like not
    clean81deploy[-1,]
    view(clean81deploy)
    clean81deploy$clientID <-  "fw"
    clean81deploy$region <-  "Chuckchi"
    clean81deploy$season <- "2013 overwinter"
    clean81deploy <- as.data.frame(clean81deploy[-1,])
    
    #as a repeatable loop
    
    deployCol <- as.character(c("recorderId", "recorderMake","recorderVersion","stationId","hydrophoneId","hydrophoneMake","sampleRate","channels","bitsPerSample","fileStructure","startDate","startTime","driveNo","latitude","longitude","meters","dropDate","dropTime","recoveryDate","recoveryTime","vPerBit","sensitivity","sensitivityFrequencyPoint","1.6","3.2","6.4","12.8","25.6","51.2","100","200","300","400","500","600","700","800","900","1000","1200","1300","1400","1500","2000","2500","3000","3500","4000","4500","5000","5500","6000","6500","7000","7500","8000","16000","32000","40000","50000","60000","70000","80000","90000","1e+05","120000","140000","160000","180000","2e+05"))
    
    ?colnames
    ?read.table()
    #This works
    drive81Deploys <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    
    #The problem had been using 'fill=T' in read.table(), it was making the number of cols misread.
    #the comment character was '#', so it was reading lines 1 AND 6 as comments, thus leaving them out of the final dataframe. #tricky tricky
    #How can I get all the csvs into one table?
    #if it's all in the working directory
    dat =NULL
    deployDF <- NULL
    setwd("~/Documents/R-over-shell-drives/CSV-copied/")
    files <- list.files("~/Documents/R-over-shell-drives/CSV-copied/", pattern="*.csv")
    for (f in files){
      dat <- read.table(f, skip=6, 
                        header=F, sep="," ,
                        blank.lines.skip = FALSE, comment.char="", colClasses = c("character","character", "character")) #read table
      #seems like, there's not a good way right away to preserve the 3 values in that row weirdness
      head(dat)
      deployDF <- dplyr::bind_rows(deployDF, dat)
    } #loop finally working!
    #but now I need to add to it - there's two sets of frequency points
    view(deployDF)
    #can I subset to exactly those variables reliably?
    #I'm going to look at each deployment df seperately
    files
    drive81Deploy2013 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OV2013.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    #get extra info
    year13clientid <- as.character(drive81Deploy2013[3,2])
    year13region<- as.character(drive81Deploy2013[3,3])
    year13period <- as.character(drive81Deploy2013[3,4])
    year13FreqPoints <- (drive81Deploy2013[5,2:(length(drive81Deploy2013))])
    year13FreqPoints <-
      year13FreqPoints %>% discard(is.na) %>% as.character()
    
    #trim dataframe
    drive81Deploy2013 <- drive81Deploy2013 %>% slice(-c(1:4))
    #that, took off the header row too, but that's ok, I'm going to build that list separate
    tmp <- drive81Deploy2009[6,-c(1)]
    tmp <- tmp %>% discard(is.na) %>% as.character() %>% head(-1)
    tmp
    deploy13header <- c(tmp, year13FreqPoints)
    deploy13header
    #glue it onto the dataframe
    colnames(drive81Deploy2013) <- deploy13header
    drive81Deploy2013 <- add_column(drive81Deploy2013, .before="recorderId", client=year13clientid,region=year13region,period=year13period)
    view(drive81Deploy2013)
    #Is this now, the way I want it too? I think so
    
    #So what I want is a loop that does all that automatically
    #and then a match and fill script that uses this dataframe, and the dataframe of the actual info, into a joint dataframe
    #and that's the real curation dataframe?
    
    drive81Deploy2009 <- read.table("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-OW09.csv", 
                                 header=F, sep="," ,
                                 blank.lines.skip = FALSE, comment.char="")
    
    #I somehow need to load this one by skipping the lines that imply the #of cols, because otherwise the data gets stacked onto eachother in a very ugly manner
    drive81Deploy2014 <- read.delim("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-SU14.csv", 
                                    header=F, sep="," ,
                                    blank.lines.skip = FALSE, comment.char="", 
                                    col.names=1:71
                                    )
    #rdocs seems to suggest getting length with count.fields before
    wideness <- count.fields("~/Documents/R-over-shell-drives/CSV-copied/deploymentInfo-SU14.csv",sep=",",
                             skip=5, comment.char = "",blank.lines.skip = FALSE)
    max(wideness)

#alrighty, that variable will hold how many cols i must import when importing deploy csvs
#rather than do these by hand, let me see if I can automate everything I just did

## loop 1 - get a list of dataframe for the csvs--------------
#above is a loop that can do a read file to datafrom from wd, worked well as just that function
setwd("~/Documents/R-over-shell-drives/CSV-copied/")

files <- list.files("~/Documents/R-over-shell-drives/CSV-copied/", pattern="*.csv")

#make a list to iterate through

deploydflst <- NULL
i <- 1
testlst <-  NULL
#pull in the deploymentInfo csvs as ugly dataframes in order to extract their fixed information (hopefully)
for (f in files){
  #look for number of cols
  wideness <- count.fields(f,sep=",", comment.char = "",skip=5,blank.lines.skip = FALSE)
  wideness <- max(wideness)
  #make dataframe
  dat <-read.table(f, 
                   header=F, sep="," ,
                   blank.lines.skip = FALSE, comment.char="", 
                   colClasses = c("character","character", "character"),
                   col.names = 1:wideness) #read table
  nam <- paste("deployDF", i, sep = "_")
  print(nam)
  assign(nam, dat)
  #make a list to iterate through
  testlst[[i]] <- nam
  i <- i+1
}
#that list isn't what I want, but this is:
deploydflst <- lapply(testlst, get)

#clean up what I don't need from that loop
rm(wideness, dat, nam,f)

# # Loop 2, make the ugly dataframes clean deployment dataframes ---------------------------------------
#go through the dataframes and make them clean deployment dataframes with tidy/long details
freqPoints <- NULL
i=1
cleandeployDFslst = NULL
for (thing in deploydflst){

  #pull those three values out
  clientid <- as.character(thing[3,2])
  region<- as.character(thing[3,3])
  period <- as.character(thing[3,4])
  freqPoints <- (thing[5,2:(length(thing))])
  freqPoints <-
    freqPoints %>% stri_remove_empty(na_empty=TRUE) %>% as.character()
  print(freqPoints)
  
  #build the header for this one
    #less that column that describes but no with value the freqpoints cols
  #needs stringi library 
  tmp <- thing[6,1:24] %>% as.character()
  print(tmp)
  hdr <- c(tmp, freqPoints)
  cat("this is the header",hdr)
  
  #trim the df to the cols/rows of deploy info
  thing <- thing %>%
    slice(-c(1:6))
  colnames(thing) <- hdr
  print(head(thing))
  
  #add the columns of the fixed information
  thing <-  add_column(thing, .before="recorderId", clientid=clientid,region=region,period=period)
  
  #rename the deployment dataframe
  nam <- paste("cleandeployDF", i, sep = "_")
  print(nam)
  assign(nam, thing)
  cleandeployDFslst[[i]] <- nam
  i <- i+1
}

#make a list pointing at the data frame object not just the names of those objects
cleandeplydflst <- lapply(cleandeployDFslst, get)
cleandeplydflst


#Clean up my environmentafter that loop
rm(freqPoints, files, hdr, i, nam, tmp, wideness, f, clientid, region, period)
rm(thing, dat, testlst, deploydflst)
rm(cleandeployDFslist, deployDF_1, deployDF_2, deployDF_3)
## test find filepath for cleandeploymentDF[value] match using target folder which is named for the station (usually?)-------- This is for another code script.

#I can and should write out the csvs of the clean deployment infos

write_csv(cleandeployDF_1, file="ax_81_deploy1.csv")
write_csv(cleandeployDF_2, file="ax_81_deploy2.csv")
write_csv(cleandeployDF_3, file="ax_81_deploy3.csv")


#OK. So, what I want now, is, a spreadsheet that uses the recorderID and station ID from deploy df, to find the .wav file in wavsdf, and with the matching, make a curation df that lists the info from the relevant row in deploy df (will repeat alot), the wav file path, and file name, and still need to do, calculated values in there like total volume, or just maybe, size of that file, 
#the subdirectories are in fact a hot mess in ax81.
#find an exact match of instance in wavs file list, of recorderID and station ID from deployment df

str_which(df_wavs81[,1], regex(pattern=recorderID, ignore_case = TRUE))
?regex
#the trick so far is definitely trying to get the regex to register I want there to be 2 patterns matched

##So, making that happen, based on client id -----------------------

#Ok so I only care about de-duped, wav file, paths. Sorry to the other valuable information stored in these things.
wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))
df_ax81 <-  df_ax81[wavs_index81,]

#find locations where the clientid matches a value in the folder path
## first, find the unique values in my deployment info dataframes, for clientid
pattrns <- NULL
#Get the unique values of col 2 into a list, based on if they are alraedy in the list
for (thing in cleandeplydflst){
  
  val <- unique(thing[,2]) #get unique value out of second column
  
  if (length(pattrns) > 0){ #check if pattrns has values
    if (val %in% pattrns){
      #do nothing
      }else{ #if the pattrns list doesn't have this value ablready
    pattrns <-  append(pattrns, val) #add to list
    }
  }else { #else add to list
      pattrns <-append(pattrns, val) #else add to list
    }
}

#did that work?
pattrns #fw, shell , so yes
client_match <-  str_subset(df_ax81$file_path, regex(pattrns, ignore_case=TRUE))
head(client_match)

#Was it really that simple?

#let's do a filter on subdirectory 3, etc, just to make sure, I don't have, like some crazy error in there
client_match_index <-  str_which(df_ax81$file_path, regex(pattrns, ignore_case=TRUE))

df_ax81[client_match_index,] %>%
  group_by(subdirectory3) %>%
  summarise(n=n()) %>%
  view()

#fw, shell, and SHell Shallow Hazards 2013 - but, that's a client as shell, yeah?
# so, success?

#I think what I really want to match on is the unique recorder id, is that in the file, path?
#First, how does, client id match, compare to recorder id match

##Ok, so making that happen, based on, recorder id -------------------
#use the loop to get unique values from the column in the deployment dataframes
pattrns <- NULL
#Get the unique values of col 5 into a list, based on if they are alraedy in the list
for (thing in cleandeplydflst){
  
  val <- unique(thing[,5]) #get unique value out of 5thh  column
  
  if (length(pattrns) > 0){ #check if pattrns has values
    if (val %in% pattrns){
      #do nothing
    }else{ #if the pattrns list doesn't have this value ablready
      pattrns <-  append(pattrns, val) #add to list
    }
  }else { #else add to list
    pattrns <-append(pattrns, val) #else add to list
  }
}
length(unique(pattrns))
#I think it's working even though it gave me those warnings about matching only the first element....?
length(unique(cleandeployDF_1[,5])) #7
length(unique(cleandeployDF_2[,5])) #8
length(unique(cleandeployDF_3[,5])) #24
#total of 39, checks out

#so will this be as easy as, last time?
recorderid_match <- str_subset(df_ax81$file_path, regex(pattrns, ignore_case=TRUE)) 

#184 matches.... out of a dataframe 9342 items long?
str_which(df_ax81, regex(pattrns[1]))
sum(str_detect(df_ax81$file_path, regex(pattrns[1]))) #there's no match to the recorder id "AMAR202.1.16000.M8EV35dB"? 1?
#I don't know how to fact check that
sum(str_detect(df_ax81$file_path, regex(pattrns[6]))) #0? 1?
sum(str_detect(df_ax81$file_path, regex(pattrns[22]))) #0, this is not working

#looking at recorderid_match

recorderid_match

#checking for pattern across all over


which(df_ax81 == pattrns[1], arr.ind = TRUE)
#seriosuly no where?
#looking at the the folder names again

df_ax81 %>%
  group_by(subdirectory3, subdirectory4, subdirectory5, subdirectory6) %>%
  summarise(n=n()) %>% 
  view()

df_ax81 %>% 
  count(subdirectory3, subdirectory4, subdirectory5, subdirectory6, sort = TRUE) %>% 
  view()
#INTERESTING HOW THESE CAME UP DIFFERENT WHEN i HAVEN'T SUBSET THE DF FOR WAV FILES...

#Let's try this with stationid ----------------
pattrns <- NULL
#Get the unique values of col 8 into a list, based on if they are already in the list
for (thing in cleandeplydflst){
  
  val <-unique(thing[,8]) #get unique value out of 5thh  column
  pattrns <-  append(pattrns, val) #add to list
  pattrns <-  unique(pattrns)

}
length(unique(pattrns))
#28 now, 37 objects long
#I think it's working even though it gave me those warnings?
length(unique(cleandeployDF_1[,8])) #7
length(unique(cleandeployDF_2[,8])) #8
length(unique(cleandeployDF_3[,8])) #22
#total of 37 but, of unique, between all three? so I accept 22.
stationIDS_list <- pattrns

#now I need, unique period from deployment info --------------------
pattrns <-  NULL
for (thing in cleandeplydflst){
  
  val <-unique(thing[,4]) #get unique value out of 4thh  column
  pattrns <-  append(pattrns, val) #add to list
  #pattrns <-  unique(pattrns)
}

#Now, Can I find those values in the file paths anywhere? ---------------------------------
pattrns[1] #2013-overwinter season

a <- str_which(df_ax81$file_path, pattrns[1]) #find those file paths
df_ax81[a,] #subset the filepaths dataframe on only 2013-overwinter season matches

df_ax81[a,] %>%
  count(subdirectory3, subdirectory4, subdirectory5, subdirectory6, subdirectory7,subdirectory8, sort = TRUE) %>% 
  write_delim(".././overwinter-2013-matching.csv", delim=",", na="NA")
#apparently, I only get them from, CL05? But there are other folders, with related information in the 2013-overwinter season folder, that we can find
#so this would need to be searched over many frames as well

seasons_match <-  pattrns

#can I find, partial matches, easily?
df_ax81$file_path %>% 
  str_detect("2013") %>% 
  sum()
#7346, which, actually checks out against, an earlier number. right?

df_ax81$file_path %>% 
  str_detect("2014") %>% 
  sum()
#3317
df_ax81$file_path %>% 
  str_detect("2009") %>% 
  sum()
#1996

#total of 12659
# a number more than the unique wav files we have, but less than total de-deuped files we have

#Can I get partial matches against my season list, and my stations list, at the same time?

pmatch(seasons_match[1], table=df_ax81, duplicates.ok=FALSE)

#this doesn't seem like it's going to work the way I want

charmatch(seasons_match[1], df_ax81$file_path, nomatch=0)

#I need to know more about how these functions are suppose to work
x <-  append(x, "yes")
charmatch("yes", x, nomatch=0)
charmatch(x, "yes", nomatch=0)

#These make no sense, I need other functions for partial matches

#Back to, finding the matches, we have, client match index, let's make, station match index? -------------

station_match_index <-  str_which(df_ax81$file_path, regex(stationIDS_list, ignore_case=TRUE))

df_ax81[station_match_index]
#not right? oh, need to call as, subset on cols/rows (add a comma)

df_ax81[station_match_index,] %>% 
  group_by(subdirectory3, subdirectory5) %>% 
  view()
#total of 327
#which is how many station match id numbers were returned
#But, wrong, this is not effective, because I know I have, 7105 from CL05

stationIDS_list

x <- c("CL05", "B05", "CL5", "B5", "PL5", "PL50", "PL05")

#agrep can do approximate matching
agrep(stationIDS_list, x)

#NO wait, the problem is that I need to loop through ALL of the stationIDS and match in df_ax81$file_path, because, it's using the first only? Because I know I need 9000 ish matches to WN40 and CL5
station_match_index <- NULL
for(thing in stationIDS_list){
  val <- str_which(df_ax81$file_path, regex(thing, ignore_case = T))
  station_match_index <- append(station_match_index, val)
}
#that gave me 9150 index numbers that match a stationID I have, which is good? *But it's basically the whole dataframe, how much good is that doing me?

df_ax81[station_match_index,] %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6) %>% 
  count() %>% 
  view()

#so that view, shows me, anywhere in the folder structure of this drive, where there's a match for a stationID in the deployments I know about (3), so I can find folders named for the stations of the deployments where hopefully there are the right files stored. Yes?------------------------
#But i need to keep them with the folders named for the period. But I know one i smore parent to the other, so I could do period first then station.
#More loops eventuallyy

#I guess I should make these a df, even though, they're, not, all the wav files?
sm_df <- df_ax81[station_match_index,]

#what are those, 100 something differences?
view(df_ax81[-station_match_index,])
#Shell Shallow Hazards are not pulling up with station ids in the file paths anywhere. Hrm. Well good to know but I'm going to press on.


#now I need to join dataframes, by period, then station.------------------------------
#firstly, it's good to know, seasons are matched in the Subdirectory 5
sm_df %>% 
  group_by(subdirectory3, subdirectory5) %>% 
  count() %>% 
  view()

#this is manual, but I know that cleandeployDF_2 is 2009, and cleandeployDF_1 is 2013, which are my two seasons for these wave files
#but it doesn't have to be manual, right, I know that I looped through the lists in order, so I know the first value in the station list or season list is the first unique value in cleandeploy_1, because, loops
#let's try this first, as a minimally curated data set.

# find the season for clean deployment df 1
period <- seasons_match[1]

#find the file paths that include this pattern, as a whole

str_which(df_ax81$file_path, regex(period)) 

temp_index <- str_which(df_ax81$file_path, regex(period))

slice(df_ax81, temp_index)
#7183 rows, 7183 locations where overwinter-2013 happens

df_ax81 %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()

#now if I subset that further for only wav files
wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE))

length(wavs_index81)
#so 9342 wav files

df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()
#6777 CL05 wav files, is all we can get from this period this drive?
#Still all in CL05?
#I guess that makes sense? 
#let's press on
getwd()

# write the file path locations out with the information for the deployment file in the file name I guess? shudder
df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  as.data.frame() -> t
  
  
  
write_lines(t$file_path, file="../df_ax81_cleandeployDF1_related-wav-file-paths.txt", sep="\n", append=FALSE)

## Repeating that process for cleandeploy_DF2 wav files ---------------------
# find the season for clean deployment df 2
period <- seasons_match[2]

#make temporary index subsetting object off it
temp_index <- str_which(df_ax81$file_path, regex(period))

#look at it real quick, subsetting for wav
df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()
#1664 files

# write the file path locations out with the information for the deployment file  in the file name I guess? shudder
df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  as.data.frame() -> t



write_lines(t$file_path, file="../df_ax81_cleandeployDF2_related-wav-file-paths.txt", sep="\n", append=FALSE)

## ON a role, repeat that basic curation with cleandeploy_DF3
# find the season for clean deployment df 2
period <- seasons_match[3]

#make temporary index subsetting object off it
temp_index <- str_which(df_ax81$file_path, regex(period))

#look at it real quick, subsetting for wav
df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory4, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()
#it's only finding, 2013-overwinter types things? are there no 2014-summer matches at all?
df_ax81 %>% 
  group_by(subdirectory5) %>% count() %>% 
  view()

#I should find 16 matches for 2014-summer period

df_ax81 %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory4, subdirectory5) %>% count %>% 
  view()
#are they not wav files?
df_ax81 %>% 
  slice(temp_index) %>% 
  view()
#they are not wav files, but I suppose, they're useful ish stuff?
# let's get those paths out anyway
df_ax81 %>% 
  slice(temp_index) %>% 
  as.data.frame() -> t



write_lines(t$file_path, file="../df_ax81_cleandeployDF3_any-related-file-paths.txt", sep="\n", append=FALSE)
