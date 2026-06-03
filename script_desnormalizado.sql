CREATE TABLE pokemon_desnormalizado (
    national_number INT PRIMARY KEY,
    gen VARCHAR(10) NOT NULL,
    english_name VARCHAR(100) NOT NULL,
    japanese_name VARCHAR(100),
    primary_type VARCHAR(50) NOT NULL,
    secondary_type VARCHAR(50) NULL,
    classification VARCHAR(100),
    percent_male FLOAT NULL,
    percent_female FLOAT NULL,
    height_m FLOAT NULL,
    weight_kg FLOAT NULL,
    
    capture_rate INT NULL,
    base_egg_steps INT NULL,
    
    -- Status Base
    hp INT NULL,
    attack INT NULL,
    defense INT NULL,
    sp_attack INT NULL,
    sp_defense INT NULL,
    speed INT NULL,
    
    -- Habilidades
    abilities_0 VARCHAR(100) NULL,
    abilities_1 VARCHAR(100) NULL,
    abilities_2 VARCHAR(100) NULL,
    abilities_hidden VARCHAR(100) NULL,
    
    -- Multiplicadores de Dano - Fraquezas
    against_normal FLOAT NULL,
    against_fire FLOAT NULL,
    against_water FLOAT NULL,
    against_electric FLOAT NULL,
    against_grass FLOAT NULL,
    against_ice FLOAT NULL,
    against_fighting FLOAT NULL,
    against_poison FLOAT NULL,
    against_ground FLOAT NULL,
    against_flying FLOAT NULL,
    against_psychic FLOAT NULL,
    against_bug FLOAT NULL,
    against_rock FLOAT NULL,
    against_ghost FLOAT NULL,
    against_dragon FLOAT NULL,
    against_dark FLOAT NULL,
    against_steel FLOAT NULL,
    against_fairy FLOAT NULL,
    
    -- Classificações Especiais
	is_sublegendary BOOLEAN DEFAULT FALSE,
	is_legendary BOOLEAN DEFAULT FALSE,
	is_mythical BOOLEAN DEFAULT FALSE,
    
    -- Cadeia Evolutiva
    evochain_0 VARCHAR(100) NULL,
    evochain_1 VARCHAR(100) NULL,
    evochain_2 VARCHAR(100) NULL,
    evochain_3 VARCHAR(100) NULL,
    evochain_4 VARCHAR(100) NULL,
    evochain_5 VARCHAR(100) NULL,
    evochain_6 VARCHAR(100) NULL,
    
    -- Formas Especiais
    gigantamax VARCHAR(100) NULL,
    mega_evolution VARCHAR(100) NULL,
    mega_evolution_alt VARCHAR(100) NULL,
    
    description TEXT NULL
);