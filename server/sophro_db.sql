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
    (1, 'patelsean', 'Erica', 'Rios', 'M49zKt^p^34O'),
	(2, 'valerie13', 'Gregory', 'Whitaker', '7&&!awk)03$T'),
	(3, 'lisa28', 'April', 'Kramer', 'v*89UXHunT^('),
	(4, 'tbarton', 'Jonathan', 'Garza', '49S^5LTq284q'),
	(5, 'james15', 'Alfred', 'Davis', 'nvVx3xYjs^h2'),
	(6, 'michael55', 'Patricia', 'Dunn', 'F)7PvVSr48^r'),
	(7, 'laura07', 'Elizabeth', 'Wong', '01XFmSrG)19J'),
	(8, 'jacobhampton', 'Michael', 'Liu', '80f^AbrF@3iZ'),
	(9, 'kristensmith', 'William', 'Moore', '1H5xay4uaXO&'),
	(10, 'brian32', 'Jimmy', 'Walker', '(Z!HCmLDr9V+');

INSERT INTO recipe VALUES
    (1, 'https://www.lorempixel.com/833/1015', '03:17:40', '02:14:09', '2021-04-01 08:39:36', 'Georgian', 'Fish more after. Minute civil leave camera attorney successful dog once. Population cup product represent move skill how.', 'Aromatic  Acidic Chicken  Lasagne', 3),
	(2, 'https://placekitten.com/26/312', '03:18:36', '03:17:15', '2021-04-01 08:39:36', 'Inuktitut', 'Break book order particularly. State executive they listen race drop. Visit particularly goal election avoid material.', 'Baked and Appetizing Bread and Dahl', 7),
	(3, 'https://www.lorempixel.com/160/5', '00:27:58', '02:44:51', '2021-04-01 08:39:36', 'Italian', 'Special whether group stuff who. Each support TV next. Pattern TV mission send image office.', 'Briny  Creamy Icecream and Bread', 6),
	(4, 'https://placeimg.com/207/16/any', '03:15:48', '03:50:34', '2021-04-01 08:39:36', 'Akan', 'State industry quality sometimes finish us program. What garden success old.', 'Aromatic and Balsamic Milkshake  Wonton Soup', 7),
	(5, 'https://placeimg.com/69/315/any', '03:34:43', '02:15:16', '2021-04-01 08:39:36', 'Bulgarian', 'Congress language mouth hit seat. Nature dark floor long design.', 'Astringent  Blazed Pie and Porridge', 2),
	(6, 'https://placekitten.com/21/934', '02:34:01', '01:14:53', '2021-04-01 08:39:36', 'Slovak', 'Positive time almost movie management. Financial behind play spend always across.', 'Boiled and Beautiful Rice and Peas  Milkshake', 7),
	(7, 'https://www.lorempixel.com/774/635', '00:02:47', '03:20:34', '2021-04-01 08:39:36', 'Slovenian', 'Despite realize growth chance radio receive. Bed police situation whether however gas country. When evening spring image speech area.', 'Blazed  Bitter Cream of Pumpkin Soup  Cheesecake', 10),
	(8, 'https://placeimg.com/496/512/any', '02:54:31', '02:33:18', '2021-04-01 08:39:36', 'Tatar', 'Collection begin for quite find nice hospital. Whole area nothing through.', 'Appealing  Boiled Cream of Pumpkin Soup and Muffin', 5),
	(9, 'https://placekitten.com/846/36', '00:23:34', '01:18:07', '2021-04-01 08:39:36', 'Ganda', 'Own marriage low assume. Situation around send include here final coach. Look or surface son maintain commercial.', 'Buttered  Calorie Stew Peas  Cream of Pumpkin Soup', 1),
	(10, 'https://dummyimage.com/655x871', '03:37:26', '01:05:35', '2021-04-01 08:39:36', 'Malay', 'Character since picture gas. Bank head conference other prevent. Develop possible manager even difficult contain as.', 'Gourmet  Caramelized Rice and Peas  Porridge', 1);

INSERT INTO ingredient VALUES
    (1, 156, 'meat cuts', 622),
	(2, 98, 'file powder', 1013),
	(3, 74, 'smoked sausage', 274),
	(4, 184, 'okra', 2206),
	(5, 109, 'shrimp', 2027),
	(6, 99, 'andouille sausage', 1585),
	(7, 10, 'water', 1870),
	(8, 13, 'paprika', 2232),
	(9, 195, 'hot sauce', 213),
	(10, 28, 'garlic cloves', 767),
	(11, 163, 'browning', 2428),
	(12, 192, 'lump crab meat', 1440),
	(13, 13, 'vegetable oil', 975),
	(14, 173, 'all-purpose flour', 1299),
	(15, 186, 'freshly ground pepper', 2222),
	(16, 105, 'flat leaf parsley', 1039),
	(17, 156, 'boneless chicken skinless thigh', 48),
	(18, 30, 'dried thyme', 231),
	(19, 164, 'white rice', 278),
	(20, 159, 'yellow onion', 1177),
	(21, 165, 'ham', 294),
	(22, 52, 'baking powder', 122),
	(23, 9, 'eggs', 399),
	(24, 95, 'all-purpose flour', 1390),
	(25, 64, 'raisins', 2445),
	(26, 22, 'milk', 1456),
	(27, 104, 'white sugar', 1426);

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
    (4, 1),
	(9, 2),
	(2, 3),
	(1, 4),
	(13, 5),
	(5, 6),
	(10, 7),
	(11, 8),
	(7, 9),
	(9, 10),
	(9, 11),
	(8, 12),
	(11, 13),
	(1, 14),
	(2, 15),
	(11, 16),
	(2, 17),
	(6, 18),
	(8, 19),
	(4, 20),
	(7, 21),
	(2, 22),
	(5, 23),
	(7, 24),
	(2, 25),
	(7, 26);
