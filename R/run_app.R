#' Run the Shiny Application
#'
#' @param launch Launch browser? Default: FALSE.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(launch = FALSE) {
  shiny::shinyApp(app_ui(), app_server, options = list(
    port = 4242, launch.browser = launch,
    auto.reload = TRUE
  ))
}
