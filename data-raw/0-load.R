## Base antiga do SireneJud

# da <- readr::read_csv("Datajud.csv", lazy = TRUE)
#
#
#
# da |>
#   dplyr::select(FID, dplyr::starts_with("partes")) |>
#   dplyr::glimpse()
#
# da_basicas <- da |>
#   dplyr::mutate(
#     lat = readr::parse_number(stringr::str_extract(geom, "(?<=\\()[^ ]+")),
#     lon = readr::parse_number(stringr::str_extract(geom, "(?<=[0-9] )[^)]+"))
#   ) |>
#   dplyr::mutate(
#     co_assunto = purrr::map(co_assunto, ler_coluna_json),
#     noassuntos = purrr::map(noassuntos, ler_coluna_json)
#   ) |>
#   dplyr::transmute(
#     id = FID,
#     id_processo = numprocess,
#     trib_esfera = esfera,
#     trib_tribunal = tribunal,
#     trib_porte = porte_tribunal_nome,
#     trib_co_orgao = cod_orgao,
#     trib_nm_orgao = orgaojulgador,
#     loc_uf = uf,
#     loc_muni = municipio,
#     loc_lat = lat,
#     loc_lon = lon,
#     sgt_nm_classe = classe,
#     sgt_nm_assunto = noassuntos,
#     sgt_co_assunto = co_assunto,
#     sgt_complexo = complex_assunto == "complex",
#     dt_novo = dt_inicio_situacao_novo,
#     dt_julgado = dt_inicio_situacao_julgado,
#     dt_baixado = dt_inicio_situacao_baixado,
#     st_grau = grau,
#     st_tempo = tempo_tramitacao,
#     st_encerrado = as.numeric(flg_julgamento == "Concluído")
#   )
#
# readr::write_rds(da_basicas, "da_basicas.rds")
#
# da_partes <- da |>
#   dplyr::transmute(
#     id = FID,
#     partes = purrr::map(partes_pa_list, ler_coluna_json)
#   ) |>
#   tidyr::unnest(partes) |>
#   janitor::clean_names()
#
# readr::write_rds(da_partes, "da_partes.rds")


# ambiental datajud -------------------------------------------------------

# sirenejud novo ----------------------------------------------------------

## Alto processamento (não rodar)

da_raw <- readr::read_csv2(
  "data-raw/sirenejud/datajud_new_261022.csv",
  lazy = TRUE, n_max = 100,
  locale = readr::locale(encoding = "UTF-8")
)

da_basicas <- da_raw |>
  # dplyr::mutate(
  #   lat = readr::parse_number(stringr::str_extract(geom, "(?<=\\()[^ ]+")),
  #   lon = readr::parse_number(stringr::str_extract(geom, "(?<=[0-9] )[^)]+"))
  # ) |>
  dplyr::mutate(
    co_assunto = purrr::map(co_assunto, ler_coluna_json),
    noassuntos = purrr::map(noassuntos, ler_coluna_json)
  ) |>
  dplyr::transmute(
    # id = geom,
    # id = FID,
    id_processo = numprocess,
    trib_esfera = esfera,
    trib_tribunal = tribunal,
    trib_porte = porte_tribunal_nome,
    trib_co_orgao = cod_orgao,
    trib_nm_orgao = orgaojulgador,
    loc_uf = uf,
    loc_muni = municipio,
    # loc_lat = lat,
    # loc_lon = lon,
    sgt_nm_classe = classe,
    sgt_nm_assunto = noassuntos,
    sgt_co_assunto = co_assunto,
    sgt_complexo = complex_assunto == "complex",
    dt_novo = dt_inicio_situacao_novo,
    dt_julgado = dt_inicio_situacao_julgado,
    dt_baixado = dt_inicio_situacao_baixado,
    st_grau = grau,
    st_tempo = tempo_tramitacao,
    st_encerrado = as.numeric(flg_julgamento == "Concluído")
  )

readr::write_rds(da_basicas, "data-raw/sirenejud/da_basicas.rds")

da_partes_sirenejud <- da_raw |>
  dplyr::semi_join(da_basicas_amazon, c("numprocess" = "id_processo")) |>
  dplyr::transmute(
    id_processo = numprocess,
    partes = purrr::map(partes_pa_list, ler_coluna_json, .progress = TRUE)
  ) |>
  tidyr::unnest(partes) |>
  janitor::clean_names()

da_partes_sirenejud_ativo <- da_raw |>
  dplyr::semi_join(da_basicas_amazon, c("numprocess" = "id_processo")) |>
  dplyr::transmute(
    id_processo = numprocess,
    partes = purrr::map(partes_at_list, ler_coluna_json, .progress = TRUE)
  ) |>
  tidyr::unnest(partes) |>
  janitor::clean_names()

readr::write_rds(da_partes_sirenejud, "data-raw/sirenejud/da_partes_sirenejud.rds")
readr::write_rds(da_partes_sirenejud, "inst/relatorios/assets/rds/da_partes_sirenejud.rds")
readr::write_rds(da_partes_sirenejud_ativo, "data-raw/sirenejud/da_partes_sirenejud_ativo.rds")
readr::write_rds(da_partes_sirenejud_ativo, "inst/relatorios/assets/rds/da_partes_sirenejud_ativo.rds")

piggyback::pb_new_release(tag = "sirenejud")
piggyback::pb_upload(
  "data-raw/sirenejud/da_basicas.rds",
  tag = "sirenejud",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/sirenejud/da_partes_sirenejud.rds",
  tag = "sirenejud",
  overwrite = TRUE
)
piggyback::pb_upload(
  "data-raw/sirenejud/da_partes_sirenejud_ativo.rds",
  tag = "sirenejud",
  overwrite = TRUE
)

## Baixo processamento (rodar)

da_basicas <- readr::read_rds("data-raw/sirenejud/da_basicas.rds")

amazon <- c("AC", "AM", "RR", "AP", "PA", "MA", "TO", "RO", "MT")
## area dos municipios na amazonia legal
am_legal <- "data-raw/misc/lista_de_municipios_Amazonia_Legal_2021.xlsx" |>
readxl::read_excel() |>
  janitor::clean_names() |>
  dplyr::transmute(
    id_municipio = as.character(cd_mun),
    area = area_int
  )

desmatamento <- "data-raw/misc/DesmatamentoMunicipios2021.txt" |>
  readr::read_csv() |>
  janitor::clean_names() |>
  dplyr::mutate(desmatado_pct = desmatado2021/area_km2) |>
  dplyr::transmute(
    id_municipio = as.character(cod_ibge),
    area_prodes = area_km2,
    desmatado = desmatado2021,
    desmatado_pct
  ) |>
  dplyr::distinct(id_municipio, .keep_all = TRUE)

da_basicas_amazon <- da_basicas |>
  dplyr::filter(
    !sgt_nm_classe %in% c("Termo Circunstanciado", "Inquérito Policial"),
    st_grau == "G1"
  ) |>
  dplyr::filter(loc_uf %in% c(amazon)) |>
  munifacil::limpar_colunas(loc_muni, loc_uf) |>
  munifacil::incluir_codigo_ibge(diagnostico = FALSE) |>
  dplyr::left_join(
    dplyr::select(abjData::muni, muni_id),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(
    dplyr::select(abjData::pnud_min, muni_id, ano, pop) |>
      dplyr::filter(ano == 2010),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(am_legal, "id_municipio") |>
  dplyr::left_join(desmatamento, "id_municipio")


readr::write_rds(da_basicas_amazon, "inst/relatorios/assets/rds/da_sirenejud.rds")

piggyback::pb_upload(
  "inst/relatorios/assets/rds/da_sirenejud.rds",
  tag = "sirenejud",
  overwrite = TRUE
)

## Segundo grau SireneJud

da_basicas <- readr::read_rds("data-raw/sirenejud/da_basicas.rds")

da_basicas_amazon <- da_basicas |>
  dplyr::filter(
    !sgt_nm_classe %in% c("Termo Circunstanciado", "Inquérito Policial"),
    st_grau == "G2"
  ) |>
  dplyr::filter(loc_uf %in% c(amazon)) |>
  munifacil::limpar_colunas(loc_muni, loc_uf) |>
  munifacil::incluir_codigo_ibge(diagnostico = FALSE) |>
  dplyr::left_join(
    dplyr::select(abjData::muni, muni_id),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(
    dplyr::select(abjData::pnud_min, muni_id, ano, pop) |>
      dplyr::filter(ano == 2010),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(am_legal, "id_municipio") |>
  dplyr::left_join(desmatamento, "id_municipio")


readr::write_rds(da_basicas_amazon, "inst/relatorios/assets/rds/da_sirenejud_2grau.rds")

piggyback::pb_upload(
  "inst/relatorios/assets/rds/da_sirenejud_2grau.rds",
  tag = "sirenejud",
  overwrite = TRUE
)

# corrupcao ---------------------------------------------------------------

## Alto processamento (não rodar)

arqs_corrup <- fs::dir_ls("data-raw/corrupcao/", glob = "*.csv", recurse = TRUE)

ler <- function(x) {
  # message(x)
  readr::read_csv2(
    x,
    col_types = readr::cols(.default = readr::col_character()),
    lazy = TRUE,
    show_col_types = FALSE,
    locale = readr::locale(grouping_mark = ".", decimal_mark = ",")
  )
}

tictoc::tic()
da_corrup <- arqs_corrup |>
  purrr::map(ler) |>
  dplyr::bind_rows(.id = "file")
tictoc::toc()

readr::write_rds(da_corrup, "data-raw/corrupcao/da_corrup.rds")

da_corrup <- readr::read_rds("data-raw/corrupcao/da_corrup.rds")

pegar_infos_json <- function(json_file) {
  rds_file <- fs::path_ext_set(json_file, ".rds")
  rds_file <- paste0("data-raw/corrupcao/datajud_chunk/", basename(rds_file))
  lista <- jsonlite::read_json(json_file, simplifyDataFrame = TRUE)[["_source"]]
  dados_basicos <- lista |>
    dplyr::select(-movimento) |>
    janitor::clean_names() |>
    tibble::as_tibble() |>
    dplyr::rename(grau_info = grau) |>
    tidyr::unnest(dados_basicos)
  # salva arquivo menor
  readr::write_rds(dados_basicos, rds_file)
  # deleta arquivo grande
  fs::file_delete(json_file)
}
arqs_datajud <- fs::dir_ls("data-raw/corrupcao/enccla-cnj/enccla-cnj/datajud/datajud")
purrr::walk(arqs_datajud, pegar_infos_json, .progress = TRUE)



piggyback::pb_new_release(tag = "corrupcao")

## Muito grande
# piggyback::pb_upload(
#   "data-raw/corrupcao/da_corrup.rds",
#   tag = "corrupcao",
#   overwrite = TRUE
# )


da_corrup_select <- da_corrup |>
  dplyr::select(
    file,
    indice,
    id,
    sigla = siglaTribunal,
    grau,
    classes = classesProcessuais,
    numero,
    assuntos,
    dt_dist = mov_1st_recebimento_dataHora,
    orgao_julgador = orgaoJulgador_codigoOrgao,
    eletronico = procEl,
    polo_at_count,
    polo_at_juridica_count,
    polo_pa_count,
    polo_pa_juridica_count,
    mov_count,
    dt_baixa = mov_1st_julgamento_dataHora
  )

readr::write_rds(da_corrup_select, "data-raw/corrupcao/da_corrup_select.rds")

piggyback::pb_upload(
  "data-raw/corrupcao/da_corrup_select.rds",
  tag = "corrupcao",
  overwrite = TRUE
)

## Baixo processamento (rodar)

da_corrup_select <- readr::read_rds("data-raw/corrupcao/da_corrup_select.rds")

rx_assuntos_drogas <- c(
  "3372|11355|5566|3553|3417|3614|5885|5895|5896|9860|5901|9862|5900"
)

da_corrup_orgaos <- da_corrup_select |>
  dplyr::mutate(orgao_julgador = as.numeric(orgao_julgador)) |>
  dplyr::semi_join(
    da_sirenejud,
    c("orgao_julgador" = "trib_co_orgao")
  ) |>
  dplyr::distinct(numero, .keep_all = TRUE) |>
  dplyr::filter(!classes %in% c("[278]", "[279]")) |>
  dplyr::filter(!stringr::str_detect(assuntos, rx_assuntos_drogas)) |>
  dplyr::filter(grau == "G1") |>
  dplyr::mutate(
    assuntos = stringr::str_extract(assuntos, "[0-9, ]+")
  ) |>
  tidyr::separate_wider_delim(
    cols = assuntos,
    names = c("codigo", "assunto2"),
    delim = ", ",
    too_few = "align_start",
    too_many = "merge",
  ) |>
  dplyr::left_join(
    dplyr::distinct(abjData::assuntos, codigo, .keep_all = TRUE),
    c("codigo")
  ) |>
  dplyr::mutate(
    dplyr::across(
      dplyr::starts_with("assunto_nome"),
      \(x) dplyr::na_if(x, y = "-")
    ),
    assunto = dplyr::coalesce(
      assunto_nome6, assunto_nome5,
      assunto_nome4, assunto_nome3,
      assunto_nome2, assunto_nome1
    )
  ) |>
  dplyr::mutate(
    pd_seq_orgao  = as.character(orgao_julgador)
  ) |>
  dplyr::left_join(obsCIEE::varas, "pd_seq_orgao") |>
  dplyr::left_join(abjData::muni, c("id_municipio" = "muni_id")) |>
  dplyr::left_join(
    abjData::pnud_min |>
      dplyr::filter(ano == 2010) |>
      dplyr::select(muni_id, pop),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(am_legal, "id_municipio") |>
  dplyr::mutate(
    dt_baixa = as.Date(lubridate::ymd_hms(dt_baixa)),
    dt_dist = as.Date(lubridate::ymd_hms(dt_dist)),
    st_encerrado = !is.na(dt_baixa),
    dt_baixa_complete = dplyr::if_else(
      st_encerrado, dt_baixa, as.Date("2022-12-07")
    ),
    st_tempo = as.numeric(dt_baixa_complete - dt_dist) / 30.25,
    st_tempo = dplyr::if_else(st_tempo < 0, NA_real_, st_tempo)
  ) |>
  dplyr::left_join(desmatamento, "id_municipio")

readr::write_rds(da_corrup_orgaos, "inst/relatorios/assets/rds/da_datajud.rds")

piggyback::pb_upload(
  "inst/relatorios/assets/rds/da_datajud.rds",
  tag = "corrupcao",
  overwrite = TRUE
)

## Segundo grau DataJud

da_corrup_select <- readr::read_rds("data-raw/corrupcao/da_corrup_select.rds")

rx_assuntos_drogas <- "3372|11355|5566|3553|3417|3614|5885|5895|5896|9860|5901|9862|5900"

da_corrup_orgaos <- da_corrup_select |>
  dplyr::mutate(orgao_julgador = as.numeric(orgao_julgador)) |>
  dplyr::filter(
    grau == "G2",
    sigla %in% paste0("TJ", amazon)
  ) |>
  dplyr::distinct(numero, .keep_all = TRUE) |>
  dplyr::filter(!classes %in% c("[278]", "[279]")) |>
  dplyr::filter(!stringr::str_detect(assuntos, rx_assuntos_drogas)) |>
  dplyr::mutate(
    assuntos = stringr::str_extract(assuntos, "[0-9, ]+")
  ) |>
  tidyr::separate_wider_delim(
    cols = assuntos,
    names = c("codigo", "assunto2"),
    delim = ", ",
    too_few = "align_start",
    too_many = "merge",
  ) |>
  dplyr::left_join(
    dplyr::distinct(abjData::assuntos, codigo, .keep_all = TRUE),
    c("codigo")
  ) |>
  dplyr::mutate(
    dplyr::across(
      dplyr::starts_with("assunto_nome"),
      \(x) dplyr::na_if(x, y = "-")
    ),
    assunto = dplyr::coalesce(
      assunto_nome6, assunto_nome5,
      assunto_nome4, assunto_nome3,
      assunto_nome2, assunto_nome1
    )
  ) |>
  dplyr::mutate(
    pd_seq_orgao  = as.character(orgao_julgador)
  ) |>
  dplyr::left_join(obsCIEE::varas, "pd_seq_orgao") |>
  dplyr::left_join(abjData::muni, c("id_municipio" = "muni_id")) |>
  dplyr::left_join(
    abjData::pnud_min |>
      dplyr::filter(ano == 2010) |>
      dplyr::select(muni_id, pop),
    c("id_municipio" = "muni_id")
  ) |>
  dplyr::left_join(am_legal, "id_municipio") |>
  dplyr::mutate(
    dt_baixa = as.Date(lubridate::ymd_hms(dt_baixa)),
    dt_dist = as.Date(lubridate::ymd_hms(dt_dist)),
    st_encerrado = !is.na(dt_baixa),
    dt_baixa_complete = dplyr::if_else(
      st_encerrado, dt_baixa, as.Date("2022-12-07")
    ),
    st_tempo = as.numeric(dt_baixa_complete - dt_dist) / 30.25,
    st_tempo = dplyr::if_else(st_tempo < 0, NA_real_, st_tempo)
  ) |>
  dplyr::left_join(desmatamento, "id_municipio")

readr::write_rds(da_corrup_orgaos, "inst/relatorios/assets/rds/da_datajud_2grau.rds")

piggyback::pb_upload(
  "inst/relatorios/assets/rds/da_datajud_2grau.rds",
  tag = "corrupcao",
  overwrite = TRUE
)

# amostra de processos ----------------------------------------------------

## Amostra antiga

# da_corrup_select |>
#   dplyr::filter(
#     sigla %in% c(paste0("TJ", amazon), "TRF1"),
#     grau %in% c("G1", "G2")
#   ) |>
#   dplyr::glimpse()


# da_completa <- da_corrup_orgaos |>
#   dplyr::transmute(
#     origem = "datajud_lavagem",
#     id_processo = numero,
#     tribunal = sigla
#   ) |>
#   dplyr::distinct(id_processo, .keep_all = TRUE) |>
#   dplyr::bind_rows(
#     dplyr::transmute(
#       da_basicas_amazon,
#       origem = "sirenejud",
#       id_processo,
#       tribunal = trib_tribunal
#     ) |>
#       dplyr::distinct(id_processo, .keep_all = TRUE)
#   )
#
# set.seed(1)
#
# amostra <- da_completa |>
#   dplyr::group_by(origem, tribunal) |>
#   dplyr::slice_sample(n = 10) |>
#   dplyr::ungroup()
#
# writexl::write_xlsx(amostra, "data-raw/export/amostra_20221128_datajud_lavagem_sirenejud.xlsx")


