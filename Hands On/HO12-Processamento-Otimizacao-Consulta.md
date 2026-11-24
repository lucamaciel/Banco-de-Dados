# HO12: Processamento e Otimização de Consulta

> Método dos Tópicos #16 e #17 do Prof. Wlad (otimização heurística):
> - **Árvore inicial**: os arquivos do FROM entram como folhas, combinados por produto cartesiano (×) na ordem do parsing. As condições do WHERE viram seleções (σ) empilhadas na ordem do parsing, e a projeção (π) fica na raiz. No parsing **natural** a 1ª condição fica mais perto das folhas. No **reverso**, a última.
> - **Regras**: *reduzir para combinar*. Seleções, depois projeções, descem até as folhas. As junções (⨝) substituem σ+× e são reordenadas para executar primeiro as mais eficientes (menores entradas e índices disponíveis), **evitando produtos cartesianos**.
> - **Consulta reescrita**: ordem do FROM/WHERE ajustada para que o parsing já gere a árvore otimizada.
> - **Plano**: método de acesso/algoritmo de cada nó. Todos os arquivos são **ISAM** (índice multinível na PK) com **índices secundários nas FKs**.
>
> Cardinalidades: Funcionarios 3.500 · Clientes 100.000 · Filmes 2.000.000 · Midias 10.000.000 · Aluguel 20.000.000 · Pagamentos 50.000.000 · Atores 10.000 · AtoresEmFilmes 1.000.000.

---

## Consulta 1

```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Funcionarios A, Clientes B, Aluguel C, Funcionarios D
WHERE A.CPF=B.CPF AND B.CPF=C.CPF_Cliente AND B.Sexo="M"
  AND C.ValorPagar>50 AND A.CPF=D.CPF_Supervisor
```

### a) Árvore inicial — parsing natural (esquerda → direita)
```
π A.CPF, A.Nome, B.Nome
└─ σ A.CPF = D.CPF_Supervisor
   └─ σ C.ValorPagar > 50
      └─ σ B.Sexo = 'M'
         └─ σ B.CPF = C.CPF_Cliente
            └─ σ A.CPF = B.CPF
               └─ ×
                  ├─ ×
                  │  ├─ ×
                  │  │  ├─ A (Funcionarios)
                  │  │  └─ B (Clientes)
                  │  └─ C (Aluguel)
                  └─ D (Funcionarios)
```

### b) Árvore inicial — parsing reverso (direita → esquerda)
```
π A.CPF, A.Nome, B.Nome
└─ σ A.CPF = B.CPF
   └─ σ B.CPF = C.CPF_Cliente
      └─ σ B.Sexo = 'M'
         └─ σ C.ValorPagar > 50
            └─ σ A.CPF = D.CPF_Supervisor
               └─ ×
                  ├─ ×
                  │  ├─ ×
                  │  │  ├─ D (Funcionarios)
                  │  │  └─ C (Aluguel)
                  │  └─ B (Clientes)
                  └─ A (Funcionarios)
```

### c) Árvore otimizada
```
π A.CPF, A.Nome, B.Nome
└─ ⨝ B.CPF = C.CPF_Cliente
   ├─ ⨝ A.CPF = D.CPF_Supervisor
   │  ├─ ⨝ A.CPF = B.CPF
   │  │  ├─ π A.CPF, A.Nome
   │  │  │  └─ A (Funcionarios)
   │  │  └─ π B.CPF, B.Nome
   │  │     └─ σ B.Sexo = 'M'
   │  │        └─ B (Clientes)
   │  └─ π D.CPF_Supervisor
   │     └─ D (Funcionarios)
   └─ π C.CPF_Cliente
      └─ σ C.ValorPagar > 50
         └─ C (Aluguel)
```
Justificativa: a menor relação (Funcionarios, 3.500) entra primeiro e é combinada com Clientes já filtrado por sexo. O resultado é pequeno (funcionários que também são clientes). Depois vem D (3.500), e por último Aluguel, a maior relação (20M), já reduzida pela seleção.

### d) Consulta reescrita — parsing natural
```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Funcionarios A, Clientes B, Funcionarios D, Aluguel C
WHERE B.Sexo = 'M' AND C.ValorPagar > 50
  AND A.CPF = B.CPF AND A.CPF = D.CPF_Supervisor AND B.CPF = C.CPF_Cliente
```

### e) Consulta reescrita — parsing reverso
```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Aluguel C, Funcionarios D, Clientes B, Funcionarios A
WHERE B.CPF = C.CPF_Cliente AND A.CPF = D.CPF_Supervisor AND A.CPF = B.CPF
  AND C.ValorPagar > 50 AND B.Sexo = 'M'
```

### f) Plano de execução
1. **Pesquisa linear** em B (Clientes): `Sexo` não é indexado. Seleciona Sexo = 'M' e projeta CPF, Nome.
2. **Junção de loop único**: varre o resultado de (1) e pesquisa o **índice ISAM de A (PK CPF)**, projetando CPF, Nome.
3. **Junção de loop único**: varre o resultado de (2) e pesquisa o **índice secundário de D em CPF_Supervisor** (FK).
4. **Junção de loop único**: varre o resultado de (3) e pesquisa o **índice secundário de C em CPF_Cliente** (FK), aplicando `ValorPagar > 50` *on the fly* nos registros recuperados. Isso evita a pesquisa linear em 20M registros, porque `ValorPagar` não é indexado.
5. **Projeção** final (pipeline).

---

## Consulta 2

```sql
SELECT A.Nome, C.Nome
FROM Filmes A, AtoresEmFilmes B, Atores C, Midias D
WHERE A.Codigo=B.CodFilme AND B.CodAtor=C.Codigo AND A.Genero="Aventura"
  AND A.Codigo=D.CodFilme AND D.PrecoDiaria>10
```

### a) Árvore inicial — parsing natural
```
π A.Nome, C.Nome
└─ σ D.PrecoDiaria > 10
   └─ σ A.Codigo = D.CodFilme
      └─ σ A.Genero = 'Aventura'
         └─ σ B.CodAtor = C.Codigo
            └─ σ A.Codigo = B.CodFilme
               └─ ×
                  ├─ ×
                  │  ├─ ×
                  │  │  ├─ A (Filmes)
                  │  │  └─ B (AtoresEmFilmes)
                  │  └─ C (Atores)
                  └─ D (Midias)
```

### b) Árvore inicial — parsing reverso
```
π A.Nome, C.Nome
└─ σ A.Codigo = B.CodFilme
   └─ σ B.CodAtor = C.Codigo
      └─ σ A.Genero = 'Aventura'
         └─ σ A.Codigo = D.CodFilme
            └─ σ D.PrecoDiaria > 10
               └─ ×
                  ├─ ×
                  │  ├─ ×
                  │  │  ├─ D (Midias)
                  │  │  └─ C (Atores)
                  │  └─ B (AtoresEmFilmes)
                  └─ A (Filmes)
```

### c) Árvore otimizada
```
π A.Nome, C.Nome
└─ ⨝ A.Codigo = D.CodFilme
   ├─ ⨝ B.CodAtor = C.Codigo
   │  ├─ ⨝ A.Codigo = B.CodFilme
   │  │  ├─ π A.Codigo, A.Nome
   │  │  │  └─ σ A.Genero = 'Aventura'
   │  │  │     └─ A (Filmes)
   │  │  └─ B (AtoresEmFilmes)
   │  └─ π C.Codigo, C.Nome
   │     └─ C (Atores)
   └─ π D.CodFilme
      └─ σ D.PrecoDiaria > 10
         └─ D (Midias)
```

### d) Consulta reescrita — parsing natural
```sql
SELECT A.Nome, C.Nome
FROM Filmes A, AtoresEmFilmes B, Atores C, Midias D
WHERE A.Genero = 'Aventura' AND D.PrecoDiaria > 10
  AND A.Codigo = B.CodFilme AND B.CodAtor = C.Codigo AND A.Codigo = D.CodFilme
```

### e) Consulta reescrita — parsing reverso
```sql
SELECT A.Nome, C.Nome
FROM Midias D, Atores C, AtoresEmFilmes B, Filmes A
WHERE A.Codigo = D.CodFilme AND B.CodAtor = C.Codigo AND A.Codigo = B.CodFilme
  AND D.PrecoDiaria > 10 AND A.Genero = 'Aventura'
```

### f) Plano de execução
1. **Pesquisa linear** em A (Filmes): `Genero` não é indexado. Seleciona 'Aventura' e projeta Codigo, Nome.
2. **Junção de loop único**: varre (1) e pesquisa o **índice secundário de B em CodFilme**.
3. **Junção de loop único**: varre (2) e pesquisa o **índice ISAM de C (PK Codigo)**, projetando Codigo, Nome.
4. **Junção de loop único**: varre (3) e pesquisa o **índice secundário de D em CodFilme**, aplicando `PrecoDiaria > 10` *on the fly*.
5. **Projeção** final (pipeline).

---

## Consulta 3

```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Funcionarios A, Clientes B, Aluguel C, Pagamentos D
WHERE A.CPF=B.CPF AND C.ValorPagar>100 AND B.CPF=C.CPF_Cliente
  AND D.Valor<50 AND A.CPF_Supervisor IS NULL AND A.CPF=C.CPF_Funcionario
```
⚠️ **Pagamentos (D) não tem condição de junção** com as outras tabelas. Por isso permanece um **produto cartesiano** inevitável. Ele deve ficar por último, já com D reduzido pela seleção. Cada tupla do resultado se repete uma vez para cada pagamento com Valor < 50. Se nenhum existir, o resultado é vazio.

### a) Árvore inicial — parsing natural
```
π A.CPF, A.Nome, B.Nome
└─ σ A.CPF = C.CPF_Funcionario
   └─ σ A.CPF_Supervisor IS NULL
      └─ σ D.Valor < 50
         └─ σ B.CPF = C.CPF_Cliente
            └─ σ C.ValorPagar > 100
               └─ σ A.CPF = B.CPF
                  └─ ×
                     ├─ ×
                     │  ├─ ×
                     │  │  ├─ A (Funcionarios)
                     │  │  └─ B (Clientes)
                     │  └─ C (Aluguel)
                     └─ D (Pagamentos)
```

### b) Árvore inicial — parsing reverso
```
π A.CPF, A.Nome, B.Nome
└─ σ A.CPF = B.CPF
   └─ σ C.ValorPagar > 100
      └─ σ B.CPF = C.CPF_Cliente
         └─ σ D.Valor < 50
            └─ σ A.CPF_Supervisor IS NULL
               └─ σ A.CPF = C.CPF_Funcionario
                  └─ ×
                     ├─ ×
                     │  ├─ ×
                     │  │  ├─ D (Pagamentos)
                     │  │  └─ C (Aluguel)
                     │  └─ B (Clientes)
                     └─ A (Funcionarios)
```

### c) Árvore otimizada
```
π A.CPF, A.Nome, B.Nome
└─ ×
   ├─ ⨝ B.CPF = C.CPF_Cliente ∧ A.CPF = C.CPF_Funcionario
   │  ├─ ⨝ A.CPF = B.CPF
   │  │  ├─ π A.CPF, A.Nome
   │  │  │  └─ σ A.CPF_Supervisor IS NULL
   │  │  │     └─ A (Funcionarios)
   │  │  └─ π B.CPF, B.Nome
   │  │     └─ B (Clientes)
   │  └─ π C.CPF_Cliente, C.CPF_Funcionario
   │     └─ σ C.ValorPagar > 100
   │        └─ C (Aluguel)
   └─ π D.Codigo
      └─ σ D.Valor < 50
         └─ D (Pagamentos)
```

### d) Consulta reescrita — parsing natural
```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Funcionarios A, Clientes B, Aluguel C, Pagamentos D
WHERE A.CPF_Supervisor IS NULL AND C.ValorPagar > 100 AND D.Valor < 50
  AND A.CPF = B.CPF AND B.CPF = C.CPF_Cliente AND A.CPF = C.CPF_Funcionario
```

### e) Consulta reescrita — parsing reverso
```sql
SELECT A.CPF, A.Nome, B.Nome
FROM Pagamentos D, Aluguel C, Clientes B, Funcionarios A
WHERE A.CPF = C.CPF_Funcionario AND B.CPF = C.CPF_Cliente AND A.CPF = B.CPF
  AND D.Valor < 50 AND C.ValorPagar > 100 AND A.CPF_Supervisor IS NULL
```

### f) Plano de execução
1. **Pesquisa linear** em A (Funcionarios): seleciona `CPF_Supervisor IS NULL` (no índice secundário da FK os nulos não são indexados) e projeta CPF, Nome.
2. **Junção de loop único**: varre (1) e pesquisa o **índice ISAM de B (PK CPF)**.
3. **Junção de loop único**: varre (2) e pesquisa o **índice secundário de C em CPF_Funcionario**, testando `C.CPF_Cliente = B.CPF` e `ValorPagar > 100` *on the fly*.
4. **Pesquisa linear** em D (Pagamentos): `Valor` não é indexado. Seleciona `Valor < 50`.
5. **Produto cartesiano** (loop aninhado) entre (3) e (4), seguido da projeção final.
