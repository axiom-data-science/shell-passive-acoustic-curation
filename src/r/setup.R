## A guide to setup for an R environment in the Axiom Data Science repo https://github.com/axiom-data-science/shell-passive-acoustic-curation

#install tidyverse, version 1.3.1 or later
install.packages("tidyverse")

#Or
#devtools::install_github("tidyverse/tidyverse")

#OR update
#tidyverse_update()


#Install Stringi, version 1.7.5 or later
install.packages("stringi")

#Or download and install from tarball or similar according to instructions https://stringi.gagolewski.com/install.html

#Install sets, version 1.0-21 or later
install.packages("sets")

#OR fetch the tarball and install according to intsructions here https://cran.r-project.org/web/packages/sets/index.html

#call the packages
library("tidyverse")
library("stringi")
library("sets")
