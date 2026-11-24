# HO02: Modelagem Conceitual — DER do SAM (v1.0), notação de Peter Chen

> **Resolução do professor:** o próprio Prof. Wlad publicou o projeto do SAM v1.0 em `aulas/relational/specs/SAM/SAM.pdf` (Seção 3, Figura 1 e Tabela 2). O que está abaixo segue exatamente esse gabarito: 5 entidades (Aluno, Área, Curso, Módulo e Tópico, sendo Tópico **fraca**), 5 relacionamentos (*integra*, *matricula*, *possui* ×3) e 3 restrições de totalidade (Curso em *possui* com Área, Módulo em *possui* com Curso, Tópico em *possui* com Módulo).

## Legenda da notação de Chen

| Símbolo | Significado |
|---|---|
| Retângulo | Entidade forte |
| Retângulo duplo | Entidade fraca |
| Losango | Relacionamento |
| Losango duplo | Relacionamento identificador (da entidade fraca) |
| Elipse | Atributo |
| Elipse com nome <u>sublinhado</u> | Atributo-chave |
| Elipse com sublinhado tracejado | Chave parcial (entidade fraca) |
| Elipse dupla | Atributo multivalorado |
| Elipse tracejada | Atributo derivado |
| Elipse ligada a outras elipses | Atributo composto |
| Linha simples / dupla | Participação parcial / total |
| 1, N, M nas linhas | Razão de cardinalidade |

## Entidades

| Entidade | Tipo | Atributos |
|---|---|---|
| **AREA** | forte | <u>Sigla</u>, Nome |
| **CURSO** | forte | <u>Sigla</u>, Nome, Custo, *Horas* (derivado, elipse tracejada), **Professores** (multivalorado e composto, elipse dupla → CPF, Nome) |
| **ALUNO** | forte | <u>CPF</u>, Nome (composto → PrimeiroNome, Sobrenome), Sexo, DataNascimento |
| **MODULO** | forte | <u>Sigla</u>, Nome |
| **TOPICO** | **fraca** (retângulo duplo) | <u>Sigla</u> (chave **parcial**, sublinhado tracejado), Nome, Horas |

## Relacionamentos

| Relacionamento | Entidades | Cardinalidade | Participação | Atributos |
|---|---|---|---|---|
| **INTEGRA** (recursivo) | AREA (integrante) — AREA (integrada) | N : 1 (uma área integra no máximo **uma** área e pode ser integrada por várias) | parcial nos dois papéis | — |
| **PERTENCE** | CURSO — AREA | N : 1 | **total** em CURSO (linha dupla), parcial em AREA | — |
| **MATRICULA** | ALUNO — CURSO | M : N | parcial / parcial | **Data**, **Pago** |
| **COMPOE** | MODULO — CURSO | N : 1 | **total** em MODULO (não existe módulo sem curso), parcial em CURSO | — |
| **CONTEM** (identificador, losango duplo) | TOPICO — MODULO | N : 1 | **total** em TOPICO | — |

## Diagrama (esboço textual em notação de Chen)

```
                       (Nome)  (<u>Sigla</u>)
                           \     /
           integrada 1 ┌──────────┐ N integrante
              ┌────────│   AREA   │────────┐
              │        └──────────┘        │
              └──────────<INTEGRA>─────────┘
                            │ 1
                       <PERTENCE>
                            ║ N  (participação total)
 ((Professores))       ┌──────────┐      (Nome) (<u>Sigla</u>) (Custo) ( - Horas - )
   /       \  ═════════│  CURSO   │════ atributos
 (CPF)   (Nome)        └──────────┘
                     M │        ║ 1
               <MATRICULA>     <COMPOE>
              (Data) (Pago)     ║ N (total)
                     N │   ┌──────────┐
               ┌──────────┐│  MODULO  │── (<u>Sigla</u>) (Nome)
               │  ALUNO   │└──────────┘
               └──────────┘     ║ 1
   (<u>CPF</u>) (Sexo) (DataNascimento)  <<CONTEM>>  (losango duplo)
   (Nome)─(PrimeiroNome)        ║ N (total)
        └─(Sobrenome)      ╔══════════╗
                           ║  TOPICO  ║── (Sigla - chave parcial) (Nome) (Horas)
                           ╚══════════╝
```

## Decisões de modelagem (justificativas)

1. **AREA–AREA recursivo**: "uma área pode ser integrada por outras áreas, sendo que uma área só pode ser integrante de uma única área" → papel *integrante* com cardinalidade N e papel *integrada* com cardinalidade 1. No relacional vira a FK `SuperArea`.
2. **CURSO pertence a AREA**: "um curso obrigatoriamente pertence a uma área" → participação **total** de CURSO.
3. **Professores** é **atributo multivalorado composto** de CURSO (o texto diz "cursos ... possuem ... professores, compostos por CPF e nome"). Não é uma entidade. Por isso, no relacional, PROFESSOR tem chave (Curso, CPF).
4. **Nome de ALUNO** é atributo composto (PrimeiroNome, Sobrenome).
5. **MATRICULA** é M:N com os atributos de relacionamento **Data** e **Pago** ("devemos conhecer a data e se o aluno pagou").
6. **MODULO** é entidade **forte**, porque tem identificador próprio (Sigla), mas tem participação **total** em COMPOE ("não existem módulos sem vínculo a algum curso").
7. **TOPICO** é entidade **fraca**: "só existe em função de um módulo" e "*potencialmente* pode ser identificado por sua sigla" → Sigla é **chave parcial**. A chave completa é (Sigla do MODULO + Sigla do TOPICO), como no relacional `TOPICO(Modulo, Sigla, ...)`.
8. **Horas de CURSO** é atributo **derivado** (soma das horas dos tópicos dos módulos do curso).
