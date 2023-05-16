## processamento intenso (não rodar)

devtools::load_all()

safe <- purrr::possibly(get_proc, "")

purrr::walk(
  sample(cjpg_filter_tempo_espaco$id_processo),
  get_proc,
  dir = "data-raw/trf1/cpopg",
  aux_foros = aux_foros,
  .progress = TRUE
)

folders <- fs::dir_ls("data-raw/trf1/cpopg")

da_parsed <- purrr::map(folders, parse, .progress = TRUE) |>
  purrr::list_rbind(names_to = "file")

readr::write_rds(da_parsed, "data-raw/trf1/da_trf1_cpopg.rds")


piggyback::pb_upload(
  "data-raw/trf1/da_trf1_cpopg.rds",
  tag = "dados_brutos",
  overwrite = TRUE
)

## processamento leve (Rodar)

da_trf1_cpopg <- readr::read_rds("data-raw/trf1/da_trf1_cpopg.rds") |>
  # reduzir tamanho
  dplyr::select(-movs)

usethis::use_data(da_trf1_cpopg, overwrite = TRUE)

# dplyr::glimpse(da_cpopg_parsed)
#
# da_cpopg_parsed$movs[[3]]


# tempos ------------------------------------------------------------------

da_tempo_trf1 <- da_trf1_cpopg |>
  dplyr::mutate(movs = purrr::map(
    movs,
    \(x) dplyr::mutate(x, complemento = as.character(complemento))
  )) |>
  tidyr::unnest(movs) |>
  dplyr::filter(stringr::str_detect(descricao, "BAIXA")) |>
  dplyr::group_by(file) |>
  dplyr::summarise(
    assunto = dplyr::first(assunto_da_peticao),
    dt_dist = dplyr::first(data_de_autuacao),
    dt_baixa = dplyr::first(data)
  ) |>
  dplyr::mutate(
    dt_dist = lubridate::dmy(dt_dist),
    dt_baixa = as.Date(lubridate::dmy_hms(dt_baixa)),
    st_tempo = as.numeric(dt_baixa - dt_dist) / 30.25,
    st_encerrado = 1
  ) |>
  tidyr::drop_na(st_tempo)

usethis::use_data(da_tempo_trf1, overwrite = TRUE)

piggyback::pb_upload(
  "data-raw/trf1/da_trf1_cpopg.rds",
  tag = "trf1",
  overwrite = TRUE
)

piggyback::pb_upload(
  "data-raw/trf1/cpopg.zip",
  tag = "dados_brutos",
  overwrite = TRUE
)

# amazonia ----------------------------------------------------------------

### sf amazonia (exige conexão com internet)
sf_amazon <- geobr::read_amazon(showProgress = FALSE)
usethis::use_data(sf_amazon, overwrite = TRUE, compress = "xz")
