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


piggyback::pb_new_release(tag = "elasticsearch")
piggyback::pb_upload(
  "data-raw/elasticsearch/1. Garimpo 14 processos.csv",
  tag = "elasticsearch",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/elasticsearch/2. Desmatamento - 257 publicações.csv",
  tag = "elasticsearch",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/elasticsearch/3. Mineração - 180 publicações.csv",
  tag = "elasticsearch",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/elasticsearch/4. Invasão de terras da União - 6 publicações.csv",
  tag = "elasticsearch",
  overwrite = TRUE
)
