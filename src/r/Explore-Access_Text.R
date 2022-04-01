#Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: October 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
install.packages('tidyverse')
library("tidyverse")

#get into the data, look at the text files
#using stringr but also just looking at it

# didn't work -------------------------------------------------------------
## All of this didn't work
?read_delim
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
setwd("./Documents")
getwd()
  
  ax81 <- read_delim("./new.invs/shell.ax81", delim='/', 
                     escape_backslash=FALSE, col_names=columnNames,
                     na="NULL", comment = "",skip_empty_rows=FALSE)
  
  #this worked to build a df of 1 col, the path
  ax81 <- read_delim("./new.invs/shell.ax81", delim='/n', 
                     escape_backslash=FALSE, col_names=columnNames,
                     na="NULL")
  
  
  #Maybe read in dictating which row is the best row to use for column assumptions
  #or hard coding in the proper header for the text files, then feeding into the R code here
  
  head(ax81)
  ax81[20:30,]
  ax81[110:130,]
  
  #this build a tibble with only 5 columns, and escpaed at any ' I think
  ax81 <- tibble(colum)
  ax81 <- read_delim("./new.invs/shell.ax81", '/', escape_backslash=FALSE, escape_double=FALSE, col_names=columnNames, skip_empty_rows = FALSE)
  #first, let's see if we can get more info
  problems(ax81)
  
  #this is not working either, so let's try to get them by line again
  vignette("readr")
  
  #annoying, I need read_lines
  #which was way better to just google. 
  
  ax81 <- read_lines_raw("./new.invs/shell.ax81", skip=0)
  ax81[1:20]
  view(ax81)
  ax81[119]
  
  #OK, now I have them as, all strings, the file paths
  #a tibble would be better
  
  df <- read_delim(ax81, '/', escape_backslash=FALSE, col_names=columnNames)
  ## This is how I knew how many columns-----------------
  #ok, let's try count.fields, an answer on stackoverflow
  ?count_fields
  fieldCount <- count.fields("./new.invs/shell.ax81", '/')
    fieldCount
  
  typeof(fieldCount)
  max(fieldCount, na.rm=TRUE)
  #OK, max doesn't like NAs
  # there should be 12 columns in this dataframe I want to make.

# This is how to make the dataframe with the right number of columns------------------------------------
  
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

getwd() #assumes answer is git repo folder and new.invs is a sibling folder
df_AX81 <- read.delim("../new.invs/shell.ax81", sep="/",
                 col.names = columnNames, header = FALSE, comment.char="",
                 blank.lines.skip=FALSE, fill =TRUE)
#this worked, 12 cols, lots of NAs so it alerts

#but this is how I want it to look for now
head(df_AX81)
#there are a lot of NAs, so it still throws that errror, but I'll take it, I now have a dataframe

#My first question, how many things are in the Trash?
#forgot I have to pipe it 
str_detect(df_AX81$subdirectory3, pattern = "\\.Trash*") %>% sum() #9
str_which(df_AX81$subdirectory3, pattern = "\\.Trash*")  #indices 4, 11, 18, 25, 32, 1998, 1999 was a good year, 2000, 2001
df_AX81$subdirectory3[1999] #success

#let's also get the recycling bin outta there
str_detect(df_AX81$subdirectory3, pattern = "^[:punct;}$") %>% sum() #ugh 0, have tried various variations

#I know there are things in $RECYCLE.BIN, but I cannot get the regex to finding them to work, moving on for now

str_detect(df_AX81$subdirectory3, pattern = "RECYCLER*") %>% sum() #75
str_which(df_AX81$subdirectory3, pattern ="RECYCLER*") -> recycling_items

length(df_AX81$subdirectory3)


#75 out of 15554 , really do I care about that? Not so much, less than ... 5%?





