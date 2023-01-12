
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

cjpg_raw

readr::write_rds(cjpg_raw, "data-raw/trf1/cjpg_raw.rds")
piggyback::pb_upload("data-raw/trf1/cjpg_raw.rds", tag = "dados_brutos")