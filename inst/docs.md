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

-   **Correlação entre desmatamento e ILG**: Gráfico de dispersão entre o Índice de Litigiosidade (ILG, calculado pela razão entre a quantidade de processos e a população em 100.000 habitantes de cada município) e a taxa de desmatamento em 2021, segundo os [dados do INPE](http://www.dpi.inpe.br/prodesdigital/prodesmunicipal.php). Cada ponto no gráfico é um município.
