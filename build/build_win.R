## build for windows
# devtools::install("../radiant.lite.data")
# devtools::build("../radiant.lite.data", binary = TRUE)

## build for windows
app <- "radiant.lite.data"
path <- "../"
devtools::install(file.path(path, app))
f <- devtools::build(file.path(path, app))
curr <- getwd(); setwd(path)
system(paste0("R CMD INSTALL --build ", f))
setwd(curr)

