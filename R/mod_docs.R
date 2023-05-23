#' docs UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_docs_ui <- function(id){
  # ns <- NS(id)
  tagList(
    shiny::fluidRow(
      shiny::column(2),
      bs4Dash::box(
        collapsible = FALSE,
        width = 8,
        shiny::includeMarkdown(app_sys("docs.md"))
      )
    )
  )
}

#' docs Server Functions
#'
#' @noRd
mod_docs_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_docs_ui("docs_1")

## To be copied in the server
# mod_docs_server("docs_1")
