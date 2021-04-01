#    HELPER FUNCTIONS   #

from faker import Faker
import random
from psycopg2 import connect


class Direction():
    IN = "IN"
    OUT = "OUT"
    INOUT = "INOUT"


def quote_string(string):
    return f"""'{string}'"""

###### TYPES ######


def decimal(digits_before_dot=None, digits_after_dot=None):
    if digits_after_dot and digits_after_dot:
        return f"DECIMAL({digits_before_dot}, {digits_after_dot})"
    elif not digits_before_dot and not digits_after_dot:
        return "DECIMAL"
    else:
        raise SyntaxError(
            "Either both digits after dot must be specified or neither are specified")


def integer():
    return "INT"


def string(max=255):
    return f"VARCHAR({max})"


def enum(values):
    values = [quote_string(value) for value in values]
    return f"""ENUM({", ".join(values)})"""

######  END TYPES   ######


###### CONSTRAINTS  ######

def primary_key(field_names):
    return f"""PRIMARY KEY({", ".join(field_names)})"""


def foreign_key(field_name, ref_table, ref_field, cascade_on_delete=True, cascade_on_update=True):
    return f"""FOREIGN KEY({field_name}) REFERENCES {ref_table}({ref_field}) ON DELETE {"CASCADE" if cascade_on_delete else "RESTRICT"} ON UPDATE {"CASCADE" if cascade_on_update else "RESTRICT"}"""


def unique_key(field_names):
    return f"""UNIQUE KEY({", ".join(field_names)})"""

######  END CONSTRAINTS  ######


def field(name, type, not_null=True, auto_increment=False):
    return f"""{name} {type}{" NOT NULL" if not_null else ""}{" AUTO_INCREMENT" if auto_increment else ""}"""


def parameter(direction, name, type):
    return f"{direction} {name} {type}"


######  CREATE QUERIES   ######

def create_table(table_name, fields, constraints):
    fields_constraints = ",\n\t".join(fields+constraints)
    return f"""
    CREATE TABLE {table_name} (
        {fields_constraints}
    );
    """


def create_procedure(procedure_name, query, parameters):
    return f"""
    DELIMITER //

    CREATE PROCEDURE {procedure_name}({", ".join(parameters)})
    BEGIN
        {query}
    END //

    DELIMITER ;
    """

##### END CREATE QUERIES ######

##### TABLE RECORD MODFICATION QUERIES ######


def insert(table_name, values):
    """Generate SQL insert statements based on the table name and values.

    Args:
        <string> table_name: The name of the database table
        <list> values: The list of the values passed in

    Returns:
        <string> A formatted string with the insert statement
    """
    insert_value = ""

    # Loop through all values except the last
    for value in range(len(values)-1):
        current_value = values[value]
        if type(current_value) == str:
            insert_value += f"{ quote_string(current_value) },"
        else:
            insert_value += f"{ current_value },"

    # Format the last value in the list of values
    if type(values[-1]) == str:
        insert_value += f"{ quote_string(values[-1]) }"
    else:
        insert_value += f"{ values[-1] }"

    return "INSERT INTO {0} VALUES ({1});".format(table_name, insert_value)

##### DB CREATION #####


CONJUNCTIONS = ["and", ""]

ADJECTIVES = [
    "Acid",
    "Acidic",
    "Ample",
    "Appealing",
    "Appetizing",
    "Aromatic",
    "Astringent",
    "Aromatic",
    "Baked",
    "Balsamic",
    "Beautiful",
    "Bite-size",
    "Bitter",
    "Bland",
    "Blazed",
    "Blended",
    "Blunt",
    "Boiled",
    "Briny",
    "Boiled",
    "Briny",
    "Brown",
    "Burnt",
    "Buttered",
    "Caked",
    "Calorie",
    "Candied",
    "Caramelized",
    "Creamed",
    "Creamy",
    "Crisp,"
    "Crunchy",
    "Gourmet"


]

FOODS = [
    "Cream of Pumpkin Soup",
    "Chicken",
    'Rice and Peas',
    "Stew Peas",
    "Wonton Soup",
    "Dahl",
    "Cheesecake",
    "Taco",
    "Milkshake",
    "Icecream",
    "Muffin",
    "Lasagne",
    "Pie",
    "Porridge",
    "Bread",
    "Brownies"
]

# open/ create the sql file

# Functions to generate the insert statements


def generate_recipe_data(no_entries, faker_obj):
    """Creates the INSERT queries for the Recipe table

    Args:
        no_entries

    Returns:
        A list containing all of the insert statements
    """
    insert_statements = []
    for value in range(no_entries):
        pass


def generate_user_data(no_entries, faker_obj):
    """Create the INSERT queries for the User table.

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
        <list> A list containing all of the insert statements
    """
    insert_statements = []
    for value in range(no_entries):

        # Generate fake user data
        user_id = value+1
        name_lst = faker_obj.unique.name().split(' ')
        username = "".join(name_lst)
        first_name = name_lst[0]
        last_name = name_lst[1]
        password = faker_obj.password(length=12)

        # Create the insert statement
        value_lst = [user_id, username, first_name, last_name, password]
        insert_statement = insert('User', value_lst)
        insert_statements.append(insert_statement)

    return insert_statements


def generate_ingredients_data(no_entries, faker_obj):
    """Create the INSERT queries for the Ingredients table.

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
        <list> A list containing all of the insert statements
    """
    pass


def generate_allergies_data(no_entries, faker_obj):
    """Create the INSERT queries for the Ingredients table.

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
         <list> A list containing all of the insert statements
    """
    pass

# Functions to create the respective tables


def create_user_table():
    """Create the user SQL table."""
    table_name = 'User'

    # Declare fields
    user_id = field('user_id', integer(), auto_increment=True)
    username = field('username', string())
    first_name = field('first_name', string())
    last_name = field('last_name', string())
    password = field('password', string())
    fields = [user_id, username, first_name, last_name, password]

    # Declare constraints
    p_key = primary_key(['user_id'])
    constraints = [p_key]

    # Create the table
    create_statement = create_table(table_name, fields, constraints)

    return create_statement

# Function to write to the file


def write_sql(file_handler, statements):
    """Write SQL to file specified withthe file handler.

    Args:
        <list> statements: The list of statements to be written to the file
        file_handler: The object used for writing to the file

    Returns:
        None
    """
    for line in statements:
        file_handler.write(f"{line}\n")


def main(faker_obj):
    # Initialize key variables
    file_handler = open("sophro_db.sql", "w")

    # Generate tables

    # Generate fake data


if __name__ == "__main__":
    fake = Faker()
