#
# Sample summaries for 1st study participants
#

stop("INTERACTIVE - DO NOT SOURCE")

library(dplyr)
library(googlesheets)

SHEETS_VAULT = "sheets"

# Get data

# retrieve sheet key and store in vault
#key = gs_ls() %>% 
#  filter(grepl("1RUDyCr6C", sheet_key)) %>% 
#  select(sheet_key) %>%
#  first()
# encrypt(.name = SHEETS_VAULT, s1_participants = key)

key = decrypt(SHEETS_VAULT)$s1_participants # get key from vault
sheet = gs_key(key) # register sheet
data = gs_read(sheet) # pull data

# Basic demographic distributions 
data %>% group_by(GENDER) %>% summarise(n()) # gender
data %>% group_by(AGE) %>% summarise(n()) # age group
data %>% group_by(country) %>% summarise(n()) # country
data %>% group_by(wave) %>% summarise(n()) # wave
data %>% summarise(first = min(submitdate), last = max(submitdate)) # data gathering period

# ACQs, workload & compensation
data %>% 
  filter(QUAL1 != "Yes" | QUAL2 != "Yes") # ACQ check
data %>% 
  mutate(tasktime.m = interviewtime / 60) %>%
  summarise(mean(tasktime.m), sd(tasktime.m)) # mean task time
data %>%
  mutate(pph = 60 * 60 * compensation / interviewtime) %>%
  summarise(mean(pph), sd(pph)) # mean pay per hour

# TODO: Story length