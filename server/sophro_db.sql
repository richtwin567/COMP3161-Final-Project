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
	description VARCHAR(1500) NOT NULL,
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
    (1, 'powellmary', 'Melissa', 'Johnson', 'B2rmoMss^A1B'),
	(2, 'holly61', 'Doris', 'Jones', 'khtCLoX9(6Pp'),
	(3, 'stacymcconnell', 'William', 'Soto', '@61ZFl9f#3Wp'),
	(4, 'joseph37', 'Lauren', 'Perez', '(kC#PFFRc5Y^'),
	(5, 'fhuber', 'Maria', 'Clayton', '!(8fHYUzujY('),
	(6, 'ryan49', 'Jim', 'Holmes', 'um!ysG_E_1Ce'),
	(7, 'mrodriguez', 'Mary', 'Lopez', 'I9F_D^c$C*#3'),
	(8, 'molly44', 'Laura', 'Serrano', 'LA9SGLHf#uLv'),
	(9, 'pagemegan', 'Craig', 'Brown', '#HQ9jVkb05(A'),
	(10, 'katherine81', 'Jack', 'House', '^6R28cR2cy$p'),
	(11, 'austinlaurie', 'Andre', 'Pennington', 'jmI0NHXmVh&d'),
	(12, 'anne14', 'Jaime', 'Rodriguez', 'E5^8bPlhS$KD'),
	(13, 'mariajohnson', 'Blake', 'Contreras', '4WZ*ylNogC3V'),
	(14, 'donald56', 'Michael', 'Taylor', 'A6RW&jix(f1P'),
	(15, 'jonesnatalie', 'Cassidy', 'Lucas', 'FAPpHrDf+9@c'),
	(16, 'simonteresa', 'Crystal', 'Bentley', '!2bQnY(BxP3*'),
	(17, 'stephen71', 'Chase', 'Phelps', '3ELgokT9$y2g'),
	(18, 'maloneadrian', 'Shannon', 'Malone', '91n8U1rs$BSR'),
	(19, 'alexanderhart', 'Samuel', 'Merritt', 'y*g1S3$gg&%I'),
	(20, 'wolson', 'Nicholas', 'Parrish', '*9HRk1nQGL)$'),
	(21, 'michael54', 'Eric', 'Beck', '22jswxMC&!YY'),
	(22, 'kimberly43', 'Francisco', 'Mitchell', 'k+9MoWGm$rfT'),
	(23, 'melissa46', 'Jared', 'Gordon', 'gO3FY(u&+BYH'),
	(24, 'adamstephens', 'Lindsey', 'Craig', '_x9QfqqIGTgu'),
	(25, 'sheila68', 'Jennifer', 'Howell', '#Ky__%#g@73Q'),
	(26, 'danielroberts', 'Cindy', 'Morrison', 'ayTPIz4x%f4K'),
	(27, 'hernandezbrittany', 'David', 'Moody', 'A#^w7PpA%*8m'),
	(28, 'mburton', 'Andrew', 'Dixon', 'p_5eWbpWScdY'),
	(29, 'davisvincent', 'Evan', 'Reyes', 'HDSGM0hq^1QQ'),
	(30, 'umcfarland', 'Gregory', 'Franklin', '3D%9vmka%iSf'),
	(31, 'johnsonchristina', 'Robert', 'Young', 'vW0+1$&y+TN@'),
	(32, 'jeff21', 'Troy', 'Campbell', '5AYBGo9b$dH_'),
	(33, 'kmartin', 'Jason', 'Park', '73DWrPApH53!'),
	(34, 'amandarodriguez', 'Shawn', 'Williams', 'k9@Qc1@$nRH!'),
	(35, 'mcculloughrobert', 'Colleen', 'Robinson', 'wUE3+YxVcn!n'),
	(36, 'sturner', 'Brandon', 'Sellers', '%8Tf7MEgGAAs'),
	(37, 'alexalexander', 'Jeffrey', 'Compton', '(L_Cx2BqGbz('),
	(38, 'scott59', 'Tammy', 'Wong', 'MysHmrcm!K6f'),
	(39, 'gbrown', 'Justin', 'Mayer', 'XMN3V&Xy*oKz'),
	(40, 'barrmia', 'Leroy', 'Robles', '$4PPEL0e(1!n'),
	(41, 'victoriakim', 'Matthew', 'Hall', 'AqJec^_#@4Mt'),
	(42, 'kathleen66', 'Stephanie', 'Barnes', '*4L1G846mnIi'),
	(43, 'farmerlaura', 'Gabriella', 'Matthews', 'PE9%juLs+^f3'),
	(44, 'barry41', 'Tyler', 'Moore', '9%%kUtYf(HFa'),
	(45, 'qthompson', 'Heather', 'Diaz', ')b8Q6jd3LFTb'),
	(46, 'kochconnor', 'Stephen', 'Gill', '^U%wOLqmy6IO'),
	(47, 'belindahicks', 'Glenn', 'Graham', '(_l54F%o!918'),
	(48, 'robert93', 'Chad', 'Conley', '$1hiDysJkG$5'),
	(49, 'padams', 'Derrick', 'Buckley', 'kPJY99d*&t76'),
	(50, 'vwright', 'Christopher', 'Larsen', 'dQWnCoZ#++3z');
