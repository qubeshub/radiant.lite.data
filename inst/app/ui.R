## ui for data menu in radiant-lite
do.call(navbarPage,
  c("Radiant Lite", getOption("radiant.nav_ui"), getOption("radiant.shared_ui"),
    help_menu("help_data_ui"))
)
