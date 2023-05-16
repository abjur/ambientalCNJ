
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ambientalCNJ

<!-- badges: start -->
<!-- badges: end -->

Este repositório contém os dados e as análises utilizadas na pesquisa
Corrupção e Lavagem de Dinheiro relacionados a Crimes Ambientais.

O estudo completo tem como objetivo identificar e analisar as cadeias de
lavagem de bens e capitais relacionadas a crimes ambientais. A pesquisa
é baseada na sistematização de informações sobre os atores e processos
judiciais envolvidos, examinados sob a perspectiva dos crimes ambientais
e da atuação jurisdicional no assunto. Ao combinar os temas de crimes
ambientais e lavagem de bens e capitais, será possível estudar as
sanções previstas nas leis de combate à lavagem de dinheiro, que
frequentemente são mais efetivas do que as sanções previstas nas leis de
crimes ambientais. Além disso, serão geradas recomendações sobre o
assunto.

A pesquisa foi desenvolvida a partir de 16 perguntas norteadoras,
listadas abaixo.

<details>
<summary>
Mostrar questões norteadoras
</summary>

1.  Quais são as atividades que conectam e alimentam a cadeia de fluxos
    de capitais que promovem o desmatamento?
2.  Quem são os atores envolvidos nos casos de lavagem de dinheiro e
    corrupção relacionados a crimes ambientais?
3.  Quais são os desafios na diferenciação entre atividades legais e
    ilegais para fins de identificação de fluxos de lavagem de capitais?
4.  Quais as teses jurídicas de defesa mais utilizadas nas ações
    envolvendo lavagem de dinheiro, fluxos de capitais para atividades
    ambientais ilegais e lavagem de dinheiro?
5.  Existem padrões identificáveis nos casos judicializados quanto às
    circunstâncias, características dos autores, modalidades e tipos de
    crimes ambientais?
6.  Quais são as decisões tomadas e seus fundamentos jurídicos de fato e
    a razão de decidir apresentadas nesses casos?
7.  Qual o papel do Poder Judiciário no combate à lavagem de dinheiro e
    corrupção relacionados a crimes ambientais?
8.  Quais os principais segmentos econômicos ou grupos empresariais que
    estão envolvidos na cadeia de produção que tenha alguma relação com
    crime ambiental (indústria de equipamentos pesados, maquinário
    agrícola, maquinário de mineração, táxi aéreo, bancos e instituições
    financeiras de fomento agrícola, leasing)?
9.  Como especificar, em caso de crimes ambientais complexos e de grande
    monta, os mandantes indiretos? Há pessoas jurídicas envolvidas? Há
    desconsideração de pessoa jurídica nesses casos?
10. Há normas de ESG (*environmental*, *social*, *and Governance*) que
    podem reduzir a lavagem de capitais e o fluxo de capitais para
    atividades ambientais ilegais?
11. Há atos normativos ou diretrizes no âmbito da Estratégia Nacional de
    Combate à Corrupção e à Lavagem de Dinheiro - ENCCLA, do Banco
    Central do Brasil e/ou do Conselho de Controle de Atividades
    Financeiras - COAF que podem facilitar a identificação de fluxo de
    capitais em matéria ambiental?
12. Há correlação entre a incidência de crimes contra a vida ou ameaça
    em regiões de alta ocorrência de desmatamento, ou mineração ilegal
    ou crimes ambientais em geral?
13. Há relação entre a ocorrência da alta incidência de demandas
    judiciais de conflitos fundiários com crimes ambientais ou crimes
    contra a vida?
14. Qual o tempo de duração médio das ações criminais que envolvam a
    temática ambiental?
15. Qual a quantidade de ações criminais que apuram crimes contra a vida
    ou de ameaça contra pessoas ligadas à defesa do meio ambiente ou de
    movimentos relacionados à proteção de populações indígenas e/ou
    povos tradicionais que ingressam por ano? Qual o tempo de duração
    médio dessas ações? Quais as espécies de crime cometidas? Qual a
    efetividade da identificação da autoria e do cumprimento da pena?
16. Qual a quantidade de ações criminais que apuram crimes relacionados
    à questão fundiária que ingressam por ano? Qual o tempo de duração
    médio dessas ações? Quais as espécies de crime cometidas? Qual a
    efetividade da identificação da autoria e do cumprimento da pena?

</details>

## Objetivo

O presente repositório tem como objetivo organizar os códigos utilizados
para i) baixar e processar as bases de dados, ii) escrever um relatório
que responde às perguntas de pesquisa que podem ser investigadas do
ponto de vista empírico-quantitativo e iii) disponibilizar um dashboard
contendo algumas análises das bases obtidas. Por se tratar de um
levantamento quantitativo, nem todas as questões podem ser endereçadas.
Das 16 perguntas listadas acima, 7 foram efetivamente analisadas.
Especificamente, as questões 1, 2, 5, 8, 12 e 14.

## Instalação

É possível instalar o pacote `ambientalCNJ` do
[GitHub](https://github.com/) rodando:

``` r
# install.packages("remotes")
remotes::install_github("abjur/ambientalCNJ")
```

## Organização do repositório

O repositório está organizado na forma de [pacote do
R](https://r-pkgs.org) e contém todos os scripts utilizados para:

1.  Gerar as bases de dados arrumadas a partir das bases de dados
    brutas.
2.  Escrever o relatório reprodutível.
3.  Desenvolver o aplicativo web.

Descrevemos os componentes em maiores detalhes a seguir.

### Processamento das bases de dados brutas

Este trabalho utilizou diversas fontes de dados. Algumas foram enviadas
pelo Conselho Nacional de Justiça (CNJ), outras foram obtidas a partir
de dados abertos, e outras foram obtidas via raspagem de dados.

Para organizar as bases, foram desenvolvidos 9 scripts de processamento,
que estão na pasta `data-raw/`. Os scripts são de uso interno para
processamento de bases e não precisam ser rodados para abrir o dashboard
ou o relatório. Detalhamos os scripts a seguir.

- [`0-load.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/0-load.R).
  Utilizado para ler e processar as bases do SireneJud e do Datajud
  (corrupção). Trata-se dos scripts com processamento mais intenso. É
  necessário pelo menos 16gb de RAM para rodar os scripts. A saída
  principal do script são as bases que estão nos
  [`assets/rds`](https://github.com/abjur/ambientalCNJ/tree/main/inst/relatorios/assets/rds),
  utilizadas no relatório.
- [`1-rfb.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/1-rfb.R).
  Acessa as bases da RFB (utilizando um BigQuery interno da ABJ) e
  extrai os dados das empresas a partir dos CNPJs. O script não é
  reprodutível para pessoas que não são da ABJ, por conta da base no
  BigQuery.
- [`2-export.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/2-export.R).
  Script utilizado para gerar amostras de dados que foram
  disponibilizados na primeira entrega da pesquisa (que foi
  posteriormente descartada). O script foi mantido apenas pelo
  histórico, já que a base não foi utilizada nas análises.
- [`3-trf1.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/3-trf1.R).
  Script que baixa os dados do TRF1 a partir do banco de sentenças,
  utilizando uma ferramenta de raspagem de dados desenvolvida pela ABJ.
  Os scripts do raspador estão no caminho
  [`R/trf1-scraper.R`](https://github.com/abjur/ambientalCNJ/tree/main/R/trf1-scraper.R).
- [`4-trf1-cpopg.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/4-trf1-cpopg.R).
  Script que baixa os dados do TRF1 a partir da consulta de processos do
  primeiro grau (CPOPG), utilizada para gerar as bases do TRF1
  utilizadas no relatório.
- [`5-elastic.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/5-elastic.R).
  Scripts utilizados para processar dados recebidos pelo CNJ a partir de
  uma consulta do ElasticSearch interno da entidade.
- [`6-jusbrasil.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/6-jusbrasil.R).
  Scripts utilizados para processar dados recebidos pela AMB a partir de
  uma consulta da ferramenta disponibilizada pelo JusBrasil.
- [`7-sinesp.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/7-sinesp.R).
  Scripts utilizados para processar dados obtidos dos [Dados Abertos do
  Ministério da
  Justiça](https://dados.gov.br/dados/conjuntos-dados/sistema-nacional-de-estatisticas-de-seguranca-publica),
  com estatísticas de homicídios.
- [`8-compilado.R`](https://github.com/abjur/ambientalCNJ/blob/main/data-raw/7-sinesp.R).
  Scripts utilizados para compilar dados do ElasticSearch, JusBrasil e
  TRF1 para compor a amostra utilizada pelos pesquisadores no estudo.

Vale notar que, por serem de uso interno, os scripts não estão 100%
documentados. Se tiver alguma dúvida sobre os scripts, [abra uma
issue](https://github.com/abjur/ambientalCNJ/issues).

A partir dos scripts desenvolvidos, foram geradas diversas bases de
dados. As bases de dados são muito pesadas para armazenar diretamente no
repositório. Por isso, as bases foram colocadas na [página de
Lançamentos (Releases) do
repositório](https://github.com/abjur/ambientalCNJ/releases). Na maioria
dos casos, as bases estão em formato `.rds`, um formato próprio do R
para armazenamento de dados no formato binário, que permite o
Input/Output de dados sem perda de formatação.

As pastas de arquivos disponibilizados são:

- [`sirenejud`](https://github.com/abjur/ambientalCNJ/releases/tag/sirenejud):
  dados processados a partir da base do SireneJud para utilização em
  passos intermediários do `data-raw/` ou utilização no relatório da
  pesquisa.
- [`corrupcao`](https://github.com/abjur/ambientalCNJ/releases/tag/corrupcao):
  dados processados a partir da base do DataJud - Corrupção e Lavagem de
  Dinheiro para utilização em passos intermediários do `data-raw/` ou
  utilização no relatório da pesquisa.
- [`trf1`](https://github.com/abjur/ambientalCNJ/releases/tag/trf1):
  dados brutos do raspador utilizado no TRF1, com dados de passos
  intermediários do `data-raw/` e utilização no relatório da pesquisa.
- [`rfb`](https://github.com/abjur/ambientalCNJ/releases/tag/rfb): dados
  processados a partir da RFB para utilização em passos intermediários
  do `data-raw/`.
- [`misc`](https://github.com/abjur/ambientalCNJ/releases/tag/misc):
  arquivos miscelânea utilizados na pesquisa (dados sobre desmatamento,
  lista de municípios da Amazônia Legal, dados do Sinesp).
- [`jusbrasil`](https://github.com/abjur/ambientalCNJ/releases/tag/jusbrasil):
  arquivos do JusBrasil utilizados na pesquisa (para gerar a amostra).
- [`elasticsearch`](https://github.com/abjur/ambientalCNJ/releases/tag/elasticsearch):
  arquivos do ElasticSearch utilizados na pesquisa (para gerar a
  amostra).

As *releases* disponibilizadas têm um limite de 2gb por arquivo. Além
disso, as bases fornecidas pelo CNJ não podem ser distribuídas
livremente sem autorização da entidade. Por isso, disponibilizamos
apenas os dados processados

Para reproduzir os scripts da pasta `data-raw/`, recomenda-se criar uma
pasta dentro de `data-raw/` com os nomes dos releases. Por exemplo,
copiar os arquivos que estão na release
[`misc`](https://github.com/abjur/ambientalCNJ/releases/tag/misc) para a
pasta `data-raw/misc`. Os scripts da pasta `data-raw/` estão preparados
para ler arquivos com esses caminhos.

Os dados processados pequenos foram disponibilizados diretamente na
pasta `data/` para facilitar a reprodução das análises. Para acessar os
arquivos, basta instalar o pacote como descrito anteriormente, rodar
`library(ambientalCNJ)` e acessar as bases de dados pelo nome. As bases
disponibilizadas são:

- `da_rfb`: dados processados na RFB com informações sobre as empresas
  (dados do SireneJud).
- `da_rfb_ativo`: dados processados na RFB com informações sobre as
  empresas no polo ativo (dados do SireneJud).
- `da_tempo_trf1`: dados com tempos dos processos extraídos do TRF1.
- `da_trf1_cjpg_pequeno`: dados da consulta de sentenças do TRF1 após
  filtrar casos dentro do escopo da pesquisa.
- `da_trf1_cpopg`: dados da consulta de processos do TRF1 a partir dos
  processos listados pelo banco de sentenças.
- `sf_amazon`: shapefile (objeto de clase `sf`) com a região amazônica,
  obtido a partir do pacote
  [`{geobr}`](https://ipeagit.github.io/geobr/) com a função
  `geobr::read_amazon()`.
- `sinesp`: dados organizados do SINESP utilizado no relatório.

Além dessas bases de dados, outras bases maiores foram utilizadas para
gerar o relatório, com origem no SireneJud e no DataJud (corrupção e
lavagem de dinheiro). Essas bases foram disponibilizadas em um release
próprio, chamado
[`relatorio`](https://github.com/abjur/ambientalCNJ/releases/tag/relatorio).
Para reproduzir o relatório, é necessário salvar os arquivos desse
release na pasta `inst/relatorios/assets/rds/`.

### Relatório reprodutível

O relatório foi desenvolvido utilizando a tecnologia
[Quarto](https://quarto.org), utilizando melhores práticas de pesquisa
reprodutível. O relatório está no arquivo
[`inst/relatorios/2-descritiva.qmd`](https://github.com/abjur/ambientalCNJ/blob/main/inst/relatorios/2-descritiva.qmd).
O relatório pode ser gerado utilizando o comando
`quarto render 2-descritiva.qmd`

Link do relatório: [aqui](abj.quarto.pub/ambientalcnj).

### Dashboard

O Dashboard foi desenvolvido usando a tecnologia
[`{golem}`](https://thinkr-open.github.io/golem/), que permite a criação
de aplicativos Shiny utilizando melhores práticas de desenvolvimento de
pacotes. Todos os scripts utilizados para gerar o dashboard estão na
pasta `R/`.

Link do Dashboard: [aqui](abjur.shinyapps.io/ambientalCNJ).

## Licença

MIT
