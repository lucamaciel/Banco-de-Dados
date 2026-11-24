-- =====================================================================
-- HO07: SQL (DML) I — mesmas consultas do HO04, agora em SQL
-- Dataset IMDB-sample (RelaX):
--   actors(id, first_name, last_name, gender)   directors(id, first_name, last_name)
--   movies(id, name, year, rank)                 roles(actor_id, movie_id, role)
--   movies_directors(director_id, movie_id)      movies_genres(movie_id, genre)
-- =====================================================================

-- 1. Primeiro e último nome dos atores do sexo feminino
SELECT a.first_name, a.last_name
FROM actors a
WHERE a.gender = 'F';

-- 2. Nome dos filmes com ano superior a 1999
SELECT m.name
FROM movies m
WHERE m.year > 1999;

-- 3. Nome do filme e nome do diretor de cada filme
SELECT m.name, d.first_name, d.last_name
FROM movies m
JOIN movies_directors md ON m.id = md.movie_id
JOIN directors d         ON md.director_id = d.id;

-- 4. Nome do filme, nome do ator e papel, para filmes com ranking acima de 6
SELECT m.name, a.first_name, a.last_name, r.role
FROM movies m
JOIN roles r  ON m.id = r.movie_id
JOIN actors a ON r.actor_id = a.id
WHERE m.rank > 6;

-- 5. Nome do diretor e número de filmes que cada diretor dirigiu
SELECT d.first_name, d.last_name, COUNT(md.movie_id) AS qtd_filmes
FROM directors d
LEFT JOIN movies_directors md ON d.id = md.director_id
GROUP BY d.id, d.first_name, d.last_name;

-- 6. Gênero e número de filmes de cada gênero
SELECT mg.genre, COUNT(mg.movie_id) AS qtd_filmes
FROM movies_genres mg
GROUP BY mg.genre;

-- 7. Gênero e ranking médio, mínimo e máximo dos filmes do gênero
SELECT mg.genre,
       AVG(m.rank) AS media,
       MIN(m.rank) AS minimo,
       MAX(m.rank) AS maximo
FROM movies_genres mg
JOIN movies m ON mg.movie_id = m.id
GROUP BY mg.genre;
