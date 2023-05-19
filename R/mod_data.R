#' data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_data_ui <- function(id){
  ns <- NS(id)
  tagList(

    shiny::fluidRow(
      bs4Dash::box(
        width = 6,
        title = "Download dos dados filtrados",
        shiny::p(
          "Você pode baixar os dados abaixo em Excel a partir ",
          "dos filtros abaixo"
        ),
        fluidRow(
          shiny::column(3,shinyWidgets::pickerInput(
            inputId = ns("base"),
            label = "Base de dados",
            choices = c(
              "SireneJud" = "sirenejud",
              "Corrupção/Lavagem" = "lavagem",
              "TRF1" = "trf1"
            ),
            selected = c("trf1"),
            multiple = TRUE,
            options = c(abjDash::picker_options(), `live-search` = FALSE)
          )),
          shiny::column(3,shinyWidgets::pickerInput(
            inputId = ns("classe"),
            label = "Tribunal",
            choices = unique(ambientalCNJ::da_dash$tribunal),
            selected = unique(ambientalCNJ::da_dash$tribunal),
            multiple = TRUE,
            options = c(abjDash::picker_options(), `live-search` = FALSE)
          )),
          shiny::column(3,shinyWidgets::pickerInput(
            inputId = ns("ano"),
            label = "Ano",
            choices = 1990:2023,
            selected = 1990:2023,
            multiple = TRUE,
            options = c(abjDash::picker_options(), `live-search` = FALSE)
          )),
          shiny::column(3,shinyWidgets::pickerInput(
            inputId = ns("grau"),
            label = "Grau",
            choices = c("G1", "G2"),
            selected = c("G1"),
            multiple = TRUE,
            options = c(abjDash::picker_options(), `live-search` = FALSE)
          ))
        ),
        shiny::downloadButton(
          ns("download"),
          "Baixar dados filtrados",
          class = "btn btn-dark"
        )
      ),
      bs4Dash::box(
        title = "Download dos dados completos",
        width = 6,
        shiny::p(
          "Se preferir, é possível acessar um link direto aos dados",
          "completos no link abaixo"
        ),
        shiny::a(
          href = "https://github.com/abjur/ambientalCNJ/releases/tag/dashboard",
          target = "_blank",
          class = "btn btn-dark",
          "Baixar dados completos"
        )
      )
    )


  )
}

#' data Server Functions
#'
#' @noRd
mod_data_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    da <- shiny::reactive({

      vcat <- list(
        "Base" = "base",
        "Tribunal" = "tribunal",
        "Ano" = "ano",
        "Grau" = "grau"
      )

      da_filtrado <- purrr::reduce(vcat, ~{
        if (length(input[[.y]]) > 0) {
          dplyr::filter(.x, .data[[.y]] %in% input[[.y]])
        } else {
          .x
        }
      }, .init = ambientalCNJ::da_dash)

      da_filtrado


    })

    output$download <- downloadHandler(
      filename = function() {
        paste("ambiental-cnj-", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        # browser()
        writexl::write_xlsx(da(), file)
      }
    )
  })
}

## To be copied in the UI
# mod_data_ui("data_1")

## To be copied in the server
# mod_data_server("data_1")
