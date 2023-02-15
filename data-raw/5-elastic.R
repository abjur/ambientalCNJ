da_elastic_raw <- fs::dir_ls("data-raw/elasticsearch") |> 
  purrr::map(readr::read_csv, show_col_types = FALSE) |> 
  purrr::list_rbind(names_to = "file") |> 
  janitor::clean_names() |> 
  dplyr::select(-c(score, type, index, version, nome_do_arquivo, timestamp, id)) |> 
  dplyr::filter(numero_do_processo != "-")

da_elastic_raw |> 
  dplyr::filter(numero_do_processo != "-") |> 
  dplyr::distinct(numero_do_processo)


# export ------------------------------------------------------------------

set.seed(1)
tab_saida_diarios <- da_elastic_raw |> 
  dplyr::transmute(
    id_processo = numero_do_processo,
    data = lubridate::mdy(stringr::str_extract(data, ".*(?= @)")),
    tribunal,
    tema = stringr::str_squish(stringr::str_extract(file, "(?<=[0-9]\\. )[^0-9-]+")),
    texto = stringr::str_trunc(texto_de_publicacao, 32000)
  ) |> 
  dplyr::slice_sample(prop = 1)

