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

safe <- purrr::possibly(get_proc, "")

purrr::walk(
  sample(cjpg_filter_tempo_espaco$id_processo), 
  get_proc,
  dir = "data-raw/trf1/cpopg", 
  aux_foros = aux_foros,
  .progress = TRUE
)

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
    lex:::xml_table() |> 
    purrr::pluck(1) |> 
    purrr::set_names("key", "val") |> 
    dplyr::mutate(key = lex:::name_repair(key)) |> 
    tidyr::pivot_wider(names_from = key, values_from = val)
  
  movs <- capa |> 
    xml2::xml_find_all("//div[@id='aba-movimentacao']/table") |> 
    lex:::xml_table() |> 
    purrr::pluck(1) |> 
    dplyr::as_tibble() |> 
    dplyr::rename_with(lex:::name_repair)
  
  partes_tbl <- partes |> 
    xml2::xml_find_first("//table")
  
  if (is.na(partes_tbl)) {
    partes <- tibble::tibble()
  } else {
    partes <- partes_tbl |> 
      lex:::xml_table() |> 
      dplyr::as_tibble() |> 
      dplyr::rename_with(lex:::name_repair)
  }
  
  meta |> 
    dplyr::mutate(movs = list(movs), partes = list(partes))
}

folders <- fs::dir_ls("data-raw/trf1/cpopg")

da_parsed <- purrr::map(folders, parse, .progress = TRUE) |> 
  purrr::list_rbind(names_to = "file")

readr::write_rds(da_parsed, "data-raw/trf1/da_cpopg_parsed.rds")

da_parsed

piggyback::pb_upload(
  "data-raw/trf1/da_cpopg_parsed.rds", 
  tag = "dados_brutos", 
  overwrite = TRUE
)

da_cpopg_parsed

dplyr::glimpse(da_cpopg_parsed)

da_cpopg_parsed$movs[[3]]
