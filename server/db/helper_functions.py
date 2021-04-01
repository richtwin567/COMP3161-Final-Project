#    HELPER FUNCTIONS   #

from faker import Faker
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


def generate_recipe_data(no_entries, faker_obj):
    """Creates the INSERT queries for the Recipe table

    Args:
        no_entries

    Returns:
        A list containing all of the insert statements
    """
    pass


def generate_user_data(no_entries, faker_obj):
    """Creates the INSERT queries for the User table

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
        <list> A list containing all of the insert statements
    """
    insert_lst = []


def generate_ingredients_data(no_entries, faker_obj):
    """Creates the INSERT queries for the Ingredients table

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
         <list> A list containing all of the insert statements
    """
    pass


def generate_allergies_data(no_entries, faker_obj):
    """Creates the INSERT queries for the Ingredients table

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
         <list> A list containing all of the insert statements
    """
    pass


def main(faker_obj):
    fp = open("sophro_db.sql", "wt")


if __name__ == "__main__":
    fake = Faker()
    main(fake)
