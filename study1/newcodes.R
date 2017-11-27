#
# Analyze codebook growth
#

# open RQDA project
openProject(RQDA_PROJECT_PATH)

# get a codings table w/ both basic codings and collapsed subcodes
codings = getCodingTable()
# create matrix of cat / code / subcode
codings.matrix = str_split_fixed(codings$codename, "-", 3) %>% as_data_frame()
colnames(codings.matrix) = c("category", "code", "subcode")
# bind them
codings = codings %>% bind_cols(codings.matrix)
# add wave 
codings = codings %>% mutate(wave = case_when(
                                          fid <= 35 & fid > 25  ~ "Wave 3",
                                          fid <= 25 & fid > 13  ~ "Wave 2",
                                          fid <= 13 & fid > 3  ~ "Wave 1", 
                                          fid <= 3 ~ "Pilot"
                                          )
                                        )
# tidy-up
codings = codings %>% mutate(category.code = paste(category, code, sep="-"),
                             category.code.subcode = codename) %>%  
  select(fid, wave, category.code, category.code.subcode)

# tables of new codes/subcodes per wave
new.codes = codings %>% select(fid, wave, category.code) %>% group_by(category.code) %>% 
  summarise_all(min) %>% arrange(fid) %>% ungroup() 
new.subcodes = codings %>% select(fid, wave, category.code.subcode) %>% group_by(category.code.subcode) %>% 
  summarise_all(min) %>% arrange(fid) %>% ungroup() 
write_csv(new.codes, OUT_CSV_NEW_CODES)  
write.csv(new.subcodes, OUT_CSV_NEW_SUBCODES)

# helpers to calculate, for each file, codes/subcodes used so far
cum.subcodes = function(curfid, data) {
  data %>% filter(fid <= curfid) %>% summarise(n_distinct(category.code.subcode)) %>% first()
}
cum.codes = function(curfid, data) {
  data %>% filter(fid <= curfid) %>% summarise(n_distinct(category.code)) %>% first()
}

# get tables of cummulative codes/subcodes
subcodes = codings %>% distinct(fid) %>% rowwise(.) %>% 
  mutate(numsubcodes = cum.subcodes(fid, codings)) %>% arrange(fid)
codes = codings %>% distinct(fid) %>% rowwise(.) %>% 
  mutate(numcodes = cum.codes(fid, codings)) %>% arrange(fid)

# plot codebook growth
plotcodes = function(data, ylab ="", main = "", labeloffset = 0.5) {
  data %>% plot(.,  
                    xlab = "Story", 
                    ylab= ylab, 
                    main = main,
                    pch = 1
                )
  text(data[[1]], data[[2]]+labeloffset, labels = data[[2]], cex = 0.6, offset = 10)
  
  # TODO: tidy this up
  text(x = mean(c(0,3.5)), y = 15, labels = "Pilot")
  abline(v = 3.5)
  text(x = mean(c(3.5,13.5)), y = 15, labels = "Wave1")
  abline(v = 13.5)
  text(x = mean(c(13.5,25.5)), y = 15, labels = "Wave2")
  abline(v = 25.5)
  text(x = mean(c(25.5, 35)), y = 15, labels = "Wave3")
}

png(paste0(OUT_SUBCODE_PLOT, ".png"), width = 600)
plotcodes(subcodes, ylab= "# codes / subcodes used", "Cummulative codes / subcodes", labeloffset = 1)
dev.off()

png(paste0(OUT_CODE_PLOT, ".png"), width = 600)
plotcodes(codes, ylab= "# codes used", "Cummulative codes")
dev.off()

# close project
closeProject()

# clean-up
rm(list = ls() %>% str_subset("code|codings"))
