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
    (1, 'daniel51', 'Monica', 'Sweeney', 'hQjnDjbH^(r8'),
	(2, 'jill02', 'Sheryl', 'Edwards', '$UHdJ*YeAr2V'),
	(3, 'brandiadams', 'Erica', 'Murphy', 'yqnh0PeeCH#+'),
	(4, 'fosteralan', 'Bradley', 'Hopkins', '0s5xtJuj&QW8'),
	(5, 'gina58', 'April', 'Hudson', '$$T@(9Yz3CnO'),
	(6, 'monique52', 'Helen', 'Pacheco', 'biS9VuP&(l8o'),
	(7, 'hodgesjennifer', 'Katherine', 'Smith', 'eDZnUiu@(5(g'),
	(8, 'cbecker', 'Larry', 'Johnson', ')27)gCHkHzB9'),
	(9, 'brittney95', 'Samuel', 'Foster', '1lH(Bn&@#&Ts'),
	(10, 'sjohnson', 'Charles', 'Hines', '+wg@0Tyc^z2t'),
	(11, 'campbellpatrick', 'Jessica', 'Reyes', 'l$z3f@Nhn%$l'),
	(12, 'avilanicole', 'Antonio', 'Cisneros', 'luheK+z5c!G4'),
	(13, 'john17', 'Justin', 'Perez', '*r$pYwgCqu8p'),
	(14, 'crios', 'Rachel', 'Long', '$4$yUscb$sE+'),
	(15, 'grantkrista', 'Daryl', 'Ball', 'e086VcKsk+NO'),
	(16, 'daniel98', 'Michael', 'Jackson', 'lI9Cz_44U&NM'),
	(17, 'xdiaz', 'Emily', 'Meza', 'O(!x1Fp3cn3W'),
	(18, 'hollowayrobert', 'Evan', 'Wiggins', 'yc%DXJbw+92C'),
	(19, 'prattkathryn', 'Catherine', 'Campbell', '0PzBPX%a9o+8'),
	(20, 'jamesjenkins', 'Joseph', 'Taylor', '8G*2UvNn3(Le'),
	(21, 'fwilliams', 'Jacob', 'Brock', 'cC16Waejq%C9'),
	(22, 'kathrynsmith', 'Barbara', 'Jenkins', 'd&2Daftbhz_B'),
	(23, 'robertsongregory', 'Dawn', 'Martinez', 'On0w%_gSX#FN'),
	(24, 'karakelly', 'Alisha', 'Beck', 'e7dcjS_1#0H&'),
	(25, 'deborahfreeman', 'Cameron', 'Nelson', 'W!1n)qQXDrdG'),
	(26, 'osbornmichele', 'Margaret', 'Willis', '(zm36rZt!6Dk'),
	(27, 'jessica74', 'Thomas', 'Davis', 'Ip&4zScI$I@a'),
	(28, 'hflores', 'Kayla', 'Harvey', 'FnNgG6nE_g0p'),
	(29, 'ian77', 'Martha', 'Turner', '_3NBmpJs%9we'),
	(30, 'guzmanaaron', 'Glenn', 'Ortiz', 'K(3XT*yLC(sh'),
	(31, 'kennethlambert', 'Bryan', 'Conley', '$%o48Ldp*Kn^'),
	(32, 'cannonalicia', 'Carol', 'Stokes', 'seSiI1RoQm$E'),
	(33, 'nthomas', 'Kendra', 'Valenzuela', 'HGUBnjadI99%'),
	(34, 'staceybrown', 'Tina', 'Bowers', 'cd4ZYQgY_q1$'),
	(35, 'tuckermichelle', 'Christopher', 'Hicks', 'tFV6PJVr4f(x'),
	(36, 'eric30', 'Jesse', 'Arias', 'F4rj#!_c(&fC'),
	(37, 'fharrison', 'Brian', 'Spencer', 'Kee0IVWxgf(P'),
	(38, 'kevin88', 'Cheryl', 'Arnold', '0AsXo)8yP!0!'),
	(39, 'bcopeland', 'Maria', 'Parker', '#6B#NIs!!va#'),
	(40, 'hskinner', 'Elizabeth', 'Ramirez', '90Sdqbn4)bnL'),
	(41, 'michellearcher', 'Paula', 'Castillo', 'i_9M0o4_tgus'),
	(42, 'sharpvanessa', 'Jennifer', 'Miller', 'LluJd&Ro6*4i'),
	(43, 'ashley43', 'Debra', 'Mcdonald', 'Ix#_JOFcdY62'),
	(44, 'asmith', 'Angie', 'Marshall', 'r$ESYlwxndV4'),
	(45, 'samuel34', 'Alexis', 'Skinner', 'xT6ajg1IK!Og'),
	(46, 'bartlettbrian', 'Mike', 'Bender', 'FBBKEAfd*8+L'),
	(47, 'millerkimberly', 'Katie', 'Lester', 'lX31hHko!D1t'),
	(48, 'efowler', 'William', 'Gilmore', 'nPH)Zwf@t(1G'),
	(49, 'hbell', 'Steven', 'Weeks', '0nXi(onQ%OqJ'),
	(50, 'fdaniels', 'Harold', 'Gonzalez', '%^Hr6_yz9$9E');
