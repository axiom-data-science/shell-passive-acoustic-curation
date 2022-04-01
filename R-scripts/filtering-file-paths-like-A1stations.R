##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: Feb 2022
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo http://git.axiom/adrienne/R-over-shell-drives/-/blob/main/R-over-shell-drives-notebook.Rmd

# Load up data wrangling environment--------
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")


#Make Dataframe if necessary
columnNames = c("file_path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10", "subdirectory11", "subdirectory12", "subdirectory13")
setwd("../")
getwd()


#a specific dataframe that I wanto examine
df_A1_filepaths <- read_delim("./outputs/stations/A12007-summer_wavs-located.txt", '/', escape_backslash=FALSE, col_names = columnNames)
#this does throw errors, about,there's only 7 cols

#make united file_path col
df <- df_A1_filepaths %>% 
  as_tibble()%>% 
  unite("file_path", 1:7, sep="/", remove=FALSE, na.rm=TRUE)

#filter dataframe on, interesting file formats

dplyr::filter(df)

#find the groupings of those
#I have to not only group, but then do another dplyr thing to the grouped df
#so, summarise?
#by count

df %>%
  group_by(subdirectory4) %>%
  summarise(n=n())

#Yes! # A tibble: 6 × 2
# subdirectory4     n
# <chr>         <int>
#   1 A13-CLN40      2498
# 2 A17-PL05       2498
# 3 A26-W10R        587
# 4 b15            1000
# 5 b20r           1737
# 6 w20r           1560

#so there's not really a station for A1, just annotations for A13 and A17 to other stations.


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