ler_coluna_json <- function(x) {
  if (is.na(x)) return(tibble::tibble())
  res <- jsonlite::fromJSON(x)
  if (length(res) == 0) return(tibble::tibble())
  if (is.data.frame(res)) res <- tibble::as_tibble(res)
  res
}

sf_amazon_dl <- function() {
  sf::st_as_sf(geobr::read_amazon(showProgress = TRUE))
}
