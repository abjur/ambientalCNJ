
da <- readr::read_csv("Datajud.csv", lazy = TRUE)

ler_coluna_json <- function(x) {
  if (is.na(x)) return(tibble::tibble())
  res <- jsonlite::fromJSON(x)
  if (length(res) == 0) return(tibble::tibble())
  if (is.data.frame(res)) res <- tibble::as_tibble(res)
  res
}


da |> 
  dplyr::select(FID, dplyr::starts_with("partes")) |> 
  dplyr::glimpse()

da_basicas <- da |> 
  dplyr::mutate(
    lat = readr::parse_number(stringr::str_extract(geom, "(?<=\\()[^ ]+")),
    lon = readr::parse_number(stringr::str_extract(geom, "(?<=[0-9] )[^)]+"))
  ) |> 
  dplyr::mutate(
    co_assunto = purrr::map(co_assunto, ler_coluna_json),
    noassuntos = purrr::map(noassuntos, ler_coluna_json)
  ) |> 
  dplyr::transmute(
    id = FID,
    id_processo = numprocess,
    trib_esfera = esfera,
    trib_tribunal = tribunal,
    trib_porte = porte_tribunal_nome,
    trib_co_orgao = cod_orgao,
    trib_nm_orgao = orgaojulgador,
    loc_uf = uf,
    loc_muni = municipio,
    loc_lat = lat, 
    loc_lon = lon,
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

readr::write_rds(da_basicas, "da_basicas.rds")

da_partes <- da |> 
  dplyr::transmute(
    id = FID,
    partes = purrr::map(partes_pa_list, ler_coluna_json)
  ) |> 
  tidyr::unnest(partes) |> 
  janitor::clean_names()

readr::write_rds(da_partes, "da_partes.rds")



# da_partes |> 
#   dplyr::glimpse()
# 
# 
# da$partes_at_list[1] |> ler_coluna_json()
# 
# da$partes_at_desc[1]
# 
# da |> 
#   dplyr::filter(grau == "G2") |> 
#   with(movimento) |> 
#   head() |> 
#   purrr::map(ler_coluna_json) |> 
#   dplyr::last() |> 
#   dplyr::glimpse() |> 
#   dplyr::count(sigla_grau)
# 
# da
# 
# 
# 
# 
# dplyr::glimpse(da)
# 
# head(da$FID, 20)
# 
# # tem duplicatas nos numeros de processo
# length(unique(da$numprocess))
# 
# 
# 
# da |> 
#   dplyr::count(partes_pa_desc)
# 
# da |> 
#   with(co_assunto) |> 
#   purrr::map(ler_coluna_json) |> 
#   purrr::map_int(length) |> 
#   table()
#   
# 
# da |> 
#   head(10) |> 
#   with(movimento) |> 
#   purrr::map(ler_coluna_json) |> 
#   dplyr::first() |> 
#   dplyr::glimpse()
# 
# da |> 
#   dplyr::filter(complex_assunto == "complex") |> 
#   View()


# ambiental datajud -------------------------------------------------------


# sirenejud novo ----------------------------------------------------------

da_raw <- readr::read_csv2(
  "data-raw/sirenejud/datajud_new_261022.csv", 
  lazy = TRUE,
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



readr::write_rds(da_basicas, "data-raw/da_basicas.rds")

amazon <- c("AC", "AM", "RR", "AP", "PA", "MA", "TO", "RO", "MT")

am_legal <- readxl::read_excel("data-raw/others/lista_de_municipios_Amazonia_Legal_2021.xlsx") |> 
  janitor::clean_names() |> 
  dplyr::transmute(
    id_municipio = as.character(cd_mun),
    area = area_int
  )

da_basicas_amazon <- da_basicas |> 
  dplyr::filter(
    !sgt_nm_classe %in% c("Termo Circunstanciado", "Inquérito Policial"),
    st_grau == "G1"
  ) |> 
  dplyr::filter(loc_uf %in% c(amazon)) |> 
  munifacil::limpar_colunas(loc_muni, loc_uf) |> 
  munifacil::incluir_codigo_ibge(diagnostico = FALSE) |> 
  dplyr::left_join(
    dplyr::select(abjData::muni, muni_id, loc_lon = lon, loc_lat = lat), 
    c("id_municipio" = "muni_id")
  ) |> 
  dplyr::left_join(
    dplyr::select(abjData::pnud_min, muni_id, ano, pop) |> 
      dplyr::filter(ano == 2010), 
    c("id_municipio" = "muni_id")
  ) |> 
  dplyr::left_join(am_legal, "id_municipio")


da_partes_sirenejud <- da_raw |> 
  dplyr::semi_join(da_basicas_amazon, c("numprocess" = "id_processo")) |> 
  dplyr::transmute(
    id_processo = numprocess, 
    partes = purrr::map(partes_pa_list, ler_coluna_json, .progress = TRUE)
  ) |> 
  tidyr::unnest(partes) |> 
  janitor::clean_names()

readr::write_rds(da_partes_sirenejud, "data-raw/da_partes_sirenejud.rds")
readr::write_rds(da_basicas_amazon, "relatorios/da_basicas_amazon.rds")

# corrupcao ---------------------------------------------------------------

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


readr::write_rds(da_corrup, "data-raw/da_corrup.rds")

da_corrup_select |> 
  dplyr::filter(orgao_julgador == "3644")

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
    dt_baixa = mov_last_baixa_dataHora
  )

readr::write_rds(da_corrup_select, "data-raw/da_corrup_select.rds")

rx_assuntos_drogas <- "3372|11355|11346|5566|9864|3553|3417|11315|3614|3548|5897|3608|3607|9859|5899|5898|5894|9858|9866|10987|5885|9861|5895|9865|5896|9860|5901|9862|9971|5900"
da_corrup_orgaos <- da_corrup_select |> 
  dplyr::mutate(orgao_julgador = as.numeric(orgao_julgador)) |> 
  dplyr::semi_join(
    da_basicas_amazon, 
    c("orgao_julgador" = "trib_co_orgao")
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
    dt_baixa_complete = dplyr::if_else(st_encerrado, dt_baixa, as.Date("2022-12-07")),
    st_tempo = as.numeric(dt_baixa_complete - dt_dist) / 30.25,
    st_tempo = dplyr::if_else(st_tempo < 0, NA_real_, st_tempo)
  )



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

# writexl::write_xlsx(amostra, "amostra_20221128_datajud_lavagem_sirenejud.xlsx")

# juntando as bases -------------------------------------------------------

# o que vamos fazer?
# talvez o primeiro passo seja arrumar as colunas, retirando as que não 
# importam para a análise


