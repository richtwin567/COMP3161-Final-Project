from faker import Faker
from psycopg2 import connect
import random


#    HELPER FUNCTIONS   #
class Direction():
    IN = "IN"
    OUT = "OUT"
    INOUT = "INOUT"


def quote_string(string):
    return f"""'{string}'"""

###### TYPES ######


def floating_point(p=2):
    return f"FLOAT({p})"

def integer():
    return "INT"

def string(max=255):
    return f"VARCHAR({max})"

def enum(values):
    values = [quote_string(value) for value in values]
    return f"""ENUM({", ".join(values)})"""

def time():
    return "TIME"

def datetime():
    return "DATETIME"


######  END TYPES   ######


###### CONSTRAINTS  ######

def primary_key(field_names):
    if type(field_names) is list:
        return f"""PRIMARY KEY({", ".join(field_names)})"""
    elif type(field_names) is str:
        return f"""PRIMARY KEY({field_names})"""
    else:
        raise TypeError("field_names must be a list or string")


def foreign_key(field_name, ref_table, ref_field, cascade_on_delete=True, cascade_on_update=True):
    return f"""FOREIGN KEY({field_name}) REFERENCES {ref_table}({ref_field}) ON DELETE {"CASCADE" if cascade_on_delete else "RESTRICT"} ON UPDATE {"CASCADE" if cascade_on_update else "RESTRICT"}"""


def unique_key(field_names):
    if type(field_names) is list:
        return f"""UNIQUE KEY({", ".join(field_names)})"""
    elif type(field_names) is str:
        return f"""UNIQUE KEY({field_names})"""
    else:
        raise TypeError("field_names must be a list or string")

######  END CONSTRAINTS  ######


def field(name, type, not_null=True, auto_increment=False):
    return f"""{name} {type}{" NOT NULL" if not_null else ""}{" AUTO_INCREMENT" if auto_increment else ""}"""


def parameter(direction, name, type):
    return f"{direction} {name} {type}"


######  CREATE QUERIES   ######

def create_table(table_name, fields, constraints):
    fields = ",\n\t".join(fields)
    constraints = ",\n\t".join(constraints)
    return f"""
CREATE TABLE {table_name} (
    {fields},

    {constraints}
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
    values = "),\n\t(".join(values)
    return f"""
INSERT INTO {table_name} VALUES
    ({values});
"""

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


##### END CUSTOM GENERATORs #####

##### DB CREATION #####

# open/ create the sql file
fp = open("sophro_db.sql", "wt")


fake = Faker()

# create db

fp.write("CREATE DATABASE sophro;\n")

fp.write("USE sophro;\n\n")

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
        primary_key("user_id")
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

# write all tables
for table in tables:
    fp.write(table)

# create procedures

procedures = []

# insert procedure

# procedures.append(create_procedure("insert_recipe", [parameter(Direction.IN,)]))

fp.close()
