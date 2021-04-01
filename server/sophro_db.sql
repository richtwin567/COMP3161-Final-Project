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
    (1, 'matthew91', 'Jessica', 'Owens', '+&SW#yZU994s'),
	(2, 'elizabethjohnson', 'Amy', 'Blankenship', 'l89_MqmbjV)Z'),
	(3, 'markaguirre', 'Louis', 'Bauer', 'p$1)yfer3Y8F'),
	(4, 'mcooley', 'Sarah', 'Jones', 'w%s)2fFb06WL'),
	(5, 'petersenmichael', 'Brian', 'Olsen', '4)Q6OtFS6sd9'),
	(6, 'pattersonpatrick', 'Whitney', 'Sanders', '(mukhcr0)S8O'),
	(7, 'donnawalker', 'Pamela', 'Williams', '82agrxDc@6GP'),
	(8, 'olivermatthew', 'Matthew', 'Foster', ')fiXQtUY^V51'),
	(9, 'michaellee', 'Jeffrey', 'Simpson', '@F8xeqRe@^jV'),
	(10, 'paulhale', 'Shannon', 'Berg', '(6&Z_7ww#7qB'),
	(11, 'tina08', 'Robin', 'Hansen', '*b5)WyV+rW%G'),
	(12, 'jeremyguerrero', 'Kylie', 'Espinoza', 'fCM&G)2aLFk6'),
	(13, 'oscar87', 'Marc', 'Rivers', '793DxHuTuB#3'),
	(14, 'kristin02', 'Penny', 'Walker', 'rt4ykhp*JPL&'),
	(15, 'carlaarias', 'Timothy', 'Schmidt', 'B7Hfv9GiWPF*'),
	(16, 'fischersherry', 'Stephen', 'Jackson', 'GUM!DmNdX)64'),
	(17, 'erin23', 'Emily', 'Holmes', '@LY@KVvmA2wp'),
	(18, 'prestonmaldonado', 'Richard', 'Parsons', 'Y+TPqd)Oa!3u'),
	(19, 'samanthapayne', 'Melissa', 'Davenport', 'sl(shKYvxX8N'),
	(20, 'alexanderchristopher', 'Ronald', 'Patel', 'V^2PdDzs@u4('),
	(21, 'amy54', 'Guy', 'Coleman', '+*uefIIq2&Ys'),
	(22, 'dixonjulia', 'Julie', 'Newton', 'MT&9Or29Ed&D'),
	(23, 'martinnorris', 'Dillon', 'Davis', 'V)v4X8mD%a^+'),
	(24, 'apierce', 'Megan', 'Johnson', '3r@!q0%q*CcU'),
	(25, 'aparker', 'Kenneth', 'Lopez', '+7L1xZiR_jCW'),
	(26, 'teresa86', 'Tina', 'Jensen', 'b@4JjXke6gOD'),
	(27, 'angel55', 'Eric', 'Golden', 'm4GyQbG1nr#Q'),
	(28, 'franklinrandall', 'Andrew', 'Fuentes', '%%zEuNyr!4XM'),
	(29, 'vryan', 'Shane', 'Wallace', '54K9beol+GLD'),
	(30, 'david38', 'Veronica', 'Parker', 'lc%c3Iey8u^i'),
	(31, 'kennethhull', 'Cindy', 'Miller', 'DX!3HwSe_hZJ'),
	(32, 'ellisaaron', 'Perry', 'Holt', 'Q9x2BvTe@!^b'),
	(33, 'ogray', 'Jon', 'Greene', '7j8UWKc5P@Qs'),
	(34, 'wilsonkaren', 'Linda', 'Ross', 'hp&2uPPk9*AR'),
	(35, 'williamsbrandon', 'James', 'Mckee', '7#g0D6YmIETc'),
	(36, 'rfitzpatrick', 'Douglas', 'Beard', '%nd5h6hC5PZv'),
	(37, 'chanrhonda', 'Stephanie', 'Cruz', 'lIeE8usw3%3F'),
	(38, 'wwhite', 'Joseph', 'Munoz', '%f)7m3Ze#1B5'),
	(39, 'michael42', 'Jenny', 'Clark', '^^fYjfyxa3sq'),
	(40, 'michaelaustin', 'Kimberly', 'Rasmussen', 's%8rNi*oZ(BH'),
	(41, 'robertssteven', 'Patricia', 'Goodman', '!aa50vUi_qjD'),
	(42, 'ebright', 'Scott', 'Hampton', ')xPCH0&A0ah^'),
	(43, 'nicole92', 'Randall', 'Jordan', 'E*9x3rn!I*Mr'),
	(44, 'loganangel', 'Courtney', 'Dawson', '88+oBdZ@!GOU'),
	(45, 'mwhite', 'Mary', 'Graves', 'dngX00OyU!5!'),
	(46, 'warddouglas', 'Christopher', 'Moore', '!vpX6q5xQ6BE'),
	(47, 'pgilmore', 'Curtis', 'Newman', 'Kj%OPu9g%3y3'),
	(48, 'josemosley', 'Ricardo', 'Martin', ')4))(OW+UtvI'),
	(49, 'millernichole', 'Anthony', 'Case', '+12#wcKee&8H'),
	(50, 'amandaanderson', 'Joshua', 'Brown', 'M@U02Gno+NHB');
