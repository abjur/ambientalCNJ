aux_foros <- function() {
  tibble::enframe(c(
    "3000" = "AC",
    "3001" = "CZU",

    "3200" = "AM",
    "3201" = "TBT",
    "3202" = "TFE",

    "3100" = "AP",
    "3101" = "LJI",
    "3102" = "OPQ",

    "3700" = "MA",
    "3703" = "BBL",
    "3704" = "BLA",
    "3702" = "CXS",
    "3701" = "ITZ",

    "3600" = "MT",
    "3605" = "BAG",
    "3601" = "CCS",
    "3604" = "DIO",
    "3606" = "JNA",
    "3602" = "ROI",
    "3603" = "SNO",

    "3900" = "PA",
    "3903" = "ATM",
    "3904" = "CAH",
    "3908" = "IAB",
    "3906" = "PGN",
    "3901" = "MBA",
    "3905" = "RDO",
    "3902" = "STM",
    "3907" = "TUU",

    "4100" = "RO",
    "4102" = "GUM",
    "4101" = "JIP",
    "4103" = "VHA",

    "4200" = "RR",

    "4300" = "TO",
    "4301" = "ARN",
    "4302" = "GUR"
  ), "id_foro", "nm_foro")

}

aux_tribunal <- function() {
  tibble::tribble(
    ~id_2dig, ~tribunal,
    "30", "TJAC",
    "31", "TJAP",
    "32", "TJAM",
    "37", "TJMA",
    "36", "TJMT",
    "39", "TJPA",
    "41", "TJRO",
    "42", "TJRR",
    "43", "TJTO"
  )
}


insist_get <- purrr::insistently(function(...) {
  r <- httr::GET(...)
  if (file.size(r$request$output$path) == 0) stop("erro")
  r
}, rate = purrr::rate_delay(10, max_times = 3))

get_proc <- function(id, dir = ".", aux_foros) {

  # Arquivos
  dir <- paste0(dir, "/", id)
  fs::dir_create(dir)
  arq_proc <- fs::path(dir, id, ext = "html")
  arq_partes <- fs::path(dir, "partes", ext = "html")

  # Base do URL
  base <- "https://processual.trf1.jus.br/consultaProcessual/"

  if (!file.exists(arq_proc)) {

    foro <- stringr::str_sub(id, -4L, -1L)
    secao <- aux_foros |>
      dplyr::filter(id_foro == foro) |>
      dplyr::pull(nm_foro)

    query <- list(
      proc = id,
      mostrarBaixados = "S",
      secao = secao,
      pg = 1,
      enviar = "Pesquisar"
    )

    insist_get(
      paste0(base, "processo.php"),
      query = query,
      httr::write_disk(arq_proc, TRUE)
    )

    # Query para pegar as partes
    gl <- "{base}arquivo/partes.php?proc={id}&secao={secao}&origem=processual"
    insist_get(
      stringr::str_glue(gl),
      httr::write_disk(arq_partes, TRUE)
    )

  }
  arq_proc
}

clean_names <- function(.data) {
  cols <- names(.data)
  cols <- stringr::str_replace_all(
    stringr::str_to_lower(abjutils::rm_accent(cols)),
    "[^[:alpha:]0-9]+", "_"
  )
  cols <- stringr::str_replace_all(cols, "\u00ba", "o")
  cols <- stringr::str_remove(cols, "_+$")
  names(.data) <- cols
  .data
}

name_repair <- function (x) {
  x |>
    stringr::str_remove("[:punct:]$") |>
    purrr::set_names() |>
    as.list() |>
    tibble::as_tibble(.name_repair = make.unique) |>
    clean_names() |>
    names()
}

parse <- function (dir) {
  stopifnot(length(dir) == 1)

  capa <- xml2::read_html(
    fs::dir_ls(dir, regexp = "partes", invert = TRUE),
    encoding = "latin1"
  )

  partes <- xml2::read_html(
    fs::dir_ls(dir, regexp = "partes"),
    encoding = "latin1"
  )

  meta <- capa |>
    xml2::xml_find_all("//div[@id='aba-processo']/table") |>
    rvest::html_table() |>
    purrr::pluck(1) |>
    purrr::set_names("key", "val") |>
    dplyr::mutate(key = name_repair(key)) |>
    tidyr::pivot_wider(names_from = key, values_from = val)

  movs <- capa |>
    xml2::xml_find_all("//div[@id='aba-movimentacao']/table") |>
    rvest::html_table() |>
    purrr::pluck(1) |>
    dplyr::as_tibble() |>
    dplyr::rename_with(name_repair)

  partes_tbl <- partes |>
    xml2::xml_find_first("//table")

  if (is.na(partes_tbl)) {
    partes <- tibble::tibble()
  } else {
    partes <- partes_tbl |>
      rvest::html_table() |>
      dplyr::as_tibble() |>
      dplyr::rename_with(name_repair)
  }

  meta |>
    dplyr::mutate(movs = list(movs), partes = list(partes))
}

