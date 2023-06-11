# Documentação

O dashboard Ambiental CNJ tem como objetivo fornecer uma versão interativa da parte quantitativa do relatório realizado sobre processos ambientais.

A base de dados utilizada contém informações sobre processos ambientais e possui 300.361 linhas e 17 colunas. Abaixo, estão descritas as características de cada coluna:

1.  `base`: Uma variável categórica que indica a fonte da informação do processo (SireneJud, DataJud-lavagem, TRF1).
2.  `id_processo`: Identificador único de cada processo segundo a Res. 65 CNJ.
3.  `esfera`: Indica a esfera do processo, como "Estadual" ou "Federal".
4.  `tribunal`: Indica o tribunal ao qual o processo está vinculado.
5.  `classe`: Classe do processo, como "Ação Civil Pública" ou "Crimes Ambientais".
6.  `assunto`: Assunto do processo, como "Dano Ambiental" ou "Crimes contra a Flora".
7.  `muni`: Indica o nome do município relacionado ao processo.
8.  `id_municipio`: Representa o identificador único do município com base no código IBGE.
9.  `area`: Representa a área em quilômetros quadrados do município relacionado ao processo.
10. `desmatado_pct`: Uma variável numérica que indica a porcentagem de desmatamento no município relacionado ao processo.
11. `lat`: Representa a latitude do município relacionado ao processo.
12. `lon`: Representa a longitude do município relacionado ao processo.
13. `ano`: Indica o ano de registro do processo.
14. `grau`: Indica o grau do processo, como "G1" (primeiro grau).
15. `tempo`: Representa o tempo de duração do processo em meses.
16. `status`: Indica o status do processo, sendo 1 para processos encerrados e 0 para processos ativos.
17. `pop`: Representa a população do município relacionado ao processo.

Essas informações fornecem detalhes sobre os processos ambientais na base de dados e podem ser utilizadas para análises relacionadas ao relatório de pesquisa.

## Bases de dados

A análise considera três bases de processos, que chamamos de SireneJud, DataJud e TRF1, com a quantidade de processos da tabela abaixo.

|Base de dados      |      Quantidade|
|:---------|------:|
|DataJud   | 234969|
|SireneJud |  55151|
|TRF1      |  10241|

Descrevemos as bases de dados a seguir.

### SireneJud

A base do SireneJud foi fornecida pelo CNJ, a partir de uma extração realizada no dia 26/10/2022. O arquivo foi fornecido no formato CSV, contendo 637.699 linhas e 37 colunas. Diferentes versões da base podem ser acessadas a partir do [link de dados abertos da ferramenta do SireneJud](https://sirenejud.cnj.jus.br/mapa/geral).

A base de dados do SireneJud apresenta uma estrutura comum de bases de dados judiciais, contendo três unidades amostrais distintas: processos, partes e movimentações.

O primeiro passo da análise foi realizar filtros para obter uma base mais próxima do escopo da pesquisa. Infelizmente, a base do SireneJud não permite a realização de filtros que identificam de forma precisa os casos relacionados à lavagem de bens e capitais em crimes ambientais. No entanto, a base auxilia no estudo da dinâmica de crimes ambientais, com diferentes níveis de profundidade.

Os filtros aplicados no momento são:

- Considerar apenas processos originários no primeiro grau.
- Remover processos de alta complexidade.
- Remover duplicatas de número de processo (ordenamos por grau antes de tirar as duplicatas).
- Remover casos com as classes "Termo Circunstanciado" e "Inquérito Policial"
- Considerar apenas processos com origem na Amazônia Legal (AC, AM, RR, AP, PA, MA, TO, RO, MT).

### DataJud

A base do DataJud também foi fornecida pelo CNJ, em dezembro de 2022. A base contém informações de processos relacionados à corrupção e lavagem de dinheiro, que podem ou não estarem ligados a crimes ambientais.

A base de dados do DataJud apresenta uma estrutura similar à do SireneJud, com colunas comuns em bases de dados judiciais, mas agrega todas as informações ao nível de processo. Como efeito, as informações das partes e das movimentações são apresentadas de forma agregada (contagens de eventos ou partes).

A base do DataJud também passou por alguns filtros antes de ser analisada:

- Considerar apenas processos originários no primeiro grau.
- Remover duplicatas de número de processo.
- Remover casos com as classes "Termo Circunstanciado" e "Inquérito Policial".
- Remover casos com alguns assuntos relacionados a posse de drogas para uso pessoal, furto e concussão.
- Considerar apenas processos com origem nas mesmas unidades jurisdicionais dos processos do SireneJud.

### TRF1

A base do TRF1 foi obtida via raspagem de dados a partir do banco de decisões do TRF1. Raspagem de dados é um processo de extração de informações de fontes da web, como sites, APIs e arquivos, e armazenamento dos dados coletados em um formato estruturado, como uma planilha ou banco de dados. Esse processo é realizado com o uso de linguagens de programação, que automatizam a extração de dados da web.

A raspagem de dados pode ser usada para coletar dados de várias fontes, sendo uma prática comum para acessar dados que são públicos, mas não são abertos, como é o caso da maior parte dos tribunais brasileiros. É importante destacar que a raspagem de dados só é necessária quando os dados não são abertos: os estudos seriam significativamente facilitados se os tribunais disponibilizassem os dados em formatos eletrônicos legíveis por máquina e não proprietários.

A vantagem da base do TRF1 é que ela é obtida a partir da consulta de palavras-chave nos textos das decisões. Isso permite uma pesquisa mais focada, já que é possível buscar por termos relacionados a questões ambientais juntamente com termos relacionados a lavagem de bens e capitais ou corrupção.

Para construir a base, partimos de algumas palavras-chave envolvendo a temática de crimes ambientais para obter uma lista inicial de processos. A lista foi, então, refinada, para obter informações de processos que se relacionam com corrupção e lavagem de bens e capitais.

Os termos utilizados para captura da primeira lista de processos foram: garimpo, desmatamento, mineração, invasão e grilagem. Os termos foram pesquisados com variações, como existência ou não de acentos e flexões das palavras (por exemplo, garimpo, garimpeiro, etc).

A primeira base obtida dessa forma tinha 32.046 processos. As informações disponíveis são bastante limitadas: o número do processo, o resumo da decisão e o texto da decisão.

A base foi, então, filtrada, com o objetivo de listar casos que podem estar dentro do escopo. Aqui existem duas versões da base: a primeira contém informações de todos os processos envolvendo questões ambientais dentro do recorte temporal e regional da pesquisa, enquanto a segunda contém, além dos recortes anteriores, filtros relacionados à lavagem e corrupção.

Por fim, a base foi enriquecida com informações da consulta processual (antiga) do TRF1. Os dados também foram obtidos via raspagem de dados, que permitiu a extração de dados como classe, vara, juiz, localização, movimentações e partes. Infelizmente, as partes só estão disponíveis em 2.936 processos.

Por ser uma base retrospectiva (listada a partir das datas de sentenças), a base do TRF1 não apresenta censuras. Por esse motivo, as estimativas de mediana de tempo obtidas via análise de sobrevivência correspondem à mediana simples dos tempos dos processos.

## Filtros

No dashboard, é possível atualizar as análises segundo os itens abaixo:

-   Base de dados (Sirene, JudCorrupção/Lavagem, TRF1)
-   Tribunal (tribunais estaduais na região amazônica e TRF1)
-   Ano de distribuição do processo
-   Grau (G1 ou G2)

É importante notar que alguns filtros podem gerar bases de dados vazias. Por exemplo, a base do TRF1 não possui processos do segundo grau. Caso a base de dados filtrada não possa gerar as visualizações desejadas, o sistema avisará que não foi possível gerar as visualizações.

## Visualizações

O aplicativo apresenta 4 visualizações:

-   **Classe/Assunto**: Tabela com as classes e assuntos processuais mais frequentes.

-   **Mapa**: Mapa de círculos com os municípios de origem dos processos. O raio dos círculos é proporcional à quantidade de processos.

-   **Tempo**: Gráfico de sobrevivência com os tempos dos processos. No eixo das abcissas (eixo x) é colocado o tempo; no eixo das ordenadas (eixo y) é colocada a probabilidade de sobrevivência (probabilidade do processo ficar ativo por mais tempo do que o valor demarcado). A linha pontilhada identifica a mediana dos tempos.

-   **Correlação entre desmatamento e ILG**: Gráfico de dispersão entre o Índice de Litigiosidade (ILG, calculado pela razão entre a quantidade de processos e a população em 100.000 habitantes de cada comarca/município-sede da unidade judiciária) e a taxa de desmatamento em 2021, segundo os [dados do INPE](http://www.dpi.inpe.br/prodesdigital/prodesmunicipal.php). Cada ponto no gráfico é um município.