#
# Story lenght statistics, pre- and post-editing.
#

# save sheet keys to vault, instead of exposing them
# key.s1_raw_stories = gs_ls() %>% 
#   filter(grepl("Study 1: raw stories", sheet_title)) %>% 
#   select(sheet_key) %>%
#   first()
# key.s1_edited_stories = gs_ls() %>% 
#   filter(grepl("Study 1: edited stories", sheet_title)) %>% 
#   select(sheet_key) %>%
#   first()
# encrypt(.name = SHEETS_VAULT, s1_raw_stories = key.s1_raw_stories)
# encrypt(.name = SHEETS_VAULT, s1_edited_stories = key.s1_edited_stories)

key.s1_raw_stories = decrypt(SHEETS_VAULT)$s1_raw_stories
key.s1_edited_stories = decrypt(SHEETS_VAULT)$s1_edited_stories

# retrieve data
stories.raw = gs_read(gs_key(key.s1_raw_stories))
stories.edited = gs_read(gs_key(key.s1_edited_stories))

# merge
stories.raw = stories.raw %>% 
  select(id, raw = story)
stories.edited = stories.edited %>%
  select(id, edited = story)
stories = stories.raw %>% 
  left_join(stories.edited)

# add word counts
stories = stories %>% 
  mutate(raw.wc = str_count(raw), edited.wc = str_count(edited))

# summarise
wordcount = 
  stories %>% 
  summarise(mean(raw.wc), sd(raw.wc), mean(edited.wc), sd(edited.wc))

# out to file
write_csv(wordcount, path = OUT_S1_WORDCOUNT)

# clean-up
rm(list = ls() %>% str_subset("stories|wordcount|key"))