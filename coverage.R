# use https://github.com/jimhester/covr
if (!require(covr)) {
 	install.packages("covr")
 	library(covr)
}

setwd("~/gh/serenity.data")

#cov <- package_coverage(type = "all")
cov <- package_coverage(type = "example")
shine(cov)

# after_success:
#   - Rscript -e 'library(covr); coveralls()'
