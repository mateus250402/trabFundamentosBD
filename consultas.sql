-- Encontra a média de ataque e defesa para cada tipo de Pokémon, ordenando pela soma de ambos
SELECT
    pt.nome_tipo,
    AVG(ps.attack) AS media_ataque,
    AVG(ps.defense) AS media_defesa
FROM pokemon_tipo pt
JOIN pokemon_status ps ON pt.pokemon_id = ps.pokemon_id
GROUP BY pt.nome_tipo
ORDER BY (media_ataque + media_defesa) DESC;

-- Lista todos os Pokémon do tipo 'Fire' com velocidade acima da média de todos os Pokémon, ordenado por velocidade
SELECT
    pdb.english_name,
    ps.speed
FROM pokemon_dados_base pdb
JOIN pokemon_status ps ON pdb.national_number = ps.pokemon_id
JOIN pokemon_tipo pt ON pdb.national_number = pt.pokemon_id
WHERE pt.nome_tipo = 'Fire' AND ps.speed > (SELECT AVG(speed) FROM pokemon_status)
ORDER BY ps.speed DESC;

-- Lista evoluções que não ocorrem por nível, mostrando o método.
SELECT
    p1.english_name AS pokemon_base,
    p2.english_name AS evolui_para,
    pe.metodo AS como_evolui
FROM pokemon_dados_base p1
JOIN pokemon_evolucao pe ON p1.national_number = pe.pokemon_id
JOIN pokemon_dados_base p2 ON pe.evolve_to_id = p2.national_number
WHERE pe.metodo IS NOT NULL AND pe.metodo NOT LIKE '%level%'
ORDER BY como_evolui;

-- Lista todos os Pokémon e para qual Pokémon eles evoluem, incluindo aqueles que não têm evolução.
SELECT
    p1.english_name AS pokemon_base,
    p2.english_name AS evolui_para
FROM pokemon_dados_base p1
LEFT JOIN pokemon_evolucao pe ON p1.national_number = pe.pokemon_id
LEFT JOIN pokemon_dados_base p2 ON pe.evolve_to_id = p2.national_number
ORDER BY p1.national_number;

-- Encontra todos os Pokémon que são do tipo 'Grass' ou 'Water' e têm uma habilidade oculta.
SELECT pdb.english_name, h.nome AS habilidade
FROM pokemon_dados_base pdb
JOIN pokemon_tipo pt ON pdb.national_number = pt.pokemon_id
JOIN pokemon_habilidade ph ON pdb.national_number = ph.pokemon_id
JOIN habilidade h ON ph.habilidade_id = h.id
WHERE (pt.nome_tipo = 'Grass' OR pt.nome_tipo = 'Water') AND ph.is_hidden = TRUE;

-- Consulta 6: Pokémon com Formas Especiais
SELECT
    pdb.english_name,
    pfe.tipo_forma
FROM pokemon_dados_base pdb
JOIN pokemon_formas_especiais pfe ON pdb.national_number = pfe.pokemon_id
ORDER BY pdb.english_name, pfe.tipo_forma;

-- Consulta 7: Pokémon com Fraqueza Dupla a Ataques de Fogo
SELECT
    pdb.english_name,
    t1.nome_tipo AS tipo_1,
    t2.nome_tipo AS tipo_2
FROM pokemon_dados_base pdb
JOIN pokemon_tipo pt1 ON pdb.national_number = pt1.pokemon_id
JOIN tipo t1 ON pt1.nome_tipo = t1.nome_tipo
JOIN pokemon_tipo pt2 ON pdb.national_number = pt2.pokemon_id AND pt1.nome_tipo != pt2.nome_tipo
JOIN tipo t2 ON pt2.nome_tipo = t2.nome_tipo
WHERE (t1.against_fire * t2.against_fire) >= 4;
