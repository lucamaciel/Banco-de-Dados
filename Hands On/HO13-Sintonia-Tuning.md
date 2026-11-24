# HO13: Sintonia (Tuning)

> Base: Tópicos #17 (otimização semântica) e #18 (Projeto Físico) do Prof. Wlad. Como **não conhecemos os índices**, reescrevemos as consultas para que o otimizador tenha mais chance de usar algum caminho de acesso eficiente:
> - trocar subconsultas `IN` / `NOT IN` / `EXISTS` correlacionadas por **junções** (o professor mostra que `WHERE CPF IN (SELECT ...)` exige força bruta, enquanto a junção permite loop único com índice);
> - evitar `OR` e desigualdades (`!=`), que impedem o uso de índices;
> - evitar `DISTINCT` desnecessário (gera ordenação).

---

## Consulta 1
```sql
SELECT DISTINCT A.CPF, A.Nome FROM Funcionarios A
WHERE A.CPF IN (SELECT CPF_Supervisor FROM Funcionarios)
  AND A.CPF NOT IN (SELECT CPF FROM Clientes)
```
**Problemas:** as duas subconsultas são avaliadas por força bruta. O `NOT IN` é especialmente caro (e tem semântica perigosa com NULL).

**Reescrita:**
```sql
SELECT DISTINCT A.CPF, A.Nome
FROM Funcionarios A
JOIN Funcionarios S ON S.CPF_Supervisor = A.CPF      -- A é supervisor
LEFT JOIN Clientes C ON C.CPF = A.CPF                -- anti-junção
WHERE C.CPF IS NULL;                                  -- A não é cliente
```
O `DISTINCT` continua necessário, porque um supervisor aparece uma vez para cada subordinado. Com índices em `CPF_Supervisor` e `Clientes.CPF` (PK), as duas junções são feitas por loop único.

---

## Consulta 2
```sql
SELECT A.CodFilme, B.Nome FROM Midias A, Filmes B
WHERE A.CodFilme = B.Codigo AND A.Tipo = "DVD" OR A.Tipo = "VHS"
```
**Problema:** `AND` tem precedência sobre `OR`. A consulta é lida como `(A.CodFilme = B.Codigo AND A.Tipo='DVD') OR A.Tipo='VHS'`, ou seja, toda mídia VHS é combinada com **todos** os filmes (produto cartesiano). Isso dá resultado errado e custo enorme. Além disso, o `OR` impede o uso de índice.

**Reescrita (corrige a semântica):**
```sql
SELECT A.CodFilme, B.Nome
FROM Midias A JOIN Filmes B ON A.CodFilme = B.Codigo
WHERE A.Tipo IN ('DVD', 'VHS');
```
**Alternativa sem OR**, para que cada parte use um índice em `Tipo`, se existir:
```sql
SELECT A.CodFilme, B.Nome FROM Midias A JOIN Filmes B ON A.CodFilme = B.Codigo WHERE A.Tipo = 'DVD'
UNION ALL
SELECT A.CodFilme, B.Nome FROM Midias A JOIN Filmes B ON A.CodFilme = B.Codigo WHERE A.Tipo = 'VHS';
```

---

## Consulta 3
```sql
SELECT A.CPF_Cliente, A.ID_Midia, A.DataLocacao
FROM Aluguel A, Clientes B
WHERE A.CPF_Cliente = B.CPF AND B.Sexo != "F"
  AND EXISTS (SELECT * FROM Pagamentos C
              WHERE C.CPF_Cliente = A.CPF_Cliente AND C.ID_Midia = A.ID_Midia
                AND C.DataLocacao = A.DataLocacao)
```
**Problemas:** o `EXISTS` correlacionado é executado para cada uma das (até 20M) linhas de Aluguel. Além disso, `!=` não usa índice.

**Reescrita:**
```sql
SELECT DISTINCT A.CPF_Cliente, A.ID_Midia, A.DataLocacao
FROM Clientes B
JOIN Aluguel A    ON A.CPF_Cliente = B.CPF
JOIN Pagamentos C ON C.CPF_Cliente = A.CPF_Cliente
                 AND C.ID_Midia    = A.ID_Midia
                 AND C.DataLocacao = A.DataLocacao
WHERE B.Sexo = 'M';
```
- `Sexo != 'F'` vira `Sexo = 'M'` (igualdade, que pode usar índice). Só é equivalente se o domínio de Sexo for {F, M}, sem NULL.
- A ordem Clientes → Aluguel → Pagamentos começa pela menor tabela já filtrada.
- O `DISTINCT` é necessário porque um aluguel pode ter vários pagamentos (o `EXISTS` não duplicava). Como (CPF_Cliente, ID_Midia, DataLocacao) é a PK de Aluguel, o resultado continua correto.
