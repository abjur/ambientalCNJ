#' plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_plot_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(

    # texto explicativo
    shiny::fluidRow(
      bs4Dash::box(
        title = shiny::span("Análises", style = "font-size: 2em;"),
        collapsible = TRUE,
        width = 12,
        shiny::tags$p(paste0(
          "Este painel apresenta visualizações"
        )),
        shiny::tags$h3("M\u00E9tricas"),
        shiny::tags$p(
          shiny::tags$b("Índice de Litigiosidade (ILG): "),
          paste0("Mede a quantidade de processos dividida por 100.000 habitantes no município, com base no IBGE/2010")
        ),
        shiny::tags$p(
          shiny::tags$b("Desmatamento: "),
          paste0("Percentual do município desmatado")
        )
      )
    ),

    # infobox ----
    shiny::fluidRow(
      bs4Dash::bs4ValueBoxOutput(ns("card1"), width = 3) |>
        bs4Dash::tooltip("Quantidade de processos no filtro"),
      bs4Dash::bs4ValueBoxOutput(ns("card2"), width = 3) |>
        bs4Dash::tooltip("Tempo mediano das ações"),
      bs4Dash::bs4ValueBoxOutput(ns("card3"), width = 3) |>
        bs4Dash::tooltip("Correlação entre ILG e desmatamento"),
      bs4Dash::bs4ValueBoxOutput(ns("card4"), width = 3) |>
        bs4Dash::tooltip("Assunto mais comum")
    ),

    shiny::fluidRow(
      bs4Dash::box(
        id = ns("controles"),
        width = 12,
        title = "Selecione o que deseja visualizar",
        shiny::tags$h2("Base de dados"),
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
            inputId = ns("tribunal"),
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

        shiny::hr(),

        shiny::fluidRow(shiny::tags$div(shiny::actionButton(
          ns("botao_filtrar"), "EXECUTAR"
        ), align = "center"))

      )
    ),

    # primeira linha ----
    shiny::fluidRow(
      bs4Dash::tabBox(
        title = "Comarca",
        width = 6, height = "446px",
        shiny::tabPanel(
          title = "Assunto",
          spinner(reactable::reactableOutput(ns("tab_assunto")))
        ),
        shiny::tabPanel(
          title = "Classe",
          spinner(reactable::reactableOutput(ns("tab_classe")))
        )
      ),
      bs4Dash::box(
        width = 6,
        title = "Mapa",
          spinner(plotly::plotlyOutput(ns("mapa"))
        )
      )
    ),

    # segunda linha ----

    shiny::fluidRow(
      bs4Dash::box(
        title = "Tempo",
        width = 6,
        spinner(plotly::plotlyOutput(ns("tempo")))
      ),
      bs4Dash::box(
        title = "Correlação desmatamento ILG",
        width = 6,
        spinner(plotly::plotlyOutput(ns("dispersao")))
      )
    )
  )
}

#' plot Server Functions
#'
#' @noRd
mod_plot_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    shiny::observe(shinyjs::runjs(stringr::str_glue(
      'document.querySelector("#{ns("controles")} > div.card-header > div > button").click();'
    ))) |>
      shiny::bindEvent(input$botao_filtrar)

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


    }) |>
      shiny::bindEvent(input$botao_filtrar)

    validar <- shiny::reactive({
      shiny::validate(shiny::need(
        nrow(da()) > 0,
        "N\u00e3o foi poss\u00edvel gerar a visualiza\u00e7\u00e3o com os par\u00e2metros selecionados."
      ))
    })

    output$card1 <- bs4Dash::renderbs4ValueBox({

      label <- "Quantidade de processos"
      val <- scales::number(nrow(da()))
      icon <- shiny::icon("hashtag")
      status <- "primary"
      prop_lab <- NULL

      bs4Dash::valueBox(
        subtitle = label,
        value = tags$p(val, style = "font-size: 2vmax; margin-bottom: 0;"),
        icon = icon,
        color = status,
        footer = prop_lab
      )
    })

    output$card2 <- bs4Dash::renderbs4ValueBox({

      label <- "Tempo mediano"

      shiny::validate(
        shiny::need(nrow(dplyr::filter(da(), tempo > 0, tempo < 10000)) > 10, "<Sem informação>")
      )

      val <- da() |>
        dplyr::filter(tempo > 0, tempo < 10000) |>
        with(survival::survfit(survival::Surv(tempo, status) ~ 1)) |>
        broom::glance() |>
        purrr::pluck("median") |>
        magrittr::divide_by(12) |>
        abjDash::tempo_lab()

      icon <- shiny::icon("clock")
      status <- "primary"
      prop_lab <- NULL

      bs4Dash::valueBox(
        subtitle = label,
        value = tags$p(val, style = "font-size: 2vmax; margin-bottom: 0;"),
        icon = icon,
        color = status,
        footer = prop_lab
      )
    })

    output$card3 <- bs4Dash::renderbs4ValueBox({

      shiny::validate(
        shiny::need(nrow(da()) > 0, "<Sem informação>")
      )

      label <- "Correlação ILG e desmatamento"
      val <- da() |>
        dplyr::group_by(id_municipio) |>
        dplyr::summarise(
          ilg = dplyr::n() / pop[1],
          desmatado_pct = desmatado_pct[1]
        ) |>
        tidyr::drop_na() |>
        with(cor(ilg, desmatado_pct)) |>
        scales::number(accuracy = .01, decimal.mark = ",")
      icon <- shiny::icon("thumbs-up")
      status <- "primary"
      prop_lab <- NULL

      bs4Dash::valueBox(
        subtitle = label,
        value = tags$p(val, style = "font-size: 2vmax; margin-bottom: 0;"),
        icon = icon,
        color = status,
        footer = prop_lab
      )
    })

    output$card4 <- bs4Dash::renderbs4ValueBox({

      shiny::validate(
        shiny::need(nrow(da()) > 0, "<Sem informação>")
      )

      label <- "Assunto mais comum"
      val <- da() |>
        dplyr::count(assunto, sort = TRUE) |>
        with(assunto[1])
      icon <- shiny::icon("pen")
      status <- "primary"
      prop_lab <- NULL

      bs4Dash::valueBox(
        subtitle = label,
        value = tags$p(val, style = "font-size: 1vmax; margin-bottom: 0;"),
        icon = icon,
        color = status,
        footer = prop_lab
      )
    })

    output$tab_classe <- reactable::renderReactable({
      validar()
      da() |>
        dplyr::count(classe, sort = TRUE) |>
        dplyr::mutate(prop = n/sum(n)) |>
        reactable::reactable(
          list(
            classe = reactable::colDef("Classe", minWidth = 250),
            n = reactable::colDef("N", minWidth = 80),
            prop = reactable::colDef("%", format = reactable::colFormat(percent = TRUE, digits = 2), minWidth = 80)
          ),
          compact = TRUE,
          highlight = TRUE
        )

    })

    output$tab_assunto <- reactable::renderReactable({
      validar()
      da() |>
        dplyr::count(assunto, sort = TRUE) |>
        dplyr::mutate(prop = n/sum(n)) |>
        reactable::reactable(
          list(
            assunto = reactable::colDef("Assunto", minWidth = 380),
            n = reactable::colDef("N", minWidth = 80),
            prop = reactable::colDef("%", format = reactable::colFormat(percent = TRUE, digits = 2), minWidth = 80)
          ),
          compact = TRUE,
          highlight = TRUE
        )


    })

    output$mapa <- plotly::renderPlotly({

      validar()
      # browser()

      p <- da() |>
        dplyr::inner_join(
          dplyr::select(abjData::muni, id_municipio = muni_id, muni_nm),
          "id_municipio"
        ) |>
        dplyr::count(muni_nm, lon, lat) |>
        ggplot2::ggplot() +
        ggplot2::geom_sf(data = ambientalCNJ::sf_amazon) +
        ggplot2::geom_point(
          ggplot2::aes(lon, lat, size = n, alpha = n, name = muni_nm),
          colour = viridis::viridis(1,1,.2,.8)
        ) +
        ggplot2::theme_void()

      p |>
        plotly::ggplotly(tooltip = c("muni_nm", "n"))

    })

    output$tempo <- plotly::renderPlotly({
      validar()
      km_geral <- da() |>
        dplyr::filter(tempo > 0, tempo < 10000) |>
        with(survival::survfit(survival::Surv(tempo, status) ~ 1))

      # browser()

      p <- survminer::ggsurvplot(
        km_geral,
        data = da() |>
          dplyr::filter(tempo > 0, tempo < 10000),
        surv.median.line = "hv"
      )$plot +
        ggplot2::scale_colour_viridis_d(begin = .1, end = .9, option = 1) +
        ggplot2::scale_fill_viridis_d(begin = .1, end = .9, option = 1) +
        ggplot2::labs(
          x = "Tempo (meses)", y = "Sobrevivência",
          colour = "", fill = ""
        ) +
        ggplot2::theme(legend.position = "none")

      plotly::ggplotly(p)

    })

    output$dispersao <- plotly::renderPlotly({
      validar()
      p <- da() |>
        dplyr::inner_join(
          dplyr::transmute(
            abjData::muni,
            id_municipio = muni_id,
            muni_nm = paste(muni_nm, "/", uf_sigla)
          ),
          "id_municipio"
        ) |>
        dplyr::group_by(muni_nm) |>
        dplyr::summarise(
          n = dplyr::n(),
          ilg = round(dplyr::n() / dplyr::first(pop) * 1e5, 1),
          desmatado_pct = dplyr::first(desmatado_pct)
        ) |>
        ggplot2::ggplot() +
        ggplot2::aes(x = desmatado_pct, y = ilg, name = muni_nm) +
        ggplot2::geom_point(
          colour = viridis::viridis(1, 1, .2, .8)
        ) +
        # ggplot2::geom_smooth() +
        ggplot2::scale_x_continuous(labels = scales::percent) +
        ggplot2::labs(
          x = "Percentual da área desmatada",
          y = "Casos novos /\n(100.000 habitantes)"
        ) +
        ggplot2::theme_minimal()

      plotly::ggplotly(p, tooltip = c("x", "y", "muni_nm"))

    })


  })
}

## To be copied in the UI
# mod_plot_ui("plot_1")

## To be copied in the server
# mod_plot_server("plot_1")
