import pandas as pd
import mysql.connector
from mysql.connector import Error
import numpy as np

def create_connection(host_name, user_name, user_password, db_name):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("Connection to MySQL DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")
    return connection

def execute_query(connection, query, data=None):
    cursor = connection.cursor()
    try:
        if data:
            cursor.execute(query, data)
        else:
            cursor.execute(query)
        connection.commit()
    except Error as e:
        # Don't print warnings about data truncation
        if e.errno != 1265:
            print(f"The error '{e}' occurred")

def get_ability_id(connection, ability_name):
    cursor = connection.cursor()
    query = "SELECT id FROM habilidade WHERE nome = %s"
    cursor.execute(query, (ability_name,))
    result = cursor.fetchone()
    return result[0] if result else None

def get_pokemon_id(connection, pokemon_name):
    if pokemon_name is None:
        return None
    cursor = connection.cursor()
    query = "SELECT national_number FROM pokemon_dados_base WHERE english_name = %s"
    cursor.execute(query, (pokemon_name,))
    result = cursor.fetchone()
    return result[0] if result else None


def insert_types(connection, df):
    # Create a dataframe with unique types and their against values
    primary_types = df[['primary_type'] + [col for col in df.columns if col.startswith('against_')]].rename(columns={'primary_type': 'nome_tipo'})
    secondary_types = df[['secondary_type'] + [col for col in df.columns if col.startswith('against_')]].rename(columns={'secondary_type': 'nome_tipo'})

    types_df = pd.concat([primary_types, secondary_types]).dropna(subset=['nome_tipo']).drop_duplicates(subset=['nome_tipo'])

    for index, row in types_df.iterrows():
        query = """
        INSERT INTO tipo (nome_tipo, against_normal, against_fire, against_water, against_electric, against_grass, against_ice, against_fighting, against_poison, against_ground, against_flying, against_psychic, against_bug, against_rock, against_ghost, against_dragon, against_dark, against_steel, against_fairy)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE nome_tipo=nome_tipo;
        """
        data = (
            row['nome_tipo'], row['against_normal'], row['against_fire'], row['against_water'], row['against_electric'],
            row['against_grass'], row['against_ice'], row['against_fighting'], row['against_poison'],
            row['against_ground'], row['against_flying'], row['against_psychic'], row['against_bug'],
            row['against_rock'], row['against_ghost'], row['against_dragon'], row['against_dark'],
            row['against_steel'], row['against_fairy']
        )
        execute_query(connection, query, data)

def insert_abilities(connection, df):
    abilities = pd.concat([df['abilities_0'], df['abilities_1'], df['abilities_2'], df['abilities_hidden']]).dropna().unique()
    for ability in abilities:
        query = "INSERT INTO habilidade (nome) VALUES (%s) ON DUPLICATE KEY UPDATE nome=nome;"
        execute_query(connection, query, (ability,))

def main():
    db_connection = create_connection("localhost", "root", "021086", "pokemons")
    if db_connection is None:
        return

    try:
        df = pd.read_csv('data/pokemon.csv', encoding='utf-16', sep='\t')
        
        # Clean numeric columns
        numeric_cols = ['percent_male', 'percent_female', 'height_m', 'weight_kg', 'capture_rate', 'base_egg_steps', 'hp', 'attack', 'defense', 'sp_attack', 'sp_defense', 'speed']
        for col in numeric_cols:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        df = df.replace({np.nan: None})


        print("Inserting types...")
        insert_types(db_connection, df)
        print("Inserting abilities...")
        insert_abilities(db_connection, df)
        print("Inserting Pokemon data...")

        for index, row in df.iterrows():
            # Insert into pokemon_dados_base
            query_base = """
            INSERT INTO pokemon_dados_base (national_number, gen, english_name, japanese_name, classification, percent_male, percent_female, height_m, weight_kg, capture_rate, base_egg_steps, description)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE national_number=national_number;
            """
            data_base = (row['national_number'], row['gen'], row['english_name'], row['japanese_name'], row['classification'], row['percent_male'], row['percent_female'], row['height_m'], row['weight_kg'], row['capture_rate'], row['base_egg_steps'], row['description'])
            execute_query(db_connection, query_base, data_base)

            # Insert into pokemon_status
            query_status = """
            INSERT INTO pokemon_status (pokemon_id, hp, attack, defense, sp_attack, sp_defense, speed)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE pokemon_id=pokemon_id;
            """
            data_status = (row['national_number'], row['hp'], row['attack'], row['defense'], row['sp_attack'], row['sp_defense'], row['speed'])
            execute_query(db_connection, query_status, data_status)

            # Insert into pokemon_tipo
            if row['primary_type']:
                query_tipo1 = "INSERT INTO pokemon_tipo (pokemon_id, nome_tipo) VALUES (%s, %s) ON DUPLICATE KEY UPDATE pokemon_id=pokemon_id;"
                execute_query(db_connection, query_tipo1, (row['national_number'], row['primary_type']))
            if row['secondary_type']:
                query_tipo2 = "INSERT INTO pokemon_tipo (pokemon_id, nome_tipo) VALUES (%s, %s) ON DUPLICATE KEY UPDATE pokemon_id=pokemon_id;"
                execute_query(db_connection, query_tipo2, (row['national_number'], row['secondary_type']))

            # Insert into pokemon_habilidade
            for i in range(3):
                ability_col = f'abilities_{i}'
                if row[ability_col]:
                    ability_id = get_ability_id(db_connection, row[ability_col])
                    if ability_id:
                        query_habilidade = "INSERT INTO pokemon_habilidade (pokemon_id, habilidade_id, is_hidden) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE pokemon_id=pokemon_id;"
                        execute_query(db_connection, query_habilidade, (row['national_number'], ability_id, False))
            if row['abilities_hidden']:
                ability_id = get_ability_id(db_connection, row['abilities_hidden'])
                if ability_id:
                    query_habilidade = "INSERT INTO pokemon_habilidade (pokemon_id, habilidade_id, is_hidden) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE pokemon_id=pokemon_id;"
                    execute_query(db_connection, query_habilidade, (row['national_number'], ability_id, True))

        print("Inserting evolution data...")
        for index, row in df.iterrows():
            pokemon_id = row['national_number']

            evochain = []
            for i in range(7):
                if row[f'evochain_{i}']:
                    evochain.append(row[f'evochain_{i}'])

            for i in range(len(evochain) - 2):
                if evochain[i+1] and ('Level' in str(evochain[i+1]) or 'Trade' in str(evochain[i+1]) or 'Stone' in str(evochain[i+1])):
                    from_pokemon_name = evochain[i]
                    to_pokemon_name = evochain[i+2]
                    method = str(evochain[i+1])

                    from_pokemon_id = get_pokemon_id(db_connection, from_pokemon_name)
                    to_pokemon_id = get_pokemon_id(db_connection, to_pokemon_name)

                    if from_pokemon_id and to_pokemon_id:
                        query = """
                        INSERT INTO pokemon_evolucao (pokemon_id, evolve_to_id, metodo)
                        VALUES (%s, %s, %s)
                        ON DUPLICATE KEY UPDATE evolve_to_id=VALUES(evolve_to_id), metodo=VALUES(metodo);
                        """
                        execute_query(db_connection, query, (from_pokemon_id, to_pokemon_id, method))

        print("Inserting special forms data...")
        for index, row in df.iterrows():
            pokemon_id = row['national_number']
            if row['gigantamax']:
                query = "INSERT INTO pokemon_formas_especiais (pokemon_id, tipo_forma, nome_forma) VALUES (%s, %s, %s);"
                execute_query(db_connection, query, (pokemon_id, 'Gigantamax', row['gigantamax']))
            if row['mega_evolution']:
                query = "INSERT INTO pokemon_formas_especiais (pokemon_id, tipo_forma, nome_forma) VALUES (%s, %s, %s);"
                execute_query(db_connection, query, (pokemon_id, 'Mega', row['mega_evolution']))
            if row['mega_evolution_alt']:
                query = "INSERT INTO pokemon_formas_especiais (pokemon_id, tipo_forma, nome_forma) VALUES (%s, %s, %s);"
                execute_query(db_connection, query, (pokemon_id, 'Mega Alt', row['mega_evolution_alt']))


        print("Data insertion complete.")

    finally:
        if db_connection and db_connection.is_connected():
            db_connection.close()
            print("MySQL connection is closed")

if __name__ == '__main__':
    main()
