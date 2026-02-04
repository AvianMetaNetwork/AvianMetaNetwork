
## About L0 R Scripts

see [main readme](../readme.md) for details. 

### This folder contains: 

- `1_generate_species_lists.R` Filters and adds regions to Clements checklist. 
   Run this only when the main checklists have been updated (annually).  The file names
   in this script will have be changed to reflect the newly downloaded lists. 
- `2_stitch_species.qmd`  cleans formats and typos in data entry csv files, merges them (stitch)
   into a single table and re-formats some columns (wide columns into long columns)
- `aux_text_corrections.csv` used by functions called by cleaning script above, a manually 
   created list of terms to change from raw data to cleaned data.  Update as needed
   
### Summary

If you have access to the raw data (collaborators only) and you want to build a new version
of the database, you will most likely only need to run 2_stitch_species.qmd to 
build a single database file from raw data entry CSVs. See the [main readme](../readme.md) for how to get started. 

More details are in [2_stitch_species.qmd](2_stitch_species.qmd)

