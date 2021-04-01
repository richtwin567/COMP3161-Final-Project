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

INSERT INTO user VALUES
    (1, 'perezlauren', 'Christopher', 'Lozano', '97RO*c%H)ZX2'),
	(2, 'daniel60', 'Karen', 'Lopez', '!($FCOtkkE5l'),
	(3, 'gcarroll', 'Lisa', 'Murphy', 'fjjq*PGf(f3E'),
	(4, 'fsimmons', 'Trevor', 'Nichols', '$04E0c*d+2j('),
	(5, 'kevindaniel', 'Jose', 'Garcia', 'r%KrLoRPYz80'),
	(6, 'maryvazquez', 'Timothy', 'Bell', 'zj5Fqp40+M&j'),
	(7, 'brownmichael', 'Melvin', 'Ramirez', 'X78EAitB$Z(e'),
	(8, 'ohubbard', 'Patricia', 'Barron', 'uX7x*z65_u^U'),
	(9, 'davispeter', 'Justin', 'Hooper', 'W*#1OtQ@(v7Z'),
	(10, 'angelfoster', 'Peter', 'Acosta', 'Ukr2wgHl(Q0V');

INSERT INTO recipe VALUES
    (1, 'https://placekitten.com/480/252', '01:15:03', '00:57:29', '2021-04-01 08:26:51', 'Maori', 'Over all enter seven. Standard machine term away possible. Because color stage smile I describe. Remember reality require save daughter them establish.', 'Beautiful  Baked Muffin  Pie', 5),
	(2, 'https://placeimg.com/797/682/any', '01:04:17', '02:46:16', '2021-04-01 08:26:51', 'Kalaallisut', 'Generation surface look. Pm maybe consider run seat.', 'Burnt and Briny Cheesecake  Stew Peas', 2),
	(3, 'https://placekitten.com/603/519', '01:57:41', '00:31:23', '2021-04-01 08:26:51', 'Luxembourgish', 'Administration soldier quality reality natural rest rich. Why artist nation apply your support.', 'Acidic and Appealing Cream of Pumpkin Soup and Milkshake', 3),
	(4, 'https://placeimg.com/1007/898/any', '00:35:33', '00:26:49', '2021-04-01 08:26:51', 'Kikuyu', 'Body history just probably accept country. Imagine over care as ever boy contain. Institution forget appear concern coach decade.', 'Gourmet and Astringent Stew Peas and Pie', 5),
	(5, 'https://placekitten.com/877/1018', '03:45:55', '02:27:22', '2021-04-01 08:26:51', 'Armenian', 'Any last alone bit. Center truth stay already charge three task group.', 'Gourmet and Bland Brownies  Lasagne', 9),
	(6, 'https://placekitten.com/181/187', '02:58:01', '03:45:32', '2021-04-01 08:26:51', 'Igbo', 'Report member game politics other her event. World drop thus.', 'Bite-size and Brown Brownies  Porridge', 6),
	(7, 'https://dummyimage.com/31x435', '03:39:24', '01:39:57', '2021-04-01 08:26:51', 'Welsh', 'Join be party international.', 'Boiled  Candied Lasagne and Porridge', 4),
	(8, 'https://placeimg.com/126/980/any', '00:01:25', '00:37:23', '2021-04-01 08:26:51', 'Korean', 'Organization generation ago develop yeah him detail.', 'Aromatic  Blazed Cheesecake and Wonton Soup', 8),
	(9, 'https://www.lorempixel.com/796/731', '01:25:07', '00:19:03', '2021-04-01 08:26:51', 'Turkish', 'These never entire member along. Nature require figure word.', 'Blended  Bite-size Brownies  Pie', 9),
	(10, 'https://placeimg.com/119/160/any', '00:35:27', '03:49:08', '2021-04-01 08:26:51', 'Hausa', 'Kid add region summer. Example appear that my. Help education whole marriage.', 'Beautiful and Buttered Icecream and Bread', 2);

INSERT INTO ingredient VALUES
    (1, 100, 'meat cuts', 2078),
	(2, 133, 'file powder', 2140),
	(3, 20, 'smoked sausage', 1340),
	(4, 183, 'okra', 1610),
	(5, 72, 'shrimp', 904),
	(6, 68, 'andouille sausage', 1199),
	(7, 177, 'water', 2418),
	(8, 30, 'paprika', 477),
	(9, 111, 'hot sauce', 1721),
	(10, 141, 'garlic cloves', 2347),
	(11, 129, 'browning', 1204),
	(12, 101, 'lump crab meat', 2360),
	(13, 79, 'vegetable oil', 2325),
	(14, 189, 'all-purpose flour', 1953),
	(15, 195, 'freshly ground pepper', 2436),
	(16, 23, 'flat leaf parsley', 1869),
	(17, 183, 'boneless chicken skinless thigh', 1994),
	(18, 155, 'dried thyme', 1755),
	(19, 137, 'white rice', 1984),
	(20, 77, 'yellow onion', 1315),
	(21, 39, 'ham', 1170),
	(22, 56, 'baking powder', 1649),
	(23, 31, 'eggs', 1572),
	(24, 155, 'all-purpose flour', 1994),
	(25, 157, 'raisins', 1482),
	(26, 98, 'milk', 1559),
	(27, 150, 'white sugar', 387);

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
    (10, 1),
	(11, 2),
	(12, 3),
	(12, 4),
	(13, 5),
	(6, 6),
	(7, 7),
	(12, 8),
	(5, 9),
	(12, 10),
	(5, 11),
	(13, 12),
	(7, 13),
	(10, 14),
	(8, 15),
	(7, 16),
	(5, 17),
	(4, 18),
	(11, 19),
	(8, 20),
	(11, 21),
	(6, 22),
	(7, 23),
	(9, 24),
	(8, 25),
	(5, 26);

INSERT INTO user_allergy VALUES
    (3, 3),
	(5, 1),
	(14, 4),
	(1, 2);
