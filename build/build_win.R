## build for windows
# devtools::install("../serenity.data")
# devtools::build("../serenity.data", binary = TRUE)

## build for windows
app <- "serenity.data"
path <- "../"
devtools::install(file.path(path, app))
f <- devtools::build(file.path(path, app))
curr <- getwd(); setwd(path)
system(paste0("R CMD INSTALL --build ", f))
setwd(curr)

