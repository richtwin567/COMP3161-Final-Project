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

    PRIMARY KEY(ingredient_id),
	UNIQUE KEY(name)
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
    (1, 'zacharystokes', 'Bradley', 'Wyatt', '^Tsl*KoV0py2'),
	(2, 'rosssamantha', 'Jessica', 'Young', 'kdn&4gAm$7MT'),
	(3, 'pmartinez', 'Paul', 'Gordon', '62VfL1Dr&bFc'),
	(4, 'catherine62', 'Jeremy', 'Walker', '+R8XJ0ps5utD'),
	(5, 'amccarthy', 'Wesley', 'Mann', '@%5gQsc2LH&e'),
	(6, 'david07', 'Danielle', 'Walsh', 'bnXI4q&O$6zb'),
	(7, 'nicole26', 'Morgan', 'Wyatt', '(@8Q1za(_3AK'),
	(8, 'michaeljones', 'Nicole', 'Giles', 'jTx*lDh%g8zW'),
	(9, 'wrightmichael', 'Robert', 'Byrd', 'v4o!bw5C(0Vi'),
	(10, 'sabrinashaw', 'David', 'Gonzalez', 'e9CgGzs(%)le'),
	(11, 'taylordaniel', 'Amber', 'Ho', '8*k+IR7f!jT!'),
	(12, 'chaneyshannon', 'Kimberly', 'Gardner', '%b32W0JsNN!!'),
	(13, 'terrytimothy', 'Kristen', 'Klein', '+o0n+bGeEeTz'),
	(14, 'katiestuart', 'Donald', 'Harper', '80M2L*Ka@V5W'),
	(15, 'mark51', 'Shawn', 'Griffith', '_v_)QElf+97Z'),
	(16, 'korr', 'Brittany', 'Morgan', '9!WvQshVmF5+'),
	(17, 'jonesandrew', 'James', 'Pierce', '^N((NM1mtJ5U'),
	(18, 'amy72', 'John', 'Baldwin', '91J@RFNs^m5#'),
	(19, 'mcdonaldjulie', 'Frederick', 'Lewis', ')^LORcxnts13'),
	(20, 'kwade', 'Nicole', 'Willis', '@5+$LNifitr%'),
	(21, 'timothykelly', 'Crystal', 'Phillips', '!tOygx$^GTT5'),
	(22, 'daniel13', 'William', 'King', '_7HTy3)tnYJK'),
	(23, 'joshua52', 'Olivia', 'Perez', '*RFVig3xK7oD'),
	(24, 'scotthendrix', 'Rebecca', 'Young', ')N@fB4r%MX6_'),
	(25, 'coreyclements', 'Jose', 'Miller', '*f#bZDlH%O+7'),
	(26, 'hwright', 'Cameron', 'Miller', '*k$ACqmiK@2N'),
	(27, 'anthony71', 'Lucas', 'Owens', '+6lA0x4kmOUW'),
	(28, 'maryrodriguez', 'Laura', 'Jackson', 'rM*4GzFgWUdM'),
	(29, 'oliverjesse', 'Ariel', 'Walsh', 'AxpJypBE(5W!'),
	(30, 'brittanymendez', 'Paul', 'Sheppard', ')(zb#5Gkdeay'),
	(31, 'umiranda', 'Jennifer', 'Wilson', '*C6h7Hins!jG'),
	(32, 'sanchezmonica', 'Shawn', 'Bright', '3cUKzJkf^_iW'),
	(33, 'gregory94', 'Martin', 'Johnson', '_k3cLst_#7(X'),
	(34, 'kmack', 'Laura', 'Hobbs', 'o$n9U6L$us0d'),
	(35, 'davidmayer', 'Charles', 'Torres', '@80QjMkx_vGR'),
	(36, 'owenjay', 'Courtney', 'Montoya', '2biUGISNm#Y3'),
	(37, 'richard38', 'Sean', 'Bush', '1kX%lbQt^F8I'),
	(38, 'michelle03', 'Nancy', 'Owen', '_er9FPCy!*NX'),
	(39, 'beckerdavid', 'Christopher', 'Hudson', 'r^Le0TuzUVaa'),
	(40, 'luke09', 'Michelle', 'Torres', 'xYaNhtnUEh0*'),
	(41, 'jgarner', 'Lindsey', 'Wilson', '_3_!yvSb1Nt6'),
	(42, 'robert13', 'Gregory', 'Evans', 'cu1XPcZd!oB%'),
	(43, 'wardtheresa', 'Sarah', 'Black', 'u9FXly8J!IHt'),
	(44, 'david04', 'Ryan', 'Collins', '^zO)vUaFW_1B'),
	(45, 'rebecca94', 'Timothy', 'Brown', '*_TKRPu3ye91'),
	(46, 'djohnson', 'Amanda', 'Franklin', 'A0L6K4GJ&lU1'),
	(47, 'ujackson', 'Kathleen', 'Spence', 'SXE3ENPc(TDS'),
	(48, 'burtonrandy', 'Natalie', 'Snyder', '(FCy9B2*1Dni'),
	(49, 'ellendavis', 'Jesus', 'Garcia', '1j&a4CZKJPU7'),
	(50, 'awarner', 'Thomas', 'Murphy', '0*&NPuGE77n5');
