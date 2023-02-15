path_jusbrasil <- "data-raw/jusbrasil/Resultados jusbrasil_17-01.xlsx"

abas <- readxl::excel_sheets(path_jusbrasil)

aux_jusbrasil <- abas[2:5] |> 
  purrr::set_names() |> 
  purrr::map(\(x) readxl::read_excel(path_jusbrasil, x)) |> 
  purrr::map(purrr::set_names, "resultados") |> 
  purrr::list_rbind(names_to = "tema") |> 
  dplyr::mutate(
    id = is.na(resultados),
    id = cumsum(id) + 1
  ) |> 
  dplyr::filter(!is.na(resultados)) |> 
  dplyr::group_by(id) |> 
  dplyr::mutate(
    coluna = c("identificacao", "data", rep("texto", length(id) - 2))
  ) |> 
  dplyr::ungroup() |> 
  dplyr::filter(!stringr::str_detect(resultados, "Mudar ordem para Data")) |> 
  tidyr::pivot_wider(
    names_from = coluna, 
    values_from = resultados,
    values_fn = \(x) paste(x, collapse = "\n")
  ) |> 
  dplyr::mutate(identificacao = dplyr::coalesce(identificacao, data, texto)) |> 
  dplyr::transmute(
    id_processo = stringr::str_extract(identificacao, "[0-9/.-]{10,}"),
    tribunal = stringr::str_extract(identificacao, "[^ ]+"),
    tema,
    identificacao,
    data = lubridate::dmy(stringr::str_extract(data, "[0-9]{2}/[0-9]{2}/[0-9]{4}")),
    texto = stringr::str_trunc(texto, 32000)
  ) |> 
  dplyr::filter(!is.na(id_processo))

set.seed(1)
tab_saida_jusbrasil <- aux_jusbrasil |> 
  dplyr::slice_sample(prop = 1)


list(
  trf1 = tab_saida_trf1,
  elastic = tab_saida_diarios,
  jusbrasil = tab_saida_jusbrasil
) |> 
  writexl::write_xlsx("data-raw/amostra_trf1_elastic_jusbrasil_202301.xlsx")


