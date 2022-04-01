##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: November 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

#install.packages('tidyverse')
library("tidyverse")
library("stringi")
#Make the dataframes of the drive directories/file paths csv and wav files specifically ----------------------------------------------

#make a vector that builds the header for this dataframe
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

  ##check your 20 --- DO THIS BY HAND--------------------------
getwd() #assumes answer is git repo folder and new.invs is a sibling folder
setwd("~/Documents/R-over-shell-drives") #make sure you're in the repo as needed

#write and assign the thing by reading in the lines, carefully, this is a finicky piece of code because of the fileath
df_AX81 <- read.delim("../new.invs/shell.ax81", sep="/",
                      col.names = columnNames, header = FALSE, comment.char="",
                      blank.lines.skip=FALSE, fill =TRUE)


#make a column in a dataframe that has the filepath included
df_ax81 <- 
  as_tibble(df_AX81) %>% 
  mutate_all(as.character) %>%
  unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

#trim the ends where NAs somehow, perpetuated?
df_ax81$file_path <- trimws(df_ax81$file_path, which="right", whitespace="/")

#De-dupe the dataframe
df_ax81 <- df_ax81 %>% 
  distinct()

#use that col of file paths to find the csvs in this drive
csvs_index81 <-str_which(df_ax81$file_path, regex(".csv$", ignore_case=TRUE))
length(csvs_index81) #3, as expected

df_csvs81 <- df_ax81[csvs_index81,]

#same, find the wavs in this drive
wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))

length(wavs_index81)
#so 9342 wav files

df_wavs81 <-df_ax81[wavs_index81,]


#Write out any useful dataframe files, like csv and wav filepaths---------------------
write_lines(df_wavs81$file_path, "./ax81-WAV-file-paths.txt")
write_lines(df_csvs81$file_path, "./ax81-CSV-file-paths.txt")

#Remove anything from my environment that I don't need now
rm(df_AX81, df_csvs81, df_wavs81,
   csvs_index81, wavs_index81)
#filtering, counting, and summarising the files on this drive TBD----------------------------------------------


#Make the deployment info spreadsheets cleaner, with unfortunately complicated loops-----------------------------------------------
#a step in bash is missing from this R code, where a remote drive was accessed and the csvs that the file_paths point to were copied to a folder in this repo
  ## loop 1 - get a list of dataframe for the csvs--------------
  ##This is a loop that can do a read file to datafrom from wd, worked well as just that function

#these deployment info files, the csvs identified in the export on line 55, gotta be in the repo, gotta have those csvs from Shell's messy harddrives in a subdir 'CSV-copied'
#wd and path can be touchy here
files <- list.files(path="./CSV-copied", pattern ="*.csv")

#make a list to iterate through

deploydflst <- NULL
i <- 1
testlst <-  NULL
#operate the loop in the folder where the csvs exist DO THIS PART BY HAND
setwd("./CSV-copied")

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
#that list isn't what I want, it's just names without pointing to the object DF in R, but this is:
deploydflst <- lapply(testlst, get)

#clean up what I don't need from that loop
rm(wideness, dat, nam,f)



  ## Loop 2, make the ugly dataframes clean deployment dataframes ---------------------------------------
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
rm(cleandeployDFslst, 
   deployDF_1, deployDF_2, deployDF_3)

##Write out anything useful from these loops, like the clean deploymentInfo spreadhseet-----------------
write_csv(cleandeployDF_1, file="../ax_81_deploy1.csv")
write_csv(cleandeployDF_2, file="../ax_81_deploy2.csv")
write_csv(cleandeployDF_3, file="../ax_81_deploy3.csv")


## fine the deployment periods for each clean deployment dataframe ------------------------
pattrns <-  NULL
for (thing in cleandeplydflst){
  
  val <-unique(thing[,4]) #get unique value out of 4thh  column, period
  pattrns <-  append(pattrns, val) #add to list
  #pattrns <-  unique(pattrns)
}
## Check assumption - each deployment file is for one deployment period only?

#find those file paths
pattrns[1] 
a <- str_which(df_ax81$file_path, pattrns[1]) 
df_ax81[a,]
seasons_match <-  pattrns

# find the season for first clean deployment df
period <- seasons_match[1]

#Subset the dataframe to it
temp_index <- str_which(df_ax81$file_path, regex(period))

#what does that look like
slice(df_ax81, temp_index)

df_ax81 %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()

#now, looking for only wav files in this instance
wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE))

length(wavs_index81)

#what does it look like, only wav files, in only this period
df_ax81 %>% 
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  group_by(subdirectory3, subdirectory5, subdirectory6, subdirectory7) %>% count() %>% 
  view()

#might need to check this
getwd()

# write the file path locations out with the information for the deployment file in the file name I guess?--------------------------
  slice(wavs_index81) %>% 
  slice(temp_index) %>% 
  as.data.frame() -> t

write_lines(t$file_path, file="../df_ax81_cleandeployDF1_related-wav-file-paths.txt", sep="\n", append=FALSE)

#Now I have a list of the wav files related to a clean and tidy (ish) spreadsheet of information about that deployment