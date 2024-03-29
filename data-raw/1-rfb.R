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


# CNPJ LIST (ativo) ---------------------------------------------------------------
da_partes_pj_ativo <- da_partes_sirenejud_ativo |>
  dplyr::filter(tipo_pessoa == "JURIDICA") |>
  dplyr::select(id_processo, nome, cnpj = numero_documento_principal) |>
  dplyr::mutate(
    nome = stringr::str_squish(nome),
    nome = abjutils::rm_accent(nome)
  )

da_partes_pj_cnpj_ativo <- da_partes_pj_ativo |>
  dplyr::distinct(cnpj) |>
  dplyr::filter(stringr::str_length(stringr::str_squish(cnpj)) == 14)

raiz_ativo <- da_partes_pj_cnpj_ativo |>
  with(stringr::str_sub(cnpj, 1, 8)) |>
  unique()

# download BQ (ativo) -------------------------------------------------------------

todos_estab_ativo <- tb |>
  dplyr::filter(cnpj_raiz %in% local(raiz_ativo))

todos_estab_ativo <- todos_estab_ativo |>
  dplyr::collect()

readr::write_rds(todos_estab_ativo, "data-raw/rfb/todos_estab_ativo.rds")

## Baixo processamento (rodar)

todos_estab_ativo <- readr::read_rds("data-raw/rfb/todos_estab_ativo.rds")
da_partes_sirenejud_ativo <- readr::read_rds("data-raw/sirenejud/da_partes_sirenejud_ativo.rds")

da_partes_pj_ativo <- da_partes_sirenejud_ativo |>
  dplyr::filter(tipo_pessoa == "JURIDICA") |>
  dplyr::select(id_processo, nome, cnpj = numero_documento_principal) |>
  dplyr::mutate(
    nome = stringr::str_squish(nome),
    nome = abjutils::rm_accent(nome)
  )

da_partes_pj_cnpj_ativo <- da_partes_pj_ativo |>
  dplyr::distinct(cnpj) |>
  dplyr::filter(stringr::str_length(stringr::str_squish(cnpj)) == 14)

da_rfb_ativo <- todos_estab_ativo |>
  dplyr::mutate(cnpj = paste0(cnpj_raiz, cnpj_comp, cnpj_dv)) |>
  dplyr::semi_join(da_partes_pj_cnpj_ativo, "cnpj")

readr::write_rds(da_rfb_ativo, "data-raw/rfb/da_rfb_ativo.rds")

usethis::use_data(da_rfb, overwrite = TRUE, compress = "xz")
usethis::use_data(da_rfb_ativo, overwrite = TRUE, compress = "xz")

piggyback::pb_new_release(tag = "rfb")
piggyback::pb_upload(
  "data-raw/rfb/todos_estab.rds",
  tag = "rfb",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/rfb/todos_estab_ativo.rds",
  tag = "rfb",
  overwrite = TRUE
)
