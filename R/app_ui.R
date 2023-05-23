#' The application User-Interface
#'
#' @import shiny
#' @noRd
app_ui <- function() {

  tagList(
    golem_add_external_resources(),

    bs4Dash::dashboardPage(

      dark = NULL,

      controlbar = bs4Dash::dashboardControlbar(
        skin = "light",
        # shiny::column(12, filtros),
        disable = TRUE
      ),

      header = bs4Dash::dashboardHeader(
        title = "Ambiental CNJ",
        skin = "light",
        status = "white",
        controlbarIcon = icon("table-cells"),
        shiny::actionButton("guide", "Guia")
      ),

      # ----
      sidebar = bs4Dash::dashboardSidebar(
        skin = "light",
        status = "primary",
        title = "Ambiental CNJ",
        border = TRUE,
        compact = FALSE,
        elevation = 4,
        collapsed = FALSE,
        minified = TRUE,
        bs4Dash::bs4SidebarMenu(
          bs4Dash::bs4SidebarMenuItem(
            "Home",
            tabName = "home",
            icon = icon("home")
          ),
          bs4Dash::bs4SidebarMenuItem(
            "Análises",
            tabName = "plot",
            icon = icon("chart-simple")
          ),
          bs4Dash::bs4SidebarMenuItem(
            "Download",
            tabName = "data",
            icon = icon("database")
          ),
          bs4Dash::bs4SidebarMenuItem(
            "Documentação",
            tabName = "docs",
            icon = icon("file-lines")
          )
        )
      ),

      body = bs4Dash::dashboardBody(
        fresh::use_theme(create_theme_css()),
        bs4Dash::bs4TabItems(
          bs4Dash::bs4TabItem("home", mod_home_ui("home_1")),
          bs4Dash::bs4TabItem("plot", mod_plot_ui("plot_1")),
          bs4Dash::bs4TabItem("data", mod_data_ui("data_1")),
          bs4Dash::bs4TabItem("docs", mod_docs_ui("docs_1"))
        )

      ),

      footer = bs4Dash::dashboardFooter(
        left = shiny::a(
          href = "https://abj.org.br",
          target = "_blank", "ABJ"
        ),
        right = paste(
          format(Sys.Date(), "%Y"),
          "desenvolvido com \u2764\ufe0f pela ABJ",
          sep = " | "
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    cicerone::use_cicerone(),
    shinyjs::useShinyjs(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'ambientalCNJ'
    ),
    metathis::meta_social(
      metathis::meta(),
      title = "ABJ",
      description = "Processos de lavagem de dinheiro e crimes ambientais",
      url = "https://abjur.shinyapps.io/ambientalCNJ",
      image = "https://lab.abj.org.br/images/abj.png",
      image_alt = "Processos de lavagem de dinheiro e crimes ambientais",
      twitter_creator = "@abjurimetria",
      twitter_card_type = "summary",
      twitter_site = "@abjurimetria",
      og_type = "profile",
      og_locale = "pt_BR"
    )
  )
}

