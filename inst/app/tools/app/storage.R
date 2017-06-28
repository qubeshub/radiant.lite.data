## Code started from https://shiny.rstudio.com/reference/shiny/latest/modalDialog.html

# Show modal when storage navPanel is clicked.
observeEvent(input$storageNav, {
  showModal(
      modalDialog(
        radioButtons(inputId = "storage_location", label = "Storage location:",
                     choiceNames = list(
                       HTML("<i class='fa fa-cloud'></i><span style='padding-left: 5px;'>QUBES</span>"),
                       HTML("<i class='fa fa-hdd-o'></i><span style='padding-left: 5px;'>Computer</span>")
                       ),
                     choiceValues = list(
                       "server",
                       "client"
                       ),
                     selected = state_init("storage_location", "client")),
        size = c("s"),
        easyClose = TRUE,
        footer = modalButton("Dismiss")
      )
  )
})
