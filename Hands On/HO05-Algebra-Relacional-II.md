# HO05: Álgebra Relacional II

> Dataset **IMDB-sample** do RelaX. Mesmo esquema do HO04. Usa operações de conjunto (∩, −, ∪), que exigem relações **compatíveis em união** (mesmos atributos). Como atores e diretores **não compartilham id**, a comparação é feita pelo nome (`first_name`, `last_name`).

**1. Atores que são diretores**
```
π first_name, last_name ( actors ) ∩ π first_name, last_name ( directors )
```

**2. Atores que não são diretores**
```
π first_name, last_name ( actors ) − π first_name, last_name ( directors )
```

**3. Atores e diretores**
```
π first_name, last_name ( actors ) ∪ π first_name, last_name ( directors )
```

**4. Nome dos filmes que não são dirigidos por nenhum diretor**
```
π name (
    movies ⨝ movies.id = sem_diretor.id
    ρ sem_diretor ( π id ( movies ) − ρ id←movie_id ( π movie_id ( movies_directors ) ) )
)
```
Forma equivalente com antijunção: `π name ( movies ▷ movies.id = movies_directors.movie_id movies_directors )`

**5. Atores que não atuaram em pelo menos dois filmes** (atuaram em 0 ou 1 filme)
```
atuacoes  = γ actor_id ; count(movie_id) → n ( roles )
dois_ou_mais = ρ id←actor_id ( π actor_id ( σ n >= 2 ( atuacoes ) ) )

π first_name, last_name (
    actors ⨝ actors.id = x.id
    ρ x ( π id ( actors ) − dois_ou_mais )
)
```
(A diferença inclui também os atores que não aparecem em `roles`, ou seja, com 0 filmes.)

**6. Por gênero e ano, o número médio de filmes com menos de dois atores atuando**
```
elenco   = γ movie_id ; count(actor_id) → n_atores ( roles )
com_2    = ρ id←movie_id ( π movie_id ( σ n_atores >= 2 ( elenco ) ) )
menos_2  = π id ( movies ) − com_2                      -- filmes com 0 ou 1 ator

por_genero_ano = γ genre, year ; count(id) → qtd (
    ( movies ⨝ movies.id = m.id ρ m ( menos_2 ) )
    ⨝ movies.id = movies_genres.movie_id movies_genres
)

γ genre ; avg(qtd) → media_filmes_por_ano ( por_genero_ano )
```
`por_genero_ano` traz, para cada (gênero, ano), quantos filmes têm menos de dois atores. A última agregação dá a **média** desse número ao longo dos anos de cada gênero.
