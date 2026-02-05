# Avian Interaction Database: 
## Workflow for cleaning and building database

###  [Spatial and Community Ecology Lab (SpaCE Lab)](https://www.communityecologylab.com)

https://github.com/SpaCE-Lab-MSU/Avian-Interaction-Database


## Overview

For an overview of the project, details about the database, its structure, and a protocol 
for how the data are pulled from primary sources, see the [Project Readme file](../readme.md) 
in the root directory. 

This documents the process and R code for cleaning and building
the Avian Interaction Database from a collection of data entry tables entered over time
by contributors to the database, primarily workers in the 
[Spatial and Community Ecology Lab (SpaCE Lab)](https://www.communityecologylab.com)

The build process and scripts in this section are for use by project collaborators only
and provided as a reference.  For details about our workflow, see [Project Readme file](../readme.md) 


## Location of data

See the [main documentation for the project](../readme.md) for a link to the finished 
database (the output of this process). 

The R folders in this project do have some support data used to harmonize and update the
taxonomic designations for species to match current species lists.  See 
the "*reconcile taxonomy*" step below, in the data folder of this repository. 

## Main database build scripts

* R/L0/1_generate_species_lists.R = Generates species lists used for taxonomic harmonization and regional subsetting
* R/L0/2_stitch_species.qmd = stitches together all individual csvs in /L0/species
* R/L1/3_subset_species_lists.R = generates regional taxonomic crosswalk species checklist for Canada, Alaska, and the Coninental United States (CONUS)
* R/L1/4_clean_network_data.qmd = fixes species names, interaction codes, checks species name discrepencies based on current and past Clements names.  
* R/L1/5_subset_network.qmd = subsets interaction network to only include focal species in the subset species list generated in script 3. 
* R/L2/6_summary_vignette.qmd = counts of records by categories of final database 

## Folders

- R/L0: code to examine, clean, and aggregate the version-controlled data entry files
- R/L1: code to clean and harmonize taxonomic entries for the final database, 
  and to create subsets for specific analyses
- R/L2: code for creating simple summaries and visualizations of the data in the database
- R/lib: scripts with shared functions used by main database build scripts
- R/archive: code from previous versions saved for reference
- R/auxilliary scripts: 

## Getting Started

Summary of the steps to be able to run these scripts and build the database. This 
assumes the use of Rstudio 2025 version or above.

1. setup 
   - clone the private git repository with the in-progress (aka 'raw') data  
     from https://github.com/SpaCE-Lab-MSU/Avian-Interaction-Database-Working.git
     to a folder on your computer.  Note the location of this folder for steps later. 
     If you are a collaborator and you don't have access, please contact the project
     director. 
   - copy file `R/filepaths_example.R` to `R/filepaths.R` and set files paths 
     pointing to data on your computer (details below). 
   - install packages as needed (details below)
   - clear R environment (scripts do not do this automatically)
1. optional: check file paths/repository state
   - open `R/auxilliary_script/L0_repo_status.qmd` Quarto file
   - in Rstudio, in the upper-right "run" button, select
     "restart R and run all chunks"
   - if there are no errors, the data is available and you may proceed.
   - if there are errors, check if `dir.exists(DATA_FOLDER)` 
1. optional/occasional: rebuild species lists
   * R/L0/1_generate_species_lists.R = Generates species lists used for taxonomic harmonization and regional subsetting
   Recent species lists are in the [data folder](../data) of this repository and only need to be
   recreated if new lists are available from our primary sources
1. aggregate (stitch) raw data into single file
   - `R/L0/2_stitch_species.qmd` = stitches together all individual csvs in /L0/species
   - in the upper-right "run" button, select
     "restart R and run all chunks"
   - this will report the file that is saved
1. build species checklist for current region of study 
   -  `R/L1/3_subset_species_lists.R` = generates regional taxonomic crosswalk species checklist for Canada, Alaska, and the Coninental United States (CONUS)

1. build taxonomy edits, running one chunk at time
   - open `R/L1/4_clean_network_data.qmd` = harmonizes species names, interaction codes, checks species name discrepencies based on current and past Clements names.  
   - edit the value for stitched_L0_file to match the L0 step above (near the top of file)
   - check the value for the main checklists 
   - position the cursor in the first block of code and run it
   - easily run all subsequent blocks, one a time, using key short cut Option+Command+N
     (see the "->Run" button at the top for more options)
   - edit or add new taxonomic fixes to the edit list

1. Subset for specific analysis
   -  Some analyses only include focal species in the subset species list generated in script 3. 
   -  R/L1/5_subset_network.qmd = subsets interaction network to 

1. Summarize and visualize results



## Detailed Set-up and Configuration for R code

These are the steps for collaborators to get this R code working to be able to 
build the database and generate summary reports and figures. 

To use these R scripts to build the database, you must set up the 
configuration for where to find the data, as each computer/execution environment 
has its own folder paths.  
To allow for collaboration, this project uses a simple R script that only sets 
variables with the paths.  
Then there is a function you can call (or gets called when you source the scripts)
to check that they are set and the paths are found. 

1. find the file `filepaths_example.R` in the top folder
2. make a copy of this file as filepaths.R  (open and 'save as...' `filepaths.R`)
   the configuration functions expect the file to be named this, and the file
   is included in the gitignore so it is not synced with this repository (each 
   user will need to create their own `filepaths.R`)
3. open the new `filepaths.R` and put the paths for your computer
   (this is an R script and uses R syntax, not a config or environment file)
   - DATA_FOLDER : the path to the folder that has the L0 and L1 subfolders.
   - CHECKLIST_FOLDER : location of various checklist files in the repository.
   
**TO-DO: we have two checklists L0 = Clements etc and L1= PLZ Curated and this
system does not accommodate for that**

   

Example `filepaths.R` contents (see also the content of the file `filepaths_example.R`)

```
# path the clone of the in-progress data repository
DATA_FOLDER =  "/Users/USERID/Avian-Interaction-Database-Working"
# Path for for L0 and L1 checklists (Clements etc):
CHECKLIST_L0 = "./data/L0/species_checklists"
CHECKLIST_L1 = "./data/L1/species_checklists"
```

### Installing Packages Details

This project uses the widely used ['here' package](https://here.r-lib.org) to 
automatically identify the top folder for scripts to be able to find each other 
regardless of where they are run. Install this package.

To install all of the packages required for this project we use the [renv](https://rstudio.github.io/renv/articles/renv.html)
package manager from Rstudio/Posit as follows from the R console


```
# if you don't have renv installed, first install it
install.packages("renv")
# this installs all the packages listed in the "renv.lock" file 
renv::init()
```

Choose option 1. restore the project from the lockfile. 

If you need to update packages, choose option 2 to re-install everything. 

See the file `renv.lock` for both the R version and package versions with 
which the code was developed and tested. 


## Code Workflow

See the main workflow document describing how data is collected, entered, 
checked-in and reviewed. This describes how the code is used to build the final
database with updated taxa from the data as entered.  

The workflow for this repository follows the guidelines set out by the 
[Environmental Data Initiative (EDI)]((https://edirepository.org/)). 
Briefly, this involves aligning with FAIR data practices, and employing a 
workflow that uses different levels for harmonization and derived data products. 
The overall workflow aligns with this EDI diagram:

<img src="https://edirepository.org/static/images/thematic-standardization-workflow.png" class="inline"/>

First, Data are entered into individual files for logistics per the main workflow
above.

The data as entered by reading from primary or secondary sources (as 
a meta analysis) may have typos or inconsistencies from data entry personnel, but
we consider the "L0" data to be a reviewed, corrected, validated and 
combined table based on our data entry process. The L0 data typically have 
common and scientific names as they appear in the literature, and thus may need
updating to current taxonomy (a step that occurs within a L1 step). 


1) **Review**

  - Data submitted for review can be checked using reviewing scripts  
  - Outcome: CSV files in the "species" folder with mostly cleaned and corrected data but with potentially outdated taxonomic designations.
  - Scripts/Notebooks:
    - `lib/config.R` : functions for checking and setting the file paths in `file_paths.R`
    - `lib/shared_functions.R` : contains functions for many  cleaning/data processing code
    - `auxilliary_scripts/L0_repo_status.qmd` : count numbers of files in various states from sources
    - `auxilliary_scripts/L0_corrections_discovery.qmd` : point out issues in files to be corrected

2) **clean and combine**

   - Outcome: single file with all interactions that are even more cleaned and made 
   consistent for interaction names, effect values, etc.
   - Scripts/Notebooks:
      - L0/L0_functions.R = contains most cleaning/data processing code
      - L0_stitch.qmd : read each file, clean (as above), and stitch together
   
3) **build checklist**
   download latest checklists if necessary and build comprehensive checklist 
   with 
     
   - 
   
4) **build taxonomic reconciliation table**
   using checklists from step above and functions to examine / compare 
   taxonomy in data as entered ('raw') and checklist to create an 'edited' version
   of the scientific name or common name to correct for typos or taxonomic changes
   to match the current checklist (typically Clements).
   
   - Outcome:  L1_taxonomonic_edits.csv


   
5) **reconcile taxonomy**

  - apply a final cleaning, then use the taxonomic edits file to merge with current create a file that ...
  - apply various methods matches the final 
  - database with the taxonomic 
  

## Additional scripts

These are used by collaborators for building and cleaning the database

- **R/lib/config.R** sourced by all scripts to set file paths, should not need editing or
sourcing.
- **R/lib/shared_functions.R** sources by most scripts, common functions for cleaning and opening the DB
  Using a script for functions helps to keep the quarto notebook files succinct. 
- **R/lib/taxonomy_functions.R** functions used by `R/L1/4_clean_network_data.qmd` for taxonomic harmonization, 
  to keep that quarto notebook readable. 
- **R/lib/compare_outputs.R** internal script specifically for comparing versions of databases created
  during a transition in late 2024. 
- **R/auxilliary_scripts** current or draft script fragements used by the database team
- **R/archive** These are from previous iterations used by the database team and can ignored.  


## Acknowledgements 

Funding is provided by Michigan State University (to P.L. Zarnetske), and by a 
MSU Ecology Evolution, and Behavior SEED Grant (to P.L. Zarnetske). 
Original work on a subset of species was funded by the Yale Climate and Energy 
Institute (to P.L. Zarnetske), Erasmus Mundus Fellowship (to S. Zonneveld).

Please see main readme for additional acknlowedgmens

---

### OPTIONAL Google Drive Setup

We use Google Sheets to facilitate data entry for each species (see protocol in
[L0/AvianInteractionData_ENTRY_INSTRUCTIONS.md](https://github.com/SpaCE-Lab-MSU/Avian-Interaction-Database-Working/L0/AvianInteractionData_ENTRY_INSTRUCTIONS.md). If, as part of using the R code, 
you'd like to view and access the intermediate files in Google Drive, you must 
ave Google Drive installed on your computer.  

**This step is not necessary to build the database.** Use only if you are a data
manager reviewing those in-process google drive sheets. 

From Google Sheets, the raw data is saved as CSV in the working repository once the work
(typically for a species) is finished.   See our main readme for the workflow.  

However you may want to check and read the google sheets before they have been saved to CSV. 
If you want to so this, you must first have access to the Avian Interaction Database working
Google drive (collaborator only), set up Google drive to sync that folder to your computer, and
possibly make changes to your google Drive setup on your computer.   There is no code here to
read directly from the Google Sheets files directly via the Google Cloud API due to restrictions
and complexity of setting that up.  

These steps are not necessary and only to check on work-in-progress that has not been 
exported to CSV. 

Use Google Drive on Windows:  section to be written

To use Google Drive on MacOS15, you may have to grant 'full file access' to 
Rstudio in the the MacOS System Settings - Privacy & Security - Full Disk Access - 
select Rstudio and/or Positron.  

Older installations of Google Drive may have it in different locations and these
locations are not documented well. You may be able to find this by dragging a 
file from an open Google Drive window into the terminal window.

Note that you then must add the location of your Google Drive folder to the 
`filepaths.R` file described above. The folder location of Google Drive on MacOS
for most recent installations is in the `filepaths_example.R` file. 

A technique for finding the location of your Google Drive folder on Mac is:

1. open the Mac Finder and find the parent folder of where you sync your data
2. open the terminal.app utility application (the Rstudio terminal doesn't work for this)
3. drag the folder where your data is into the terminal.app window
   this will then show the full path to the Google Drive folder.  
4. highlight this folder and copy it (Command+c or rightclick and copy)
5. paste this folder into `filepaths.R`

For those who have an older install of Google Drive, it is in the `/Volumes..` 
path but in newer installs the path is something like

`/Users/YOURUSERID/Library/CloudStorage/GoogleDrive-youremail@someplace.com/`
 
