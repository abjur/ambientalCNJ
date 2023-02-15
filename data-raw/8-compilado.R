path_compilado <- "data-raw/compilado/Achados TRF1 e Insper.xlsx"
tabelas <- readxl::excel_sheets(path_compilado)

dados_brutos <- purrr::map(tabelas, \(x) readxl::read_excel(path_compilado, x))

dados_brutos[[3]] <- dados_brutos[[3]] |> 
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
    identificacao,
    data = lubridate::dmy(stringr::str_extract(data, "[0-9]{2}/[0-9]{2}/[0-9]{4}")),
    texto = stringr::str_trunc(texto, 32000)
  ) |> 
  dplyr::filter(!is.na(id_processo))

ids_base1 <- dados_brutos[[1]] |> 
  dplyr::filter(stringr::str_length(id_processo) == 20) |> 
  dplyr::pull(id_processo)

ids_base2 <- dados_brutos[[2]] |> 
  janitor::clean_names() |> 
  dplyr::mutate(
    id_processo = abjutils::clean_cnj(extracoes_insper),
    id_processo = stringr::str_pad(id_processo, 20, "left", "0")
  ) |> 
  dplyr::distinct(id_processo) |> 
  dplyr::pull(id_processo)

ids_base3 <- dados_brutos[[3]] |> 
  dplyr::mutate(id_processo = abjutils::clean_cnj(id_processo)) |> 
  dplyr::distinct(id_processo) |> 
  dplyr::pull(id_processo)

todos <- list(base1 = ids_base1, base2 = ids_base2, base3 = ids_base3) |> 
  tibble::enframe() |> 
  tidyr::unnest(value)

dados_brutos[[2]] <- dados_brutos[[2]] |> 
  janitor::clean_names() |> 
  dplyr::mutate(
    id_processo = abjutils::clean_cnj(extracoes_insper),
    id_processo = stringr::str_pad(id_processo, 20, "left", "0")
  ) |> 
  dplyr::distinct(id_processo, .keep_all = TRUE)

dados_brutos[[3]] <- dados_brutos[[3]] |> 
  dplyr::distinct(id_processo, .keep_all = TRUE)

dados_arrumados <- dados_brutos

writexl::write_xlsx(dados_arrumados, "data-raw/compilado/dados_arrumados.xlsx")
