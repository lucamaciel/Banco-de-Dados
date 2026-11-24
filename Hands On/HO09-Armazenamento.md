# HO09: Armazenamento e Organização de Dados

> Método do Tópico #12 (Organização de Dados) do Prof. Wlad: bloco t = 2KB = 2.048B, registros de tamanho fixo e **não espalhados**.
> - Fator de bloco: **F = ⌊t / r⌋**
> - Nº de blocos: **B = ⌈n / F⌉**
> - Espaço não usado por bloco: **U = t − (F × r)**
> - Espaço total: **S = B × t**

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

### Atores

- Registro: Codigo (16B) + Nome (160B) = **176B**
- Fator de bloco: F = ⌊2.048B / 176B⌋ = ⌊11,64⌋ = **11** registros/bloco
- Nº de blocos: B = ⌈10.000 / 11⌉ = ⌈909,09⌉ = **910** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (11 × 176B) = **112B**
- Espaço total: S = 910 × 2KB = **1.820KB** ≈ 1,78MB (0,00GB)

### Clientes

- Registro: CPF (11B) + Nome (160B) + Endereco (200B) + Telefone (16B) + DataNascimento (12B) + Sexo (1B) = **400B**
- Fator de bloco: F = ⌊2.048B / 400B⌋ = ⌊5,12⌋ = **5** registros/bloco
- Nº de blocos: B = ⌈100.000 / 5⌉ = ⌈20.000,00⌉ = **20.000** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (5 × 400B) = **48B**
- Espaço total: S = 20.000 × 2KB = **40.000KB** ≈ 39,06MB (0,04GB)

### Filmes

- Registro: Codigo (16B) + Nome (160B) + Genero (80B) = **256B**
- Fator de bloco: F = ⌊2.048B / 256B⌋ = ⌊8,00⌋ = **8** registros/bloco
- Nº de blocos: B = ⌈2.000.000 / 8⌉ = ⌈250.000,00⌉ = **250.000** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (8 × 256B) = **0B**
- Espaço total: S = 250.000 × 2KB = **500.000KB** ≈ 488,28MB (0,48GB)

### Funcionarios

- Registro: CPF (11B) + Nome (160B) + CPF_Supervisor (11B) = **182B**
- Fator de bloco: F = ⌊2.048B / 182B⌋ = ⌊11,25⌋ = **11** registros/bloco
- Nº de blocos: B = ⌈3.500 / 11⌉ = ⌈318,18⌉ = **319** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (11 × 182B) = **46B**
- Espaço total: S = 319 × 2KB = **638KB** ≈ 0,62MB (0,00GB)

### Midias

- Registro: Identificador (24B) + Tipo (8B) + PrecoDiaria (24B) + CodFilme (16B) = **72B**
- Fator de bloco: F = ⌊2.048B / 72B⌋ = ⌊28,44⌋ = **28** registros/bloco
- Nº de blocos: B = ⌈10.000.000 / 28⌉ = ⌈357.142,86⌉ = **357.143** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (28 × 72B) = **32B**
- Espaço total: S = 357.143 × 2KB = **714.286KB** ≈ 697,54MB (0,68GB)

### Aluguel

- Registro: CPF_Cliente (11B) + ID_Midia (24B) + DataLocacao (12B) + DataDevolucao (10B) + ValorPagar (24B) + CPF_Funcionario (11B) = **92B**
- Fator de bloco: F = ⌊2.048B / 92B⌋ = ⌊22,26⌋ = **22** registros/bloco
- Nº de blocos: B = ⌈20.000.000 / 22⌉ = ⌈909.090,91⌉ = **909.091** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (22 × 92B) = **24B**
- Espaço total: S = 909.091 × 2KB = **1.818.182KB** ≈ 1.775,57MB (1,73GB)

### Pagamentos

- Registro: Codigo (48B) + CPF_Cliente (11B) + ID_Midia (24B) + DataLocacao (12B) + Data (12B) + Valor (24B) = **131B**
- Fator de bloco: F = ⌊2.048B / 131B⌋ = ⌊15,63⌋ = **15** registros/bloco
- Nº de blocos: B = ⌈50.000.000 / 15⌉ = ⌈3.333.333,33⌉ = **3.333.334** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (15 × 131B) = **83B**
- Espaço total: S = 3.333.334 × 2KB = **6.666.668KB** ≈ 6.510,42MB (6,36GB)

### AtoresEmFilmes

- Registro: CodFilme (16B) + CodAtor (16B) = **32B**
- Fator de bloco: F = ⌊2.048B / 32B⌋ = ⌊64,00⌋ = **64** registros/bloco
- Nº de blocos: B = ⌈1.000.000 / 64⌉ = ⌈15.625,00⌉ = **15.625** blocos
- Espaço desperdiçado por bloco: U = 2.048B − (64 × 32B) = **0B**
- Espaço total: S = 15.625 × 2KB = **31.250KB** ≈ 30,52MB (0,03GB)

## Resumo

| Arquivo | Registro | F | Blocos | Desperdício/bloco | Espaço total |
|---|---|---|---|---|---|
| Atores | 176B | 11 | 910 | 112B | 1.820KB |
| Clientes | 400B | 5 | 20.000 | 48B | 40.000KB |
| Filmes | 256B | 8 | 250.000 | 0B | 500.000KB |
| Funcionarios | 182B | 11 | 319 | 46B | 638KB |
| Midias | 72B | 28 | 357.143 | 32B | 714.286KB |
| Aluguel | 92B | 22 | 909.091 | 24B | 1.818.182KB |
| Pagamentos | 131B | 15 | 3.333.334 | 83B | 6.666.668KB |
| AtoresEmFilmes | 32B | 64 | 15.625 | 0B | 31.250KB |
