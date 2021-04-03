DROP DATABASE IF EXISTS sophro;
CREATE DATABASE sophro;
USE sophro;


CREATE TABLE allergy (
    allergy_id INT NOT NULL AUTO_INCREMENT,
	allergy_name VARCHAR(255) NOT NULL,

    PRIMARY KEY(allergy_id),
	UNIQUE KEY(allergy_name)
);

CREATE TABLE ingredient (
    ingredient_id INT NOT NULL AUTO_INCREMENT,
	ingredient_name VARCHAR(255) NOT NULL,
	calorie_count INT NOT NULL,

    PRIMARY KEY(ingredient_id),
	UNIQUE KEY(ingredient_name)
);

CREATE TABLE measurement (
    measurement_id INT NOT NULL AUTO_INCREMENT,
	unit VARCHAR(15) NOT NULL,

    PRIMARY KEY(measurement_id),
	UNIQUE KEY(unit)
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
	recipe_name VARCHAR(255) NOT NULL,
	image_url VARCHAR(255) NOT NULL,
	prep_time TIME NOT NULL,
	cook_time TIME NOT NULL,
	creation_date DATETIME NOT NULL,
	culture VARCHAR(255) NOT NULL,
	description VARCHAR(255) NOT NULL,
	created_by INT,

    PRIMARY KEY(recipe_id),
	FOREIGN KEY(created_by) REFERENCES user(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	UNIQUE KEY(recipe_name)
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
	FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE KEY(instruction_id, step_number, instruction_details, recipe_id)
);

CREATE TABLE recipe_ingredient_measurement (
    recipe_id INT NOT NULL,
	ingredient_id INT NOT NULL,
	measurement_id INT NOT NULL,
	amount FLOAT(2) NOT NULL,

    PRIMARY KEY(recipe_id, ingredient_id),
	FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(measurement_id) REFERENCES measurement(measurement_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE meal_plan (
    plan_id INT NOT NULL AUTO_INCREMENT,
	for_user INT NOT NULL,

    PRIMARY KEY(plan_id),
	FOREIGN KEY(for_user) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
	UNIQUE KEY(for_user)
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
	stock_quantity INT NOT NULL,

    PRIMARY KEY(user_id, ingredient_id),
	FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE VIEW user_allergy_joined
AS

SELECT
    u.user_id,
    jua.allergy_id,
    jua.allergy_name,
    u.username,
    u.first_name,
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
;
    
CREATE VIEW user_allergy_joined_agg
AS

SELECT
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
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
;
    
CREATE VIEW ingredient_allergy_joined
AS

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
;
    
CREATE VIEW ingredient_allergy_joined_agg
AS

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
;
    
CREATE VIEW user_in_stock_joined
AS

SELECT 
    u.user_id,
    u.username,
    u.first_name,
    u.last_name,
    u.allergy_id,
    si.allergy_name,
    si.ingredient_id,
    si.ingredient_name,
    si.calorie_count,
    si.stock_quantity,
    si.allergy_id ing_allergy_id,
    si.allergy_name ing_allergy_name
FROM 
    user_allergy_joined u
    JOIN
        (
            SELECT 
                s.stock_quantity,
                i.ingredient_id,
                i.ingredient_name,
                i.calorie_count,
                i.allergy_id,
                i.allergy_name,
                s.user_id
            FROM
                in_stock s
                JOIN ingredient_allergy_joined i
                ON i.ingredient_id=s.ingredient_id
        ) si
    ON si.user_id=u.user_id
;
    
CREATE VIEW user_in_stock_joined_agg
AS

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
;
    
CREATE VIEW ingredient_measurement_joined
AS

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
;
    
CREATE VIEW ingredient_measurement_joined_agg
AS

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
;
    
CREATE VIEW instruction_agg
AS

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
;
    
CREATE VIEW all_recipes
AS

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
        GROUP BY r.recipe_id
    ) ri
    ON ri.recipe_id=rimj.recipe_id
;
    
CREATE VIEW all_recipes_agg
AS

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
;
    
CREATE VIEW planned_meal_recipe_joined
AS

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
;
    
CREATE VIEW planned_meal_recipe_joined_agg
AS

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
;
    
CREATE VIEW meal_plans_with_planned_meals
AS

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
;
    
CREATE VIEW meal_plans_with_planned_meals_agg
AS

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
;
    
CREATE VIEW shopping_lists
AS

SELECT
    pa.for_user,
    u.username,
    u.first_name,
    u.last_name,
    pa.ingredient_name,
    u.stock_quantity,
    pa.total_amount amount_needed,
    pa.unit
FROM
    user_in_stock_joined u
    JOIN 
        (
            SELECT
                p.for_user,
                p.ingredient_name,
                SUM(p.amount) total_amount,
                p.unit
            FROM
                meal_plans_with_planned_meals p
            GROUP BY p.for_user, p.ingredient_name
        ) pa
    ON pa.for_user=u.user_id
GROUP BY pa.for_user, pa.ingredient_name
;
    
DELIMITER //

CREATE PROCEDURE insert_recipe(IN mew_image_url VARCHAR(255), IN new_prep_time TIME, IN new_cook_time TIME, IN new_creation_date DATETIME, IN new_culture VARCHAR(255), IN new_description VARCHAR(255), IN new_created_by INT, OUT new_id INT)
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

CREATE PROCEDURE get_user_meal_plan(IN uid INT)
BEGIN
    
    SELECT *
    FROM
        meal_plans_with_planned_meals_agg m
    WHERE m.for_user=uid;
    
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_user_shopping_list(IN user_id INT)
BEGIN
    
    SELECT *
    FROM shopping_lists s WHERE s.for_user=user_id;
    
END //

DELIMITER ;

INSERT INTO user VALUES
    (1, 'anthonyconner', 'Christopher', 'Kaufman', '*lsc&4FwtfFh'),
	(2, 'bakermary', 'Cynthia', 'Marquez', '#wM2ojpEtg6D'),
	(3, 'kelly44', 'Brianna', 'Henderson', 'RhU5O5R6%^n)'),
	(4, 'vmassey', 'Jesse', 'Melton', '!Qg2vcWVv8dA'),
	(5, 'jessicagallagher', 'Olivia', 'Porter', 'sqbOYE7go!8Z'),
	(6, 'toddjordan', 'John', 'May', '6t1^dZwH#k15'),
	(7, 'elizabethwhite', 'Brittany', 'Ramos', 'V21TBtHF+jCF'),
	(8, 'kevin31', 'Michelle', 'Clark', '#eTXOvRs8EC8'),
	(9, 'christy01', 'Amy', 'Griffith', '@y*&BOlpW(3^'),
	(10, 'waynechandler', 'Jacob', 'Harris', 'a%L4Yf$^$uos'),
	(11, 'ronaldchapman', 'Samuel', 'Dixon', 'JAI7HyBtQ*5^'),
	(12, 'rebeccathomas', 'Benjamin', 'Collins', '0$3DG!^P(jR5'),
	(13, 'johnny22', 'Gregory', 'Thomas', 'vX87mqc89)$R'),
	(14, 'dbennett', 'Heather', 'Barrera', 'H%(C1c#0a#8S'),
	(15, 'mclaughlinmelinda', 'Claudia', 'Peck', 'v_oiUSitlug6'),
	(16, 'edwardcolon', 'Ryan', 'Francis', 'Do4(!eVN(!fR'),
	(17, 'jonesjoshua', 'Gary', 'Calhoun', ')97VacVIZxh2'),
	(18, 'lcarter', 'Daniel', 'Johnston', 'Ci3C#ekcV)Rj'),
	(19, 'nnguyen', 'Aaron', 'Armstrong', '@#&YWmn27+y+'),
	(20, 'wross', 'Shelley', 'Gentry', '9dg3AKjSVc8%'),
	(21, 'gwoods', 'Angelica', 'Romero', '!ASkDXmG@20l'),
	(22, 'ellisryan', 'Dwayne', 'Morris', '0sP2Wjvcl_2S'),
	(23, 'sandrapaul', 'Ryan', 'Bentley', 'S7k&##7ADjvK'),
	(24, 'christianmichael', 'Morgan', 'Palmer', '@(1^S2du2ehI'),
	(25, 'umeyer', 'Crystal', 'Gray', '9EYHfZym!Q2R'),
	(26, 'cody85', 'Madeline', 'Hudson', '444UpJO6_(1h'),
	(27, 'iharper', 'Jimmy', 'Foster', ')nte2iTk2D6F'),
	(28, 'cory67', 'Kathleen', 'King', '&UDDQknh6PZ*'),
	(29, 'gonzalesamy', 'Justin', 'Young', '@3@65XenBY09'),
	(30, 'eddie91', 'Anna', 'Spencer', 'u!q21BsTe7Z1'),
	(31, 'chavezkimberly', 'Jacob', 'Shaw', 'hFpO5rJp&9$P'),
	(32, 'timothy31', 'Juan', 'Perry', 'M3OfDg2w)Ji7'),
	(33, 'bolson', 'Daniel', 'Dawson', '15Noc!VN@K5J'),
	(34, 'davislawrence', 'Frank', 'Richards', 'Hc6&Xeib#s)2'),
	(35, 'amber73', 'Nicole', 'Beard', '+wZ+Ow3+94Z3'),
	(36, 'johnsonjohn', 'Seth', 'Thomas', '#9J88uGu+h*2'),
	(37, 'matthewrich', 'Yvette', 'Miller', '0Lkl3ce$*)Zw'),
	(38, 'whiteheadcharlotte', 'Kyle', 'Clark', 'Akf+@waeQ8^M'),
	(39, 'kpatton', 'Bradley', 'Wong', '+o_6QIb)5zf3'),
	(40, 'zgarcia', 'Jeffrey', 'Foster', '^8PoJQpwgFad'),
	(41, 'emily80', 'Erica', 'Lawrence', '872jPxZK&IH_'),
	(42, 'christopher17', 'Tyler', 'Fischer', 'sugUJZgk)0I&'),
	(43, 'gutierrezthomas', 'Brian', 'Eaton', '&7&0nM0an6_M'),
	(44, 'dpayne', 'Jeffrey', 'Crawford', 'D8BpLuyN&(P2'),
	(45, 'fsullivan', 'Tammy', 'Wright', 'A!XL23W(!2Yy'),
	(46, 'dawnyates', 'Elizabeth', 'Singleton', '_5cL(_8nvAcV'),
	(47, 'grosssamantha', 'Russell', 'Nelson', '!4#)K8VBsgLK'),
	(48, 'johnmartin', 'Susan', 'Estes', '0rYf66Cpy@bK'),
	(49, 'tlee', 'Lauren', 'Wilson', '$5OluZtL%oib'),
	(50, 'stacygreen', 'Tiffany', 'Vega', 'V5Ms9g9T_3(Y');

INSERT INTO recipe VALUES
    (1, 'Astringent Balsamic Cornmeal Porridge and Milkshake', 'https://placeimg.com/273/686/any', '03:07:45', '03:42:42', '2021-04-03 00:45:50', 'Latvian', 'About somebody early fill like trade. Explain defense finish senior hit none. Treat dream owner.', 37),
	(2, 'Bland and Acidic Shepards Pie and Plantain Porridge', 'https://www.lorempixel.com/192/12', '00:13:24', '02:14:49', '2021-04-03 00:45:50', 'Ndonga', 'Deep traditional skill that agency tree music allow. Big behavior eight seem religious eye hundred high. According heavy miss mention seven bed Republican.', 7),
	(3, 'Candied and Burnt Cream of Pumpkin Soup Taco', 'https://www.lorempixel.com/982/498', '01:25:57', '02:21:15', '2021-04-03 00:45:50', 'Chinese', 'Wish recently significant middle operation go sure mind. Still technology fact network. On area sometimes partner age.', 49),
	(4, 'Blended Brown Fried Rice and Icecream', 'https://placekitten.com/735/804', '00:51:56', '03:52:25', '2021-04-03 00:45:50', 'Turkish', 'Interest wait situation data also season seven. They site if learn pass himself miss. Realize say police six short scientist.', 6),
	(5, 'Aromatic Creamed Brownies and Icecream', 'https://placekitten.com/552/871', '00:57:41', '03:52:04', '2021-04-03 00:45:50', 'Western Frisian', 'Clear attention also. Success explain seem culture hard.', 16),
	(6, 'Boiled Blended Icecream and Chicken Soup', 'https://dummyimage.com/290x94', '01:25:22', '02:26:13', '2021-04-03 00:45:50', 'Somali', 'Plant military bed skill challenge PM. Citizen suggest could hand imagine report situation us. Land help agreement word account.', 8),
	(7, 'Caramelized Boiled Icecream and Chicken Soup', 'https://placeimg.com/752/717/any', '03:48:30', '00:52:22', '2021-04-03 00:45:50', 'Pushto', 'Standard court necessary include avoid boy. Stock site they general state. Drop discussion fear home wait.', 1),
	(8, 'Tasty Ample Cornmeal Porridge and Wonton Soup', 'https://dummyimage.com/115x899', '02:48:10', '00:36:20', '2021-04-03 00:45:50', 'Thai', 'Available soon once interview admit see threat. Somebody we individual sing article. Anything role cause customer later white can.', 48),
	(9, 'Caked Bite-size Brownies and Stew Peas', 'https://placekitten.com/770/306', '03:18:02', '02:27:08', '2021-04-03 00:45:50', 'Azerbaijani', 'Late cell music fast then church. Sister along word claim second provide race. Seven could suggest computer hear detail kitchen away.', 31),
	(10, 'Boiled Astringent Chop Suey Chicken Soup', 'https://www.lorempixel.com/1000/815', '01:17:35', '03:44:35', '2021-04-03 00:45:50', 'Northern Sami', 'Time message sign. Which weight computer. Moment present suddenly task consumer.', 11),
	(11, 'Calorie and Blunt Red Peas Soup and Icecream', 'https://placeimg.com/1018/10/any', '02:52:25', '00:50:23', '2021-04-03 00:45:50', 'Basque', 'Everybody play road right. Project or sound college century certainly. Enjoy like also later new.', 41),
	(12, 'Bite-size and Roasted Cornmeal Porridge and Chicken', 'https://placeimg.com/478/277/any', '03:17:45', '00:08:27', '2021-04-03 00:45:50', 'Tahitian', 'Most chair eye today. Of bank sing sort. Experience rich brother impact so.', 23),
	(13, 'Tasty Ample Chop Suey Brownies', 'https://placekitten.com/912/107', '03:25:28', '00:00:18', '2021-04-03 00:45:50', 'Javanese', 'Listen even possible avoid easy decision others. Single generation effect why protect second.', 32),
	(14, 'Caked Astringent Icecream Chicken', 'https://www.lorempixel.com/401/38', '03:06:00', '03:42:43', '2021-04-03 00:45:50', 'Ndonga', 'Study describe any news compare name. Him reveal behind hour.', 22),
	(15, 'Caramelized Creamy Chop Suey Wonton Soup', 'https://placeimg.com/762/157/any', '02:38:41', '00:58:19', '2021-04-03 00:45:50', 'Uzbek', 'Smile instead point structure order. Though subject take play. Party special exactly far identify American. Five exist field local send arm big foot.', 48),
	(16, 'Astringent Boiled Muffin and Dahl', 'https://dummyimage.com/107x37', '00:57:01', '01:05:12', '2021-04-03 00:45:50', 'Chichewa', 'Work much open return car. Mention environmental necessary house admit lot similar law. Administration issue computer have such.', 45),
	(17, 'Appetizing and Buttered Muffin Chicken Soup', 'https://www.lorempixel.com/476/927', '00:29:20', '01:03:16', '2021-04-03 00:45:50', 'Tigrinya', 'Professor the card. Since full happen do reason should enter would. Consumer development police relate always trip.', 2),
	(18, 'Blended Roasted Apple Pie Red Peas Soup', 'https://placekitten.com/164/487', '00:48:55', '02:03:46', '2021-04-03 00:45:50', 'Oriya', 'All write early.', 24),
	(19, 'Acidic and Balsamic Wonton Soup Stew Peas', 'https://dummyimage.com/701x462', '02:35:24', '03:26:48', '2021-04-03 00:45:50', 'Afrikaans', 'Sure site know nation work religious. Listen plan service herself. Piece simple decision while modern hotel day to.', 47),
	(20, 'Beautiful Candied Brownies and Dahl', 'https://placekitten.com/290/988', '00:29:27', '00:59:15', '2021-04-03 00:45:50', 'Haitian', 'Minute question treatment example since develop. Far budget kitchen same.', 45),
	(21, 'Acid Creamed Icecream and Chicken Soup', 'https://dummyimage.com/690x378', '00:13:02', '00:23:39', '2021-04-03 00:45:50', 'Manx', 'Beautiful which book. Black they nature summer language lawyer cost.', 26),
	(22, 'Acid and Caked Beef Lasagne Cheesecake', 'https://dummyimage.com/851x822', '01:42:49', '01:22:50', '2021-04-03 00:45:50', 'Albanian', 'Knowledge order company draw six market interest. Base modern produce firm note think science anything. Garden couple hair would.', 17),
	(23, 'Candied and Blended Fried Rice and Stew Peas', 'https://dummyimage.com/487x547', '01:55:42', '00:23:08', '2021-04-03 00:45:50', 'Bashkir', 'Follow serious staff small look. Drive reach name according without role. Organization protect debate treatment top.', 34),
	(24, 'Aromatic and Bite-size Stew Peas and Cornmeal Porridge', 'https://placeimg.com/1011/205/any', '01:26:05', '03:35:51', '2021-04-03 00:45:50', 'Sundanese', 'Much experience similar relate. Well investment his also myself usually. Action after score article eat third soldier.', 1),
	(25, 'Calorie and Yummy Bread and Plantain Porridge', 'https://placekitten.com/917/465', '03:39:51', '02:32:48', '2021-04-03 00:45:50', 'Ganda', 'Idea despite knowledge. Interview lot us reduce.', 21),
	(26, 'Beautiful and Crisp,Crunchy Brownies and Chop Suey', 'https://placekitten.com/491/272', '03:01:10', '02:51:23', '2021-04-03 00:45:50', 'Kannada', 'His address today policy. Everyone around bar eight base.', 2),
	(27, 'Briny Yummy Plantain Porridge Chicken', 'https://dummyimage.com/324x212', '00:35:58', '02:26:44', '2021-04-03 00:45:50', 'Sotho, Southern', 'Prepare professor source. Think also behavior century wrong. Authority west doctor history bed audience animal inside.', 12),
	(28, 'Calorie Balsamic Muffin and Bread', 'https://placeimg.com/277/138/any', '02:51:05', '00:37:10', '2021-04-03 00:45:50', 'Norwegian', 'Let evidence base use during democratic ask. Tonight instead out. Plant positive including red.', 14),
	(29, 'Bitter and Ample Chicken Chicken Soup', 'https://placeimg.com/647/50/any', '03:59:30', '00:21:56', '2021-04-03 00:45:50', 'Croatian', 'Smile reason per represent cut product. During serious well leg able. Leg draw appear different region image sport.', 7),
	(30, 'Astringent Appealing Bread Stew Peas', 'https://placeimg.com/164/836/any', '00:00:33', '00:47:07', '2021-04-03 00:45:50', 'Tsonga', 'Authority sound ground ten stay. Kitchen issue Republican cause could lay city.', 7),
	(31, 'Gourmet Buttered Beef Lasagne Shepards Pie', 'https://placekitten.com/975/946', '02:29:36', '00:34:09', '2021-04-03 00:45:50', 'Turkmen', 'Market most rise. Too bank different with stay. Discuss travel keep black arrive human college.', 12),
	(32, 'Blended and Balsamic Beef Lasagne Chicken Soup', 'https://placeimg.com/254/621/any', '03:16:53', '00:40:49', '2021-04-03 00:45:50', 'Quechua', 'Drop hundred state there window in fight maybe. Relationship country only draw.', 48),
	(33, 'Ample Crisp,Crunchy Muffin Cream of Pumpkin Soup', 'https://placekitten.com/5/420', '00:17:20', '02:52:43', '2021-04-03 00:45:50', 'Chamorro', 'Everything deal pick measure before note reach. Watch deep all save on rather.', 5),
	(34, 'Appealing and Caramelized Plantain Porridge Wonton Soup', 'https://dummyimage.com/101x178', '03:44:34', '03:26:47', '2021-04-03 00:45:50', 'Estonian', 'Whole require early nearly under bill time. Certain program hear year.', 5),
	(35, 'Roasted Burnt Muffin Apple Pie', 'https://www.lorempixel.com/384/463', '02:47:29', '03:57:57', '2021-04-03 00:45:50', 'Guarani', 'Congress general focus impact official source. List prepare Democrat matter under tree school.', 33),
	(36, 'Blazed and Astringent Shepards Pie and Cheesecake', 'https://placeimg.com/707/227/any', '02:09:27', '01:22:18', '2021-04-03 00:45:50', 'Hindi', 'Everybody whom worker movement type. Main growth back likely paper. Remember investment light agreement our particular energy.', 32),
	(37, 'Appealing and Boiled Bread Wonton Soup', 'https://dummyimage.com/928x163', '01:43:28', '00:40:23', '2021-04-03 00:45:50', 'Aragonese', 'Minute both we beautiful. Control guy born light.', 30),
	(38, 'Bite-size and Brown Shepards Pie Red Peas Soup', 'https://placeimg.com/169/926/any', '03:57:56', '03:44:54', '2021-04-03 00:45:50', 'Kurdish', 'Necessary floor drive tonight deep. Five develop treatment respond policy center. Policy wear size decide.', 6),
	(39, 'Caked and Briny Muffin and Beef Lasagne', 'https://placekitten.com/364/740', '03:25:12', '01:48:08', '2021-04-03 00:45:50', 'Catalan', 'Center responsibility teacher fight development. Cup tree bring certainly stock happen manager degree. Increase seat they article include. Report group cup condition father trade.', 22),
	(40, 'Acid and Ample Shepards Pie and Taco', 'https://placekitten.com/844/289', '03:53:56', '01:40:41', '2021-04-03 00:45:50', 'Slovak', 'Recent why maybe charge notice per him side. Month accept open voice identify.', 24),
	(41, 'Juicy Astringent Bread Taco', 'https://placeimg.com/219/952/any', '00:44:52', '03:28:55', '2021-04-03 00:45:50', 'Bulgarian', 'Exist civil force style enjoy east.', 45),
	(42, 'Yummy and Burnt Apple Pie Cream of Pumpkin Soup', 'https://www.lorempixel.com/487/397', '00:39:36', '03:48:33', '2021-04-03 00:45:50', 'Komi', 'Difference up mention pattern trade cover federal. Degree work air several compare our.', 24),
	(43, 'Balsamic Creamed Bread and Cheesecake', 'https://placeimg.com/384/215/any', '02:38:52', '03:43:55', '2021-04-03 00:45:50', 'Kinyarwanda', 'Open culture woman central maybe drug friend recent. Relate town pull white right. Action beautiful in history any government catch.', 32),
	(44, 'Astringent and Juicy Cornmeal Porridge and Pecan Pie', 'https://dummyimage.com/241x68', '00:02:50', '00:27:12', '2021-04-03 00:45:50', 'Albanian', 'All single available staff take maybe good stand. Assume know clearly from raise. Most police minute talk lawyer your. Quickly line try chair.', 43),
	(45, 'Beautiful Gourmet Cream of Pumpkin Soup Bread', 'https://www.lorempixel.com/327/1017', '01:17:05', '03:19:44', '2021-04-03 00:45:50', 'Corsican', 'Resource who simply best. Back Mrs soldier defense big enjoy beyond. Beautiful responsibility hospital strategy interesting attack military.', 41),
	(46, 'Beautiful and Baked Cheesecake Apple Pie', 'https://www.lorempixel.com/864/333', '01:01:34', '01:47:55', '2021-04-03 00:45:50', 'Kikuyu', 'Firm much color difference determine why them professional. Box nation yet wide score as. Old help cultural agent.', 27),
	(47, 'Roasted and Creamy Red Peas Soup and Cream of Pumpkin Soup', 'https://placekitten.com/400/325', '02:02:08', '00:38:48', '2021-04-03 00:45:50', 'Aymara', 'Experience bad best hope political. Yard eat behavior Republican show.', 22),
	(48, 'Blunt Blended Shepards Pie and Stew Peas', 'https://placeimg.com/819/802/any', '03:28:26', '01:56:09', '2021-04-03 00:45:50', 'Croatian', 'Worry commercial structure ready thing. Respond send rise design girl two start management.', 16),
	(49, 'Juicy and Creamy Muffin Cheesecake', 'https://dummyimage.com/1019x76', '01:48:23', '02:44:32', '2021-04-03 00:45:50', 'Lingala', 'Under central enter must rate. Long energy put lay south consumer.', 6),
	(50, 'Blazed Balsamic Cheesecake and Red Peas Soup', 'https://dummyimage.com/229x804', '00:13:06', '01:51:43', '2021-04-03 00:45:50', 'Galician', 'Rock most leg position know.', 16);

INSERT INTO ingredient VALUES
    (1, 'meat cuts', 1943),
	(2, 'file powder', 1840),
	(3, 'smoked sausage', 672),
	(4, 'okra', 597),
	(5, 'shrimp', 2261),
	(6, 'andouille sausage', 215),
	(7, 'water', 1555),
	(8, 'paprika', 1951),
	(9, 'hot sauce', 756),
	(10, 'garlic cloves', 2393),
	(11, 'browning', 1633),
	(12, 'lump crab meat', 2097),
	(13, 'vegetable oil', 1164),
	(14, 'all-purpose flour', 387),
	(15, 'freshly ground pepper', 450),
	(16, 'flat leaf parsley', 1147),
	(17, 'boneless chicken skinless thigh', 387),
	(18, 'dried thyme', 1501),
	(19, 'white rice', 2212),
	(20, 'yellow onion', 2196),
	(21, 'ham', 1417),
	(22, 'baking powder', 2219),
	(23, 'eggs', 1804),
	(24, 'raisins', 2372),
	(25, 'milk', 310),
	(26, 'white sugar', 1813);

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
	(14, 'Procrastination Allergy'),
	(15, 'Soy allergy'),
	(16, 'Caffine Sensitivity'),
	(17, 'FODMAPs Sensitivity'),
	(18, 'Sulfite Sensitivity'),
	(19, 'Fructose Sensitivity'),
	(20, 'Aspartame Sensitivity'),
	(21, 'Egg Sensitivity'),
	(22, 'MSG Sensitivity'),
	(23, 'Yeast Allergy');

INSERT INTO ingredient_allergy VALUES
    (13, 1),
	(2, 2),
	(19, 3),
	(11, 4),
	(18, 5),
	(17, 6),
	(19, 7),
	(23, 8),
	(1, 9),
	(22, 10),
	(15, 11),
	(2, 12),
	(12, 13),
	(14, 14),
	(22, 15),
	(10, 16),
	(20, 17),
	(10, 18),
	(7, 19),
	(16, 20),
	(18, 21),
	(7, 22),
	(13, 23),
	(20, 24),
	(12, 25);
