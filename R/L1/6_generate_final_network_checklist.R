# ------------------------------------------------------------
# Identify Clements taxa used in the AIN dataset and flag
# which ones occur in the Canada / Alaska / CONUS species list
# ------------------------------------------------------------

# Load shared helper functions used across the project
source(here::here('R/lib/shared_functions.R'))

# Get standardized file paths for the project data directories
file_paths <- get_file_paths()

# Read the official eBird/Clements taxonomy checklist (L0 reference)
clem <- readr::read_csv(
  file.path(
    file_paths$CHECKLIST_L0,
    "eBird-Clements-v2024-integrated-checklist-October-2024-rev.csv"
  )
)

# Read the CAC species checklist subset (L1)
spp_cac <- readr::read_csv(
  file.path(
    file_paths$CHECKLIST_L1,
    "spp_joint_cac.csv"
  )
)

# Read the avian interaction network (AIN) dataset
ain <- readr::read_csv(
  file.path(
    file_paths$L1,
    "ain_cac.csv"
  )
)

# Extract all unique Clements names used in the interaction data
# (from both taxa1 and taxa2 columns)
ain_clem_names <- unique(c(ain$taxa1_clements, ain$taxa2_clements))

# Display the actual names that are missing from the Clements checklist
ain_clem_names[which(!(ain_clem_names %in% clem$scientific.name))]

# Subset the Clements checklist to only taxa that appear in the AIN dataset
clem_for_ain_spp <- clem[clem$scientific.name %in% ain_clem_names, ]

# Add a logical flag indicating whether each taxon occurs in
# the CAC species checklist (Canada / Alaska / CONUS)
clem_for_ain_spp$canada_ak_conus <- ifelse(
  clem_for_ain_spp$scientific.name %in% spp_cac$scientific_name_clements2024,
  TRUE,
  FALSE
)

# Ensure all names in AIN are also in network and vice versa
which(!(ain_clem_names %in% clem$scientific.name))
which(!(clem_for_ain_spp$scientific.name %in% ain_clem_names))

sum(ain_clem_names %in% clem$scientific.name) == length(ain_clem_names)
sum(clem_for_ain_spp$scientific.name %in% ain_clem_names) == length(clem_for_ain_spp$scientific.name)

# Write the filtered and annotated Clements checklist to disk
write.csv(
  clem_for_ain_spp,
  here::here("./data/L1/species_checklists/spp_clem_in_ain_cac.csv")
)
