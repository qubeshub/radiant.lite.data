## Code started from https://shiny.rstudio.com/reference/shiny/latest/modalDialog.html

# Show modal when storage navPanel is clicked.
# Return the UI for a modal dialog with data selection input. If 'failed' is
# TRUE, then display a message that the previous value was invalid.
observeEvent(input$storageNav, {
  showModal(
      modalDialog(
        radioButtons(inputId = "storage_location", label = "Storage location:",
                     choiceNames = list(
                       HTML("<i class='fa fa-cloud'></i><span style='padding-left: 5px;'>QUBES</span>"),
                       HTML("<i class='fa fa-hdd-o'></i><span style='padding-left: 5px;'>Computer</span>")
                       ),
                     choiceValues = list(
                       "qubes",
                       "client"
                       ),
                     selected = state_init("storage_location", "client")),
        easyClose = TRUE,
        footer = modalButton("Dismiss")
      )
  )
})
