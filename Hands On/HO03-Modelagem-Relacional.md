# HO03: Modelagem Relacional — BPE (v1.0)

> Diagrama de esquema na notação de Elmasri & Navathe (Fig. 3.7 / 5.7): chave primária <u>sublinhada</u>, setas das chaves estrangeiras para a chave referenciada. Mapeamento ER→Relacional do cap. 9 e do Tópico #06 do Prof. Wlad.

## 1. Modelo conceitual de partida (resumo)

- **FUNCIONARIO** (<u>CPF</u>, Nome, Endereco, Telefone, Sexo, Salario)
- **DEPENDENTE** — entidade **fraca** de FUNCIONARIO (CPF, Nome, Sexo, DataNascimento, Parentesco)
- **DEPARTAMENTO** (<u>Sigla</u>, Nome, {Locais (Cidade, Estado, Pais)} — multivalorado composto)
- **PROJETO** (<u>Sigla</u>, Nome, DataConclusao, *TotalHoras* — derivado)
- ALOCADO: FUNCIONARIO N:1 DEPARTAMENTO (total em FUNCIONARIO)
- POSSUI: FUNCIONARIO 1:N DEPENDENTE (identificador, total em DEPENDENTE)
- SUPERVISIONA: FUNCIONARIO 1:N FUNCIONARIO (recursivo, parcial)
- GERENCIA: FUNCIONARIO 1:N DEPARTAMENTO (total em DEPARTAMENTO)
- DESENVOLVE: DEPARTAMENTO M:N PROJETO, atributo Horas
- TRABALHA: FUNCIONARIO M:N (DEPARTAMENTO–DESENVOLVE–PROJETO), atributo Horas. É um relacionamento com a **agregação** DESENVOLVE, porque "somente os funcionários alocados em um departamento trabalham nos projetos desenvolvidos por aquele departamento".

## 2. Esquema relacional

```
FUNCIONARIO ( CPF, Nome, Endereco, Telefone, Sexo, Salario, Departamento, Supervisor )
              ‾‾‾
DEPENDENTE  ( Funcionario, CPF, Nome, Sexo, DataNascimento, Parentesco )
              ‾‾‾‾‾‾‾‾‾‾‾  ‾‾‾
DEPARTAMENTO( Sigla, Nome, Gerente )
              ‾‾‾‾‾
LOCAL       ( Departamento, Cidade, Estado, Pais )
              ‾‾‾‾‾‾‾‾‾‾‾‾  ‾‾‾‾‾‾  ‾‾‾‾‾‾  ‾‾‾‾
PROJETO     ( Sigla, Nome, DataConclusao )
              ‾‾‾‾‾
DESENVOLVE  ( Departamento, Projeto, Horas )
              ‾‾‾‾‾‾‾‾‾‾‾‾  ‾‾‾‾‾‾‾
TRABALHA    ( Funcionario, Departamento, Projeto, Horas )
              ‾‾‾‾‾‾‾‾‾‾‾  ‾‾‾‾‾‾‾‾‾‾‾‾  ‾‾‾‾‾‾‾
```

### Chaves estrangeiras (setas do diagrama)

| Origem | → | Destino | Observação |
|---|---|---|---|
| FUNCIONARIO.Departamento | → | DEPARTAMENTO.Sigla | NOT NULL (alocação obrigatória) |
| FUNCIONARIO.Supervisor | → | FUNCIONARIO.CPF | recursivo, admite NULL |
| DEPENDENTE.Funcionario | → | FUNCIONARIO.CPF | entidade fraca: faz parte da PK, ON DELETE CASCADE |
| DEPARTAMENTO.Gerente | → | FUNCIONARIO.CPF | NOT NULL (todo depto tem gerente) |
| LOCAL.Departamento | → | DEPARTAMENTO.Sigla | atributo multivalorado composto |
| DESENVOLVE.Departamento | → | DEPARTAMENTO.Sigla | relacionamento M:N |
| DESENVOLVE.Projeto | → | PROJETO.Sigla | relacionamento M:N |
| TRABALHA.(Departamento, Projeto) | → | DESENVOLVE.(Departamento, Projeto) | só projetos que o depto desenvolve |
| TRABALHA.(Funcionario, Departamento) | → | FUNCIONARIO.(CPF, Departamento) | só funcionários alocados no depto (exige UNIQUE(CPF, Departamento) em FUNCIONARIO) |

### Diagrama de esquema

```
FUNCIONARIO
┌─────┬──────┬──────────┬──────────┬──────┬─────────┬──────────────┬────────────┐
│ CPF │ Nome │ Endereco │ Telefone │ Sexo │ Salario │ Departamento │ Supervisor │
└─────┴──────┴──────────┴──────────┴──────┴─────────┴──────┬───────┴─────┬──────┘
   ▲   ▲  ▲                                                 │             │
   │   │  └─────────────────────────────────────────────────┼─────────────┘ (Supervisor → CPF)
   │   │                                                    ▼
   │   │   DEPARTAMENTO        ┌───────┬──────┬─────────┐
   │   └───────────────────────│ Sigla │ Nome │ Gerente │ (Gerente → FUNCIONARIO.CPF)
   │                           └───────┴──────┴─────────┘
   │                               ▲  ▲  ▲
   │   LOCAL ┌──────────────┬────────┬────────┬──────┐
   │         │ Departamento │ Cidade │ Estado │ Pais │──► DEPARTAMENTO.Sigla
   │         └──────────────┴────────┴────────┴──────┘
   │   DEPENDENTE ┌─────────────┬─────┬──────┬──────┬────────────────┬────────────┐
   ├──────────────│ Funcionario │ CPF │ Nome │ Sexo │ DataNascimento │ Parentesco │
   │              └─────────────┴─────┴──────┴──────┴────────────────┴────────────┘
   │   PROJETO ┌───────┬──────┬───────────────┐
   │           │ Sigla │ Nome │ DataConclusao │
   │           └───────┴──────┴───────────────┘
   │                ▲
   │   DESENVOLVE ┌──────────────┬─────────┬───────┐
   │              │ Departamento │ Projeto │ Horas │ ──► DEPARTAMENTO.Sigla / PROJETO.Sigla
   │              └──────────────┴─────────┴───────┘
   │                      ▲ (Departamento, Projeto)
   │   TRABALHA ┌─────────────┬──────────────┬─────────┬───────┐
   └────────────│ Funcionario │ Departamento │ Projeto │ Horas │
                └─────────────┴──────────────┴─────────┴───────┘
```

## 3. Justificativas do mapeamento

1. **Entidades fortes** → uma relação cada (FUNCIONARIO, DEPARTAMENTO, PROJETO).
2. **Entidade fraca DEPENDENTE** → relação própria cuja PK inclui a PK do dono: (Funcionario, CPF). Mesmo com o CPF do dependente sendo único, a dependência de existência é garantida pela FK com `ON DELETE CASCADE`.
3. **1:N ALOCADO** → FK `Departamento` em FUNCIONARIO (lado N), **NOT NULL** por causa da participação total.
4. **1:N recursivo SUPERVISIONA** → FK `Supervisor` em FUNCIONARIO, admite NULL ("alguns funcionários").
5. **1:N GERENCIA** → FK `Gerente` em DEPARTAMENTO (lado com participação total), NOT NULL.
6. **Atributo multivalorado composto Locais** → relação LOCAL com PK (Departamento, Cidade, Estado, Pais).
7. **M:N DESENVOLVE** → relação própria com PK composta pelas FKs, mais o atributo Horas.
8. **TRABALHA** → relação com FK composta para DESENVOLVE (agregação). Assim o funcionário só pode trabalhar em projeto desenvolvido pelo departamento, e a FK (Funcionario, Departamento) garante que ele esteja alocado nesse departamento. PK (Funcionario, Projeto).
9. **TotalHoras de PROJETO** é **derivado** (`SUM(TRABALHA.Horas)` por projeto), por isso não é armazenado.
