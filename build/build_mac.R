## build for mac
# devtools::install("~/gh/radiant.lite.data")
# devtools::build("~/gh/radiant.lite.data")
# devtools::build("~/gh/radiant.lite.data", binary = TRUE)

## build for mac
app <- "radiant.lite.data"
path <- "~/gh"
devtools::install(file.path(path, app))
f <- devtools::build(file.path(path, app))
curr <- getwd(); setwd(path)
system(paste0("R CMD INSTALL --build ", f))
setwd(curr)
