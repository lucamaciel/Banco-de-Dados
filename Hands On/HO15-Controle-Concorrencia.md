# HO15: Controle de Concorrência

> Técnicas do Tópico #20 do Prof. Wlad. Commit implícito logo após a última operação de cada transação. No 2PL **estrito** os bloqueios só são liberados no commit/abort. Detecção de deadlock: aborta-se a transação **mais recente** (a que começou por último).

```
        1      2      3      4      5      6      7      8      9      10     11     12
Sa = r3(y), r2(z), r1(x), r2(x), r3(z), r2(y), w3(y), r1(y), w2(z), w1(x), r3(x), r1(z)
```
Ordem de início: T3 (pos. 1) → T2 (pos. 2) → T1 (pos. 3). **T1 é a mais recente, depois T2, e T3 é a mais antiga.**
Última operação: T2 = w2(z) (9), T3 = r3(x) (11), T1 = r1(z) (12).

---

## 1. Bloqueio exclusivo (binário), 2PL estrito

Com bloqueio binário, qualquer acesso (r ou w) exige o bloqueio exclusivo l(item).

| Passo | Operação | Ação | Estado |
|---|---|---|---|
| 1 | r3(y) | l3(y) ✔ | T3: y |
| 2 | r2(z) | l2(z) ✔ | T2: z |
| 3 | r1(x) | l1(x) ✔ | T1: x |
| 4 | r2(x) | x com T1 → **T2 espera T1** | |
| 5 | r3(z) | z com T2 → **T3 espera T2** | |
| 6–7 | r2(y), w3(y) | T2 e T3 já bloqueadas (ficam na fila) | |
| 8 | r1(y) | y com T3 → **T1 espera T3** | |

**Grafo de espera:** T1 → T3 → T2 → T1. **Deadlock entre T1, T2 e T3.**

Resolução:
1. Aborta **T1** (a mais recente) e libera x.
2. T2 obtém x: **r2(x)**. Em seguida pede y (r2(y)), mas y está com T3 → T2 espera T3, e T3 ainda espera T2 (z). **Novo deadlock entre T2 e T3.**
3. Aborta **T2** (mais recente que T3) e libera z e x.
4. T3 prossegue: r3(z), w3(y), r3(x), **c3**.

**Escalonamento efetivamente executado** (as operações de transações abortadas são desfeitas):
```
Sa = r3(y), r3(z), w3(y), r3(x), c3
```
T1 e T2 são abortadas e reescalonadas. Mantendo os timestamps originais (T2 mais antiga que T1), elas executam depois: `r2(z), r2(x), r2(y), w2(z), c2, r1(x), r1(y), w1(x), r1(z), c1`.

---

## 2. Bloqueio compartilhado (ternário), 2PL estrito

Leitura usa rl (compartilhado). Escrita usa wl (exclusivo, com promoção do rl).

| Passo | Operação | Ação | Bloqueios |
|---|---|---|---|
| 1 | r3(y) | rl3(y) ✔ | y: {T3} |
| 2 | r2(z) | rl2(z) ✔ | z: {T2} |
| 3 | r1(x) | rl1(x) ✔ | x: {T1} |
| 4 | r2(x) | rl2(x) ✔ (compartilhado) | x: {T1,T2} |
| 5 | r3(z) | rl3(z) ✔ | z: {T2,T3} |
| 6 | r2(y) | rl2(y) ✔ | y: {T3,T2} |
| 7 | w3(y) | wl3(y): y lido por T2 → **T3 espera T2** | |
| 8 | r1(y) | rl1(y) ✔ (compartilhado) | y: {T3,T2,T1} |
| 9 | w2(z) | wl2(z): z lido por T3 → **T2 espera T3** | |

**Grafo de espera:** T3 → T2 → T3. **Deadlock entre T2 e T3.** A mais recente das duas é **T2**, que é abortada (libera rl2(z), rl2(x), rl2(y)).

Continuação:
- T3 ainda não consegue wl3(y), porque y também está bloqueado para leitura por T1 → T3 espera T1.
- 10: w1(x) → wl1(x) ✔ (agora só T1 tem x).
- 11: r3(x) → T3 está bloqueada (fica na fila).
- 12: r1(z) → rl1(z) ✔ (compartilhado com T3). T1 termina → **c1**, libera x, y e z.
- T3 obtém wl3(y): **w3(y)**, depois rl3(x): **r3(x)**, e **c3**.

**Escalonamento efetivamente executado:**
```
Sa = r3(y), r1(x), r3(z), r1(y), w1(x), r1(z), c1, w3(y), r3(x), c3
```
T2 é abortada e reescalonada depois: `r2(z), r2(x), r2(y), w2(z), c2`.

---

## 3. Ordenação por timestamp

TS pela ordem de início: **TS(T3) = 1, TS(T2) = 2, TS(T1) = 3**.
Regras:
- **r(x)** por T: se wTS(x) > TS(T), rejeita e aborta T. Senão aceita e faz rTS(x) = max(rTS(x), TS(T)).
- **w(x)** por T: se rTS(x) > TS(T) ou wTS(x) > TS(T), rejeita e aborta T. Senão aceita e faz wTS(x) = TS(T).

| Passo | Operação | Teste | Resultado | rTS/wTS após |
|---|---|---|---|---|
| 1 | r3(y) | wTS(y)=0 ≤ 1 | ✔ | rTS(y)=1 |
| 2 | r2(z) | wTS(z)=0 ≤ 2 | ✔ | rTS(z)=2 |
| 3 | r1(x) | wTS(x)=0 ≤ 3 | ✔ | rTS(x)=3 |
| 4 | r2(x) | wTS(x)=0 ≤ 2 | ✔ | rTS(x)=max(3,2)=3 |
| 5 | r3(z) | wTS(z)=0 ≤ 1 | ✔ | rTS(z)=max(2,1)=2 |
| 6 | r2(y) | wTS(y)=0 ≤ 2 | ✔ | rTS(y)=max(1,2)=2 |
| 7 | w3(y) | rTS(y)=2 > TS(T3)=1 | ✘ **aborta T3** | — |
| 8 | r1(y) | wTS(y)=0 ≤ 3 | ✔ | rTS(y)=3 |
| 9 | w2(z) | rTS(z)=2 ≤ 2, wTS(z)=0 ≤ 2 | ✔ | wTS(z)=2 |
| 10 | w1(x) | rTS(x)=3 ≤ 3, wTS(x)=0 ≤ 3 | ✔ | wTS(x)=3 |
| 11 | r3(x) | T3 abortada | — | — |
| 12 | r1(z) | wTS(z)=2 ≤ 3 | ✔ | rTS(z)=3 |

**Escalonamento efetivamente executado** (sem as operações da T3 abortada, como no exemplo do professor):
```
Sa = r2(z), r1(x), r2(x), r2(y), r1(y), w2(z), w1(x), r1(z)
```
Esse escalonamento é equivalente ao serial T2 → T1 (ordem de timestamp). Não há deadlock. T3 seria reiniciada com um novo timestamp.
