# HO14: Processamento de Transação

> Definições do Tópico #19 do Prof. Wlad.

```
T1 = r(x), r(y), w(x), r(z)
T2 = r(z), r(x), r(y), w(z)
T3 = r(y), r(z), w(y), r(x)

        1      2      3      4      5      6      7      8      9      10     11     12
Sa = r3(y), r2(z), r1(x), r2(x), r3(z), r2(y), w3(y), r1(y), w2(z), w1(x), r3(x), r1(z)
```

## 1. O escalonamento Sa é completo?

**Sim.** Um escalonamento é completo quando possui todas as operações de cada transação, as operações são exatamente as das transações originais e a ordem delas dentro de cada transação é preservada:

| Transação | Operações em Sa (posição) | Ordem preservada? |
|---|---|---|
| T1 | r1(x) 3 → r1(y) 8 → w1(x) 10 → r1(z) 12 | ✔ |
| T2 | r2(z) 2 → r2(x) 4 → r2(y) 6 → w2(z) 9 | ✔ |
| T3 | r3(y) 1 → r3(z) 5 → w3(y) 7 → r3(x) 11 | ✔ |

Sa tem as 12 operações (4 de cada transação), nenhuma operação extra, e a ordem interna de cada transação é a mesma das originais.

## 2. Com c2, c3, c1 no final, Sa é recuperável?

Sa' = …, r1(z), **c2, c3, c1**

**Leituras sujas** (uma transação lê um item escrito por outra que ainda não confirmou):

| Escrita | Leitura suja | Quem lê de quem |
|---|---|---|
| w3(y) (7) | r1(y) (8) | T1 lê y de T3 |
| w2(z) (9) | r1(z) (12) | T1 lê z de T2 |
| w1(x) (10) | r3(x) (11) | T3 lê x de T1 |

Recuperável = nenhuma transação que leu um item escrito por outra pode confirmar **antes** da que escreveu.
- T1 leu de T3 e T2: c1 vem depois de c3 e c2 ✔
- T3 leu de T1: **c3 vem antes de c1** ✘

**Sa não é recuperável.** T3 confirma depois de ler x escrito por T1, que ainda não confirmou. Se T1 abortar, T3 (já confirmada) teria de ser desfeita, violando a durabilidade.

## 3. Sa é serializável?

**Operações em conflito** (transações diferentes, mesmo item, pelo menos uma escrita):

| Item | Conflito (ordem em Sa) | Precedência |
|---|---|---|
| x | r2(x) 4 → w1(x) 10 | T2 antes de T1 |
| x | w1(x) 10 → r3(x) 11 | T1 antes de T3 |
| y | r2(y) 6 → w3(y) 7 | T2 antes de T3 |
| y | w3(y) 7 → r1(y) 8 | T3 antes de T1 |
| z | r3(z) 5 → w2(z) 9 | T3 antes de T2 |
| z | w2(z) 9 → r1(z) 12 | T2 antes de T1 |

**Grafo de precedência** (convenção do professor: aresta **da transação sucedente para a precedente**):

```
T1 → T2   (r2(x) < w1(x)  e  w2(z) < r1(z))
T3 → T1   (w1(x) < r3(x))
T3 → T2   (r2(y) < w3(y))
T1 → T3   (w3(y) < r1(y))
T2 → T3   (r3(z) < w2(z))

        ┌──────► T2 ◄──────┐
        │         │  ▲     │
        │         ▼  │     │
       T1 ◄──────── T3 ────┘
        └──────────►┘
```
Arestas: T1→T2, T1→T3, T3→T1, T2→T3, T3→T2.

O grafo tem **ciclos**: T1 → T3 → T1 e T2 → T3 → T2. Portanto **Sa não é serializável** (não é equivalente por conflito a nenhum escalonamento serial).

> No Elmasri a seta vai da precedente para a sucedente (T2→T1, T1→T3, T2→T3, T3→T1, T3→T2). Os ciclos são os mesmos e a conclusão também.
