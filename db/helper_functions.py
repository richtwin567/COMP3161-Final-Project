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
    values = [", ".join([value if type(value) != "str" else quote_string(
        value) for value in value_list]) for value_list in values]
    return f"""
    INSERT INTO {table_name} VALUES
        ({"),\n\t(".join(values)});
    """

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
fp = open("sophro_db.sql", "wt")


fake = Faker()


