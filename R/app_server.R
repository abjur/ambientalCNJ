#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {


  shiny::observe(guide()$init()$start()) |>
    shiny::bindEvent(input$guide)

  mod_home_server("home_1")
  mod_plot_server("plot_1")
  mod_data_server("data_1")

}

