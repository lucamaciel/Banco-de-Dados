# HO11: Indexação Multinível

> Método do Tópico #15 do Prof. Wlad: bloco 2.048B, ponteiro de bloco 16B, ponteiro de nó 12B, 1 nó = 1 bloco, ocupação da B+ = 69%.

> **Índice multinível estático (ISAM) na PK:** fan-out fo = ⌊2.048 / (chave + 16B)⌋. O 1º nível tem 1 entrada por bloco de dados: BM1 = ⌈blocos de dados / fo⌉, BM2 = ⌈BM1 / fo⌉, … até 1 bloco. Espaço = Σ blocos × 2KB. Acessos = h + 1, com h = ⌈log_fo(blocos de dados)⌉.

> **Árvore B+ em cada FK** (como no slide do professor):
> - Nó índice: 2.048 ≥ (m−1)(chave + 12) + 12 → (m−1) = ⌊2.036 / (chave+12)⌋, ordem m.
> - Altura h = ⌈log_m(nº de registros)⌉, com hi = h − 1 níveis de nós índice.
> - Nó registro (folha): 2.048 ≥ (m−1)(chave + 16) + 12 → (m−1) = ⌊2.036 / (chave+16)⌋.
> - FB+ = folha × 0,69 (arredondado). Blocos folha = ⌈registros / FB+⌉.
> - Blocos de nós índice = ⌈blocos folha / ((m−1)×0,69 + hi)⌉.
> - Espaço = (folhas + nós índice) × 2KB. Acessos = h + 1.

> Obs.: Atores, Clientes e Filmes não têm FK, então só têm o índice estático.

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

**Índice multinível estático (ISAM) em (Codigo)**

- Entrada: 16B + 16B = 32B → fan-out fo = ⌊2.048/32⌋ = **64**
- Blocos por nível: BM1 = 15, BM2 = 1
- Total: 16 blocos → Espaço = 16 × 2KB = **32KB**
- Níveis: h = ⌈log_64 910⌉ = **2** → Acessos = 2 + 1 = **3**

### Clientes  (arquivo de dados: 20.000 blocos, 100.000 registros)

**Índice multinível estático (ISAM) em (CPF)**

- Entrada: 11B + 16B = 27B → fan-out fo = ⌊2.048/27⌋ = **75**
- Blocos por nível: BM1 = 267, BM2 = 4, BM3 = 1
- Total: 272 blocos → Espaço = 272 × 2KB = **544KB**
- Níveis: h = ⌈log_75 20.000⌉ = **3** → Acessos = 3 + 1 = **4**

### Filmes  (arquivo de dados: 250.000 blocos, 2.000.000 registros)

**Índice multinível estático (ISAM) em (Codigo)**

- Entrada: 16B + 16B = 32B → fan-out fo = ⌊2.048/32⌋ = **64**
- Blocos por nível: BM1 = 3.907, BM2 = 62, BM3 = 1
- Total: 3.970 blocos → Espaço = 3.970 × 2KB = **7.940KB**
- Níveis: h = ⌈log_64 250.000⌉ = **3** → Acessos = 3 + 1 = **4**

### Funcionarios  (arquivo de dados: 319 blocos, 3.500 registros)

**Índice multinível estático (ISAM) em (CPF)**

- Entrada: 11B + 16B = 27B → fan-out fo = ⌊2.048/27⌋ = **75**
- Blocos por nível: BM1 = 5, BM2 = 1
- Total: 6 blocos → Espaço = 6 × 2KB = **12KB**
- Níveis: h = ⌈log_75 319⌉ = **2** → Acessos = 2 + 1 = **3**

**Árvore B+ em (CPF_Supervisor)** — chave 11B

- Nó índice: 2.048 ≥ (m−1)×(11B + 12B) + 12B → (m−1) = ⌊2.036/23⌋ = 88 → ordem **m = 89**
- Altura: h = ⌈log_89 3.500⌉ = **2** → nós índice hi = h − 1 = 1
- Nó registro (folha): 2.048 ≥ (m−1)×(11B + 16B) + 12B → (m−1) = ⌊2.036/27⌋ = 75
- Fator de bloco (69%): FB+ = 75 × 0,69 ≈ 51,75 = **52**
- Blocos folha: ⌈3.500 / 52⌉ = **68**
- Blocos de nós índice: ⌈68 / ((88×0,69) + 1)⌉ = ⌈68 / 62⌉ = **2**
- Espaço: (68 + 2) × 2KB = **140KB** ≈ 0,14MB
- Acessos: h + 1 = **3**

### Midias  (arquivo de dados: 357.143 blocos, 10.000.000 registros)

**Índice multinível estático (ISAM) em (Identificador)**

- Entrada: 24B + 16B = 40B → fan-out fo = ⌊2.048/40⌋ = **51**
- Blocos por nível: BM1 = 7.003, BM2 = 138, BM3 = 3, BM4 = 1
- Total: 7.145 blocos → Espaço = 7.145 × 2KB = **14.290KB**
- Níveis: h = ⌈log_51 357.143⌉ = **4** → Acessos = 4 + 1 = **5**

**Árvore B+ em (CodFilme)** — chave 16B

- Nó índice: 2.048 ≥ (m−1)×(16B + 12B) + 12B → (m−1) = ⌊2.036/28⌋ = 72 → ordem **m = 73**
- Altura: h = ⌈log_73 10.000.000⌉ = **4** → nós índice hi = h − 1 = 3
- Nó registro (folha): 2.048 ≥ (m−1)×(16B + 16B) + 12B → (m−1) = ⌊2.036/32⌋ = 63
- Fator de bloco (69%): FB+ = 63 × 0,69 ≈ 43,47 = **43**
- Blocos folha: ⌈10.000.000 / 43⌉ = **232.559**
- Blocos de nós índice: ⌈232.559 / ((72×0,69) + 3)⌉ = ⌈232.559 / 53⌉ = **4.388**
- Espaço: (232.559 + 4.388) × 2KB = **473.894KB** ≈ 462,79MB
- Acessos: h + 1 = **5**

### Aluguel  (arquivo de dados: 909.091 blocos, 20.000.000 registros)

**Índice multinível estático (ISAM) em (CPF_Cliente, ID_Midia, DataLocacao)**

- Entrada: 47B + 16B = 63B → fan-out fo = ⌊2.048/63⌋ = **32**
- Blocos por nível: BM1 = 28.410, BM2 = 888, BM3 = 28, BM4 = 1
- Total: 29.327 blocos → Espaço = 29.327 × 2KB = **58.654KB**
- Níveis: h = ⌈log_32 909.091⌉ = **4** → Acessos = 4 + 1 = **5**

**Árvore B+ em (CPF_Cliente)** — chave 11B

- Nó índice: 2.048 ≥ (m−1)×(11B + 12B) + 12B → (m−1) = ⌊2.036/23⌋ = 88 → ordem **m = 89**
- Altura: h = ⌈log_89 20.000.000⌉ = **4** → nós índice hi = h − 1 = 3
- Nó registro (folha): 2.048 ≥ (m−1)×(11B + 16B) + 12B → (m−1) = ⌊2.036/27⌋ = 75
- Fator de bloco (69%): FB+ = 75 × 0,69 ≈ 51,75 = **52**
- Blocos folha: ⌈20.000.000 / 52⌉ = **384.616**
- Blocos de nós índice: ⌈384.616 / ((88×0,69) + 3)⌉ = ⌈384.616 / 64⌉ = **6.010**
- Espaço: (384.616 + 6.010) × 2KB = **781.252KB** ≈ 762,94MB
- Acessos: h + 1 = **5**

**Árvore B+ em (ID_Midia)** — chave 24B

- Nó índice: 2.048 ≥ (m−1)×(24B + 12B) + 12B → (m−1) = ⌊2.036/36⌋ = 56 → ordem **m = 57**
- Altura: h = ⌈log_57 20.000.000⌉ = **5** → nós índice hi = h − 1 = 4
- Nó registro (folha): 2.048 ≥ (m−1)×(24B + 16B) + 12B → (m−1) = ⌊2.036/40⌋ = 50
- Fator de bloco (69%): FB+ = 50 × 0,69 ≈ 34,50 = **34**
- Blocos folha: ⌈20.000.000 / 34⌉ = **588.236**
- Blocos de nós índice: ⌈588.236 / ((56×0,69) + 4)⌉ = ⌈588.236 / 43⌉ = **13.680**
- Espaço: (588.236 + 13.680) × 2KB = **1.203.832KB** ≈ 1.175,62MB
- Acessos: h + 1 = **6**

**Árvore B+ em (CPF_Funcionario)** — chave 11B

- Nó índice: 2.048 ≥ (m−1)×(11B + 12B) + 12B → (m−1) = ⌊2.036/23⌋ = 88 → ordem **m = 89**
- Altura: h = ⌈log_89 20.000.000⌉ = **4** → nós índice hi = h − 1 = 3
- Nó registro (folha): 2.048 ≥ (m−1)×(11B + 16B) + 12B → (m−1) = ⌊2.036/27⌋ = 75
- Fator de bloco (69%): FB+ = 75 × 0,69 ≈ 51,75 = **52**
- Blocos folha: ⌈20.000.000 / 52⌉ = **384.616**
- Blocos de nós índice: ⌈384.616 / ((88×0,69) + 3)⌉ = ⌈384.616 / 64⌉ = **6.010**
- Espaço: (384.616 + 6.010) × 2KB = **781.252KB** ≈ 762,94MB
- Acessos: h + 1 = **5**

### Pagamentos  (arquivo de dados: 3.333.334 blocos, 50.000.000 registros)

**Índice multinível estático (ISAM) em (Codigo)**

- Entrada: 48B + 16B = 64B → fan-out fo = ⌊2.048/64⌋ = **32**
- Blocos por nível: BM1 = 104.167, BM2 = 3.256, BM3 = 102, BM4 = 4, BM5 = 1
- Total: 107.530 blocos → Espaço = 107.530 × 2KB = **215.060KB**
- Níveis: h = ⌈log_32 3.333.334⌉ = **5** → Acessos = 5 + 1 = **6**

**Árvore B+ em (CPF_Cliente, ID_Midia, DataLocacao)** — chave 47B

- Nó índice: 2.048 ≥ (m−1)×(47B + 12B) + 12B → (m−1) = ⌊2.036/59⌋ = 34 → ordem **m = 35**
- Altura: h = ⌈log_35 50.000.000⌉ = **5** → nós índice hi = h − 1 = 4
- Nó registro (folha): 2.048 ≥ (m−1)×(47B + 16B) + 12B → (m−1) = ⌊2.036/63⌋ = 32
- Fator de bloco (69%): FB+ = 32 × 0,69 ≈ 22,08 = **22**
- Blocos folha: ⌈50.000.000 / 22⌉ = **2.272.728**
- Blocos de nós índice: ⌈2.272.728 / ((34×0,69) + 4)⌉ = ⌈2.272.728 / 27⌉ = **84.176**
- Espaço: (2.272.728 + 84.176) × 2KB = **4.713.808KB** ≈ 4.603,33MB
- Acessos: h + 1 = **6**

### AtoresEmFilmes  (arquivo de dados: 15.625 blocos, 1.000.000 registros)

**Índice multinível estático (ISAM) em (CodFilme, CodAtor)**

- Entrada: 32B + 16B = 48B → fan-out fo = ⌊2.048/48⌋ = **42**
- Blocos por nível: BM1 = 373, BM2 = 9, BM3 = 1
- Total: 383 blocos → Espaço = 383 × 2KB = **766KB**
- Níveis: h = ⌈log_42 15.625⌉ = **3** → Acessos = 3 + 1 = **4**

**Árvore B+ em (CodFilme)** — chave 16B

- Nó índice: 2.048 ≥ (m−1)×(16B + 12B) + 12B → (m−1) = ⌊2.036/28⌋ = 72 → ordem **m = 73**
- Altura: h = ⌈log_73 1.000.000⌉ = **4** → nós índice hi = h − 1 = 3
- Nó registro (folha): 2.048 ≥ (m−1)×(16B + 16B) + 12B → (m−1) = ⌊2.036/32⌋ = 63
- Fator de bloco (69%): FB+ = 63 × 0,69 ≈ 43,47 = **43**
- Blocos folha: ⌈1.000.000 / 43⌉ = **23.256**
- Blocos de nós índice: ⌈23.256 / ((72×0,69) + 3)⌉ = ⌈23.256 / 53⌉ = **439**
- Espaço: (23.256 + 439) × 2KB = **47.390KB** ≈ 46,28MB
- Acessos: h + 1 = **5**

**Árvore B+ em (CodAtor)** — chave 16B

- Nó índice: 2.048 ≥ (m−1)×(16B + 12B) + 12B → (m−1) = ⌊2.036/28⌋ = 72 → ordem **m = 73**
- Altura: h = ⌈log_73 1.000.000⌉ = **4** → nós índice hi = h − 1 = 3
- Nó registro (folha): 2.048 ≥ (m−1)×(16B + 16B) + 12B → (m−1) = ⌊2.036/32⌋ = 63
- Fator de bloco (69%): FB+ = 63 × 0,69 ≈ 43,47 = **43**
- Blocos folha: ⌈1.000.000 / 43⌉ = **23.256**
- Blocos de nós índice: ⌈23.256 / ((72×0,69) + 3)⌉ = ⌈23.256 / 53⌉ = **439**
- Espaço: (23.256 + 439) × 2KB = **47.390KB** ≈ 46,28MB
- Acessos: h + 1 = **5**
