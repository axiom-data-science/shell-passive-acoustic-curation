#testing loopingthorughdataframes and writing out values I want
#make crazy dummy dataframes
juliet <- matrix(nrow=4, ncol=3)
juliet[1:4] <- 1:4
zoey <- juliet
zoey[1:4] <- 5:8
sampson <- juliet
sampson[1:4,2] <- 9:12
sampson[1:4,3] <- c("x",'k','c','d')
juliet[1:4,2] <- sampsom[1:4,3]
juliet[1:4,2] <- sampson[1:4,3]
zoey <- juliet

#make a list of those dataframes
y <- c('juliet','zoey','sampson')
y <- lapply(y, get)

#with col names
colnames(y[[1]]) <- c("V1","V2",'V3')
colnames(y[[2]]) <- c("V1","V2",'V3')
colnames(y[[3]]) <- c("V1","V2",'V3')

#make them tibbles to behave right
y <- lapply(y,as_tibble)

#check it for behavior I can test and understand
View(y)


#make a loop and see if I get the behavior I want, tweak until I do
i <- 1
for(thing in y){
  ind <- thing[[1,2]]
  print(ind)
  for(val in x){
    print(c("looking for",val))
    val_match <- str_subset(thing$V2, pattern=regex(val, ignore_case = TRUE))
    print(c("AND FOUND##",length(val_match)))
    if(length(val_match)>0){
      write_lines(val_match, file=paste("outputs/stations/",val,"_",ind,"test-located.txt", sep=""))
    }
  }
}