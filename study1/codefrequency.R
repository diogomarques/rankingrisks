source("study1/setup.R")

#
# Compute code frequencies and output to CSV files
#
OUT_CSV_CATEGORY_FREQUENCY =  "out/s1_frequency_categories.csv"
OUT_CSV_CODE_FREQUENCY =      "out/s1_frequency_codes.csv"
OUT_CSV_SUBCODE_FREQUENCY =   "out/s1_frequency_subcodes.csv"

# open project
openProject(RQDA_PROJECT_PATH)

# get base tables fromRQDA
codings = getCodingTable()
codecat = RQDAQuery("select * from codecat")
codecat = codecat %>% filter(status == 1)
code = RQDAQuery("select * from freecode")
code = code %>% filter(status == 1)

# create matrix of cat / code / subcode
codings.matrix = str_split_fixed(codings$codename, "-", 3) %>% as_data_frame()
colnames(codings.matrix) = c("category", "code", "subcode")

# bind them
codings = codings %>% bind_cols(codings.matrix)
# filter out irrelevant data
codings = codings %>% select(codename, category, code, subcode, fid)

# code frequency at subcode level
codings.f.subcode = codings %>% group_by(codename, category, code, subcode) %>% summarise(n = n())
# ... w/ memos
codings.f.subcode = codings.f.subcode %>% left_join(code, by=c("codename" = "name")) %>% ungroup() %>%
  select(category, code, subcode, description = memo, n)

# code frequency at code level
codings.f.code = codings %>% group_by(category, code) %>% summarise(n = n())

# code frequency at category level
codings.f.category = codings %>% group_by(category) %>% summarise(n = n())
# ... w/ memos
codings.f.category = codings.f.category %>% left_join(codecat, by=c("category" = "name")) %>%
  select(category, description = memo, n)

# output to files
write_csv(codings.f.category, OUT_CSV_CATEGORY_FREQUENCY)
write_csv(codings.f.code, OUT_CSV_CODE_FREQUENCY)
write_csv(codings.f.subcode, OUT_CSV_SUBCODE_FREQUENCY)

closeProject()
