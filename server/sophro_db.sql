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
    (1, 'lambertmichael', 'Joseph', 'Lynch', '$+VHO!bh*25M'),
	(2, 'miranda37', 'Michael', 'Haynes', 'z)d8iTOpM(Wl'),
	(3, 'obanks', 'Ricardo', 'Colon', '+5*uyUjzpaYa'),
	(4, 'hernandeztammy', 'Jessica', 'Jones', '!%VJoxqnY%6K'),
	(5, 'josephbell', 'Nicholas', 'Taylor', '*$t57OrG4dVr'),
	(6, 'gmccarthy', 'Dustin', 'Harper', 'U4d_oZrs%j3b'),
	(7, 'morenogarrett', 'Randall', 'Howard', '+!41QAqsxoGK'),
	(8, 'drich', 'Sarah', 'Bates', 'Lgi(@KCp+8X+'),
	(9, 'kathleen21', 'Taylor', 'Collins', '8eN@5Zxf!5&H'),
	(10, 'emilybuchanan', 'Christopher', 'Perez', '9g5IHQ5bh_A8');

INSERT INTO ingredient VALUES
    (1, 36, 'meat cuts', 1864),
	(2, 29, 'file powder', 1986),
	(3, 118, 'smoked sausage', 2336),
	(4, 57, 'okra', 2360),
	(5, 156, 'shrimp', 675),
	(6, 95, 'andouille sausage', 771),
	(7, 51, 'water', 1595),
	(8, 164, 'paprika', 108),
	(9, 61, 'hot sauce', 208),
	(10, 129, 'garlic cloves', 1665),
	(11, 25, 'browning', 2219),
	(12, 16, 'lump crab meat', 1887),
	(13, 58, 'vegetable oil', 398),
	(14, 5, 'all-purpose flour', 2377),
	(15, 54, 'freshly ground pepper', 2011),
	(16, 126, 'flat leaf parsley', 1884),
	(17, 41, 'boneless chicken skinless thigh', 1952),
	(18, 43, 'dried thyme', 1288),
	(19, 105, 'white rice', 1062),
	(20, 106, 'yellow onion', 213),
	(21, 51, 'ham', 1029),
	(22, 97, 'baking powder', 798),
	(23, 45, 'eggs', 1243),
	(24, 59, 'all-purpose flour', 2209),
	(25, 120, 'raisins', 431),
	(26, 28, 'milk', 1133),
	(27, 49, 'white sugar', 2479);

INSERT INTO recipe VALUES
    (1, 'https://www.lorempixel.com/974/1021', '01:09:37', '00:18:46', '2021-04-01 07:19:31', 'Azerbaijani', 'South employee city yard until. President by view surface community production. Especially opportunity religious without story. Material kitchen compare rate from firm score.', 'Gourmet and Acidic Stew Peas and Chicken', 2),
	(2, 'https://placekitten.com/156/386', '00:26:23', '03:15:50', '2021-04-01 07:19:31', 'Nepali', 'Artist Republican whole will night reflect. Add region bad laugh control.', 'Brown and Brown Cheesecake and Chicken', 5),
	(3, 'https://dummyimage.com/655x747', '02:48:38', '02:39:30', '2021-04-01 07:19:31', 'Guarani', 'Up life different success miss event eight. Decide role firm lead.', 'Creamed  Buttered Brownies and Muffin', 8),
	(4, 'https://dummyimage.com/866x755', '02:16:41', '03:33:48', '2021-04-01 07:19:31', 'Czech', 'Name away pick you feel play national. Tell college meeting free court seek.', 'Blended and Briny Stew Peas and Stew Peas', 10),
	(5, 'https://www.lorempixel.com/180/163', '02:14:36', '00:46:08', '2021-04-01 07:19:31', 'Georgian', 'Cell tree present population. Themselves consumer business vote no report. Spring general or list what mother majority.', 'Balsamic  Briny Milkshake and Wonton Soup', 4),
	(6, 'https://www.lorempixel.com/302/305', '02:56:20', '01:44:41', '2021-04-01 07:19:31', 'Western Frisian', 'Chance high seem plant option. In theory kid open these. Arrive time although effort. Wait operation system citizen may key.', 'Astringent and Appetizing Cheesecake and Cream of Pumpkin Soup', 4),
	(7, 'https://placeimg.com/905/534/any', '00:33:51', '03:09:17', '2021-04-01 07:19:31', 'Javanese', 'Performance worker do because system tax loss mention. Show blood put notice note. Table study month alone fire lay see recognize. Show outside television some.', 'Aromatic  Bitter Milkshake  Wonton Soup', 4),
	(8, 'https://dummyimage.com/614x620', '00:55:20', '01:30:23', '2021-04-01 07:19:31', 'Portuguese', 'Order civil high life memory. General inside through finish Democrat indicate federal back. Car surface someone style easy.', 'Appetizing  Aromatic Lasagne  Cheesecake', 5),
	(9, 'https://dummyimage.com/882x332', '00:42:42', '02:41:20', '2021-04-01 07:19:31', 'Japanese', 'Soon upon plan account often. Back family power least beautiful outside risk.', 'Balsamic and Acidic Cream of Pumpkin Soup  Milkshake', 9),
	(10, 'https://placekitten.com/704/591', '01:36:47', '02:54:33', '2021-04-01 07:19:31', 'Chinese', 'I heavy attack picture camera man better. Detail onto subject.', 'Blended and Bite-size Stew Peas  Pie', 5);
