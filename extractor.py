import csv
import mysql.connector
from mysql.connector import Error

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

def safe_convert(value, target_type):
    """Safely convert a value to a target type (int or float), returning None on failure."""
    if value is None or value == '':
        return None
    try:
        return target_type(value)
    except (ValueError, TypeError):
        return None

def main():
    db_connection = create_connection("localhost", "root", "mysql1", "pokemons")
    if db_connection is None:
        return

    try:
        expected_columns = [
            'national_number', 'gen', 'english_name', 'japanese_name', 'primary_type', 'secondary_type',
            'classification', 'percent_male', 'percent_female', 'height_m', 'weight_kg', 'capture_rate',
            'base_egg_steps', 'hp', 'attack', 'defense', 'sp_attack', 'sp_defense', 'speed',
            'abilities_0', 'abilities_1', 'abilities_2', 'abilities_hidden', 'against_normal',
            'against_fire', 'against_water', 'against_electric', 'against_grass', 'against_ice',
            'against_fighting', 'against_poison', 'against_ground', 'against_flying', 'against_psychic',
            'against_bug', 'against_rock', 'against_ghost', 'against_dragon', 'against_dark',
            'against_steel', 'against_fairy', 'is_sublegendary', 'is_legendary', 'is_mythical',
            'evochain_0', 'evochain_1', 'evochain_2', 'evochain_3', 'evochain_4', 'evochain_5',
            'evochain_6', 'gigantamax', 'mega_evolution', 'mega_evolution_alt', 'description'
        ]
        
        numeric_indices = {
            expected_columns.index('percent_male'): float,
            expected_columns.index('percent_female'): float,
            expected_columns.index('height_m'): float,
            expected_columns.index('weight_kg'): float,
            expected_columns.index('capture_rate'): int,
            expected_columns.index('base_egg_steps'): int,
            expected_columns.index('hp'): int,
            expected_columns.index('attack'): int,
            expected_columns.index('defense'): int,
            expected_columns.index('sp_attack'): int,
            expected_columns.index('sp_defense'): int,
            expected_columns.index('speed'): int,
            expected_columns.index('against_normal'): float,
            expected_columns.index('against_fire'): float,
            expected_columns.index('against_water'): float,
            expected_columns.index('against_electric'): float,
            expected_columns.index('against_grass'): float,
            expected_columns.index('against_ice'): float,
            expected_columns.index('against_fighting'): float,
            expected_columns.index('against_poison'): float,
            expected_columns.index('against_ground'): float,
            expected_columns.index('against_flying'): float,
            expected_columns.index('against_psychic'): float,
            expected_columns.index('against_bug'): float,
            expected_columns.index('against_rock'): float,
            expected_columns.index('against_ghost'): float,
            expected_columns.index('against_dragon'): float,
            expected_columns.index('against_dark'): float,
            expected_columns.index('against_steel'): float,
            expected_columns.index('against_fairy'): float,
        }

        data_to_insert = []
        with open('data/pokemon.csv', 'r', encoding='utf-16') as file:
            reader = csv.reader(file, delimiter='\t')
            next(reader)  # Skip header row
            for i, row in enumerate(reader):
                row_data = row[:len(expected_columns)]
                while len(row_data) < len(expected_columns):
                    row_data.append(None)
                
                processed_row = []
                for j, val in enumerate(row_data):
                    if j in numeric_indices:
                        processed_row.append(safe_convert(val, numeric_indices[j]))
                    else:
                        processed_row.append(None if val == '' else val)

                data_to_insert.append(tuple(processed_row))

        cursor = db_connection.cursor()
        
        cursor.execute("TRUNCATE TABLE pokemon_desnormalizado;")
        print("Table pokemon_desnormalizado truncated.")

        columns_sql = ", ".join([f"`{col}`" for col in expected_columns])
        placeholders = ", ".join(["%s"] * len(expected_columns))
        insert_query = f"INSERT INTO pokemon_desnormalizado ({columns_sql}) VALUES ({placeholders})"
        
        cursor.executemany(insert_query, data_to_insert)
        db_connection.commit()

        print(f"{cursor.rowcount} records inserted into pokemon_desnormalizado.")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if db_connection and db_connection.is_connected():
            db_connection.close()
            print("MySQL connection is closed")

if __name__ == '__main__':
    main()
