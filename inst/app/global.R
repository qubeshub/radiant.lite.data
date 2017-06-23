# Shrink load times ----

## based on https://github.com/rstudio/shiny/issues/1237
## This is to help shrink load times.
## Might be a bug in RStudio that will be fixed in the future.
## See the above GitHub issue for more information.
suppressWarnings(
  try(
    rm("registerShinyDebugHook", envir = as.environment("tools:rstudio")),
    silent = TRUE
  )
)

# Import functions ----

## function to load/import required packages and functions
import_fs <- function(ns, libs = c(), incl = c(), excl = c()) {
  tmp <- sapply(libs, library, character.only = TRUE); rm(tmp)
  if (length(incl) != 0 || length(excl) != 0) {
    import_list <- getNamespaceImports(ns)
    if (length(incl) == 0)
      import_list[names(import_list) %in% c("base", "methods", "stats", "utils", libs, excl)] <- NULL
    else
      import_list <- import_list[names(import_list) %in% incl]
    import_names <- names(import_list)

    for (i in seq_len(length(import_list))) {
      fun <- import_list[[i]]
      lib <- import_names[[i]]
      ## replace with character.only option when new version of import is posted to CRAN
      ## https://github.com/smbache/import/issues/11
      eval(parse(text = paste0("import::from(",lib,", '",paste0(fun,collapse="', '"),"')")))
    }
  }
  invisible()
}

## import required functions and packages
import_fs("serenity.data", libs = "plotly", incl = "ggplotly")
if (!"package:serenity.data" %in% search())
  import_fs("serenity.data", libs = c("magrittr","ggplot2","lubridate","tidyr","dplyr","broom","tibble"))

# Initialize reactive data ----

init_data <- function() {

  ## Joe Cheng: "Datasets can change over time (i.e., the changedata function).
  ## Therefore, the data need to be a reactive value so the other reactive
  ## functions and outputs that depend on these datasets will know when they
  ## are changed."
  r_data <- reactiveValues()

  df_name <- getOption("serenity.init.data", default = "diamonds")
  if (file.exists(df_name)) {
    df <- load(df_name) %>% get
    df_name <- basename(df_name) %>% {gsub(paste0(".",tools::file_ext(.)),"",., fixed = TRUE)}
  } else {
    df <- data(list = df_name, package = "serenity.data", envir = environment()) %>% get
  }

  r_data[[df_name]] <- df
  r_data[[paste0(df_name, "_descr")]] <- attr(df, "description")
  r_data$datasetlist <- df_name
  r_data$url <- NULL
  r_data
}

# Local vs server ----

## Running local or on a server
# print (paste0("On server? ", ifelse(Sys.getenv('SHINY_PORT') == "", "No", "Yes")))
if (Sys.getenv('SHINY_PORT') == "") {
  options(serenity.local = TRUE)
  ## no limit to filesize locally
  options(shiny.maxRequestSize = -1)
} else {
  options(serenity.local = FALSE)
  ## limit upload filesize on server (10MB)
  options(shiny.maxRequestSize = 10 * 1024^2)
}

## Path to use for local or server use
ifelse (grepl("serenity.data", getwd()) && file.exists("../../inst") ,
        "..",
        system.file(package = "serenity.data")) %>%
  options(serenity.path.data = .)

# Encoding ----
options(serenity.encoding = "UTF-8")

# Print options ----
options(width = 250, scipen = 100)
options(max.print = max(getOption("max.print"), 5000))

# List of function arguments ----
list("n" = "length", "n_missing" = "n_missing", "n_distinct" = "n_distinct",
     "mean" = "mean_rm", "median" = "median_rm", "min" = "min_rm",
     "max" = "max_rm", "sum" = "sum_rm",
     "var" = "var_rm", "sd" = "sd_rm", "se" = "se", "cv" = "cv",
     "prop" = "prop", "varprop" = "varprop", "sdprop" = "sdprop", "seprop" = "seprop",
     "varpop" = "varpop", "sdpop" = "sdpop",
     "5%" = "p05", "10%" = "p10", "25%" = "p25", "75%" = "p75", "90%" = "p90",
     "95%" = "p95", "skew" = "skew","kurtosis" = "kurtosi") %>%
options(serenity.functions = .)

## For report and code in menu R ----

knitr::opts_knit$set(progress = TRUE)
knitr::opts_chunk$set(echo = FALSE, comment = NA, cache = FALSE,
  message = FALSE, warning = FALSE, error = TRUE, dpi = 96,
  # screenshot.force = FALSE,
  fig.path = normalizePath(tempdir(), winslash = "/"))

## Create UI ----
options(serenity.nav_ui =
  list(windowTitle = "Serenity",
       id = "nav_serenity",
       inverse = TRUE,
       collapsible = TRUE,
       tabPanel("Data",
                withMathJax(),
                uiOutput("ui_data")
                )
       )
  )

options(serenity.shared_ui =
  tagList(
    navbarMenu("R",
               tabPanel("Report",
                        uiOutput("report"),
                        icon = icon("edit")),
               tabPanel("Code",
                        uiOutput("rcode"),
                        icon = icon("code")
                        )
    ),

    navbarMenu("", icon = icon("save"),
               ## Weird icon issue:  https://groups.google.com/forum/#!topic/shiny-discuss/R88VpjRRu_U
               # This doesn't work:  tabPanel(downloadLink("saveStateNav", "Save state", icon = icon("cloud-download"))),
               tabPanel(downloadLink("saveStateNav", " Save state", class = "fa fa-download")),
               ## waiting for this feature in Shiny
               # tabPanel(tags$a(id = "loadStateNav", href = "", class = "shiny-input-container",
               #                 type='file', accept='.rmd,.Rmd,.md', list(icon("refresh"), "Refresh"))),
               # tabPanel(uploadLink("loadState", "Load state"), icon = icon("folder-open")),
               tabPanel(actionLink("shareState", "Share state", icon = icon("share"))),
               tabPanel("View state", uiOutput("view_state"), icon = icon("user")),
               HTML("<hr/>"),
               tabPanel("Storage space", uiOutput("storage_location"), icon = icon("hdd-o"))
    ),

    ## works but badly aligned in navbar
    # tabPanel(tags$a(id = "quitApp", href = "#", class = "action-button",
    #          list(icon("power-off"), ""), onclick = "window.close();")),

    ## stop app *and* close browser window
    navbarMenu("", icon = icon("power-off"),
               tabPanel(actionLink("stop_serenity", "Stop", icon = icon("stop"),
                                   onclick = "setTimeout(function(){window.close();}, 100); ")),
               if (rstudioapi::isAvailable()) {
                 tabPanel(actionLink("stop_serenity_rmd", "Stop & Report", icon = icon("stop"),
                                     onclick = "setTimeout(function(){window.close();}, 100); "))
               } else {
                 tabPanel("")
               },
               tabPanel(tags$a(id = "refresh_serenity", href = "#", class = "action-button",
                               list(icon("refresh"), "Refresh"), onclick = "window.location.reload();")),
               ## had to remove class = "action-button" to make this work
               tabPanel(tags$a(id = "new_session", href = "./", target = "_blank",
                               list(icon("plus"), "New session")
                               )
                        )
               )
    )
  )

## function to generate help, must be in global because used in ui.R
help_menu <- function(hlp) {
  tagList(
    navbarMenu("", icon = icon("question-circle"),
               tabPanel("Help", uiOutput(hlp), icon = icon("question")),
               tabPanel("Videos", uiOutput("help_videos"), icon = icon("film")),
               tabPanel("About", uiOutput("help_about"), icon = icon("info")),
               tabPanel(tags$a("", href = "https://radiant-rstats.github.io/docs/", target = "_blank",
                               list(icon("globe"), "Serenity docs"))),
               tabPanel(tags$a("", href = "https://github.com/serenity-r/serenity/issues", target = "_blank",
                               list(icon("github"), "Report issue")))
    ),
    tags$head(
      tags$script(src = "js/session.js"),
      tags$script(src = "js/returnTextAreaBinding.js"),
      tags$script(src = "js/returnTextInputBinding.js"),
      tags$script(src = "js/video_reset.js"),
      tags$script(src = "js/message-handler.js"),
      tags$script(src = "js/run_return.js"),
      # tags$script(src = "js/draggable_modal.js"),
      tags$link(rel = "shortcut icon", href = "imgs/icon.png")
    )
  )
}

# Session info ----

## environment to hold session information
r_sessions <- new.env(parent = emptyenv())

## create directory to hold session files
file.path(normalizePath("~"),"serenity.sessions") %>% {if (!file.exists(.)) dir.create(.)}

## adding the figures path to avoid making a copy of all figures in www/figures
addResourcePath("figures", file.path(getOption("serenity.path.data"), "app/tools/help/figures/"))
addResourcePath("imgs", file.path(getOption("serenity.path.data"), "app/www/imgs/"))
addResourcePath("js", file.path(getOption("serenity.path.data"), "app/www/js/"))

options(serenity.mathjax.path = "https://cdn.mathjax.org/mathjax/latest")

# using mathjax bundeled with Rstudio if available
# if (Sys.getenv("RMARKDOWN_MATHJAX_PATH") == "") {
#   options(serenity.mathjax.path = "https://cdn.mathjax.org/mathjax/latest")
# } else {
#   options(serenity.mathjax.path = Sys.getenv("RMARKDOWN_MATHJAX_PATH"))
# }

# withMathJaxR <- function (...)  {
#   path <- paste0(getOption("serenity.mathjax.path"),"/MathJax.js?config=TeX-AMS-MML_HTMLorMML")
#   tagList(tags$head(singleton(tags$script(src = path, type = "text/javascript"))),
#           ..., tags$script(HTML("if (window.MathJax) MathJax.Hub.Queue([\"Typeset\", MathJax.Hub]);")))
# }

## copy-right text
options(serenity.help.cc = "&copy; M. Drew LaMar (2017) <a rel='license' href='http://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank'><img alt='Creative Commons License' style='border-width:0' src ='imgs/80x15.png' /></a></br>")

# URL processing to share results ----

## relevant links
# http://stackoverflow.com/questions/25306519/shiny-saving-url-state-subpages-and-tabs/25385474#25385474
# https://groups.google.com/forum/#!topic/shiny-discuss/Xgxq08N8HBE
# https://gist.github.com/jcheng5/5427d6f264408abf3049

## try http://127.0.0.1:3174/?url=multivariate/conjoint/plot/&SSUID=local
options(serenity.url.list =
  list("Data" = list("tabs_data" = list("Manage"    = "data/",
                                        "View"      = "data/view/",
                                        "Visualize" = "data/visualize/",
                                        "Pivot"     = "data/pivot/",
                                        "Explore"   = "data/explore/",
                                        "Transform" = "data/transform/",
                                        "Combine"   = "data/combine/"))
  ))

make_url_patterns <- function(url_list = getOption("serenity.url.list"),
                              url_patterns = list()) {
  for (i in names(url_list)) {
    res <- url_list[[i]]
    if (!is.list(res)) {
      url_patterns[[res]] <- list("nav_serenity" = i)
    } else {
      tabs <- names(res)
      for (j in names(res[[tabs]])) {
        url <- res[[tabs]][[j]]
        url_patterns[[url]] <- setNames(list(i,j), c("nav_serenity",tabs))
      }
    }
  }
  url_patterns
}

## generate url patterns
options(serenity.url.patterns = make_url_patterns())

## Installed packages versions ----
tmp <- grep("serenity.", installed.packages()[,"Package"], value = TRUE)
if ("serenity" %in% installed.packages()) tmp <- c("serenity" = "serenity", tmp)

serenity.versions <- "Unknown"
if (length(tmp) > 0)
  serenity.versions <- sapply(names(tmp), function(x) paste(x, paste(packageVersion(x), sep = ".")))

options(serenity.versions = paste(serenity.versions, collapse = ", "))
rm(tmp, serenity.versions)
