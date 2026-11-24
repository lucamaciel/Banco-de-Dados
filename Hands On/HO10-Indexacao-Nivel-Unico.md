# HO10: Indexação de Nível Único

> Método do Tópico #14 do Prof. Wlad: bloco 2.048B, ponteiro de bloco 16B.
> - **Índice primário** (na chave primária, arquivo ordenado por ela): **esparso**, 1 entrada por **bloco** do arquivo de dados (âncora do bloco).
> - **Índice secundário** (em cada chave estrangeira, campo não ordenado): **denso**, 1 entrada por **registro**.
> - Entrada = campo de indexação + ponteiro (16B). F = ⌊2.048 / entrada⌋. Blocos = ⌈entradas / F⌉. Desperdício = 2.048 − F × entrada. Espaço = blocos × 2KB.
> - Acessos = **⌈log₂(blocos do índice)⌉ + 1** (busca binária no índice + 1 acesso ao bloco de dados).

Nº de blocos dos arquivos de dados (do HO09): Atores 910 · Clientes 20.000 · Filmes 250.000 · Funcionarios 319 · Midias 357.143 · Aluguel 909.091 · Pagamentos 3.333.334 · AtoresEmFilmes 15.625.

## Modelo relacional (com as chaves estrangeiras)

```
Atores(Codigo, Nome)                                    AtoresEmFilmes(CodFilme→Filmes, CodAtor→Atores)
Filmes(Codigo, Nome, Genero)                            Midias(Identificador, Tipo, PrecoDiaria, CodFilme→Filmes)
Clientes(CPF, Nome, Endereco, Telefone, DataNascimento, Sexo)
Funcionarios(CPF, Nome, CPF_Supervisor→Funcionarios)
Aluguel(CPF_Cliente→Clientes, ID_Midia→Midias, DataLocacao, DataDevolucao, ValorPagar, CPF_Funcionario→Funcionarios)
Pagamentos(Codigo, (CPF_Cliente, ID_Midia, DataLocacao)→Aluguel, Data, Valor)
```
Tamanhos das FKs = tamanho do campo referenciado: CPF 11B, ID_Midia 24B, CodFilme/CodAtor 16B, DataLocacao 12B.

## Cálculos

### Atores  (arquivo de dados: 910 blocos, 10.000 registros)

**Índice primário em (Codigo)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 16B + 16B = 32B
- Fator de bloco: ⌊2.048 / 32⌋ = **64**
- Nº de blocos: ⌈910 / 64⌉ = **15**
- Desperdício por bloco: 2.048 − 64×32 = **0B**
- Espaço: 15 × 2KB = **30KB**
- Acessos: ⌈log₂ 15⌉ + 1 = 4 + 1 = **5**

### Clientes  (arquivo de dados: 20.000 blocos, 100.000 registros)

**Índice primário em (CPF)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 11B + 16B = 27B
- Fator de bloco: ⌊2.048 / 27⌋ = **75**
- Nº de blocos: ⌈20.000 / 75⌉ = **267**
- Desperdício por bloco: 2.048 − 75×27 = **23B**
- Espaço: 267 × 2KB = **534KB**
- Acessos: ⌈log₂ 267⌉ + 1 = 9 + 1 = **10**

### Filmes  (arquivo de dados: 250.000 blocos, 2.000.000 registros)

**Índice primário em (Codigo)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 16B + 16B = 32B
- Fator de bloco: ⌊2.048 / 32⌋ = **64**
- Nº de blocos: ⌈250.000 / 64⌉ = **3.907**
- Desperdício por bloco: 2.048 − 64×32 = **0B**
- Espaço: 3.907 × 2KB = **7.814KB**
- Acessos: ⌈log₂ 3.907⌉ + 1 = 12 + 1 = **13**

### Funcionarios  (arquivo de dados: 319 blocos, 3.500 registros)

**Índice primário em (CPF)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 11B + 16B = 27B
- Fator de bloco: ⌊2.048 / 27⌋ = **75**
- Nº de blocos: ⌈319 / 75⌉ = **5**
- Desperdício por bloco: 2.048 − 75×27 = **23B**
- Espaço: 5 × 2KB = **10KB**
- Acessos: ⌈log₂ 5⌉ + 1 = 3 + 1 = **4**

**Índice secundário em (CPF_Supervisor)** — denso: 1 entrada por registro

- Entrada: 11B + 16B = 27B
- Fator de bloco: ⌊2.048 / 27⌋ = **75**
- Nº de blocos: ⌈3.500 / 75⌉ = **47**
- Desperdício por bloco: 2.048 − 75×27 = **23B**
- Espaço: 47 × 2KB = **94KB**
- Acessos: ⌈log₂ 47⌉ + 1 = 6 + 1 = **7**

### Midias  (arquivo de dados: 357.143 blocos, 10.000.000 registros)

**Índice primário em (Identificador)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 24B + 16B = 40B
- Fator de bloco: ⌊2.048 / 40⌋ = **51**
- Nº de blocos: ⌈357.143 / 51⌉ = **7.003**
- Desperdício por bloco: 2.048 − 51×40 = **8B**
- Espaço: 7.003 × 2KB = **14.006KB**
- Acessos: ⌈log₂ 7.003⌉ + 1 = 13 + 1 = **14**

**Índice secundário em (CodFilme)** — denso: 1 entrada por registro

- Entrada: 16B + 16B = 32B
- Fator de bloco: ⌊2.048 / 32⌋ = **64**
- Nº de blocos: ⌈10.000.000 / 64⌉ = **156.250**
- Desperdício por bloco: 2.048 − 64×32 = **0B**
- Espaço: 156.250 × 2KB = **312.500KB**
- Acessos: ⌈log₂ 156.250⌉ + 1 = 18 + 1 = **19**

### Aluguel  (arquivo de dados: 909.091 blocos, 20.000.000 registros)

**Índice primário em (CPF_Cliente, ID_Midia, DataLocacao)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 47B + 16B = 63B
- Fator de bloco: ⌊2.048 / 63⌋ = **32**
- Nº de blocos: ⌈909.091 / 32⌉ = **28.410**
- Desperdício por bloco: 2.048 − 32×63 = **32B**
- Espaço: 28.410 × 2KB = **56.820KB**
- Acessos: ⌈log₂ 28.410⌉ + 1 = 15 + 1 = **16**

**Índice secundário em (CPF_Cliente)** — denso: 1 entrada por registro

- Entrada: 11B + 16B = 27B
- Fator de bloco: ⌊2.048 / 27⌋ = **75**
- Nº de blocos: ⌈20.000.000 / 75⌉ = **266.667**
- Desperdício por bloco: 2.048 − 75×27 = **23B**
- Espaço: 266.667 × 2KB = **533.334KB**
- Acessos: ⌈log₂ 266.667⌉ + 1 = 19 + 1 = **20**

**Índice secundário em (ID_Midia)** — denso: 1 entrada por registro

- Entrada: 24B + 16B = 40B
- Fator de bloco: ⌊2.048 / 40⌋ = **51**
- Nº de blocos: ⌈20.000.000 / 51⌉ = **392.157**
- Desperdício por bloco: 2.048 − 51×40 = **8B**
- Espaço: 392.157 × 2KB = **784.314KB**
- Acessos: ⌈log₂ 392.157⌉ + 1 = 19 + 1 = **20**

**Índice secundário em (CPF_Funcionario)** — denso: 1 entrada por registro

- Entrada: 11B + 16B = 27B
- Fator de bloco: ⌊2.048 / 27⌋ = **75**
- Nº de blocos: ⌈20.000.000 / 75⌉ = **266.667**
- Desperdício por bloco: 2.048 − 75×27 = **23B**
- Espaço: 266.667 × 2KB = **533.334KB**
- Acessos: ⌈log₂ 266.667⌉ + 1 = 19 + 1 = **20**

### Pagamentos  (arquivo de dados: 3.333.334 blocos, 50.000.000 registros)

**Índice primário em (Codigo)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 48B + 16B = 64B
- Fator de bloco: ⌊2.048 / 64⌋ = **32**
- Nº de blocos: ⌈3.333.334 / 32⌉ = **104.167**
- Desperdício por bloco: 2.048 − 32×64 = **0B**
- Espaço: 104.167 × 2KB = **208.334KB**
- Acessos: ⌈log₂ 104.167⌉ + 1 = 17 + 1 = **18**

**Índice secundário em (CPF_Cliente, ID_Midia, DataLocacao)** — denso: 1 entrada por registro

- Entrada: 47B + 16B = 63B
- Fator de bloco: ⌊2.048 / 63⌋ = **32**
- Nº de blocos: ⌈50.000.000 / 32⌉ = **1.562.500**
- Desperdício por bloco: 2.048 − 32×63 = **32B**
- Espaço: 1.562.500 × 2KB = **3.125.000KB**
- Acessos: ⌈log₂ 1.562.500⌉ + 1 = 21 + 1 = **22**

### AtoresEmFilmes  (arquivo de dados: 15.625 blocos, 1.000.000 registros)

**Índice primário em (CodFilme, CodAtor)** — esparso: 1 entrada por bloco do arquivo (âncora)

- Entrada: 32B + 16B = 48B
- Fator de bloco: ⌊2.048 / 48⌋ = **42**
- Nº de blocos: ⌈15.625 / 42⌉ = **373**
- Desperdício por bloco: 2.048 − 42×48 = **32B**
- Espaço: 373 × 2KB = **746KB**
- Acessos: ⌈log₂ 373⌉ + 1 = 9 + 1 = **10**

**Índice secundário em (CodFilme)** — denso: 1 entrada por registro

- Entrada: 16B + 16B = 32B
- Fator de bloco: ⌊2.048 / 32⌋ = **64**
- Nº de blocos: ⌈1.000.000 / 64⌉ = **15.625**
- Desperdício por bloco: 2.048 − 64×32 = **0B**
- Espaço: 15.625 × 2KB = **31.250KB**
- Acessos: ⌈log₂ 15.625⌉ + 1 = 14 + 1 = **15**

**Índice secundário em (CodAtor)** — denso: 1 entrada por registro

- Entrada: 16B + 16B = 32B
- Fator de bloco: ⌊2.048 / 32⌋ = **64**
- Nº de blocos: ⌈1.000.000 / 64⌉ = **15.625**
- Desperdício por bloco: 2.048 − 64×32 = **0B**
- Espaço: 15.625 × 2KB = **31.250KB**
- Acessos: ⌈log₂ 15.625⌉ + 1 = 14 + 1 = **15**
