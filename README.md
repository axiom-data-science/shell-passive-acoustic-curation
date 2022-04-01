
Overview
--------

The code in this repository shows the exploration and curation process for a 'data archeaology' project of retired digital storage for on-going passive acoustic projects hosted by Shell Oil off Alaska's shores. The goal was to examine 59 retired harddrives for re-usable passive acoustic data and metadata. This repository stores both R and Python code examples for how the files were listed, examined and eventually sorted. A text file representation of these 59 drives was used to generate mostly machine organized outputs. It's an excellent exercise in text wrangling.

Data Availability and Provenance Statements
-------------------------------------------

The text representation of these harddrives ('text dummy' that was used to sort and curate final files) is available in the git repo as 'all_files.txt' It is approximately 16.4 million lines long.


These data were provided thanks to the partnership of Shell Oil Company, Greeneridge Sciences, and North Pacific Research Board. It was collected and analyzed as part of Chukchi Sea Environmental Science Program (CSESP).


Many other data products have results from the same research effort, including:

* Wisdom, Sheyna; Alaska Ocean Observing System (AOOS) (2014). Physical, chemical, biological, geophysical, and meteorological data collected in the Arctic Ocean and Chukchi Sea in support of the Chukchi Sea Environmental Studies Program (CSESP) from 2007 to 2014 (NCEI Accession 0124308). NOAA National Centers for Environmental Information. Dataset. https://www.ncei.noaa.gov/archive/accession/0124308.

* Wisdom, Sheyna; Olgoonik Fairweather LLC (2012). Physical and meteorological data collected by shipboard ADCP and CTD, and moored meteorological buoy data collected in the Chukchi Sea from February 2007 to October 2013 by contractors for Shell, ConocoPhillips and Statoil (NCEI Accession 0093399). NOAA National Centers for Environmental Information. Dataset. https://www.ncei.noaa.gov/archive/accession/0093399.


These data are under ongoing analysis by the originators. Some of their recent efforts include:

* Greenridge Sciences Inc. Project History. https://www.greeneridge.com/en/projects/history

* Abadj, S. H., Thode, A. M., Blackwell, S. B. and D. R. Dowling (2014).Ranging bowhead whale calls in a shallow-water dispersive waveguide. _The Journal of the Acoustical Society of America._ 136. https://doi.org/10.1121/1.4881924 

* Blackwell, S. and Thode, A. (2021). Analyzing Bowhead Whale call source levels and functions using eight years of passive acoustice localization data in the Beaufort Sea, 2008-2014.

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 


### License for Repository

These materials are licensed under GNU General Public License v3.0. See [LICENSE.txt](LICENSE.txt) for details.


### Summary of Availability

- [ ] All data **are** publicly available.
- [X] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

Computational requirements
---------------------------


### Software Requirements

The following softwares, and associated libraries and plug-ins, were used in this analysis:

-Python 3+

-R version 4.1.2 (2021-11-01) 
  - `tidyverse` (1.3.1)
  - `stringi` (1.7.5)
  - `sets` (1.0-21)

Portions of the code use bash scripting, used in command line interfaces from Ubuntu software.

In general, command line interfaces were used for locating and creating copies of files. Python was used for both creating the text dummy, and for data exploration and analysis in parallel to the R data exploration to verify numbers and reveal strategies.


### Memory and Runtime Requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard desktop machine (32Gb memory available):

- [ ] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-8 hours
- [X] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days
- [ ] Not feasible to run on a desktop machine, as described below.

#### Details

The code was last run on a **8-core Intel-based desktop running Ubuntu 20.04.4 LTS**. 

Description of programs/code
----------------------------

### Primary files

- The `notebooks` directory holds the R notebook files. `R-over-shell-drives-notebook.Rmd` and corresponding `R-over-shell-drives-notebook.html` files provide the step by step narrative, and example commands, including  command line, Python  and R manipulations, on how the final decision to curate the data was arrived at.
- The `outputs` directory holds the text files listing approximately 1.5 million file paths, sorted by station (location) and year of collection. 
- The `data/stationids.txt` file is the hand-sorted list of station IDs found in deployment metadata, that was used to curate the station-year file lists.
- The `data/periodIDS.txt` file is a plain text list of deployment periods found in deployment metadata related to these data.
- The `outputs/summaryDF.csv` is an output of the R notebook, and lists for each of 57 drives, the number of csvs and wav files found in each drive. It assumes the file path ends in the file type extension (ie, .wav or .csv).
- The `outputs/clean-deploy-dfs` directory holds the re-arranged deployment metadata sheets, with a single header and one row per instrument per deployment, for the acoustic sound collection. They are labeled by deployment and season. These were the most reliable metadata found in the project thus far.
- The `Shell_data_rescue_StationMetadata.csv` file lists the stations used in curating the final file lists, along with the approximate average latitutde and longitude in degrees negative east, for the station. It also lists the years that station was monitored, according to available deployment metadata.

### Secondary files

- Files in `src/r` are R scripts, including a `setup.R script`, that demonstrate various exploratory steps in wrangling the text dummy, including splitting by drive, sorting and summarizing by directory level, and counting wav files. Some are attempts to 'do-it-all.'
- Files in `Rproj-Saves` are environment files saved out of RStudio that can be used to load a global environment with objects in use in various scripts. They were mainly used to speed up exploration by saving memory during run time.
- Files in `data/CSV-copied` are results of command line instruction that found csv files in the harddrives, according to information found in the text dummy (for locating DeploymentInfo sheets, in this case)
- Files in `notebooks/R-over-shell-drives-notebook_files` are outputs from 'knitting' an html file from the RMarkdown notebook. (making pretty docs, etc). 


## References

Abadj, S. H., Thode, A. M., Blackwell, S. B. and D. R. Dowling (2014).Ranging bowhead whale calls in a shallow-water dispersive waveguide. _The Journal of the Acoustical Society of America._ 136. https://doi.org/10.1121/1.4881924 

Blackwell, S. and Thode, A. (2021). Analyzing Bowhead Whale call source levels and functions using eight years of passive acoustice localization data in the Beaufort Sea, 2008-2014. http://projects.nprb.org/#metadata/29436ce0-702d-4a5a-842e-c75c63fd981a/project/folder_metadata/1816285

Greenridge Sciences. https://www.greeneridge.com/en/projects/history


Points of Contact
-----------------

Axiom Data Science: info@axiomdatascience.com

Adrienne Canino, Data Librarian, Axiom Data Science: adrienne@axiomdatascience.com

Chris Turner, Data Librarian, Axiom Data Science: chris@axiomdatascience.com

Karina Khazmutdinova, Project Manager, Axiom Data Science: Karina@axiomdatascience.com
