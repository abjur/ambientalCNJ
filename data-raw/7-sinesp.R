
path_sinesp <- "data-raw/others/sinesp.xlsx"
sheets <- readxl::excel_sheets(path_sinesp)

tabelas <- purrr::map(sheets, \(x) readxl::read_excel(path_sinesp, x))

sinesp <- tabelas |>
  purrr::set_names(sheets) |>
  purrr::list_rbind(names_to = "uf") |>
  janitor::clean_names() |>
  dplyr::mutate(ano = lubridate::year(mes_ano)) |>
  dplyr::filter(ano == 2021) |>
  dplyr::group_by(cod_ibge) |>
  dplyr::summarise(vitimas = sum(vitimas)) |>
  dplyr::transmute(id_municipio = as.character(cod_ibge), vitimas) |>
  dplyr::inner_join(
    dplyr::select(abjData::pnud_min, muni_id, ano, pop) |>
      dplyr::filter(ano == 2010),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::mutate(tx_crim = vitimas / pop * 1e5) |>
  dplyr::select(id_municipio, vitimas, tx_crim)

usethis::use_data(sinesp, overwrite = TRUE)

piggyback::pb_new_release(tag = "misc")
piggyback::pb_upload(
  "data-raw/misc/DesmatamentoMunicipios2021.txt",
  tag = "misc",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/misc/lista_de_municipios_Amazonia_Legal_2021.xlsx",
  tag = "misc",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/misc/sinesp.xlsx",
  tag = "misc",
  overwrite = TRUE
)
