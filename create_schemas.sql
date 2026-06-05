create database pokemons;
use pokemons;

-- Tabela Desnormalizada
CREATE TABLE IF NOT EXISTS pokemon_desnormalizado (
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
    capture_rate VARCHAR(50) NULL,
    base_egg_steps INT NULL,
    hp INT NULL,
    attack INT NULL,
    defense INT NULL,
    sp_attack INT NULL,
    sp_defense INT NULL,
    speed INT NULL,
    abilities_0 VARCHAR(100) NULL,
    abilities_1 VARCHAR(100) NULL,
    abilities_2 VARCHAR(100) NULL,
    abilities_hidden VARCHAR(100) NULL,
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
    is_sublegendary BOOLEAN DEFAULT FALSE,
    is_legendary BOOLEAN DEFAULT FALSE,
    is_mythical BOOLEAN DEFAULT FALSE,
    evochain_0 VARCHAR(255) NULL,
    evochain_1 VARCHAR(255) NULL,
    evochain_2 VARCHAR(255) NULL,
    evochain_3 VARCHAR(255) NULL,
    evochain_4 VARCHAR(255) NULL,
    evochain_5 VARCHAR(255) NULL,
    evochain_6 VARCHAR(255) NULL,
    gigantamax VARCHAR(100) NULL,
    mega_evolution VARCHAR(100) NULL,
    mega_evolution_alt VARCHAR(100) NULL,
    description TEXT NULL
);


-- Tabela de Tipos
CREATE TABLE IF NOT EXISTS tipo (
    nome_tipo VARCHAR(50) PRIMARY KEY,
    against_normal FLOAT NOT NULL DEFAULT 1.0,
    against_fire FLOAT NOT NULL DEFAULT 1.0,
    against_water FLOAT NOT NULL DEFAULT 1.0,
    against_electric FLOAT NOT NULL DEFAULT 1.0,
    against_grass FLOAT NOT NULL DEFAULT 1.0,
    against_ice FLOAT NOT NULL DEFAULT 1.0,
    against_fighting FLOAT NOT NULL DEFAULT 1.0,
    against_poison FLOAT NOT NULL DEFAULT 1.0,
    against_ground FLOAT NOT NULL DEFAULT 1.0,
    against_flying FLOAT NOT NULL DEFAULT 1.0,
    against_psychic FLOAT NOT NULL DEFAULT 1.0,
    against_bug FLOAT NOT NULL DEFAULT 1.0,
    against_rock FLOAT NOT NULL DEFAULT 1.0,
    against_ghost FLOAT NOT NULL DEFAULT 1.0,
    against_dragon FLOAT NOT NULL DEFAULT 1.0,
    against_dark FLOAT NOT NULL DEFAULT 1.0,
    against_steel FLOAT NOT NULL DEFAULT 1.0,
    against_fairy FLOAT NOT NULL DEFAULT 1.0
);

-- Tabela de Habilidades
CREATE TABLE IF NOT EXISTS habilidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS pokemon_dados_base (
    national_number INT PRIMARY KEY,
    gen VARCHAR(10) NOT NULL,
    english_name VARCHAR(100) NOT NULL,
    japanese_name VARCHAR(100),
    classification VARCHAR(100),
    percent_male FLOAT NULL,
    percent_female FLOAT NULL,
    height_m FLOAT NULL,
    weight_kg FLOAT NULL,
    capture_rate INT NULL,
    base_egg_steps INT NULL,
    description TEXT NULL
);



-- Tabela de Status
CREATE TABLE IF NOT EXISTS pokemon_status (
    pokemon_id INT PRIMARY KEY,
    hp INT NOT NULL,
    attack INT NOT NULL,
    defense INT NOT NULL,
    sp_attack INT NOT NULL,
    sp_defense INT NOT NULL,
    speed INT NOT NULL,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon_dados_base(national_number)
);

-- Tabela Intermediária:
CREATE TABLE IF NOT EXISTS pokemon_tipo (
    pokemon_id INT,
    nome_tipo VARCHAR(50),
    slot INT,
    PRIMARY KEY (pokemon_id, nome_tipo),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon_dados_base(national_number),
    FOREIGN KEY (nome_tipo) REFERENCES tipo(nome_tipo)
);

-- Tabela Intermediária:
CREATE TABLE IF NOT EXISTS pokemon_habilidade (
    pokemon_id INT,
    habilidade_id INT,
    is_hidden BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (pokemon_id, habilidade_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon_dados_base(national_number),
    FOREIGN KEY (habilidade_id) REFERENCES habilidade(id)
);

-- Tabela de Evolução
CREATE TABLE IF NOT EXISTS pokemon_evolucao (
    pokemon_id INT,
    evolve_to_id INT,
    metodo TEXT NULL,
    PRIMARY KEY (pokemon_id, evolve_to_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon_dados_base(national_number),
    FOREIGN KEY (evolve_to_id) REFERENCES pokemon_dados_base(national_number)
);

-- Tabela de Formas Especiais
CREATE TABLE IF NOT EXISTS pokemon_formas_especiais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pokemon_id INT,
    tipo_forma VARCHAR(20) NOT NULL,
    nome_forma VARCHAR(100) NOT NULL,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon_dados_base(national_number)
);
