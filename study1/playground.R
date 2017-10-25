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
# New codes per story
##
codings = getCodingTable()
codings = codings %>% select(fid, codename)

# function to calculate, for each file, subcodes used so far
cum.subcodes = function(curfid, data) {
  data %>% filter(fid <= curfid) %>% summarise(n_distinct(codename)) %>% first()
}

# get table of cummulative codes per file
subcodes = codings %>% distinct(fid) %>% rowwise(.) %>% 
  mutate(numcodes = cum.subcodes(fid, codings)) %>% arrange(fid)

# plot
subcodes %>% plot(numcodes ~ fid, data = ., 
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

###
# Clean-up
###
closeProject()
saveProjectToVault(delete = F)
