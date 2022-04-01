##Using R to do Shell Data curation -----
#Adrienne trying to at least
#Last updated: December 2021
#git repo for folder with script, etc
#new.invs too big, stored in neighboring directory for access
#using gitrepo https://github.com/AdrienneCanino/R-over-shell-drives.git

##Finding deployment info spreadsheets that are not csvs, but that I want to make into CSV
library(tidyverse)
# 1 - make all the text dummys of the shell drives into dfs with a File_path column I can regex search over-----------------
#make sure wd is local git repo
files <- list.files(path="../new.invs")

##create column header for the dfs I'm going to make
columnNames = c("path","directory","subdirectory1", "subdirectory2","subdirectory3","subdirectory4","subdirectory5","subdirectory6","subdirectory7","subdirectory8","subdirectory9","subdirectory10" )

dat <-  NULL
drives_lst <- NULL

## Loop through to read lines
for(f in files){
  #setup file path for readin
  pth <- capture.output(cat("../new.invs/",f, sep=""))
  print(pth)
  
  #read in the lines to dataframe
  dat <- read.delim(file=pth, sep="/",
                col.names = columnNames, header = FALSE, comment.char="",
                blank.lines.skip=FALSE, fill =TRUE)
  
  #make a context specific name for that DF
  nam <- paste("df", as.character(f), sep = "_")
  print(nam)
  assign(nam, dat)
  
  #make a list of DF names to iterate through
  drives_lst <- append(drives_lst, nam)
  
}

#Turn that list of names into object listing the call-able dataframes
new_drives_lst<- lapply(drives_lst, get)


## Loop through to make file path columns

i <- 1
path_dfs_lst <- NULL
dat <- NULL
nam <-  NULL

for(thing in new_drives_lst){

  #re-assign dataframe with united colum
  dat<- 
    as_tibble(new_drives_lst[[i]])%>% 
    #mutate_all(as.character) %>%
    unite(col = "file_path", 1:12, remove = FALSE, na.rm = T, sep = "/")
  
  dat$file_path <-trimws(dat$file_path, which="right", whitespace="/")
  
  #rename it and list it
  nam <- paste("paths_df", files[i], sep = "_")
  print(nam)
  assign(nam, dat)
  path_dfs_lst <- append(path_dfs_lst, nam)
  
  #iterator
  i <- i+1
  
}
new_path_dfs_lst <- lapply(path_dfs_lst, get)

#optional: use the character (old) drives list to remove all these uneccessary dfs
#rm(list=drives_lst)


## 2 - use these path DFs to find excel files, write them out to txt files-------------------
#use that col of file paths to find the csvs in this drive

#This is a hacky shortcut but I need to know which files it's finding excel in. Also need it to name the write_out files.
i <- 29

for(df in new_path_dfs_lst){

  xls_index <-str_which(df$file_path, regex(".xls*$", ignore_case=TRUE))
  len <- length(xls_index)
  print(c(i,"excel files found:",len))
  if(len>0){
    
    df_xls <- df[xls_index,]
    write_lines(df_xls$file_path, file=paste("exl-file-paths_ax",i,".txt", sep="_"))
  }
  i <- i+1
}
#finds them in 6 drives

## I wonder if it finds both .xls, and .xlsx files?
for(df in new_path_dfs_lst){
  
  xlsx_index <-str_which(df$file_path, regex(".xlsx$", ignore_case=TRUE))
  len <- length(xlsx_index)
  print(c(i,"excel-10 files found:",len))
  if(len>0){
    
    df_xls <- df[xlsx_index,]
    write_lines(df_xls$file_path, file=paste("exl-x-file-paths_ax",i,".txt", sep="_"))
  }
  i <- i+1
}
#finds them in 7 drives
#apparently missed ax70 before? ok, interesting.
#Oh yeah, totally missed

## Fin ---------------------------------