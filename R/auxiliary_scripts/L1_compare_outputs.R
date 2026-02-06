library(dplyr)
library(stringr)
library(purrr)
library(tidyr)

# -----------------------------
# 0) helpers
# -----------------------------
norm_txt <- function(x) {
  x %>%
    as.character() %>%
    str_squish() %>%
    na_if("") %>%
    str_to_lower()
}

standardize_for_compare <- function(df) {
  df %>%
    rename(
      species1_common     = any_of(c("species1_common", "taxa1_common")),
      species2_common     = any_of(c("species2_common", "taxa2_common")),
      species1_scientific = any_of(c("species1_scientific", "taxa1_scientific")),
      species2_scientific = any_of(c("species2_scientific", "taxa2_scientific")),
      interaction         = any_of(c("interaction"))
    ) %>%
    transmute(
      species1_common     = norm_txt(species1_common),
      species2_common     = norm_txt(species2_common),
      species1_scientific = norm_txt(species1_scientific),
      species2_scientific = norm_txt(species2_scientific),
      interaction         = norm_txt(interaction)
    ) %>%
    distinct()
}

make_swap_safe <- function(df_cmp) {
  df_cmp %>%
    mutate(
      common_pair = if_else(species1_common <= species2_common,
                            paste(species1_common, species2_common, sep = " | "),
                            paste(species2_common, species1_common, sep = " | ")),
      sci_pair    = if_else(species1_scientific <= species2_scientific,
                            paste(species1_scientific, species2_scientific, sep = " | "),
                            paste(species2_scientific, species1_scientific, sep = " | "))
    ) %>%
    transmute(common_pair, sci_pair, interaction) %>%
    distinct()
}

# exclude rows where either taxon in sci_pair is in removed_taxa
drop_removed_taxa_rows <- function(df_key, removed_taxa) {
  removed_norm <- norm_txt(removed_taxa)

  df_key %>%
    mutate(sci_taxa = str_split(norm_txt(sci_pair), " \\| ")) %>%
    filter(!map_lgl(sci_taxa, ~ any(.x %in% removed_norm))) %>%
    select(-sci_taxa)
}

# exclude rows where interaction is in altered_interactions
drop_altered_interactions <- function(df_key, altered_interactions) {
  altered_norm <- norm_txt(altered_interactions)
  df_key %>% filter(!interaction %in% altered_norm)
}

# -----------------------------
# 1) read + standardize + key
# -----------------------------
source("./R/lib/config.R")
file_paths <- get_file_paths()
d1 <- read.csv(paste0(file_paths$DATA_FOLDER, "/L1/ain_cac_breeding_7Jan2026.csv"))
d2 <- read.csv(paste0(file_paths$DATA_FOLDER, "/L1/ain_cac_breeding.csv"))

d1_key <- d1 %>% standardize_for_compare() %>% make_swap_safe()
d2_key <- d2 %>% standardize_for_compare() %>% make_swap_safe()

# -----------------------------
# 2) known changes lists
# -----------------------------
removed_taxa <- c(
  "Procellariiformes sp.",
  "Seabird sp.",
  "Waterbird sp.",
  "Anseriformes sp.",
  "Warbler sp.",
  "Wading bird sp.",
  "Flycatcher sp.",
  "Galliform sp.",
  "Procellariiform sp.",
  "Robin sp.",
  "Hydrobatidae sp."
)

altered_interactions <- c(
  "competition-foraging",
  "competition-nest site",
  "competition-territory",
  "kleptoparasitism-food",
  "kleptoparasitism-nest material",
  "facilitation-creching",
  "facilitation-distress calls",
  "facilitation-feeding",
  "nest predation",
  "shared-scolding",
  "scavanging",
  "copulation?",
  "commensalism-scavange",
  "commesalism-scavenge",
  "commesalism-scavange",
  "nest parasitism",
  "shared scolding"
)

# Apply exclusions consistently to both sides BEFORE diffing
d1_key_f <- d1_key %>%
  drop_removed_taxa_rows(removed_taxa) %>%
  drop_altered_interactions(altered_interactions)%>%
  mutate(source = "d1") %>%
  distinct()

d2_key_f <- d2_key %>%
  drop_removed_taxa_rows(removed_taxa) %>%
  drop_altered_interactions(altered_interactions) %>%
  mutate(source = "d2") %>%
  distinct()

# -----------------------------
# 3) differences you probably care about
# -----------------------------

# A) rows only in df1 (after excluding known changes)
only_in_d1 <- d1_key_f %>%
  anti_join(d2_key_f, by = c("common_pair","sci_pair","interaction"))

# B) rows only in df2 (after excluding known changes)
only_in_d2 <- d2_key_f %>%
  anti_join(d1_key_f, by = c("common_pair","sci_pair","interaction"))

# C) pairs that exist in both but interaction changed (after exclusions)
#    This is often the most useful "what changed" view.
changed_interactions <- full_join(
  d1_key_f,
  d2_key_f,
  by = c("common_pair","sci_pair","interaction", "source")
) %>%
  # keep only pairs that appear in both dataframes but with different interactions
  # easier: compare interaction sets per pair
  select(common_pair, sci_pair, interaction, source) %>%
  distinct() %>%
  group_by(common_pair, sci_pair) %>%
  summarize(
    interactions_d1 = paste(sort(unique(interaction[source == "d1"])), collapse = ", "),
    interactions_d2 = paste(sort(unique(interaction[source == "d2"])), collapse = ", "),
    .groups = "drop"
  ) %>%
  filter(interactions_d1 != interactions_d2)

# -----------------------------
# 4) quick counts / inspect
# -----------------------------
nrow(only_in_d1)
nrow(only_in_d2)
nrow(changed_interactions)

only_in_d1
only_in_d2
changed_interactions
