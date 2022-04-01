##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: October 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment--------
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")


#Make Dataframe if necessary
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
setwd("../")
getwd()
df_AX81 <- read_delim("./new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames)
#this does throw errors, about, parsing 12 columns of information where only 5 values can be pulled out of the txt file.
#I think it's ok.


#filter dataframe on, interesting file formats

dplyr::filter(df_AX81)

#Let's start with what summarise can tell me
?summarise()
summarise(df_AX81$subdirectory3)

#Hm, not applicable to object of class "character" , which makes sense, and I did not think of that
#First, to treat, subdirectory3, 4, 5, hell all of them, as, categories

df_AX81$subdirectory3 <- as.factor(df_AX81$subdirectory3)
df_AX81 %>%
  group_by(subdirectory3)

#7 groupings off subdirectory
?factor
subdirectoriesLVL3_ax81 <- levels(df_AX81$subdirectory3)

#this is a terrible name for an object

sub3_lvls <- subdirectoriesLVL3_ax81

rm(subdirectoriesLVL3_ax81)

sub3_lvls
#".Trash-1001"                "$RECYCLE.BIN"               "fw"                         "RECYCLER"                  
#"shell"                      "Shell Shallow Hazards 2013" "System Volume Information" 

#not that useful, let's go back to finding the file extension I'm interested in

#let's build a vector of the index numbers where the value ends in .csv, and store that as an object, then use that object to subset the whole df
#first, find where values end in .csv 
?str_which()

#Can't take the whole dataframe, so let's do, subdirectory10
#this might have to get looped somehow, like do subdirectory 4-10 with the same method
str_which(df_AX81$subdirectory10, regex(".csv$", ignore_case=TRUE, ))

#returns "integer(0)" so... there's nothing there?
#nothing in 9 , 8, 7
str_which(df_AX81$subdirectory6, regex(".csv$", ignore_case=TRUE, ))

# 2010 2027 2044 2061 2078 2095 2112 2129 8150 8243 8251 8259 8267 8275 8283 8291

str_which(df_AX81$path, regex(".csv$", ignore_case=TRUE, ))
#and, nothing  in any of the other locations, so. Let's see if this work the way I wanted

df_AX81$subdirectory6[2010]
# "deploymentInfo.csv" , so, yeah, that's what I wanted. Now for the whole, row of values
#so the csvs are in subdirectory3

df_AX81[2010,]
#so that's the directory, how do I get that as a string?
?toString
?unite
unite(df_AX81, col = "file_path", 1:12, na.rm= T, remove = FALSE, sep = "/")

#this did what I wanted, let's save that output

typeof(df_AX81)

df_ax81 <- 
  as_tibble(df_AX81) %>% 
  mutate_all(as.character) %>%
  unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")

df_ax81$file_path <- trimws(df_ax81$file_path, which="right", whitespace="/")
#so now I have the dataframe with the subdirectories as cols and a col for the pathname as a whole string

#That was kind of a sidebar, what I still want is, all the csvs, which I have those index numbers now.
#so I should be able to output, the path col value, where those index are, right?
rm(df_AX81)

#ok first make the object holding the index values
csvs_index81 <-str_which(df_ax81$file_path, regex(".csv$", ignore_case=TRUE))
length(csvs_index81) #16
df_ax81$file_path[csvs_index81]

df_csvs81 <- df_ax81[csvs_index81,]
#hooray!

#Let's do the same for WAVs

str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))
length(str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, )))
#Whoa, 13334 - that's a lot, is it right? Must be right.

df_ax81$file_path[2480]
#hmm,  "mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40/F42C1113.WAV"
df_ax81$file_path[1808]
#yep, "mnt/shell/ax81/Shell Shallow Hazards 2013/AMAR D 216 - 2nd deployment/16BitChannel9/AMAR 216.424.Chan_9-16bps.1374976743.2013-07-28-01-59-03.wav"
#yikes that's an ugly pathname

wavs_index81 <- str_which(df_ax81$file_path, regex(".wav$", ignore_case=TRUE, ))

length(wavs_index81)
#so 13334 wav files, but I knew that?
#make dataframe of all the wavs files

df_wavs81 <-df_ax81[wavs_index81,]
head(df_wavs81)

#find the groupings of those
#I have to not only group, but then do another dplyr thing to the grouped df
#so, summarise?
#by count

df_wavs81 %>%
  group_by(subdirectory3) %>%
  summarise(n=n())

#Yes!  A tibble: 3 x 2
# subdirectory3                  n
# <fct>                      <int>
#   1 fw                          7154
# 2 shell                       5988
# 3 Shell Shallow Hazards 2013   192

#so most of the wave files are in fw, I think I'll need more information than that, I'm going to look down a level and see if I can get more

df_wavs81$subdirectory4 <- as_factor(df_wavs81$subdirectory4)
levels(df_wavs81$subdirectory4)
sub4_lvls<- levels(df_wavs81$subdirectory4)

#2? really? I have much distrust. Yeah, totally not, I did something wrong there.

tail(df_wavs81$subdirectory4)

#These are, specific to only where there are wav files, let's check against the total dataframe to see how off the thing is
df_ax81$subdirectory4 <- as_factor(df_ax81$subdirectory4)
levels(df_ax81$subdirectory4)

#ah, in this instance, I get 22 levels? 
#I still feel suspicious, like AMAR B 226 should have some wav files, not just, the others.
#let's see how many files are in each subdirectory 4, a summarise table by count again

df_ax81 %>%
  group_by(subdirectory4) %>%
  summarise(n=n()) %>%
  view()

#so of all of Jen's analysis folder, 1702 files, there are NO wav files in there?
df_ax81 %>% 
  filter(subdirectory4 == "Jen's Analysis folder") %>%
  filter(subdirectory5 == "SB - Echosounder") %>% #picking the folder with the most files
  group_by(subdirectory6)%>% #how many unique things are in this folder, according to this dataframe of file paths?
  summarise(n=n())

#Ok, so I may believe it that Jen's Analysis folder doesn't have any .wav files

#AMAR B 226 only has like 7 files, AMAR A and C only 11. So, maybe , it makes sense there are no wavs in there?

#What happens if I look up a level

df_wavs81$subdirectory2 <- as_factor(df_wavs81$subdirectory2)
levels(df_wavs81$subdirectory2)

#not that helpful, that would be why I focused on subdir3 in the first place.
 
#well, anyway, I can get a list of these file paths, 13,334 of them. 

df_wavs81$file_path
length(df_wavs81$file_path)
length(unique(df_wavs81$file_path))
#intriguing, 9342 unique?


#so that means I can write them out, and I want to write out the unique ones only, so I don't duplicate file paths

write_lines(unique(df_wavs81$file_path), "./ax81-WAV-file-paths.txt")
write_lines(unique(df_ax81$file_path[csvs_index81]), "./ax81-CSV-file-paths.txt")

#I guess I should really dedupe the whole dateframe

df_ax81 <- df_ax81 %>% 
  distinct()

#but this doesn't answer the question of, are there sensible groupings within? I can still use some useful dplyr tools to try to answer that question

#for instance, if all teh wav files show up in just 2 subdirectories, what are the next places where they show up?

unique(df_wavs81$subdirectory5) #3
unique(df_wavs81$subdirectory6) #194, whoa

?cur_column

#de-dupe
df_wavs81 <- distinct(df_wavs81)

sum(df_wavs81$subdirectory3 == "fw") #7154
levels(df_wavs81$subdirectory3) #null

#There are wav files in the trash and recycling bin?

df_wavs81 %>%
  group_by(subdirectory3) %>%
  summarise(n=n())

#that's confusing, there are the factor levels of it in the dataframe, but they do not get grouped with anything to count in the summarise function
#so there are not files, there's just, the factor level of the subdirectory?

tail(df_wavs81, 25) %>% view()

df_wavs81 %>%
  filter(subdirectory3 == "RECYCLER")

# tibble: 0 x 13
# … with 13 variables.... 
#OK, so, there are no wav files in Recycler, it just, retains it's levels from previous dataframes?

#So my starting place for wav file organization are the 3 subdirectories that have wav files, in this drive:
#fw, shell, and Shell Shallow Hazards 2013

df_wavs81 %>%
  filter(subdirectory3 == "fw") %>%
  group_by(subdirectory4)%>%
  view()
#chuckchi

#make each column factor
df_wavs81 %>%
  mutate_if(is.character,funs(factor(.)))

#group by subdirectory5, aonly in "fw" subdirectory3, and count
df_wavs81 %>%
  filter(subdirectory3 == "fw") %>%
  group_by(subdirectory5) %>%
  summarise(n=n())

#Hm, what I really need is unique values grouped by then count


df_wavs81 %>%
    group_by(subdirectory3, subdirectory4, subdirectory5, subdirectory6) %>%
    summarise(n=n())

#now we're talking
df_wavs81 %>%
  count(subdirectory3, subdirectory4, subdirectory5, subdirectory6, sort = TRUE)

#now I can see, that only in fw and Shell do I need to do more work in subdirectory 6

df_wavs81 %>%
  filter(subdirectory3=="fw") %>% 
  count(subdirectory4, subdirectory5, subdirectory6, subdirectory7, subdirectory8, subdirectory9, sort=TRUE) %>% 
  view()

#this is very manual

df_wavs81 %>%
  filter(subdirectory3=="shell") %>% 
  count(subdirectory4, subdirectory5, 
        subdirectory6, #subdirectory7, 
        #subdirectory8, subdirectory9, 
        sort=TRUE)
#Wait, this is interesting, is there a count of 3 of the exact same file?
#similar to the csvs situation?