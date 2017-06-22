## ui for data menu in serenity
do.call(navbarPage,
  c("Serenity [under development]", getOption("serenity.nav_ui"), getOption("serenity.shared_ui"),
    help_menu("help_data_ui"))
)
