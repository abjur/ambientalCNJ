#' Pegar tempo a partir do tidy kaplan meier
#'
#' @param d_km Tidy do modelo kaplan meier
#' @param quantile quantil
#' @param var agrupou por variável? Default `FALSE`
#'
#' @export
pegar_tempo <- function(d_km, quantile, var = FALSE) {
  if(var) {
    tempo <- d_km |>
      dplyr::mutate(
        tempo = abs(estimate - quantile)
      ) |>
      dplyr::group_by(strata) |>
      dplyr::mutate(
        eh_valor_minimo = tempo == min(tempo),
        strata = stringr::str_remove(strata, stringr::regex(".+="))
      ) |>
      dplyr::filter(eh_valor_minimo) |>
      dplyr::arrange(time) |>
      dplyr::slice(1) |>
      dplyr::ungroup() |>
      dplyr::select(strata, time)
  } else {
    tempo <- d_km |>
      dplyr::mutate(
        tempo = abs(estimate - quantile),
        eh_valor_minimo = tempo == min(tempo)
      ) |>
      dplyr::filter(eh_valor_minimo) |>
      dplyr::summarise(tempo = min(time)) |>
      dplyr::select(time = tempo)
  }
  return(tempo)
}


# arruma a base para o dashboard
da_dash <- function() {
  ambientalCNJ::da_trf1_cjpg_pequeno
}


guide <- function() {

  cicerone::Cicerone$
    new()$
    step(
      "tab-plot",
      "Gráficos",
      "Navegue pelos gráficos da pesquisa!"
    )$
    step(
      el = "controlbar-toggle",
      title = "Controles laterais",
      description = paste(
        "Selecione os valores dos filtros. ",
        "As visualizações serão atualizadas automaticamente"
      )
    )$
    step(
      "tab-data",
      "Dados",
      paste(
        "Baixe os dados filtrados ou completos",
        "para realizar suas próprias análises."
      )
    )


}

spinner <- function(el) {
  shinycssloaders::withSpinner(el, type = 6, color = "#003366")
}
