amazon <- c("AC", "AM", "RR", "AP", "PA", "MA", "TO", "RO", "MT")

paste_unique <- function(x) {
  paste(sort(unique(x)), collapse = ", ")
}

set.seed(20221110)
  
amostra <- da_basicas |> 
  dplyr::transmute(
    id_processo, 
    trib_esfera, 
    trib_tribunal,
    trib_nm_orgao,
    loc_uf,
    sgt_nm_classe,
    sgt_nm_assunto = purrr::map_chr(sgt_nm_assunto, paste_unique),
    st_grau
  ) |> 
  dplyr::filter(loc_uf %in% amazon) |> 
  dplyr::group_by(trib_esfera, loc_uf) |> 
  dplyr::slice_sample(n = 5) |> 
  dplyr::ungroup()

writexl::write_xlsx(amostra, "amostra_analisar_20221110.xlsx")
