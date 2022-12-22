
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

da_raw <- readr::read_csv2("data-raw/sirenejud/datajud_new_261022.csv", lazy = TRUE)

dplyr::glimpse(head(da_raw))


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

da_basicas_amazon <- da_basicas |> 
  dplyr::filter(!sgt_nm_classe %in% c("Termo Circunstanciado", "Inquérito Policial")) |> 
  dplyr::filter(loc_uf %in% c(amazon, "DF"))

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
    dt_dist = dataAjuizamento,
    orgao_julgador = orgaoJulgador_codigoOrgao,
    eletronico = procEl,
    polo_at_count,
    polo_at_juridica_count,
    polo_pa_count,
    polo_pa_juridica_count,
    mov_count
  )

readr::write_rds(da_corrup_select, "data-raw/da_corrup_select.rds")

da_corrup_orgaos <- da_corrup_select |> 
  dplyr::mutate(orgao_julgador = as.numeric(orgao_julgador)) |> 
  dplyr::semi_join(
    da_basicas_amazon, 
    c("orgao_julgador" = "trib_co_orgao")
  )

da_completa <- da_corrup_orgaos |> 
  dplyr::transmute(
    origem = "datajud_lavagem",
    id_processo = numero, 
    tribunal = sigla
  ) |> 
  dplyr::distinct(id_processo, .keep_all = TRUE) |> 
  dplyr::bind_rows(
    dplyr::transmute(
      da_basicas_amazon, 
      origem = "sirenejud",
      id_processo, 
      tribunal = trib_tribunal
    ) |> 
      dplyr::distinct(id_processo, .keep_all = TRUE)
  )

set.seed(1)

amostra <- da_completa |> 
  dplyr::group_by(origem, tribunal) |> 
  dplyr::slice_sample(n = 10) |> 
  dplyr::ungroup()

writexl::write_xlsx(amostra, "amostra_20221128_datajud_lavagem_sirenejud.xlsx")

# juntando as bases -------------------------------------------------------

# o que vamos fazer?
# talvez o primeiro passo seja arrumar as colunas, retirando as que não 
# importam para a análise


