stop("INTERATIVE - DO NOT SOURCE")

source("study1/setup.R")
openProject(RQDA_PROJECT_PATH)
##
# Data retrieval / visual inspection
##
# main tables:
View(getCodingTable())
View(filesByCodes())

# SQL tables:
codecat = RQDAQuery("select * from codecat")
codecat = codecat %>% filter(status == 1)
View(codecat)

treecode = RQDAQuery("select * from treecode")
treecode = treecode %>% filter(status == 1)
View(treecode)

code = RQDAQuery("select * from freecode")
code = code %>% filter(status == 1)
View(code)

# example: inspect to which files codes with a certain pattern are attributed to:
View(getCodingTable() %>% filter(grepl("knowledge", codename)))

##
# New codes / subcodes per story
##
codings = getCodingTable()
codings = codings %>% select(fid, codename)
# create matrix of cat / code / subcode
codings.matrix = str_split_fixed(codings$codename, "-", 3) %>% as_data_frame()
colnames(codings.matrix) = c("category", "code", "subcode")
# bind them
codings = codings %>% bind_cols(codings.matrix)
# tidy-up
codings = codings %>% mutate(category.code = paste(category, code, sep="-"),
                             category.code.subcode = codename) %>%  
  select(fid, category.code, category.code.subcode)

paste("a", "b", sep = "-")

# functions to calculate, for each file, codes/subcodes used so far
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

# plots
# subcodes
subcodes %>% plot(numsubcodes ~ fid, data = ., 
                  xlab = "Story", 
                  ylab= "# codes / subcodes used", 
                  main = "Cummulative codes / subcodes")

# add wave markers
text(x = mean(c(0,3.5)), y = 15, labels = "Pilot")
abline(v = 3.5)
text(x = mean(c(3.5,13.5)), y = 15, labels = "Wave1")
abline(v = 13.5)
text(x = mean(c(13.5,25.5)), y = 15, labels = "Wave2")
abline(v = 25.5)
text(x = mean(c(25.5, 35)), y = 15, labels = "Wave3")

# codes only
codes %>% plot(numcodes ~ fid, data = ., 
                  xlab = "Story", 
                  ylab= "# codes used", 
                  main = "Cummulative codes")

# add wave markers
text(x = mean(c(0,3.5)), y = 15, labels = "Pilot")
abline(v = 3.5)
text(x = mean(c(3.5,13.5)), y = 15, labels = "Wave1")
abline(v = 13.5)
text(x = mean(c(13.5,25.5)), y = 15, labels = "Wave2")
abline(v = 25.5)
text(x = mean(c(25.5, 35)), y = 15, labels = "Wave3")

# TODO: which were the new codes & subcodes?

###
# Clean-up
###
closeProject()
saveProjectToVault(delete = F)
