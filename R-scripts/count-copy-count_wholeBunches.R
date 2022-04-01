##Using R to do Shell Data curation
#Adrienne trying to at least
#Last updated: October 2021
#git repo for folder with script, etc
#data too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

# Load up data wrangling environment
#I always want tidyverse? Yea, I always want tidyverse.
#install.packages('tidyverse')
library("tidyverse")

#Make Dataframe if necessary
#use the files in a neighboring folder to the git repo folder, because, too big to be happy with github.com

columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )
df_AX81 <- read_delim("./new.invs/shell.ax81", '/', escape_backslash=FALSE, col_names = columnNames, fill=TRUE)
#this does throw errors, about, parsing 12 columns of information where only 5 values can be pulled out of the txt file.
#I think it's ok.

#Or, check if I still have my environment
df_wavs81
df_csvs81

#get to the targetFolders
#that means, understanding how many sub directories have wav files, and grouping them
#make all cols behave as factors
?mutate
head(df_wavs81)
df_wavs81 %>%
  mutate_if(is.character,list(~factor(.)))

#This is a df already subset to only .wav endings. 
#so I just need to group the files by the penultimate non-null value
#for loop that goes through every row, looks for the first null value in the row, and returns the value in the column 2 previous (so not the value with the .WAV, but the value with the, targetFolder)
#And I need the index of that
#Can I use stringer, with a not argument, to go through  the columns instead and then get  
dim(df_wavs81)[1]

a <- c()
#What can I use to look across rows?
?apply()
?by
?str_which
#This will return, the index of the row, of the wav file ending
str_which(df_wavs81[1,], regex(".wav$", ignore_case = TRUE))
#so the value in that cell
df_wavs81[1,9]

#oh man this is a hot mess, but it's a first go
for (i in 1:dim(df_wavs81)[1]){
  r <- df_wavs81[i,] #get the row to work with
  penult <- str_which(df_wavs81[i,], regex(".wav$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- r[targetFolderIndex] #assign that value to a temp object
  append(a, tf) #put it in the empty list I started
}
#ok that printed a lot of things that looked right, but, doesn't seem, to have given me the a I want, is append the worng thing?
?append

append(1:5, 0:1, after = 3)
append(a, 1)
head(a)
a
# What does penult look like?
penult
df_wavs81[13334, 12]

#that worked as expected
b <-  penult - 1
df_wavs81[b]
#that's the problem, in this function, penult is a tibble, not a single value, and so the tibbles all printed
#that tibble can still be used to get the value I want though
b <-  penult - 1
tf <- df_wavs81[13334,b]
print(tf)
append(a, tf)
append(a, tf)
#Oh is this the problem, append() is not permanentyly altering data?
#that doesn't seem right to me

#wellfixing the penult as a tibble is easier than expected, because I can jsut drop col 1 (which will always have yes, if somewhere else is a yes, because it's the nice put together file path)
#and, append needs to be assignment operate prefaced to save the value in it
#let's try again
for (i in 1:dim(df_wavs81)[1]){
  r <- df_wavs81[i,] #get the row to work with
  penult <- str_which(df_wavs81[i,2:13], regex(".wav$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- r[targetFolderIndex] #assign that value to a temp object
  a <- append(a, tf) #put it in the empty list I started
}
#it's still returning, tibbles, I wonder if that will be , a problem?
#OK, let's see
a

#a prints, it's tibbles bound together, not nicely
unique(a)
tf
as.character(tf)
#so to make it a tibble in its own right as an output, I gotta try one more time (though, I think I could get my answers here, I wanna make it good code)
for (i in 1:dim(df_wavs81)[1]){
  r <- df_wavs81[i,] #get the row to work with
  penult <- str_which(df_wavs81[i,2:13], regex(".wav$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  #print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- r[targetFolderIndex] #assign that value to a temp object
  a <- append(a, as.character(tf)) #put it in the empty list I started
}

#that looks different, at least
#whatever I did this time, it's taking a lot more itme
#using rowbind in the last line of this for loop was taking so long, I stopped it, and used as.character instead
#a is a 'large list'
head(a)
unique(a)
unique(a)
factor(a)
levels(a)
is.na(a)

#now I'm just confused. I'm going to go back a step.
#What if I didn't, work with rows at a time, but just, had this for loop returrn a subset dataframe for the target folders I want?
for (i in 1:dim(df_wavs81)[1]){
  penult <- str_which(df_wavs81[i,2:13], regex(".wav$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  #print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- r[targetFolderIndex] #assign that value to a temp object
  a <- append(a, tf) #put it in the empty list I started
}
tf
?str_which
#this didn't work, penult is returning the target folder, not the wav file. Why not?
#is it because it's not character data anymore, it's vector? But it's reading as character
# the subsetting is getting me messed up. 8 in the subset of columns 2:13 is really 9, when not subsetting col 1 out. 
#let's try to remove that challenge, and give it one more go
df <- df_wavs81[,2:13]
df[5,8]

#as expected. Let's try it again.
a =c()
for (i in 1:dim(df)[1]){
  penult <- str_which(df[i,], regex(".wav$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  #print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- df[[i,targetFolderIndex]] #assign that value (and only the value) to a temp object
  a <- append(a, tf) #put it in the empty list I started
}
head(a)
unique(a)

#curiouser and curiouser, I get different answers every time I try for the list of subfolders that I want.
#and they all make sense. this is because of the subsetting of the file skipping column 1 and then using the non subset df to look up the value. So in the above I had to make a subset df and commit to it from here on.

df[13334,10:12]

#how can I see what's up in this list I made?
levels(a)
a <- as_factor(a)
levels(a)
#Levels: 16BitChannel9 WN40 AMAR219.1.16000.M8EV35dB
?summarise
count(a)
sum(a)
a <- as.character(a)
sum(a)
count(a)
a
sum(str_count(a, "WN40")) #5988
sum(str_count(a, "16BitChannel9")) #192
sum(str_count(a, "AMAR219.1.16000.M8EV35dB")) #7154
5988+192+7154 #13334
#checks out

#how to get the file paths I want from this process?
?str_locate_all
#get the index numbers where these targetFolders are, make sure they're the right length according to the numbers above
wn40_index <-  str_which(df_wavs81$file_path, "WN40")
Bit9_index <-  str_which(df_wavs81$file_path, "16BitChannel9")
amar219yada_index <-  str_which(df_wavs81$file_path, "AMAR219.1.16000.M8EV35dB")

#OK. Cool. Wait, would extract do that better? Nope, subset, and I need to put it so it's the folder, and not the WAV files
?regex
wn40_filepaths <-  str_subset(df_wavs81$file_path, "WN40")
Bit9_filepaths <-  str_subset(df_wavs81$file_path, "16BitChannel9")
amar219yada_filepaths <-  str_subset(df_wavs81$file_path, "AMAR219.1.16000.M8EV35dB")

#ok, cool.
#how about, THE file path?
#very manual way: mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40
head(wn40_filepaths)

#how do I know, that, these file paths are all in chukchi/2009-overwinter ?
str_detect(wn40_filepaths, "mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40")

#logical returned, how to make that a usefule return....
sum(str_detect(wn40_filepaths, "mnt/shell/ax81/shell/chukchi/2009-overwinter/WN40"))
#doesn't like the pipe?
?str_detect
#5988, so yes all of them are in the chukchi/2009-overwinter folder


#And, now the same for CSVs
df2 <- df_csvs81[,2:13]

x =c()
for (i in 1:dim(df2)[1]){
  penult <- str_which(df2[i,], regex(".csv$", ignore_case = TRUE)) #find the wav file
  targetFolderIndex <-  penult-1 #look one before it to get the index number of the target folder
  #print(r[targetFolderIndex]) #print the value in the targetFolder cell
  tf <- df2[[i,targetFolderIndex]] #assign that value (and only the value hence doubl []) to a temp object
  x <- append(x, tf) #put it in the empty list I started
}
head(x)
unique(x)
#"2009-overwinter" "2014-summer"     "2013-overwinter"
#which makes perfect sense
pattern <-  c("2009-overwinter","2014-summer","2013-overwinter")
deployment_filepaths <- tibble()
for(thing in pattern){
  deployment_filepaths <- append(deployment_filepaths, as.character(str_subset(df_csvs81$file_path,thing)))
}

deployment_filepaths
unique(deployment_filepaths)

# [1] "mnt/shell/ax81/shell/chukchi/2009-overwinter/deploymentInfo.csv"
# 
# [[2]]
# [1] "mnt/shell/ax81/fw/chukchi/2014-summer/deploymentInfo.csv"
# 
# [[3]]
# [1] "mnt/shell/ax81/fw/chukchi/2013-overwinter/deploymentInfo.csv"

sum(str_detect(deployment_filepaths, "mnt/shell/ax81/shell/chukchi/2009-overwinter/deploymentInfo.csv"))

#why is this 9? This file path got identified, 9 times, in the dataframe that subset for files ending in csv
sum(str_detect(deployment_filepaths, "mnt/shell/ax81/fw/chukchi/2014-summer/deploymentInfo.csv"))
#1, that was the expected answer
sum(str_detect(deployment_filepaths, "mnt/shell/ax81/fw/chukchi/2013-overwinter/deploymentInfo.csv"))
#14, exciting.

