##
# Calculate agreement scores for initial codings.
##
## TODO: Was used in first-round agreement; must be cleaned-up.

# split data for iota, which needs list of dfs per variable
# for other cases, codings.complete.wide is already well formed
data.split = 
  codings.complete.wide %>% 
  split(f = .$variable) %>% # split to list of dfs
  map(. %>% select(diogo, tiago, ivan)) # purrr magic, select is applied to each 
                                        # to remove extra cols
data.split.all = 
  data.split %>% 
  map(. %>% filter(complete.cases(.)))

data.split.r1.r2 = 
  data.split %>%
  map(. %>% select(diogo, ivan) %>% filter(complete.cases(.)))

data.split.r1.r3 = 
  data.split %>%
  map(. %>% select(diogo, tiago) %>% filter(complete.cases(.)))

# make results tables
r1.r2.spec = "Diogo vs. Ivan, initial codings"
r1.r2.agree = 
  agree(codings.complete.wide %>% select(diogo, ivan)) %>% 
  unclass() %>% 
  as_tibble()
r1.r2.kappa = 
  kappa2(codings.complete.wide %>% select(diogo, ivan)) %>%
  unclass() %>% 
  as_tibble()
r1.r2.iota = 
  iota(data.split.r1.r2, scaledata = "nominal") %>%
  unclass() %>% 
  magrittr::extract(1:5) %>% # exclude detail, which turns up NULL
  as_tibble()

r1.r2 = 
  bind_rows(r1.r2.agree, r1.r2.kappa, r1.r2.iota) %>%
  mutate(spec = r1.r2.spec) %>%
  select(spec, everything())

r1.r3.spec = "Diogo vs. Tiago, initial codings"
r1.r3.agree = 
  agree(codings.complete.wide %>% select(diogo, tiago)) %>% 
  unclass() %>% 
  as_tibble()
r1.r3.kappa = 
  kappa2(codings.complete.wide %>% select(diogo, tiago)) %>% 
  unclass() %>% 
  as_tibble()
r1.r3.iota=
  iota(data.split.r1.r3, scaledata = "nominal")  %>%
  unclass() %>% 
  magrittr::extract(1:5) %>% # exclude detail, which turns up NULL
  as_tibble()

r1.r3 = 
  bind_rows(r1.r3.agree, r1.r3.kappa, r1.r3.iota) %>%
  mutate(spec = r1.r3.spec) %>%
  select(spec, everything())

r1.r2.r3.spec = "Diogo vs. Tiago vs. Ivan, initial codings"
r1.r2.r3.agree = 
  agree(codings.complete.wide %>% select(diogo, ivan, tiago)) %>% 
  unclass() %>% 
  as_tibble()
r1.r2.r3.kappa= 
  kappam.fleiss(codings.complete.wide %>% select(diogo, ivan, tiago)) %>% 
  unclass() %>% 
  as_tibble()
r1.r2.r3.iota = 
  iota(data.split.all, scaledata = "nominal") %>%
  unclass() %>% 
  magrittr::extract(1:5) %>% # exclude detail, which turns up NULL
  as_tibble()

r1.r2.r3 = 
  bind_rows(r1.r2.r3.agree, r1.r2.r3.kappa, r1.r2.r3.iota) %>%
  mutate(spec = r1.r2.r3.spec) %>%
  select(spec, everything())

all = 
  bind_rows(r1.r2, r1.r3, r1.r2.r3)

# Output
write_csv(all, OUT_CSV_AGREEMENT_R1)

# clean-up
rm(list = ls() %>% str_subset("^r[1-3]|data|all"))
