# HO04: Álgebra Relacional I

> Dataset **IMDB-sample** da calculadora RelaX (https://dbis-uibk.github.io/relax). Sintaxe do RelaX.
> Esquema do dataset:
> `actors(id, first_name, last_name, gender)` · `directors(id, first_name, last_name)` · `movies(id, name, year, rank)` · `roles(actor_id, movie_id, role)` · `movies_directors(director_id, movie_id)` · `movies_genres(movie_id, genre)` · `directors_genres(director_id, genre, prob)`
>
> ⚠️ O antigo `Hands_on6.txt` usava `movies.title`, `movies.director_id` e `genres`, que **não existem** no IMDB-sample. O nome do filme é `name`, a nota é `rank`, o diretor fica em `movies_directors` e o gênero em `movies_genres`.

**1. Primeiro e último nome dos atores do sexo feminino**
```
π first_name, last_name ( σ gender = 'F' ( actors ) )
```

**2. Nome dos filmes com ano superior a 1999**
```
π name ( σ year > 1999 ( movies ) )
```

**3. Nome do filme e nome do diretor de cada filme**
```
π movies.name, directors.first_name, directors.last_name (
    ( movies ⨝ movies.id = movies_directors.movie_id movies_directors )
    ⨝ movies_directors.director_id = directors.id directors
)
```

**4. Nome do filme, nome do ator e papel, para filmes com ranking acima de 6**
```
π movies.name, actors.first_name, actors.last_name, roles.role (
    ( σ rank > 6 ( movies ) ⨝ movies.id = roles.movie_id roles )
    ⨝ roles.actor_id = actors.id actors
)
```

**5. Nome do diretor e número de filmes que cada diretor dirigiu**
```
γ directors.id, directors.first_name, directors.last_name ; count(movies_directors.movie_id) → qtd_filmes (
    directors ⨝ directors.id = movies_directors.director_id movies_directors
)
```
(Agrupa também por `id` para não juntar diretores homônimos. Diretores sem filme não aparecem. Se quiser mostrá-los com 0, use a junção externa `⟕` no lugar de `⨝`.)

**6. Gênero e número de filmes de cada gênero**
```
γ genre ; count(movie_id) → qtd_filmes ( movies_genres )
```

**7. Gênero e ranking médio, mínimo e máximo dos filmes do gênero**
```
γ genre ; avg(rank) → media, min(rank) → minimo, max(rank) → maximo (
    movies_genres ⨝ movies_genres.movie_id = movies.id movies
)
```
