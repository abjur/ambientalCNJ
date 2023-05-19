#' home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_home_ui <- function(id){
  # ns <- NS(id)
  tagList(
    shiny::fluidRow(
      shiny::column(
        12,
        bs4Dash::bs4Jumbotron(
          title = "Boas vindas!",
          lead = paste(
            "Este aplicativo apresenta análises do projeto",
            "Corrupção e Lavagem de Dinheiro relacionados a Crimes Ambientais, realizado",
            "pela ABJ em parceria com o Conselho Nacional de Justiça (CNJ) e a ",
            "Associação de Magistrados Brasileiros (AMB)."
          ),
          btnName = NULL,
          href = NULL
        )
      )
    ),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Realização",
        width = 12,
        collapsible = FALSE,
        shiny::fluidRow(
          shiny::column(
            width = 4,
            shiny::a(
              href = "https://abj.org.br/", target = "_blank",
              shiny::img(
                src = "www/logo_home_abj.png",
                style = "display: block; margin: 0 auto; max-width: 60%;"
              )
            )
          ),
          shiny::column(
            width = 4,
            shiny::a(
              href = "https://cnj.jus.br", target = "_blank",
              shiny::img(
                src = "www/logocnj.png",
                style = "display: block; margin: 0 auto; max-width: 50%;"
              )
            )
          ),
          shiny::column(
            width = 4,
            shiny::a(
              href = "https://amb.com.br", target = "_blank",
              shiny::img(
                src = "www/logo_amb.jpg",
                style = "display: block; margin: 0 auto; max-width: 25%;"
              )
            )
          )
        )
      )
    )
  )
}

#' home Server Functions
#'
#' @noRd
mod_home_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_home_ui("home_1")

## To be copied in the server
# mod_home_server("home_1")
