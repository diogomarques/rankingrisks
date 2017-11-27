#
# Sample summaries for 1st study participants
#

# Get data
# retrieve sheet key and store in vault
#key = gs_ls() %>% 
#  filter(grepl("1RUDyCr6C", sheet_key)) %>% 
#  select(sheet_key) %>%
#  first()
# encrypt(.name = SHEETS_VAULT, s1_participants = key)
key = decrypt(SHEETS_VAULT)$s1_participants # get key from vault
data = gs_read(gs_key(key)) # pull data

# Basic demographic distributions 
# gender
stat.gender = 
  data %>% group_by(GENDER) %>% summarise(n()) 
# age group
stat.age = 
  data %>% group_by(AGE) %>% summarise(n()) 
# country
stat.country = 
  data %>% group_by(country) %>% summarise(n()) 
# wave
stat.wave = 
  data %>% group_by(wave) %>% summarise(n())
# data gathering period
stat.period=
  data %>% summarise(first = min(submitdate), last = max(submitdate)) 
# task completion time
stat.tct = 
  data %>% 
  mutate(tasktime.m = interviewtime / 60) %>%
  summarise(mean(tasktime.m), sd(tasktime.m)) # mean task time
# payment per hour
stat.pph = 
  data %>%
  mutate(pph = 60 * 60 * compensation / interviewtime) %>%
  summarise(mean(pph), sd(pph)) # mean pay per hour
# missed ACQs
stat.missed = 
  data %>% 
  filter(QUAL1 != "Yes" | QUAL2 != "Yes") %>% 
  summarise(`n missed at least one ACQ` = n())

# write them all out
stats = ls() %>% 
  str_subset("stat\\.")
  
stats.out = 
  tibble(
    var = stats,
    value = map(var, get),
    name = 
      var %>% 
      str_extract("(?<=\\.)[a-z]*"),
    outfile = 
      glue(OUT_S1_PARTICIPANTS_PATTERN, stat = name)
  )

stats.out %>% 
  pmap(function(value, outfile, ...) write_csv(value, outfile))

# clean-up
rm(list = ls() %>% str_subset("key|data|stat|out"))
