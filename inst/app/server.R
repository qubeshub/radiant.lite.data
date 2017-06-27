shinyServer(function(input, output, session) {

  ## source shared functions
	source("init.R", encoding = getOption("serenity.encoding"), local = TRUE)
	source("serenity.R", encoding = getOption("serenity.encoding"), local = TRUE)

  ## packages to use for example data
  options(serenity.example.data = "serenity.data")

	## source data & analysis tools from files in tools/app and tools/data directories
  for (file in list.files(c("tools/app","tools/data"), pattern="\\.(r|R)$", full.names = TRUE))
  	source(file, encoding = getOption("serenity.encoding"), local = TRUE)

  ## save state on refresh or browser close
  saveStateOnRefresh(session)
})
