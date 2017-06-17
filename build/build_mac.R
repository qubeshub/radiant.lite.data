## build for mac
# devtools::install("~/gh/serenity.data")
# devtools::build("~/gh/serenity.data")
# devtools::build("~/gh/serenity.data", binary = TRUE)

## build for mac
app <- "serenity.data"
path <- "~/gh"
devtools::install(file.path(path, app))
f <- devtools::build(file.path(path, app))
curr <- getwd(); setwd(path)
system(paste0("R CMD INSTALL --build ", f))
setwd(curr)
