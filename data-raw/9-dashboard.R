## SireneJud
da_sirenejud <- readr::read_rds("inst/relatorios/assets/rds/da_sirenejud.rds")
da_sirenejud_2grau <- readr::read_rds("inst/relatorios/assets/rds/da_sirenejud_2grau.rds")

## DataJud
da_datajud <- readr::read_rds("inst/relatorios/assets/rds/da_datajud.rds")
da_datajud_2grau <- readr::read_rds("inst/relatorios/assets/rds/da_datajud_2grau.rds")

## Outras
devtools::load_all()

## Colunas desejadas
## id_processo, esfera, tribunal, classe, assunto, muni, id_ibge, ano, grau, tempo
## desmatamento,

da_sirenejud_min <- da_sirenejud |>
  dplyr::transmute(
    id_processo,
    esfera = trib_esfera,
    tribunal = trib_tribunal,
    classe = sgt_nm_classe,
    assunto = purrr::map_chr(sgt_nm_assunto, \(x) x[1]),
    muni = muni_join,
    id_municipio,
    area,
    desmatado_pct,
    lat = loc_lat,
    lon = loc_lon,
    ano = lubridate::year(dt_novo),
    grau = "G1",
    tempo = st_tempo / 30.25,
    status = st_encerrado,
    pop
  ) |>
  dplyr::bind_rows(
    da_sirenejud_2grau |>
      dplyr::transmute(
        id_processo,
        esfera = trib_esfera,
        tribunal = trib_tribunal,
        classe = sgt_nm_classe,
        assunto = purrr::map_chr(sgt_nm_assunto, \(x) x[1]),
        id_municipio,
        area,
        desmatado_pct,
        lat = loc_lat,
        lon = loc_lon,
        ano = lubridate::year(dt_novo),
        grau = "G2",
        tempo = st_tempo / 30.25,
        status = st_encerrado,
        pop
      )
  ) |>
  dplyr::mutate(
    base = "sirenejud",
    .before = 1
  )

da_datajud_min <- da_datajud |>
  dplyr::transmute(
    id_processo = numero,
    esfera = justica,
    tribunal = sigla,
    classe = classes,
    assunto,
    id_municipio,
    area,
    desmatado_pct,
    lat,
    lon,
    ano = lubridate::year(dt_dist),
    grau = "G1",
    tempo = st_tempo,
    status = st_encerrado,
    pop
  ) |>
  dplyr::bind_rows(
    da_datajud_2grau |>
      dplyr::transmute(
        id_processo = numero,
        esfera = justica,
        tribunal = sigla,
        classe = classes,
        assunto,
        id_municipio,
        area,
        desmatado_pct,
        lat,
        lon,
        ano = lubridate::year(dt_dist),
        grau = "G2",
        tempo = st_tempo,
        status = st_encerrado,
        pop
      )
  ) |>
  dplyr::mutate(
    base = "lavagem",
    .before = 1
  )

aux_join_latlon <- forosCNJ::da_foro_comarca |>
  dplyr::filter(sigla == "TRF1") |>
  dplyr::mutate(
    descricao = stringr::str_remove(descricao, " [0-9]+.*"),
    descricao = stringr::str_squish(descricao),
    comarca = dplyr::case_when(
      comarca == "RIO BRANCO" ~ "ACRE",
      comarca == "MACAPA" ~ "AMAPA",
      .default = comarca
    ),
    descricao = dplyr::case_match(
      descricao,
      "Rio Banco" ~ "Rio Branco",
      "São Luiz" ~ "São Luis",
      "Monte Claros" ~ "Montes Claros",
      "Dvinópolis" ~ "Divinópolis",
      "Paulo Alfonso" ~ "Paulo Afonso",
      "Alamira" ~ "Altamira",
      "São João Del Rey" ~ "São João Del Rei",
      .default = descricao
    )
  ) |>
  dplyr::inner_join(
    dplyr::distinct(abjData::muni, uf_sigla, uf_nm) |>
      dplyr::mutate(uf_nm = toupper(abjutils::rm_accent(uf_nm))),
    c("comarca" = "uf_nm")
  ) |>
  munifacil::limpar_colunas(descricao, uf_sigla) |>
  munifacil::incluir_codigo_ibge() |>
  dplyr::select(
    id_foro, id_municipio
  ) |>
  dplyr::inner_join(
    dplyr::select(abjData::muni, id_municipio = muni_id, lat, lon),
    "id_municipio"
  ) |>
  dplyr::distinct(id_foro, .keep_all = TRUE)

da_trf1 <- da_trf1_cpopg |>
  dplyr::mutate(
    id_processo = basename(file),
    id_foro = stringr::str_sub(id_processo, -4, -1)
  ) |>
  dplyr::left_join(aux_join_latlon, c("id_foro")) |>
  dplyr::left_join(
    dplyr::select(da_tempo_trf1, file, st_tempo, st_encerrado),
    "file"
  ) |>
  dplyr::left_join(
    dplyr::distinct(da_sirenejud_min, id_municipio, .keep_all = TRUE) |>
      dplyr::select(id_municipio, area, desmatado_pct, pop),
    "id_municipio"
  ) |>
  dplyr::transmute(
    id_processo = basename(file),
    esfera = "Federal",
    tribunal = "TRF1",
    classe = stringr::str_remove(classe, "[0-9]+ - "),
    classe = stringr::str_replace_all(classe, "Ã´", "ô"),
    classe = stringr::str_replace_all(classe, "Ã©", "é"),
    classe = stringr::str_replace_all(classe, "Ã§", "ç"),
    classe = stringr::str_replace_all(classe, "Ã£", "ã"),
    classe = stringr::str_replace_all(classe, "Ãµ", "õ"),
    classe = stringr::str_replace_all(classe, "Ã¢", "â"),
    classe = stringr::str_replace_all(classe, "Ã¡", "á"),
    classe = stringr::str_replace_all(classe, "Ãº", "ú"),
    classe = stringr::str_replace_all(classe, "Ãª", "ê"),
    classe = stringr::str_replace_all(classe, "Ã", "í"),
    classe = stringr::str_replace_all(classe, "í³", "ó"),
    classe = stringr::str_replace_all(classe, "ãoA", "ão / A"),
    assunto = stringr::str_remove(assunto_da_peticao, "[0-9]+ - "),
    assunto = stringr::str_replace_all(assunto, "Ã´", "ô"),
    assunto = stringr::str_replace_all(assunto, "Ã©", "é"),
    assunto = stringr::str_replace_all(assunto, "Ã§", "ç"),
    assunto = stringr::str_replace_all(assunto, "Ã£", "ã"),
    assunto = stringr::str_replace_all(assunto, "Ãµ", "õ"),
    assunto = stringr::str_replace_all(assunto, "Ã¢", "â"),
    assunto = stringr::str_replace_all(assunto, "Ã¡", "á"),
    assunto = stringr::str_replace_all(assunto, "Ãº", "ú"),
    assunto = stringr::str_replace_all(assunto, "Ãª", "ê"),
    assunto = stringr::str_replace_all(assunto, "Ã", "í"),
    assunto = stringr::str_replace_all(assunto, "í³", "ó"),
    assunto = stringr::str_replace_all(assunto, "ãoA", "ão / A"),
    id_municipio,
    area,
    desmatado_pct,
    lat,
    lon,
    ano = lubridate::year(lubridate::dmy(data_de_autuacao)),
    grau = "G1",
    tempo = st_tempo,
    status = st_encerrado,
    pop
  ) |>
  dplyr::mutate(
    base = "trf1",
    .before = 1
  )


da_dash <- dplyr::bind_rows(
  da_sirenejud_min,
  da_datajud_min,
  da_trf1
)

usethis::use_data(da_dash, overwrite = TRUE)




# - Empilhar as bases para colocar no dashboard
#
# - Filtros
# -- Estado
# -- Ano
# -- Grau
#
# - Cards
# -- número de processos
# -- tempo mediano das ações
# -- correlação ILG e crime
# -- correlação ILG e desmatamento
#
# - Visualizações
# -- Classes e Assuntos
# -- Mapa
# -- Tempo
# -- Correlações (área desmatada x ILG, crimes x ILG)

