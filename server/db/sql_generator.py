from faker import Faker
from faker.providers import BaseProvider
from datetime import datetime, timedelta
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


def sql_time():
    """
    The time data type
    """
    return "TIME"


def sql_datetime():
    """
    the datetime data type
    """
    return "DATETIME"


def boolean():
    """
    The data type to represent boolean
    """
    return "TINYINT"


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


def create_view(view_name, select_query):
    """
    Creates a new view

    Args:
        view_name(str):
            The name of the view

        select_query(str):
            The query for the view

    Returns:
        str: the create view statement
    """

    return f"""
CREATE VIEW {view_name}
AS
{select_query};
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
    str_values = []
    list_str_values = []

    for value_list in values:
        for value in value_list:
            str_value = str(value) if not type(
                value) is str else quote_string(value)
            str_values.append(str_value)
        list_str_values.append(", ".join(str_values))
        str_values = []

    list_str_values = "),\n\t(".join(list_str_values)

    return f"""
INSERT INTO {table_name} VALUES
    ({list_str_values});
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

    return "\nINSERT INTO {0} VALUES ({1});".format(table_name, insert_value)


##### CUSTOM GENERATORS #####
fake = Faker()


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
    "Gourmet",
    "Tasty",
    "Yummy",
    "Juicy",
    "Roasted"
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
    "Beef Lasagne",
    "Shepards Pie",
    "Cornmeal Porridge",
    "Bread",
    "Brownies",
    "Red Peas Soup",
    "Chicken Soup",
    "Plantain Porridge",
    "Chop Suey",
    "Fried Rice",
    "Apple Pie",
    "Pecan Pie"
]

INGREDIENTS = [
    "meat cuts",
    "file powder",
    "smoked sausage",
    "okra",
    "shrimp",
    "andouille sausage",
    "water",
    "paprika",
    "hot sauce",
    "garlic cloves",
    "browning",
    "lump crab meat",
    "vegetable oil",
    "all-purpose flour",
    "freshly ground pepper",
    "flat leaf parsley",
    "boneless chicken skinless thigh",
    "dried thyme",
    "white rice",
    "yellow onion",
    "ham",
    "baking powder",
    "eggs",
    "raisins",
    "milk",
    "white sugar"
]

ALLERGIES = [
    "Nut Allergy",
    "Oral Allergy Syndrome",
    "Stone Fruit Allergy",
    "Insulin Allergy",
    "Allium Allergy",
    "Histamine Allergy",
    "Gluten Allergy",
    "Legume Allergy",
    "Salicylate Allergy",
    "Cruciferous Allergy",
    "Lactose intolerance",
    "Shellfish Allergy",
    "Sugar Allergy / Intolerance",
    "Procrastination Allergy",
    "Soy allergy",
    "Caffine Sensitivity",
    "FODMAPs Sensitivity",
    "Sulfite Sensitivity",
    "Fructose Sensitivity",
    "Aspartame Sensitivity",
    "Egg Sensitivity",
    "MSG Sensitivity",
    "Yeast Allergy",
]

UNITS = [
    "kg",
    "cups",
    "tsp",
    "tbsp",
    "ml",
    "g",
    "gallon",
    "quarts"
]


TIME_OF_DAY = [
    "Breakfast",
    "Lunch",
    "Dinner"
]

##### CUSTOM PROVIDERS #####


class RecipeProvider(BaseProvider):
    def recipe_name(self):
        c_adjectives = random.choices(ADJECTIVES, k=2)
        while c_adjectives[0] == c_adjectives[1]:
            c_adjectives = random.choices(ADJECTIVES, k=2)
        c_foods = random.choices(FOODS, k=2)
        while c_foods[0] == c_foods[1]:
            c_foods = random.choices(FOODS, k=2)

        name_parts = [c_adjectives[0], random.choice(
            CONJUNCTIONS), c_adjectives[1], c_foods[0], random.choice(CONJUNCTIONS), c_foods[1]]
        name = [part for part in name_parts if part != ""]
        return " ".join(name)


fake.add_provider(RecipeProvider)

##### END CUSTOM PROVIDERS #####

# Utility Functions


def random_time():
    hours = str(random.randint(0, 3)).zfill(2)
    minutes = str(random.randint(0, 59)).zfill(2)
    seconds = str(random.randint(0, 59)).zfill(2)

    return f"{hours}:{minutes}:{seconds}"


# Functions to generate the insert statements
CAP = 100000


def generate_recipe_data(no_entries, no_users, faker_obj):
    """Creates the INSERT queries for the Recipe table

    Args:
        no_entries

    Returns:
        A list containing all of the insert statements
    """
    value_lists = []
    batch = []
    for value in range(no_entries):

        # Retrieve and format the current date
        now = datetime.utcnow()
        creation_date = now.strftime('%Y-%m-%d %H:%M:%S')

        # Generate fake recipe data
        recipe_id = value+1
        img_url = faker_obj.image_url()
        prep_time = random_time()
        cook_time = random_time()

        culture = faker_obj.language_name()
        description = faker_obj.paragraph()
        recipe_name = faker_obj.unique.recipe_name()

        created_by = random.randint(1, no_users)

        # Create the insert list
        recipe_lst = [recipe_id, recipe_name, img_url, prep_time, cook_time,
                      creation_date, culture, description,
                      created_by]

        value_lists.append(recipe_lst)

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all('recipe', value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all('recipe', value_lists)
        batch.append(insert_statement)

    return batch


def generate_user_data(no_entries, faker_obj):
    """Creates the INSERT queries for the User table

    Args:
        (int) no_entries: The number of insert statements to be created

    Returns:
        (string) A list containing the insert statement
    """

    value_lists = []
    batch = []
    for value in range(no_entries):

        # Generate fake user data
        user_id = value+1
        username = faker_obj.unique.user_name()
        first_name = faker_obj.first_name()
        last_name = faker_obj.last_name()
        password = faker_obj.password(length=12)

        # Create the insert list
        value_lst = [user_id, username, first_name, last_name, password]
        value_lists.append(value_lst)

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all("user", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("user", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_ingredients_data():
    """Create the INSERT queries for the Ingredients table

    Args:
        (int)no_entries: The number of insert statements to be created

    Returns:
        (string) A list containing the insert statement
    """
    value_lists = []
    batch = []
    for value in range(len(INGREDIENTS)):

        # Pull from the ingredients array
        ingredient_id = value+1
        # stock_quantity = random.randint(0, 200)  # Randomize the quantity
        ingredient_name = INGREDIENTS[value]
        calorie_count = random.randint(0, 2500)

        # Create the insert list
        ingredient_data = [ingredient_id, ingredient_name, calorie_count]

        value_lists.append(ingredient_data)

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all("ingredient", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("ingredient", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_allergies_data():
    """Creates the INSERT queries for the Allergy table

    Args:
        no_entries(int): The number of insert statements to be created

    Returns:
        (string) A list containing the insert statement
    """
    value_lists = []
    batch = []
    for value in range(len(ALLERGIES)):

        # Pull from the allergies array
        allergy_id = value+1
        allergy_name = ALLERGIES[value]

        # Create the insert list
        allergy_data = [allergy_id, allergy_name]
        value_lists.append(allergy_data)

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all("allergy", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("allergy", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_ingredient_allergies():
    """Creates the INSERT queries for the Ingredient Allergies table

    Args:
        None

    Returns:
        (string) A list containing the insert statement
    """
    # Initializing key variables
    value_lists = []
    no_allergies = len(ALLERGIES)
    batch = []
    for value in range(1, len(INGREDIENTS)+1):

        # Randomly assign allergies
        allergy_id = random.randint(1, no_allergies)
        ingredient_id = value

        # Create the insert list
        allergy_data = [allergy_id, ingredient_id]
        value_lists.append(allergy_data)

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all("ingredient_allergy", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("ingredient_allergy", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_user_allergies(no_users):
    """Creates the INSERT queries for the User Allergies table

    Args:
        (int) no_users: The number of users initially inserted

    Returns:
        (string) A list containing the insert statement
    """
    # Initializing key variables
    value_lists = []
    no_allergies = len(ALLERGIES)
    batch = []

    # Assuming half of the users have allergies
    user_ids = list(range(1, (no_users//2)+1))

    for value in range(1, (no_users//2)+1):

        # Randomly assign allergies to users
        allergy_id = random.randint(1, no_allergies)
        user_id = random.choice(user_ids)
        user_ids.pop(user_ids.index(user_id))  # Prevent duplicates

        # Create the insert list
        allergy_data = [user_id, allergy_id]
        value_lists.append(allergy_data)

        if(len(value_lists) % CAP == 0):
            insert_statement = insert_all("user_allergy", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("user_allergy", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_measurment_inserts():
    """Creates the INSERT queries for the Ingredient Allergies table

    Args:
        no_entries(int): The number of insert statements to be created

    Returns:
        (string) A list containing the insert statement
    """
    # Initializing key variables
    value_lists = []
    batch = []
    for value in range(1, len(UNITS)+1):

        # Randomly generate measurement values
        measurement_id = value
        #amount = random.uniform(2, 500)
        unit = UNITS[value-1]

        # Craete the insert list
        measurement_data = [measurement_id, unit]
        value_lists.append(measurement_data)

        if(len(value_lists) % CAP == 0):
            insert_statement = insert_all("measurement", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("measurement", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


# I do not recommend that we run this function with the amount of records
# sir requested, since we'd be generating 6m records and im not sure
# if any of our computers can handle that amount of data without crashing.
def generate_in_stock_data(no_users):
    """Creates the INSERT queries for the In Stock table

    Args:
       (int) no_users: The number of users initially created
       (int) no_ingredients: The number of ingredients

    Returns:
        (string) A list containing the insert statement
    """
    # Initializing key variables
    value_lists = []
    batch = []
    no_ingredients = len(INGREDIENTS)
    for user_id in range(1, no_users+1):
        for ingredient_id in range(1, no_ingredients):
            ingredient_amt = random.randint(0, 50)

            # Create and store the insert list
            stock_data = [user_id, ingredient_id, ingredient_amt]
            value_lists.append(stock_data)

            if len(value_lists) % CAP == 0:
                insert_statement = insert_all("in_stock", value_lists)
                value_lists = []
                batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("in_stock", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_instruction_data(faker_obj, no_recipes):
    """Creates the INSERT queries for the Instruction table.

    Args:
       (int) no_users: The number of recipes created

    Returns:
        (string) A list containing the insert statement
    """
    # Initializing key variables
    value_lists = []
    batch = []
    instruction_id = 1
    for recipe in range(1, no_recipes+1):
        recipe_id = random.randint(1, no_recipes)

        # Generate random instructions
        no_steps = random.randint(2, 6)
        instruction_list = [faker_obj.paragraph()] * no_steps
        for step in range(1, no_steps+1):
            instruction_details = instruction_list[step-1]

            # Generate the insert list
            instruction_data = [instruction_id,
                                step, instruction_details, recipe_id]
            instruction_id += 1
            value_lists.append(instruction_data)

            if(len(value_lists) % CAP == 0):
                insert_statement = insert_all("instruction", value_lists)
                value_lists = []
                batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("instruction", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_recipe_measurement(no_recipes, faker_obj):
    """
    Creates the INSERT queries for recipe_ingreient_measurement table.
    Generates recipe ingredients and 

    Args:
        no_recipes(int):
            The total number of recipes in the database

    Returns:
        str: The insert statement string
    """

    no_ing = len(INGREDIENTS)
    no_measurements = len(UNITS)
    value_lists = []
    batch = []
    for rid in range(1, no_recipes+1):
        no_items = random.randint(1, 7)
        for _ in range(no_items):
            ing_id = faker_obj.unique.random_int(1, no_ing)
            m_id = random.randint(1, no_measurements)
            amount = round(random.uniform(1, 5), random.randint(0, 2))
            values = [rid, ing_id, m_id, amount]
            value_lists.append(values)

            if(len(value_lists) % CAP == 0):
                insert_statement = insert_all(
                    "recipe_ingredient_measurement", value_lists)
                value_lists = []
                batch.append(insert_statement)

        faker_obj.unique.clear()

    if value_lists:
        insert_statement = insert_all(
            "recipe_ingredient_measurement", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_meal_plans(no_users):
    """
    Creates the insert queries for the meal_plan table

    Args:
        no_users(int):
            The number of users in the database

    Returns:
        str: The insert statement
    """

    value_lists = []
    batch = []
    for id in range(1, no_users+1):
        value_lists.append([id, id])

        if len(value_lists) % CAP == 0:
            insert_statement = insert_all("meal_plan", value_lists)
            value_lists = []
            batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("meal_plan", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


def generate_planned_meals(no_users, no_recipes):
    """
    Creates the insert statements for the planned meal table

    Args:
        no_users(int):
            The number of users in the database

        no_recipes(int):
            The number of recipes in the database

    Returns:
        str: The insert statement
    """

    meal_id = 1
    value_lists = []
    batch = []
    for plan_id in range(1, no_users+1):
        for weekday in range(7):
            for tday in TIME_OF_DAY:
                recipe_id = random.randint(1, no_recipes)
                serving_size = random.randint(1, 6)
                values = [meal_id, tday, serving_size, recipe_id, plan_id]
                meal_id += 1
                value_lists.append(values)

                if len(value_lists) % CAP == 0:
                    insert_statement = insert_all("planned_meal", value_lists)
                    value_lists = []
                    batch.append(insert_statement)

    if value_lists:
        insert_statement = insert_all("planned_meal", value_lists)
        value_lists = []
        batch.append(insert_statement)

    return batch


##### END CUSTOM GENERATORS #####


##### DB CREATION #####

# create db

db_name = "sophro"

drop_db_stmt = f"DROP DATABASE IF EXISTS {db_name};\n"

db_create_stmt = f"CREATE DATABASE {db_name};\n"

use_db_stmt = f"USE {db_name};\n\n"

# build tables

tables = []

# allergy table
tables.append(create_table("allergy",
                           [
                               field("allergy_id", integer(),
                                     auto_increment=True),
                               field("allergy_name", string())
                           ],
                           [primary_key("allergy_id"),
                            unique_key("allergy_name")]
                           ))


# ingredient table
tables.append(create_table("ingredient",
                           [
                               field("ingredient_id", integer(),
                                     auto_increment=True),
                               field("ingredient_name", string()),
                               field("calorie_count", integer())
                           ],
                           [
                               primary_key("ingredient_id"),
                               unique_key("ingredient_name")
                           ]
                           ))


# measurement table
tables.append(create_table("measurement",
                           [
                               field("measurement_id", integer(),
                                     auto_increment=True),
                               field("unit", string(15))
                           ],
                           [
                               primary_key("measurement_id"),
                               unique_key("unit")
                           ]
                           ))


# user table
tables.append(create_table("user",
                           [
                               field("user_id", integer(),
                                     auto_increment=True),
                               field("username", string()),
                               field("first_name", string()),
                               field("last_name", string()),
                               field("password", string())
                           ],
                           [
                               primary_key("user_id"),
                               unique_key("username")
                           ]))


# recipe table
tables.append(create_table("recipe",
                           [
                               field("recipe_id", integer(),
                                     auto_increment=True),
                               field("recipe_name", string()),
                               field("image_url", string()),
                               field("prep_time", sql_time()),
                               field("cook_time", sql_time()),
                               field("creation_date", sql_datetime()),
                               field("culture", string()),
                               field("description", string()),
                               field("created_by", integer(), False)
                           ],
                           [
                               primary_key("recipe_id"),
                               foreign_key("created_by", "user",
                                           "user_id", False),
                               unique_key("recipe_name")
                           ]))


# ingredient_allergy table
tables.append(create_table("ingredient_allergy",
                           [
                               field("allergy_id", integer()),
                               field("ingredient_id", integer())
                           ],
                           [
                               primary_key(["allergy_id", "ingredient_id"]),
                               foreign_key("allergy_id", "allergy",
                                           "allergy_id"),
                               foreign_key("ingredient_id",
                                           "ingredient", "ingredient_id")
                           ]))


# instruction table
tables.append(create_table("instruction",
                           [
                               field("instruction_id", integer(),
                                     auto_increment=True),
                               field('step_number', integer()),
                               field("instruction_details", string()),
                               field("recipe_id", integer())
                           ],
                           [
                               primary_key("instruction_id"),
                               foreign_key("recipe_id", "recipe", "recipe_id"),
                               unique_key(
                                   ["instruction_id", "step_number", "instruction_details", "recipe_id"])
                           ]))


# recipe_ingredient_measurement table
tables.append(create_table("recipe_ingredient_measurement",
                           [
                               field("recipe_id", integer()),
                               field("ingredient_id", integer()),
                               field("measurement_id", integer()),
                               field("amount", floating_point()),
                           ],
                           [
                               primary_key(
                                   ["recipe_id", "ingredient_id"]),
                               foreign_key("recipe_id", "recipe", "recipe_id"),
                               foreign_key("ingredient_id",
                                           "ingredient", "ingredient_id"),
                               foreign_key("measurement_id",
                                           "measurement", "measurement_id")
                           ]))


# meal_plan table
tables.append(create_table("meal_plan",
                           [
                               field("plan_id", integer(),
                                     auto_increment=True),
                               field("for_user", integer())
                           ],
                           [
                               primary_key("plan_id"),
                               foreign_key("for_user", "user", "user_id"),
                               unique_key("for_user")
                           ]))


# planned_meal table
tables.append(create_table("planned_meal",
                           [
                               field("meal_id", integer(),
                                     auto_increment=True),
                               field("time_of_day", enum(
                                   ["Breakfast", "Lunch", "Dinner"])),
                               field("serving_size", integer()),
                               field("recipe_id", integer()),
                               field("plan_id", integer())
                           ],
                           [
                               primary_key(["meal_id", "plan_id"]),
                               foreign_key("recipe_id", "recipe", "recipe_id"),
                               foreign_key("plan_id", "meal_plan", "plan_id")
                           ]))


# user_allergy table
tables.append(create_table("user_allergy",
                           [
                               field("user_id", integer()),
                               field("allergy_id", integer())
                           ],
                           [
                               primary_key(["user_id", "allergy_id"]),
                               foreign_key("user_id", "user", "user_id"),
                               foreign_key(
                                   "allergy_id", "allergy", "allergy_id")
                           ]))

# in_stock table
tables.append(create_table("in_stock",
                           [
                               field("user_id", integer()),
                               field("ingredient_id", integer()),
                               field("stock_quantity", integer())
                           ],
                           [
                               primary_key(["user_id", "ingredient_id"]),
                               foreign_key("user_id", "user", "user_id"),
                               foreign_key("ingredient_id",
                                           "ingredient", "ingredient_id")
                           ]))


# build views

views = []


views.append(create_view("user_allergy_joined", """
SELECT
    u.user_id,
    jua.allergy_id,
    jua.allergy_name,
    u.username,
    u.first_name,
    u.password,
    u.last_name
FROM
    user u
    JOIN
        (
            SELECT 
                ua.allergy_id,
                a.allergy_name,
                ua.user_id
            FROM
                user_allergy ua
                JOIN allergy a
                ON a.allergy_id=ua.allergy_id
        ) jua
    ON jua.user_id=u.user_id
"""))

views.append(create_view("user_allergy_joined_agg", """
SELECT
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    u.password,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'allergy_id',
            u.allergy_id,
            'allergy_name',
            u.allergy_name
        )
    ) allergies
FROM
    user_allergy_joined u
    GROUP BY u.user_id
"""))

views.append(create_view("ingredient_allergy_joined", """
SELECT
    i.ingredient_id,
    jia.allergy_name,
    jia.allergy_id,
    i.ingredient_name,
    i.calorie_count
FROM
    ingredient i
    JOIN
        (
            SELECT 
                a.allergy_name,
                a.allergy_id,
                ia.ingredient_id
            FROM
                ingredient_allergy ia
                JOIN allergy a
                ON a.allergy_id=ia.allergy_id
        ) jia
    ON jia.ingredient_id=i.ingredient_id
"""))

views.append(create_view("ingredient_allergy_joined_agg", """
SELECT
    ingredient_id,
    ingredient_name,
    calorie_count,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'allergy_id',
            allergy_id,
            'allergy_name',
            allergy_name
        )
    ) allergies
FROM ingredient_allergy_joined
GROUP BY ingredient_id
"""))

views.append(create_view("user_in_stock_joined", """
SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    si.ingredient_id,
    si.ingredient_name,
    si.stock_quantity
FROM 
    user u
    JOIN
        (
            SELECT 
                s.stock_quantity,
                i.ingredient_id,
                i.ingredient_name,
                s.user_id
            FROM
                in_stock s
                JOIN ingredient i
                ON i.ingredient_id=s.ingredient_id
        ) si
    ON si.user_id=u.user_id
"""))

views.append(create_view("user_in_stock_joined_agg", """
SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    u.allergies,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'ingredient',
            JSON_OBJECT(
                'ingredient_id',
                si.ingredient_id,
                'ingredient_name',
                si.ingredient_name,
                'calorie_count',
                si.calorie_count,
                'allergies',
                si.allergies
            ),
            'stock_quantity',
            si.stock_quantity
        )
    ) stock
FROM
    user_allergy_joined_agg u
    JOIN
        (
            SELECT 
                s.stock_quantity,
                i.ingredient_id,
                i.ingredient_name,
                i.calorie_count,
                i.allergies,
                s.user_id
            FROM
                in_stock s
                JOIN ingredient_allergy_joined_agg i
                ON i.ingredient_id=s.ingredient_id
        ) si
    ON si.user_id=u.user_id
    GROUP BY u.user_id
"""))


views.append(create_view("ingredient_measurement_joined", """
SELECT 
    rimj.ingredient_id,
    rimj.ingredient_name,
    m.measurement_id,
    rimj.amount,
    m.unit,
    rimj.allergy_id,
    rimj.allergy_name,
    rimj.calorie_count,
    rimj.recipe_id
FROM 
    measurement m 
    JOIN 
        (
            SELECT 
                rim.recipe_id,
                rim.ingredient_id,
                ing.ingredient_name,
                ing.calorie_count,
                rim.measurement_id,
                rim.amount,
                ing.allergy_id,
                ing.allergy_name
            FROM 
                recipe_ingredient_measurement rim 
                JOIN ingredient_allergy_joined ing 
                ON ing.ingredient_id=rim.ingredient_id
        ) rimj 
    ON rimj.measurement_id=m.measurement_id
"""))

views.append(create_view("ingredient_measurement_joined_agg", """
SELECT
    im.recipe_id,
    SUM(im.calorie_count) total_calories,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'ingredient',JSON_OBJECT('ingredient_id', im.ingredient_id,'ingredient_name',im.ingredient_name, 'calore_count',im.calorie_count), 
            'measurement', JSON_OBJECT('amount', im.amount,'unit', im.unit )
        )
    ) ingredients
FROM ingredient_measurement_joined im
GROUP BY im.recipe_id
"""))

views.append(create_view("instruction_agg", """
SELECT
    recipe_id,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'instruction_id',
            instruction_id,
            'step_number',
            step_number,
            'instruction_details',
            instruction_details
        )
    ) instructions
FROM instruction
GROUP BY recipe_id
"""))

views.append(create_view("all_recipes", """
SELECT 
    ri.recipe_id,
    ri.recipe_name,
    ri.image_url,
    ri.prep_time,
    ri.cook_time,
    ri.creation_date,
    ri.culture,
    ri.description,
    ri.created_by,
    ri.instruction_id,
    ri.step_number,
    ri.instruction_details,
    rimj.ingredient_id,
    rimj.ingredient_name,
    rimj.measurement_id,
    rimj.amount,
    rimj.unit,
    rimj.allergy_id,
    rimj.allergy_name,
    rimj.calorie_count
FROM
    ingredient_measurement_joined rimj
    JOIN
    (
        SELECT
            r.recipe_id,
            r.recipe_name,
            r.image_url,
            r.prep_time,
            r.cook_time,
            r.creation_date,
            r.culture,
            r.description,
            r.created_by,
            instr.instruction_id,
            instr.step_number,
            instr.instruction_details
        FROM recipe r JOIN instruction instr ON instr.recipe_id=r.recipe_id
    ) ri
    ON ri.recipe_id=rimj.recipe_id
"""))

views.append(create_view("all_recipes_agg", """
SELECT 
    ri.recipe_id,
    ri.recipe_name,
    ri.image_url,
    ri.prep_time,
    ri.cook_time,
    ri.creation_date,
    ri.culture,
    ri.description,
    ri.instructions,
    jimr.ingredients,
    jimr.total_calories
FROM
    ingredient_measurement_joined_agg jimr 
    JOIN
    (
        SELECT 
            r.recipe_id, 
            r.recipe_name,
            r.image_url,
            r.prep_time,
            r.cook_time,
            r.creation_date,
            r.culture,
            r.description,
            created_by created_by_id, 
            instr.instructions
        FROM recipe r JOIN instruction_agg instr ON instr.recipe_id=r.recipe_id
        GROUP BY r.recipe_id
    ) ri
    ON ri.recipe_id=jimr.recipe_id
    GROUP BY ri.recipe_id
"""))

views.append(create_view("planned_meal_recipe_joined", """
SELECT 
    a.recipe_id,
    a.recipe_name,
    a.image_url,
    a.prep_time,
    a.cook_time,
    a.creation_date,
    a.culture,
    a.description,
    a.created_by,
    a.instruction_id,
    a.step_number,
    a.instruction_details,
    a.ingredient_id,
    a.ingredient_name,
    a.measurement_id,
    a.amount,
    a.unit,
    a.allergy_id,
    a.allergy_name,
    a.calorie_count,
    p.meal_id,
    p.serving_size,
    p.plan_id,
    p.time_of_day
FROM
    planned_meal p JOIN all_recipes a ON p.recipe_id=a.recipe_id
"""))


views.append(create_view("planned_meal_recipe_joined_agg", """
SELECT
    a.recipe_id,
    a.recipe_name,
    a.image_url,
    a.prep_time,
    a.cook_time,
    a.creation_date,
    a.culture,
    a.description,
    a.instructions,
    a.ingredients,
    a.total_calories,
    p.meal_id,
    p.serving_size,
    p.plan_id,
    p.time_of_day
FROM
    planned_meal p JOIN all_recipes_agg a ON p.recipe_id=a.recipe_id
"""))

views.append(create_view("meal_plans_with_planned_meals", """
SELECT
    m.plan_id,
    m.for_user,
    p.recipe_id,
    p.recipe_name,
    p.image_url,
    p.prep_time,
    p.cook_time,
    p.creation_date,
    p.culture,
    p.description,
    p.created_by,
    p.instruction_id,
    p.step_number,
    p.instruction_details,
    p.ingredient_id,
    p.ingredient_name,
    p.measurement_id,
    p.amount,
    p.unit,
    p.allergy_id,
    p.allergy_name,
    p.calorie_count,
    p.meal_id,
    p.serving_size,
    p.time_of_day
FROM
    meal_plan m JOIN planned_meal_recipe_joined p ON p.plan_id=m.plan_id
"""))

views.append(create_view("meal_plans_with_planned_meals_agg", """
SELECT 
    m.for_user, 
    m.plan_id,
    JSON_ARRAYAGG(JSON_OBJECT(
        'image_url',
        p.image_url,
        'recipe_name',
        p.recipe_name,
        'time_of_day',
        p.time_of_day,
        'serving_size', 
        p.serving_size,
        'prep_time',
        p.prep_time,
        'cook_time',
        p.cook_time,
        'creation_date',
        p.creation_date,
        'instructions',
        p.instructions,
        'ingredients',
        p.ingredients,
        'culture',
        p.culture,
        'description',
        p.description)) planned_meals
FROM
    meal_plan m JOIN planned_meal_recipe_joined_agg p ON p.plan_id=m.plan_id
"""))


views.append(create_view("shopping_lists", """
SELECT
    pa.for_user,
    u.username,
    u.first_name,
    u.last_name,
    pa.ingredient_name,
    u.stock_quantity,
    pa.amount amount_needed
FROM
    user_in_stock_joined u
    JOIN 
        (
            SELECT
                p.for_user,
                p.ingredient_name,
                p.amount
            FROM
                meal_plans_with_planned_meals p
        ) pa
    ON pa.for_user=u.user_id
"""))
# build procedures

procedures = []

# procedure to insert recipe and retreive inserted record id
procedures.append(create_procedure("insert_recipe", """
    INSERT INTO recipe(recipe_name, image_url, prep_time, cook_time,  creation_date, culture, description, created_by)
    VALUES (new_name,new_image_url, new_prep_time, new_cook_time, new_creation_date, new_culture, new_description, new_created_by);
    SET new_id = LAST_INSERT_ID();
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "new_name", string()),
                                       parameter(Direction.IN,
                                                 "new_image_url", string()),
                                       parameter(Direction.IN,
                                                 "new_prep_time", sql_time()),
                                       parameter(Direction.IN,
                                                 "new_cook_time", sql_time()),
                                       parameter(
                                           Direction.IN, "new_creation_date", sql_datetime()),
                                       parameter(Direction.IN,
                                                 "new_culture", string()),
                                       parameter(
                                           Direction.IN, "new_description", string(255)),
                                       parameter(Direction.IN,
                                                 "new_created_by", integer()),
                                       parameter(Direction.OUT,
                                                 "new_id", integer())
                                   ]))

# procedure to insert allergy and retreive inserted record id
procedures.append(create_procedure("insert_allergy", """
    INSERT INTO allergy(allergy_name) VALUES(new_allergy);
    SET new_id = LAST_INSERT_ID();
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "new_allergy", string()),
                                       parameter(Direction.OUT,
                                                 "new_id", integer())
                                   ]))

# procedure to insert user and return inserted record id
procedures.append(create_procedure("insert_user", """
    INSERT INTO user(username, first_name, last_name, password) VALUES
    (new_username, new_first_name, new_last_name, new_password);
    SET new_id = LAST_INSERT_ID();
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "new_username", string()),
                                       parameter(Direction.IN,
                                                 "new_first_name", string()),
                                       parameter(Direction.IN,
                                                 "new_last_name", string()),
                                       parameter(Direction.IN,
                                                 "new_password", string()),
                                       parameter(Direction.OUT,
                                                 "new_id", integer())
                                   ]))

# procedure to insert user with an allergy and return inserted record id
procedures.append(create_procedure("insert_user_with_allergy", """
    INSERT INTO user(username, first_name, last_name, password) VALUES
    (new_username, new_first_name, new_last_name, password);
    SET new_id = LAST_INSERT_ID();
    CALL insert_user_allergy(new_id, allergy_id);
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "new_username", string()),
                                       parameter(Direction.IN,
                                                 "new_first_name", string()),
                                       parameter(Direction.IN,
                                                 "new_last_name", string()),
                                       parameter(Direction.IN,
                                                 "new_password", string()),
                                       parameter(Direction.IN,
                                                 "allergy_id", integer()),
                                       parameter(Direction.OUT,
                                                 "new_id", integer())
                                   ]))

# simple delete procedure
procedures.append(create_procedure("delete_record", """
    DELETE FROM table_name WHERE id=value;""",
                                   [
                                       parameter(Direction.IN,
                                                 "table_name", string()),
                                       parameter(Direction.IN, "id", string()),
                                       parameter(Direction.IN,
                                                 "value", integer())
                                   ]))


# get procedures

# get a specific user's meal plan
procedures.append(create_procedure("get_user_meal_plan", """
    SELECT *
    FROM
        meal_plans_with_planned_meals_agg m
    WHERE m.for_user=uid;
    """,
                                   [parameter(Direction.IN, "uid", integer())]))

procedures.append(create_procedure("get_user_shopping_list", """
    SELECT
        SUM(p.amount) amount_needed,
        si.stock_quantity,
        p.ingredient_id,
        p.ingredient_name
    FROM
        meal_plans_with_planned_meals p
    JOIN(
        SELECT
            s.user_id,
            s.stock_quantity,
            i.ingredient_id,
            i.ingredient_name
        FROM
            ingredient i
        JOIN(
            SELECT
                *
            FROM
                `in_stock` ist
            WHERE
                ist.user_id=uid
        ) s
    ON
        i.ingredient_id = s.ingredient_id
    ) si
    ON
        p.for_user = si.user_id AND p.ingredient_id=si.ingredient_id
    GROUP BY
        p.ingredient_id,
        si.stock_quantity;
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "uid", integer())
                                   ]))

procedures.append(create_procedure("get_one_user", """
    SELECT * FROM user_allergy_joined_agg WHERE user_id=uid;
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "uid", integer())
                                   ]))

procedures.append(create_procedure("get_user_by_login", """
SELECT * FROM user
WHERE username=uname AND password=pass;
""", [
    parameter(Direction.IN, 'uname', string()),
    parameter(Direction.IN, 'pass', string())
]))

procedures.append(create_procedure("get_recipe_detail", """
    SELECT 
        ri.recipe_id,
        ri.recipe_name,
        ri.image_url,
        ri.prep_time,
        ri.cook_time,
        ri.creation_date,
        ri.culture,
        ri.description,
        ri.created_by,
        ri.instructions,
        JSON_ARRAYAGG(JSON_OBJECT(
            'ingredient_id',
            rimj.ingredient_id,
            'ingredient_name',
            rimj.ingredient_name,
            'amount',
            rimj.amount,
            'unit',
            rimj.unit,
            'allergy_id',
            rimj.allergy_id,
            'allergy_name',
            rimj.allergy_name,
            'calorie_count',
            rimj.calorie_count)) ingredient_measurements
    FROM
        ingredient_measurement_joined rimj
        JOIN
        (
            SELECT
                r.recipe_id,
                r.recipe_name,
                r.image_url,
                r.prep_time,
                r.cook_time,
                r.creation_date,
                r.culture,
                r.description,
                r.created_by,
                JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'instruction_id',
                        instr.instruction_id,
                        'step_number',
                        instr.step_number,
                        'instruction_details',
                        instr.instruction_details
                    )
                ) instructions
            FROM recipe r JOIN instruction instr ON instr.recipe_id=r.recipe_id
            WHERE r.recipe_id=rid
            GROUP BY recipe_id
        ) ri
        ON ri.recipe_id=rimj.recipe_id
        GROUP BY ri.recipe_id;
    """,
                                   [
                                       parameter(Direction.IN,
                                                 "rid", integer())
                                   ]))


##### END DB CREATION #####


def print_info(msg):
    """
    Prints a message and returns to the start of the line
    """
    print(msg, end="\r")


def print_done(msg):
    """
    Prints a message indicating that the job is finished.
    Clears the line first and prints a green tick in front of the message
    """
    try:
        print("\033[2K\033[32m\u2713\033[0m "+msg)
    except UnicodeEncodeError:
        print("\033[2K"+msg)


def format_time_elapsed(ttime: timedelta):
    def get_time_elapsed(t: timedelta):
        hours, remainder = divmod(t.total_seconds(), 3600)
        minutes, remainder = divmod(remainder, 60)
        seconds, milliseconds = divmod(remainder, 1000)

        return int(hours), int(minutes), int(seconds), milliseconds

    hrs, m, s, ms = get_time_elapsed(ttime)
    return f"""{f"{hrs}hrs, " if hrs else ""}{f"{m}min, " if m else ""}{f"{s}s, " if s else ""}{ms}ms"""

##### DB INSERT #####


if __name__ == "__main__":
    start = datetime.now()
    file_handler = open("sophro_db.sql", "w")

    # write data
    file_handler.write(drop_db_stmt)

    file_handler.write(db_create_stmt)

    file_handler.write(use_db_stmt)

    # write all tables
    for table in tables:
        file_handler.write(table)

    print_done("Tables created")

    # write all views
    for view in views:
        file_handler.write(view)

    print_done("Views created")

    # write all procedures
    for procedure in procedures:
        file_handler.write(procedure)

    print_done("Procedures created")

    no_users = 200
    no_recipes = 600

    print_info("Generating allergies data...")
    allergies_data = generate_allergies_data()
    print_done("Allergies data generated")

    print_info("Generating ingredients data...")
    ingredients_data = generate_ingredients_data()
    print_done("Ingredients data generated")

    print_info("Generating user data...")
    user_data = generate_user_data(no_users, fake)
    print_done("User data generated")

    print_info("Generating recipe data...")
    recipe_data = generate_recipe_data(no_recipes, no_users, fake)
    print_done("Recipe data generated")

    print_info("Generating ingredient allergies data...")
    ingredient_allergies = generate_ingredient_allergies()
    print_done("Ingredient allergies data generated")

    print_info("Generating instruction data...")
    instruction_data = generate_instruction_data(fake, no_recipes)
    print_done("Instruction data generated")

    print_info("Generating in stock data...")
    in_stock_data = generate_in_stock_data(no_users)
    print_done("In stock data generated")

    print_info("Generating measurement data...")
    measurement_data = generate_measurment_inserts()
    print_done("Measurement data generated")

    print_info("Generating user allergy data...")
    user_allergies = generate_user_allergies(no_users)
    print_done("User allergy data generated")

    print_info("Generating the recipe ingredients and measurements data...")
    recipe_ingredients = generate_recipe_measurement(no_recipes, fake)
    print_done("Recipe ingredients and measurements data generated")

    print_info("Generating meal plan data...")
    meal_plan_data = generate_meal_plans(no_users)
    print_done("Meal plans generated")

    print_info("Generating planned meals...")
    planned_meal_data = generate_planned_meals(no_users, no_recipes)
    print_done("Planned meals generated")

    data_lst = [user_data, recipe_data, ingredients_data,
                allergies_data, ingredient_allergies, instruction_data, in_stock_data, measurement_data, user_allergies, recipe_ingredients, meal_plan_data, planned_meal_data]

    for data in data_lst:
        for data_str in data:
            file_handler.write(data_str)

    print_done("Data inserts written to file")

    # close file
    file_handler.close()

    # print time stats
    end = datetime.now()
    total_time = end-start
    print(f"Finished in {format_time_elapsed(total_time)}")
