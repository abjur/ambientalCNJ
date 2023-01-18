
# Estratégia: baixar dados de palavras-chave genéricas, para processar depois.
# Palavras-chave genéricas: garimp*, minera*, desmata*


# download ----------------------------------------------------------------

arqs_garimpo <- lex::trf1_cjpg_download(
  "garimp*", dir = "data-raw/trf1/garimpo"
)
arqs_desmatamento <- lex::trf1_cjpg_download(
  "desmata*", 
  dir = "data-raw/trf1/desmatamento"
)
arqs_mineracao <- lex::trf1_cjpg_download(
  "minerac*", 
  dir = "data-raw/trf1/minerac"
)
arqs_mineracao <- lex::trf1_cjpg_download(
  "mineraç*", 
  dir = "data-raw/trf1/mineraccedil"
)
arqs_invasao <- lex::trf1_cjpg_download(
  "invasa*",
  dir = "data-raw/trf1/invasao"
)
arqs_invasao <- lex::trf1_cjpg_download(
  "invasã*",
  dir = "data-raw/trf1/invasatilde"
)

arqs <- fs::dir_ls(
  "data-raw/trf1/",
  recurse = TRUE,
  type = "file",
  glob = "*.html"
)

# arqs[2830] |> 
#   # httr::BROWSE()
#   lex::trf1_cjpg_parse()

cjpg_raw <- arqs |> 
  purrr::map(lex::trf1_cjpg_parse, .progress = TRUE) |> 
  purrr::list_rbind(names_to = "file")

dplyr::glimpse(cjpg_raw)

readr::write_rds(cjpg_raw, "data-raw/trf1/cjpg_raw.rds")
piggyback::pb_upload("data-raw/trf1/cjpg_raw.rds", tag = "dados_brutos", overwrite = TRUE)

# filter ------------------------------------------------------------------

# primeiro, vamos filtrar para casos que fazem parte do escopo
# da pesquisa.

foros_trf1 <- forosCNJ::da_foro |> 
  dplyr::filter(id_justica == "4", id_tribunal == "01")

aux_foros <- tibble::enframe(c(
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


cjpg_filter_tempo_espaco <- cjpg_raw |> 
  dplyr::mutate(
    id_processo = abjutils::clean_cnj(id_processo),
    id_processo = stringr::str_pad(id_processo, 20, "left", "0"),
    valido = abjutils::verify_cnj(id_processo),
    ano = stringr::str_sub(id_processo, 10, 13)
  ) |> 
  dplyr::filter(valido == "valido", ano %in% c(2012:2022)) |> 
  dplyr::mutate(id_foro = stringr::str_sub(id_processo, 17, 20)) |> 
  dplyr::left_join(foros_trf1, "id_foro") |> 
  dplyr::semi_join(aux_foros, "id_foro") |> 
  dplyr::distinct(id_processo, .keep_all = TRUE)

## Agora, a ideia é filtrar os processos que temos interesse usando 
## palavras-chave relacionadas a corrupção e lavagem de dinheiro

# ("organização criminosa" or "associação criminosa" or "quadrilha") and "lavagem"

rx_lavagem <- stringr::regex("lavagem|corrup", TRUE)
rx_crime <- stringr::regex("(organiza|associa)[cç][ãa]o criminosa|quadrilha|opera[çc][aã]o", TRUE)
rx_habeas <- stringr::regex("habeas", TRUE)

# tentar outros termos, eventualmente
## talvez nomes de operações
## ...


cjpg_filter <- cjpg_filter_tempo_espaco |> 
  dplyr::filter(
    stringr::str_detect(texto, rx_lavagem),
    stringr::str_detect(texto, rx_crime),
    !stringr::str_detect(texto, rx_habeas)
  )

readr::write_rds(cjpg_filter_tempo_espaco, "data-raw/trf1/cjpg_filter_tempo_espaco.rds")
readr::write_rds(cjpg_filter, "data-raw/trf1/cjpg_filter.rds")

piggyback::pb_upload(
  "data-raw/trf1/cjpg_filter_tempo_espaco.rds", 
  tag = "dados_brutos", 
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/trf1/cjpg_filter.rds", 
  tag = "dados_brutos", 
  overwrite = TRUE
)

## upload zip
# fs::dir_ls("data-raw/trf1", glob = "*.zip") |> 
#   purrr::walk(piggyback::pb_upload, tag = "dados_brutos", overwrite = TRUE)

# amostra -----------------------------------------------------------------

set.seed(202301)
tamanho_amostra <- 100

amostra <- cjpg_filter |> 
  dplyr::slice_sample(n = tamanho_amostra)

# leitura manual ----------------------------------------------------------

dplyr::glimpse(cjpg_filter)
cjpg_filter |> 
  dplyr::slice_sample(n = 1) |> 
  with(paste(resumo, texto, sep = "\n\n\n@@@@@@@@@@@@@@@@@@\n\n\n")) |> 
  stringr::str_view(rx_lavagem)




