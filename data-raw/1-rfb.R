## Alto processamento e conexão BD externo (não rodar)

con <- cargueiro::bq_connect("rfb", "datajudApp")
DBI::dbListTables(con)
tb <- dplyr::tbl(con, "estabelecimento")


# CNPJ LIST ---------------------------------------------------------------
da_partes_pj <- da_partes_sirenejud |> 
  dplyr::filter(tipo_pessoa == "JURIDICA") |> 
  dplyr::select(id_processo, nome, cnpj = numero_documento_principal) |> 
  dplyr::mutate(
    nome = stringr::str_squish(nome),
    nome = abjutils::rm_accent(nome)
  )

da_partes_pj_cnpj <- da_partes_pj |> 
  dplyr::distinct(cnpj) |> 
  dplyr::filter(stringr::str_length(stringr::str_squish(cnpj)) == 14)

raiz <- da_partes_pj_cnpj |> 
  with(stringr::str_sub(cnpj, 1, 8)) |> 
  unique()

# download BQ -------------------------------------------------------------

todos_estab <- tb |>
  dplyr::filter(cnpj_raiz %in% local(raiz))

todos_estab <- todos_estab |> 
  dplyr::collect()

readr::write_rds(todos_estab, "data-raw/rfb/todos_estab.rds")

## Baixo processamento (rodar)

todos_estab <- readr::read_rds("data-raw/rfb/todos_estab.rds")
da_partes_sirenejud <- readr::read_rds("data-raw/sirenejud/da_partes_sirenejud.rds")

da_partes_pj <- da_partes_sirenejud |> 
  dplyr::filter(tipo_pessoa == "JURIDICA") |> 
  dplyr::select(id_processo, nome, cnpj = numero_documento_principal) |> 
  dplyr::mutate(
    nome = stringr::str_squish(nome),
    nome = abjutils::rm_accent(nome)
  )

da_partes_pj_cnpj <- da_partes_pj |> 
  dplyr::distinct(cnpj) |> 
  dplyr::filter(stringr::str_length(stringr::str_squish(cnpj)) == 14)

da_rfb <- todos_estab |> 
  dplyr::mutate(cnpj = paste0(cnpj_raiz, cnpj_comp, cnpj_dv)) |> 
  dplyr::semi_join(da_partes_pj_cnpj, "cnpj")

readr::write_rds(da_rfb, "data-raw/rfb/da_rfb.rds")
readr::write_rds(da_rfb, "inst/relatorios/da_rfb.rds")