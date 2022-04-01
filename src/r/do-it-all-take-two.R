##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: Feb 2022
#git repo for folder with script, etc
#using new repo on gitlab http://git.axiom/adrienne/R-over-shell-drives
#What if I made this script point at the all_files.txt new text dummy we have?

#install.packages('tidyverse')
library("tidyverse")
library("stringi")
#Make the dataframes of the drive directories/file paths csv and wav files specifically ----------------------------------------------
## check your 20 --- DO THIS BY HAND
getwd() #assumes answer is git repo folder and new.invs is a sibling folder
setwd("~/Documents/R-over-shell-drives") #make sure you're in the repo as needed


#make a vector that builds the header for this dataframe, make it really long
columnNames = c("file_path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10", "subdirectory11", "subdirectory12", "subdirectory13", "subdirectory14", "subdirectory15" )

#store the drive list, and the csv list, and the stationIDs
dr_list <- list.files(path="../new.invs")
csv_fls <- list.files(path="./CSV-copied")
stationIDS <-  read.delim("./stationids.txt", sep="\n",col.names="ID")

#make the dataframe with the all_files.txt

all_fls_df <- read.delim("./all_files.txt", sep="/",
                        col.names = columnNames, header = FALSE, comment.char="",
                        blank.lines.skip=FALSE, fill =TRUE)

#let's get some details about that
table(all_fls_df[,17]) #what does the last, subdirectory14 look like? 
#Looks like there is still one folder with 6 files in it (05-06-2008), but mostly empties, or there's text, wav, log, box?, pdfs or other files here. 

#UPDATE: adding subdirectory15, reran code, now it's almost all empties besides 10 files. so that's the end, it's 17 col wide dataframe, 16503660 observations (16.5 mill), I don't need the details anymore

#remove duplicates etc -----------------------
df <- as_tibble(all_fls_df)%>% 
  distinct() #removes a single duplicate

#let's trim recyclebin, trash,   etc
df <-  filter(df, subdirectory1 != "$RECYCLE.BIN ")

df <-  filter(df, subdirectory1 != ".Trashes ")

df <-  filter(df, subdirectory1 != "System Volume Information")

# Get united path value in 1 large df if desired -------------------------
df <- df %>% 
  mutate_all(as.character) %>%
  unite(col = "file_path", 1:17, remove = TRUE, na.rm = T, sep = "/") %>% 
  df$file_path <- trimws(df$file_path, which="right", whitespace="/")

head(df)
df %>% group_by(directory)
# Split the all text file into multiple drive dfs again, if desired ------------------
#It's too big to work with, all at once. Make split by drive.
test_lst <- as_tibble(df)%>% 
  group_by(directory) %>% 
  group_split()

test_lst <- test_lst[1:57] #exclude weird end data frames that were labels and megaSAS log, and also exclude 90 and 91, the NOAA-prepped things (what I consider not the raw stuff)


##as a loop, when there are dfs per drive, make the filepath column useful, and rename each df as a thing in my environment to work with, -------
testlst <-  NULL
i <- 1
for(thing in test_lst){
  #get name ready
  nam <- paste("df", thing$directory[1], sep="_")
  #make a column in a dataframe that has the filepath included
  df <- thing %>% 
    mutate_all(as.character) %>%
    unite(col = "file_path", 1:17, remove = TRUE, na.rm = T, sep = "/") #remove arg removes cols not of interest to me
  print(i)
  #trim the ends where NAs somehow, perpetuated?
  df$file_path <- trimws(df$file_path, which="right", whitespace="/")
  #print(head(df))

  print(nam)
  assign(nam, df)
  #make a list to iterate through
  testlst[[i]] <- nam
  i <- i+1
}
lst <- lapply(testlst, get)

rm(testlst,thing, df, test_lst)



#find the wavs in the paths, looping through multiple dfs---------
#make an empty dataframe, iterator, etc
summ <- tibble(x='a', y=2)
colnames(summ) <- c("x","y")
summ
i <-  1

#loop through and count wavs
for(df in lst){
  #where in the drives are we
  d <- as.character(df[1,1])
  
  #get index numbers of where these wav files are
  wavs_index <- str_which(df$file_path, regex(".wav$|.WAV$", ignore_case=TRUE))
  val <- length(wavs_index)
  
  #print some info for me
  print(c(d,"wavs:",val))
  #subset & store them in a df of their own
  #df_wavs <-df[wavs_index,]
  
  #Write out any useful dataframe files, like csv and wav filepaths
  #write_lines(df_wavs$file_path, file=paste(testlst[i], "wave-file-paths.txt", sep="_"))
  
  i <- i+1
}
#Remove anything from my environment that I don't need now
rm(wavs_index)

#find the station ids in the file path
