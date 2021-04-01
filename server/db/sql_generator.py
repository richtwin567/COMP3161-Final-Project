from faker import Faker
from psycopg2 import connect
import random


#    HELPER FUNCTIONS   #
class Direction():
    """
    Directions for parameter types in procedures
    """
    IN = "IN"
    OUT = "OUT"
    INOUT = "INOUT"


def quote_string(string):
    """
    Surrounds a string in single quotes
    """
    return f"""'{string}'"""

###### TYPES ######


def floating_point(p=2):
    """
    The float data type

    Args:
        p(int):
            The precision. 0-24 defines a float while 25-53 defines a double.

    Returns:
        str: The float data type
    """

    return f"FLOAT({p})"

def integer():
    """
    The int data type
    """
    return "INT"

def string(max=255):
    """
    the varchar data type

    Args:
        max(int):
            The maximum number of characters
    """
    return f"VARCHAR({max})"

def enum(values):
    """
    the enum data type
    """
    values = [quote_string(value) for value in values]
    return f"""ENUM({", ".join(values)})"""

def time():
    """
    The time data type
    """
    return "TIME"

def datetime():
    """
    the datetime data type
    """
    return "DATETIME"


######  END TYPES   ######


###### CONSTRAINTS  ######

def primary_key(field_names):
    """
    Creates a primary key constraint on the given field_name(s).

    Args:
        field_names (str | list) :
            The names of the fields that make up the primary key
    
    Return:
        str: the primary key constraint
    """

    if type(field_names) is list:
        return f"""PRIMARY KEY({", ".join(field_names)})"""
    elif type(field_names) is str:
        return f"""PRIMARY KEY({field_names})"""
    else:
        raise TypeError("field_names must be a list or string")


def foreign_key(field_name, ref_table, ref_field, cascade_on_delete=True, cascade_on_update=True):
    """
    Creates a foreign key constraint

    Args:
        field_name(str):
            The foreign key field name

        ref_table(str):
            The table the foreign key references

        ref_field(str):
            The name of the field in the ref_table to reference

        cascade_on_delete(bool):
            If true, on delete is set to cascade. If false on delete is set to restict

        cascade_on_update(bool):
            If true, on update is set to cascade. If false on update is set to restict
    
    Return:
        str: The foreign key constraint
    """

    return f"""FOREIGN KEY({field_name}) REFERENCES {ref_table}({ref_field}) ON DELETE {"CASCADE" if cascade_on_delete else "RESTRICT"} ON UPDATE {"CASCADE" if cascade_on_update else "RESTRICT"}"""


def unique_key(field_names):
    """
    Create a unique key constraint on the given field_name(s)

    Args:
        field_names (str | list) :
            The names of the fields that make up the unique key
    
    Return:
        str: the unique key constraint
    """

    if type(field_names) is list:
        return f"""UNIQUE KEY({", ".join(field_names)})"""
    elif type(field_names) is str:
        return f"""UNIQUE KEY({field_names})"""
    else:
        raise TypeError("field_names must be a list or string")

######  END CONSTRAINTS  ######


def field(name, type, not_null=True, auto_increment=False):
    """
    Creates a table field

    Args:
        name(str):
            The field name
        
        type(str):
            The data type of the field

        not_null(bool):
            Whether the field can be null or not

        auto_increment(bool):
            whether the field auto increments
    
    Returns:
        str: The field
    """

    return f"""{name} {type}{" NOT NULL" if not_null else ""}{" AUTO_INCREMENT" if auto_increment else ""}"""


def parameter(direction, name, type):
    """
    Creates a procedure parameter

    Args:
        direction(Direction):
            The directionality of the parameter (IN, INOUT, OUT)

        name(str):
            The name of the parameter

        type(str):
            The type of the parameter

    Returns:
        str: The parameter
    """

    return f"{direction} {name} {type}"


######  CREATE QUERIES   ######

def create_table(table_name, fields, constraints):
    """
    Creates a table

    Args:
        table_name(str):
            The name of the table

        fields(list[str]):
            A list of fields in the table

        constraints(list[str]):
            A list of constraints in the table

    Returns:
        str: The create table statement
    """

    fields = ",\n\t".join(fields)
    constraints = ",\n\t".join(constraints)
    return f"""
CREATE TABLE {table_name} (
    {fields}{"," if constraints else ""}

    {constraints}
);
"""


def create_procedure(procedure_name, query, parameters=[]):
    """
    Creates a new procedure that executes the given query and taken the given parameters.

    Args:
        procedure_name(str):
            The name of the procedure
        
        query(str):
            The query the procedure should execute

        parameters(list[str]):
            The parameters the procedure takes
        
    Returns:
        str: The create procedure statement
    """

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


def insert_all(table_name, values):
    """
    Creates a single statement to insert multiple records 

    Args:
        table_name(str):
            The name of the table to insert into

        values(list[list[str]]):
            The list of value lists to insert
    
    Returns:
        str: The insert statement
    """

    values = [", ".join([str(value) if not type(value) is str else quote_string(
        value) for value in value_list]) for value_list in values]
    values = "),\n\t(".join(values)
    return f"""
INSERT INTO {table_name} VALUES
    ({values});
"""

def insert_one(table_name, value_list):
    """Generate SQL insert statements based on the table name and values.

    Args:
        <string> table_name: The name of the database table
        <list> values: The list of the values passed in

    Returns:
        <string> A formatted string with the insert statement
    """
    insert_value = ""

    # Loop through all values except the last
    for value in range(len(value_list)-1):
        current_value = value_list[value]
        if type(current_value) == str:
            insert_value += f"{ quote_string(current_value) },"
        else:
            insert_value += f"{ current_value },"

    # Format the last value in the list of values
    if type(value_list[-1]) == str:
        insert_value += f"{ quote_string(value_list[-1]) }"
    else:
        insert_value += f"{ value_list[-1] }"

    return "INSERT INTO {0} VALUES ({1});".format(table_name, insert_value)


##### CUSTOM GENERATORS #####


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

def random_recipe_name():
    c_adjectives = random.choices(ADJECTIVES,k=2)
    c_foods = random.choices(FOODS,k=2)

    return " ".join([c_adjectives[0],random.choice(CONJUNCTIONS), c_adjectives[1],c_foods[0] ,random.choice(CONJUNCTIONS), c_foods[1]])


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
    """Creates the INSERT queries for the User table

    Args:
        <int> no_entries: The number of database entries to be created

    Returns:
        <list> A list containing all of the insert statements
    """
    value_lists = []
    for value in range(no_entries):

        # Generate fake user data
        user_id = value+1
        username = faker_obj.unique.user_name()
        first_name = faker_obj.unique.first_name()
        last_name = faker_obj.unique.last_name()
        password = faker_obj.password(length=12)

        # Create the insert list
        value_lst = [user_id, username, first_name, last_name, password]
        value_lists.append(value_lst)
    
    insert_statement = insert_all("user",value_lists)

    return insert_statement


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

# Functions to create the respective tables

# Function to write to the file


def write_sql(file_handler, statements):
    """Writes SQL to file specified withthe file handler

        Args:
            <list> statements: The list of statements to be written to the file
            file_handler: The object used for writing to the file

        Returns:
            None
    """
    for line in statements:
        file_handler.write(f"{line}\n")


##### END CUSTOM GENERATORS #####

##### DB CREATION #####

file_handler = open("sophro_db.sql", "w")

# create db

db_name = "sophro"

drop_stmt = f"DROP DATABASE IF EXISTS {db_name};\n"

create_db_stmt = f"CREATE DATABASE {db_name};\n"

use_db_stmt = f"USE {db_name};\n\n"

# build tables

tables=[]

# allergy table 
tables.append(create_table("allergy", 
    [
        field("allergy_id", integer(), auto_increment=True), 
        field("allergy_name", string())
    ], 
    [primary_key("allergy_id")]
))


# ingredient table
tables.append(create_table("ingredient",
    [
        field("ingredient_id", integer(), auto_increment=True),
        field("stock_quantity", integer()),
        field("name", string()),
        field("calorie_count", integer())
    ], 
    [primary_key("ingredient_id")]
))


# measurement table
tables.append(create_table("measurement",
    [
        field("measurement_id", integer(), auto_increment=True),
        field("amount", floating_point()),
        field("unit", string(15))
    ],
    [
        primary_key("measurement_id")
    ]
))


# user table
tables.append(create_table("user",
    [
        field("user_id", integer(), auto_increment=True),
        field("username", string()),
        field("first_name", string()),
        field("last_name", string()),
        field("password",string())
    ],
    [
        primary_key("user_id"),
        unique_key("username")
    ]))


# recipe table
tables.append(create_table("recipe",
    [
        field("recipe_id",integer(),auto_increment=True),
        field("image_url", string()),
        field("prep_time", time()),
        field("cook_time", time()),
        field("creation_date",datetime()),
        field("culture", string()),
        field("description", string()),
        field("created_by", integer(),False)
    ],
    [
        primary_key("recipe_id"),
        foreign_key("created_by", "user", "user_id",False)
    ]))


# ingredient_allergy table 
tables.append(create_table("ingredient_allergy",
    [
        field("allergy_id",integer()),
        field("ingredient_id", integer())
    ],
    [
        primary_key(["allergy_id","ingredient_id"]),
        foreign_key("allergy_id","allergy","allergy_id"),
        foreign_key("ingredient_id","ingredient","ingredient_id")
    ]))


# instruction table
tables.append(create_table("instruction",
    [
        field("instruction_id",integer(), auto_increment=True),
        field('step_number',integer()),
        field("instruction_details", string()),
        field("recipe_id", integer())
    ],
    [
        primary_key("instruction_id"),
        foreign_key("recipe_id","recipe","recipe_id")
    ]))


# recipe_ingredient_measurement table
tables.append(create_table("recipe_ingredient_measurement",
    [
        field("recipe_id", integer()),
        field("ingredient_id", integer()),
        field("measurement_id", integer())
    ],
    [
        primary_key(["recipe_id", "ingredient_id", "measurement_id"]),
        foreign_key("recipe_id","recipe","recipe_id"),
        foreign_key("ingredient_id","ingredient","ingredient_id"),
        foreign_key("measurement_id","measurement","measurement_id")
    ]))


# meal_plan table
tables.append(create_table("meal_plan",
    [
        field("plan_id",integer(), auto_increment=True),
        field("for_user", integer())
    ],
    [
        primary_key("plan_id"),
        foreign_key("for_user","user","user_id")
    ]))


# planned_meal table
tables.append(create_table("planned_meal",
    [
        field("meal_id", integer(), auto_increment=True),
        field("time_of_day",enum(["Breakfast","Lunch", "Dinner"])),
        field("serving_size",integer()),
        field("recipe_id",integer()),
        field("plan_id",integer())
    ],
    [
        primary_key(["meal_id","plan_id"]),
        foreign_key("recipe_id","recipe", "recipe_id"),
        foreign_key("plan_id","meal_plan","plan_id")
    ]))


# user_allergy table
tables.append(create_table("user_allergy",
    [
        field("user_id",integer()),
        field("allergy_id", integer())
    ],
    [
        primary_key(["user_id","allergy_id"]),
        foreign_key("user_id","user","user_id"),
        foreign_key("allergy_id","allergy","allergy_id")
    ]))


file_handler.write(drop_stmt)

file_handler.write(create_db_stmt)

file_handler.write(use_db_stmt)

# write all tables
for table in tables:
    file_handler.write(table)

##### END DB CREATION #####

##### DB INSERT #####

if __name__ == "__main__":
    #f_handler = open("./db/test.sql", "w")
    fake = Faker()
    data = generate_user_data(50, fake)
    file_handler.write(data)
