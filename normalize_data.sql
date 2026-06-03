
-- Inserir Tipos
INSERT INTO tipo (nome_tipo, against_normal, against_fire, against_water, against_electric, against_grass, against_ice, against_fighting, against_poison, against_ground, against_flying, against_psychic, against_bug, against_rock, against_ghost, against_dragon, against_dark, against_steel, against_fairy)
SELECT DISTINCT
    primary_type,
    against_normal, against_fire, against_water, against_electric, against_grass, against_ice, against_fighting, against_poison, against_ground, against_flying, against_psychic, against_bug, against_rock, against_ghost, against_dragon, against_dark, against_steel, against_fairy
FROM pokemon_desnormalizado
WHERE primary_type IS NOT NULL;

INSERT INTO tipo (nome_tipo, against_normal, against_fire, against_water, against_electric, against_grass, against_ice, against_fighting, against_poison, against_ground, against_flying, against_psychic, against_bug, against_rock, against_ghost, against_dragon, against_dark, against_steel, against_fairy)
SELECT DISTINCT
    secondary_type,
    against_normal, against_fire, against_water, against_electric, against_grass, against_ice, against_fighting, against_poison, against_ground, against_flying, against_psychic, against_bug, against_rock, against_ghost, against_dragon, against_dark, against_steel, against_fairy
FROM pokemon_desnormalizado
WHERE secondary_type IS NOT NULL;

-- Inserir Habilidades
INSERT INTO habilidade (nome)
SELECT DISTINCT abilities_0 FROM pokemon_desnormalizado WHERE abilities_0 IS NOT NULL
UNION
SELECT DISTINCT abilities_1 FROM pokemon_desnormalizado WHERE abilities_1 IS NOT NULL
UNION
SELECT DISTINCT abilities_2 FROM pokemon_desnormalizado WHERE abilities_2 IS NOT NULL
UNION
SELECT DISTINCT abilities_hidden FROM pokemon_desnormalizado WHERE abilities_hidden IS NOT NULL;

-- Inserir Dados Base do Pokémon
INSERT INTO pokemon_dados_base (national_number, gen, english_name, japanese_name, classification, percent_male, percent_female, height_m, weight_kg, capture_rate, base_egg_steps, description)
SELECT
    national_number, gen, english_name, japanese_name, classification,
    CAST(REPLACE(percent_male, ',', '.') AS FLOAT),
    CAST(REPLACE(percent_female, ',', '.') AS FLOAT),
    height_m, weight_kg,
    CAST(capture_rate AS UNSIGNED),
    base_egg_steps, description
FROM pokemon_desnormalizado;

-- Inserir Status do Pokémon
INSERT INTO pokemon_status (pokemon_id, hp, attack, defense, sp_attack, sp_defense, speed)
SELECT national_number, hp, attack, defense, sp_attack, sp_defense, speed
FROM pokemon_desnormalizado;

-- Inserir Relação Pokémon-Tipo
INSERT INTO pokemon_tipo (pokemon_id, nome_tipo)
SELECT national_number, primary_type FROM pokemon_desnormalizado WHERE primary_type IS NOT NULL
UNION
SELECT national_number, secondary_type FROM pokemon_desnormalizado WHERE secondary_type IS NOT NULL;

-- Inserir Relação Pokémon-Habilidade
INSERT INTO pokemon_habilidade (pokemon_id, habilidade_id, is_hidden)
SELECT p.national_number, h.id, FALSE
FROM pokemon_desnormalizado p
JOIN habilidade h ON p.abilities_0 = h.nome
WHERE p.abilities_0 IS NOT NULL
UNION
SELECT p.national_number, h.id, FALSE
FROM pokemon_desnormalizado p
JOIN habilidade h ON p.abilities_1 = h.nome
WHERE p.abilities_1 IS NOT NULL
UNION
SELECT p.national_number, h.id, FALSE
FROM pokemon_desnormalizado p
JOIN habilidade h ON p.abilities_2 = h.nome
WHERE p.abilities_2 IS NOT NULL
UNION
SELECT p.national_number, h.id, TRUE
FROM pokemon_desnormalizado p
JOIN habilidade h ON p.abilities_hidden = h.nome
WHERE p.abilities_hidden IS NOT NULL;

-- Inserir Evoluções
INSERT INTO pokemon_evolucao (pokemon_id, evolve_to_id, metodo)
SELECT
    p_from.national_number,
    p_to.national_number,
    pd.evochain_1
FROM pokemon_desnormalizado pd
JOIN pokemon_dados_base p_from ON pd.evochain_0 = p_from.english_name
JOIN pokemon_dados_base p_to ON pd.evochain_2 = p_to.english_name
WHERE pd.evochain_1 IS NOT NULL AND pd.evochain_2 IS NOT NULL;

-- Inserir Formas Especiais
INSERT INTO pokemon_formas_especiais (pokemon_id, tipo_forma, nome_forma)
SELECT national_number, 'Gigantamax', gigantamax FROM pokemon_desnormalizado WHERE gigantamax IS NOT NULL
UNION
SELECT national_number, 'Mega', mega_evolution FROM pokemon_desnormalizado WHERE mega_evolution IS NOT NULL
UNION
SELECT national_number, 'Mega Alt', mega_evolution_alt FROM pokemon_desnormalizado WHERE mega_evolution_alt IS NOT NULL;

