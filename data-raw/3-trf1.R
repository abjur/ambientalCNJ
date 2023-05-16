
# Estratégia: baixar dados de palavras-chave genéricas, para processar depois.
# Palavras-chave genéricas: garimp*, minera*, desmata*

devtools::load_all()

## Processamento pesado (não rodar)

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
arqs_grilagem <- lex::trf1_cjpg_download(
  "grilagem",
  dir = "data-raw/trf1/grilagem"
)

arqs <- fs::dir_ls(
  "data-raw/trf1/",
  recurse = TRUE,
  type = "file",
  glob = "*.html"
) |>
  stringr::str_subset("cpopg", TRUE) |>
  purrr::set_names()

# arqs[2830] |>
#   # httr::BROWSE()
#   lex::trf1_cjpg_parse()

cjpg_raw <- arqs |>
  purrr::map(lex::trf1_cjpg_parse, .progress = TRUE) |>
  purrr::list_rbind(names_to = "file")

dplyr::glimpse(cjpg_raw)

readr::write_rds(cjpg_raw, "data-raw/trf1/cjpg_raw.rds")
piggyback::pb_upload("data-raw/trf1/cjpg_raw.rds", tag = "trf1", overwrite = TRUE)

# filter ------------------------------------------------------------------

# primeiro, vamos filtrar para casos que fazem parte do escopo
# da pesquisa.

foros_trf1 <- forosCNJ::da_foro |>
  dplyr::filter(id_justica == "4", id_tribunal == "01")

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
  dplyr::semi_join(aux_foros(), "id_foro") |>
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
    # !stringr::str_detect(texto, rx_habeas)
  ) |>
  dplyr::mutate(
    habeas_corpus = stringr::str_detect(texto, rx_habeas),
    habeas_corpus = dplyr::if_else(habeas_corpus, "Sim", "Não")
  ) |>
  dplyr::mutate(
    id_2dig = stringr::str_sub(id_foro, 1, 2)
  ) |>
  dplyr::inner_join(aux_tribunal(), "id_2dig")

readr::write_rds(cjpg_filter_tempo_espaco, "data-raw/trf1/cjpg_filter_tempo_espaco.rds")
readr::write_rds(cjpg_filter, "data-raw/trf1/cjpg_filter.rds")


piggyback::pb_upload(
  "data-raw/trf1/cjpg_filter_tempo_espaco.rds",
  tag = "trf1",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/trf1/cjpg_filter.rds",
  tag = "trf1",
  overwrite = TRUE
)

## upload zip
# fs::dir_ls("data-raw/trf1", glob = "*.zip") |>
#   purrr::walk(piggyback::pb_upload, tag = "dados_brutos", overwrite = TRUE)

## Processamento leve (Rodar)

da_trf1_cjpg_pequeno <- readr::read_rds("data-raw/trf1/cjpg_filter.rds") |>
  dplyr::select(-texto)

# readr::write_rds(da_trf1_cjpg_pequeno, "inst/relatorios/da_trf1_cjpg_pequeno.rds")
usethis::use_data(da_trf1_cjpg_pequeno, overwrite = TRUE)

## Amostra exportada (não rodar)

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

# export ------------------------------------------------------------------

set.seed(1)
tab_saida_trf1 <- cjpg_filter |>
  dplyr::transmute(
    id_processo,
    tribunal,
    ano,
    tema = basename(dirname(dirname(file))),
    tema = stringr::str_replace(tema, "tilde", "o"),
    tema = stringr::str_replace(tema, "cedil", "ao"),
    habeas_corpus,
    resumo = stringr::str_trunc(resumo, width = 32000),
    texto = stringr::str_trunc(texto, width = 32000)
  ) |>
  dplyr::slice_sample(prop = 1)

