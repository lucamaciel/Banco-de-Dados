-- =====================================================================
-- HO08: SQL (DML) II — mesmas consultas do HO05, agora em SQL
-- Dataset IMDB-sample (mesmo esquema do HO07).
-- Atores e diretores não compartilham id: a comparação é feita pelo nome.
-- =====================================================================

-- 1. Atores que são diretores
SELECT first_name, last_name FROM actors
INTERSECT
SELECT first_name, last_name FROM directors;

-- 2. Atores que não são diretores
SELECT first_name, last_name FROM actors
EXCEPT
SELECT first_name, last_name FROM directors;

-- 3. Atores e diretores
SELECT first_name, last_name FROM actors
UNION
SELECT first_name, last_name FROM directors;

-- 4. Filmes que não são dirigidos por nenhum diretor
SELECT m.name
FROM movies m
WHERE NOT EXISTS (SELECT 1 FROM movies_directors md WHERE md.movie_id = m.id);

-- 5. Atores que não atuaram em pelo menos dois filmes (0 ou 1 filme)
SELECT a.first_name, a.last_name
FROM actors a
LEFT JOIN roles r ON r.actor_id = a.id
GROUP BY a.id, a.first_name, a.last_name
HAVING COUNT(DISTINCT r.movie_id) < 2;

-- 6. Por gênero e ano, número médio de filmes com menos de dois atores atuando
--    (a) filmes com 0 ou 1 ator   (b) contagem por gênero/ano   (c) média por gênero
SELECT t.genre, AVG(t.qtd) AS media_filmes_por_ano
FROM (
    SELECT mg.genre, m.year, COUNT(*) AS qtd
    FROM movies m
    JOIN movies_genres mg ON mg.movie_id = m.id
    WHERE (SELECT COUNT(*) FROM roles r WHERE r.movie_id = m.id) < 2
    GROUP BY mg.genre, m.year
) t
GROUP BY t.genre;

-- Se o professor pedir só a contagem por (gênero, ano), use a subconsulta interna:
-- SELECT mg.genre, m.year, COUNT(*) AS qtd
-- FROM movies m JOIN movies_genres mg ON mg.movie_id = m.id
-- WHERE (SELECT COUNT(*) FROM roles r WHERE r.movie_id = m.id) < 2
-- GROUP BY mg.genre, m.year;
