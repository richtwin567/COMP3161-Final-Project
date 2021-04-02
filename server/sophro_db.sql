DROP DATABASE IF EXISTS sophro;
CREATE DATABASE sophro;
USE sophro;


CREATE TABLE allergy (
    allergy_id INT NOT NULL AUTO_INCREMENT,
	allergy_name VARCHAR(255) NOT NULL,

    PRIMARY KEY(allergy_id)
);

CREATE TABLE ingredient (
    ingredient_id INT NOT NULL AUTO_INCREMENT,
	stock_quantity INT NOT NULL,
	name VARCHAR(255) NOT NULL,
	calorie_count INT NOT NULL,

    PRIMARY KEY(ingredient_id)
);

CREATE TABLE measurement (
    measurement_id INT NOT NULL AUTO_INCREMENT,
	amount FLOAT(2) NOT NULL,
	unit VARCHAR(15) NOT NULL,

    PRIMARY KEY(measurement_id)
);

CREATE TABLE user (
    user_id INT NOT NULL AUTO_INCREMENT,
	username VARCHAR(255) NOT NULL,
	first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255) NOT NULL,
	password VARCHAR(255) NOT NULL,

    PRIMARY KEY(user_id),
	UNIQUE KEY(username)
);

CREATE TABLE recipe (
    recipe_id INT NOT NULL AUTO_INCREMENT,
	image_url VARCHAR(255) NOT NULL,
	prep_time TIME NOT NULL,
	cook_time TIME NOT NULL,
	creation_date DATETIME NOT NULL,
	culture VARCHAR(255) NOT NULL,
	description VARCHAR(255) NOT NULL,
	recipe_name VARCHAR(255) NOT NULL,
	created_by INT,

    PRIMARY KEY(recipe_id),
	FOREIGN KEY(created_by) REFERENCES user(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ingredient_allergy (
    allergy_id INT NOT NULL,
	ingredient_id INT NOT NULL,

    PRIMARY KEY(allergy_id, ingredient_id),
	FOREIGN KEY(allergy_id) REFERENCES allergy(allergy_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE instruction (
    instruction_id INT NOT NULL AUTO_INCREMENT,
	step_number INT NOT NULL,
	instruction_details VARCHAR(255) NOT NULL,
	recipe_id INT NOT NULL,

    PRIMARY KEY(instruction_id),
	FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE recipe_ingredient_measurement (
    recipe_id INT NOT NULL,
	ingredient_id INT NOT NULL,
	measurement_id INT NOT NULL,

    PRIMARY KEY(recipe_id, ingredient_id, measurement_id),
	FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(measurement_id) REFERENCES measurement(measurement_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE meal_plan (
    plan_id INT NOT NULL AUTO_INCREMENT,
	for_user INT NOT NULL,

    PRIMARY KEY(plan_id),
	FOREIGN KEY(for_user) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE planned_meal (
    meal_id INT NOT NULL AUTO_INCREMENT,
	time_of_day ENUM('Breakfast', 'Lunch', 'Dinner') NOT NULL,
	serving_size INT NOT NULL,
	recipe_id INT NOT NULL,
	plan_id INT NOT NULL,

    PRIMARY KEY(meal_id, plan_id),
	FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(plan_id) REFERENCES meal_plan(plan_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_allergy (
    user_id INT NOT NULL,
	allergy_id INT NOT NULL,

    PRIMARY KEY(user_id, allergy_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(allergy_id) REFERENCES allergy(allergy_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE in_stock (
    user_id INT NOT NULL,
	ingredient_id INT NOT NULL,
	in_stock TINYINT NOT NULL,

    PRIMARY KEY(user_id, ingredient_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE
);

DELIMITER //

CREATE PROCEDURE insert_recipe(IN mew_image_url VARCHAR(255), IN new_prep_time TIME, IN new_cook_time TIME, IN new_creation_date DATETIME, IN new_culture VARCHAR(255), IN new_description VARCHAR(1500), IN new_created_by INT, OUT new_id INT)
BEGIN
    
    INSERT INTO recipe(image_url, prep_time, cook_time,  creation_date, culture, description, created_by)
    VALUES (new_image_url, new_prep_time, new_cook_time, new_creation_date, new_culture, new_description, new_created_by);
    SET new_id = LAST_INSERT_ID();
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE insert_allergy(IN new_allergy VARCHAR(255), OUT new_id INT)
BEGIN
    
    INSERT INTO allergy(allergy_name) VALUES(new_allergy);
    SET new_id = LAST_INSERT_ID();
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE insert_user(IN new_username VARCHAR(255), IN new_first_name VARCHAR(255), IN new_last_name VARCHAR(255), IN new_password VARCHAR(255), OUT new_id INT)
BEGIN
    
    INSERT INTO user(username, first_name, last_name, password) VALUES
    (new_username, new_first_name, new_last_name, password);
    SET new_id = LAST_INSERT_ID();
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE insert_user_with_allergy(IN new_username VARCHAR(255), IN new_first_name VARCHAR(255), IN new_last_name VARCHAR(255), IN new_password VARCHAR(255), IN allergy_id INT, OUT new_id INT)
BEGIN
    
    INSERT INTO user(username, first_name, last_name, password) VALUES
    (new_username, new_first_name, new_last_name, password);
    SET new_id = LAST_INSERT_ID();
    CALL insert_user_allergy(new_id, allergy_id);
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE delete_record(IN table_name VARCHAR(255), IN id VARCHAR(255), IN value INT)
BEGIN
    
    DELETE FROM table_name WHERE id=value;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE join_ingredient_measurement()
BEGIN
    
    DROP VIEW IF EXISTS ingredient_measurements;
    CREATE VIEW ingredient_measurements
    AS
    SELECT
        rimj.recipe_id,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'ingredient_name', rimj.name, 
                'calorie_count', rimj.calorie_count, 
                'measurement', JSON_OBJECT('amount', m.amount,'unit', m.unit )
            )
        ) ingredients
    FROM 
        measurement m 
        JOIN 
            (
                SELECT * 
                FROM 
                    recipe_ingredient_measurement rim 
                    JOIN ingredient ing 
                    ON ing.ingredient_id=rim.ingredient_id
            ) rimj 
        ON rimj.measurement_id=m.measurement_id
    GROUP BY rimj.recipe_id;
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_all_recipes()
BEGIN
    
    CALL join_ingredient_measurement();
    DROP VIEW IF EXISTS all_recipes;
    CREATE VIEW all_recipes
    AS
    SELECT 
        ri.recipe_id,
        ri.image_url,
        ri.prep_time,
        ri.cook_time,
        ri.creation_date,
        ri.culture,
        ri.description,
        JSON_ARRAYAGG(ri.instruction) instructions,
        jimr.ingredients
    FROM
        ingredient_measurements jimr 
        JOIN
        (
            SELECT 
                r.recipe_id, 
                r.image_url,
                r.prep_time,
                r.cook_time,
                r.creation_date,
                r.culture,
                r.description,
                created_by created_by_id, 
                JSON_OBJECTAGG(instr.step_number, instr.instruction_details) instruction
            FROM recipe r JOIN instruction instr ON instr.recipe_id=r.recipe_id
            GROUP BY r.recipe_id
        ) ri
        ON ri.recipe_id=jimr.recipe_id
        GROUP BY ri.recipe_id;
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_planned_meals_with_recipe()
BEGIN
    
    CALL get_all_recipes();
    DROP VIEW IF EXISTS planned_meals_with_recipe;
    CREATE VIEW planned_meals_with_recipe
    AS
    SELECT *
    FROM
        planned_meal p JOIN all_recipes a ON p.recipe_id=a.recipe_id;
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_user_meal_plan(IN uid INT)
BEGIN
    
    CALL get_planned_meals_with_recipe();
    SELECT 
        m.for_user, 
        m.plan_id,
        JSON_ARRAYAGG(JSON_OBJECT(
            'image_url',
            p.image_url,
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
            p.description))
    FROM
        meal_plan m JOIN planned_meals_with_recipe p ON p.plan_id=m.plan_id
    WHERE m.for_user=uid
    GROUP BY m.plan_id;
    
END //

DELIMITER ;

INSERT INTO user VALUES
    (1, 'kevinwalker', 'Nathan', 'Roberson', 't_5V6tTDzi#L'),
	(2, 'ryan70', 'Ryan', 'Johnson', ')B8*Gd#rfh+5'),
	(3, 'danielle15', 'Michele', 'Moore', '0jTv*fRS&!eA'),
	(4, 'mcdanielrachel', 'Lynn', 'Reid', 'SKGKHx!S%#0w'),
	(5, 'williamspatricia', 'Lauren', 'Travis', '*UxNVr0TL*1G'),
	(6, 'rickey69', 'Samantha', 'Scott', 'f7t#sUIKwCU&'),
	(7, 'natasha82', 'Elizabeth', 'Davis', '6tt3C6Br@ID+'),
	(8, 'pleonard', 'Steve', 'Gordon', '^KBjLliPA5A8'),
	(9, 'gloverelizabeth', 'Frederick', 'Miller', '(#7Awqx1ZtEg'),
	(10, 'martinezamber', 'Donna', 'Wolf', '3EyFKoPn@6OH');

INSERT INTO recipe VALUES
    (1, 'https://www.lorempixel.com/447/743', '00:37:29', '01:02:52', '2021-04-02 02:04:07', 'Portuguese', 'Cultural doctor task why main husband several reduce. Citizen instead operation street.', 'Bitter and Buttered Fried Rice and Pecan Pie', 9),
	(2, 'https://dummyimage.com/732x197', '01:16:28', '00:07:39', '2021-04-02 02:04:07', 'Korean', 'Reason short author lead well nice. He power why. Debate several provide.', 'Bitter  Gourmet Stew Peas  Plantain Porridge', 3),
	(3, 'https://placekitten.com/490/740', '03:12:44', '03:04:13', '2021-04-02 02:04:07', 'Bislama', 'International skill state artist piece beat once. National computer reduce realize billion billion magazine.', 'Briny  Crisp,Crunchy Beef Lasagne and Cream of Pumpkin Soup', 2),
	(4, 'https://www.lorempixel.com/940/853', '01:48:04', '01:55:01', '2021-04-02 02:04:07', 'Herero', 'Phone stand participant order goal gas. Apply nature agent require data word. Economy example she meet news personal adult.', 'Appetizing and Caked Milkshake and Rice and Peas', 5),
	(5, 'https://dummyimage.com/881x788', '03:11:19', '03:08:47', '2021-04-02 02:04:07', 'Chamorro', 'Available father we different life issue. Set without and. Common experience explain party check small buy.', 'Briny and Balsamic Muffin and Milkshake', 10),
	(6, 'https://placeimg.com/513/84/any', '00:42:46', '01:11:06', '2021-04-02 02:04:07', 'Ido', 'Teacher form cultural pull figure. National president front want blood standard. Anything example every two prevent last.', 'Briny and Boiled Muffin  Chicken', 10),
	(7, 'https://dummyimage.com/440x662', '00:54:40', '02:57:19', '2021-04-02 02:04:07', 'Amharic', 'Couple recognize add outside anything leader collection. Woman throw meet radio source ready will. Threat manage reality wonder.', 'Appetizing  Acid Dahl and Dahl', 5),
	(8, 'https://placekitten.com/1009/324', '03:06:49', '02:34:33', '2021-04-02 02:04:07', 'Vietnamese', 'Media order central produce. Age participant edge.', 'Calorie and Creamy Chop Suey and Bread', 5),
	(9, 'https://placeimg.com/490/210/any', '02:12:52', '00:17:20', '2021-04-02 02:04:07', 'Chichewa', 'Budget work of test often unit. Meeting under join country.', 'Blended and Bite-size Chicken Soup and Chop Suey', 6),
	(10, 'https://placekitten.com/78/410', '03:34:06', '03:42:57', '2021-04-02 02:04:07', 'Swati', 'Now series although up. Bring off your we.', 'Bite-size and Burnt Dahl and Pecan Pie', 5);

INSERT INTO ingredient VALUES
    (1, 69, 'meat cuts', 894),
	(2, 19, 'file powder', 291),
	(3, 47, 'smoked sausage', 2026),
	(4, 192, 'okra', 2397),
	(5, 105, 'shrimp', 2412),
	(6, 110, 'andouille sausage', 591),
	(7, 2, 'water', 2317),
	(8, 160, 'paprika', 1841),
	(9, 153, 'hot sauce', 1696),
	(10, 162, 'garlic cloves', 1113),
	(11, 65, 'browning', 1640),
	(12, 195, 'lump crab meat', 1441),
	(13, 46, 'vegetable oil', 1777),
	(14, 99, 'all-purpose flour', 507),
	(15, 36, 'freshly ground pepper', 977),
	(16, 169, 'flat leaf parsley', 1993),
	(17, 173, 'boneless chicken skinless thigh', 1871),
	(18, 148, 'dried thyme', 1043),
	(19, 55, 'white rice', 1640),
	(20, 146, 'yellow onion', 1399),
	(21, 109, 'ham', 452),
	(22, 13, 'baking powder', 1781),
	(23, 88, 'eggs', 1760),
	(24, 67, 'all-purpose flour', 777),
	(25, 87, 'raisins', 1028),
	(26, 129, 'milk', 1216),
	(27, 165, 'white sugar', 1214);

INSERT INTO allergy VALUES
    (1, 'Nut Allergy'),
	(2, 'Oral Allergy Syndrome'),
	(3, 'Stone Fruit Allergy'),
	(4, 'Insulin Allergy'),
	(5, 'Allium Allergy'),
	(6, 'Histamine Allergy'),
	(7, 'Gluten Allergy'),
	(8, 'Legume Allergy'),
	(9, 'Salicylate Allergy'),
	(10, 'Cruciferous Allergy'),
	(11, 'Lactose intolerance'),
	(12, 'Shellfish Allergy'),
	(13, 'Sugar Allergy / Intolerance'),
	(14, 'Procrastination Allergy');

INSERT INTO ingredient_allergy VALUES
    (12, 1),
	(12, 2),
	(9, 3),
	(2, 4),
	(6, 5),
	(11, 6),
	(6, 7),
	(13, 8),
	(9, 9),
	(12, 10),
	(4, 11),
	(8, 12),
	(6, 13),
	(9, 14),
	(8, 15),
	(13, 16),
	(10, 17),
	(4, 18),
	(3, 19),
	(2, 20),
	(2, 21),
	(12, 22),
	(9, 23),
	(9, 24),
	(3, 25),
	(7, 26);
