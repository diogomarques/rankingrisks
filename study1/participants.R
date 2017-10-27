# Sample summaries for 1st study participants
stop("INTERACTIVE - DO NOT SOURCE")

# Load data from CSV
library(readr)
data = read_tsv("study1/study1_pop.tsv")

# Save data to vault

# Load data from vault

# Summaries: pay per hour pro rata, 
library(dplyr)
data %>% group_by(GENDER) %>% summarise(n()) # gender
data %>% group_by(AGE) %>% summarise(n()) # age group
data %>% group_by(country) %>% summarise(n()) # country
data %>% group_by(wave) %>% summarise(n()) # wave
data %>% summarise(first = min(submitdate), last = max(submitdate)) # data gathering period
data %>% filter(QUAL1 != "Yes" | QUAL2 != "Yes") # qualification double-check

# Mean time & pay per hour
data %>% group_by(wave,compensation) %>% summarise(meantime= mean(interviewtime)) %>% mutate(pph = (60 * 60 * compensation / meantime))
data %>% select(compensation,interviewtime) %>% 
  mutate(pph = (60 * 60 * compensation / interviewtime))
%>% 
  summarise(mean(interviewtime), mean(pph))
# TODO: this can'be be right.
