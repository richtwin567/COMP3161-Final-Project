import "./NewRecipe.css";
import React, { useReducer, useState, useEffect } from "react";
import Spinner from "../../components/Spinner/Spinner";
import { useHistory} from "react-router";

function reducer(prev, { type, value }) {
	switch (type) {
		case "name":
			return { ...prev, recipeName: value };
		case "image":
			return { ...prev, recipeImg: value };
		case "desc":
			return { ...prev, recipeDescription: value };
		case "prep-time":
			return { ...prev, recipePrepTime: value };
		case "cook-time":
			return { ...prev, recipeCookTime: value };
		case "culture":
			return { ...prev, recipeCulture: value };
		case "ingredient-add":
			if (
				prev.recipeIngredients.filter(
					(v) => v.ingredient_id === value.ingredient_id
				).length === 0
			) {
				var newlist = [...prev.recipeIngredients];
				newlist.push(value);
				console.log("activate");
				return { ...prev, recipeIngredients: newlist };
			}
			return prev;
		case "ingredient-remove":
			return {
				...prev,
				recipeIngredients: prev.recipeIngredients.filter(
					(v, i) => i !== value
				),
			};
		case "instruction-add":
			if (value) {
				return {
					...prev,
					recipeInstructions: prev.recipeInstructions.concat(value),
				};
			}
			return prev;
		case "instruction-remove":
			return {
				...prev,
				recipeInstructions: prev.recipeInstructions.filter(
					(v, i) => i !== value
				),
			};
		default:
			break;
	}

	return {};
}

function NewRecipe() {
	const [formState, updateFormState] = useReducer(reducer, {
		recipeName: "",
		recipeImg: "",
		recipeDescription: "",
		recipeCulture: "",
		recipePrepTime: "",
		recipeCookTime: "",
		recipeIngredients: [],
		recipeInstructions: [],
	});

	const history = useHistory();
	const [ingredients, setIngredients] = useState([]);
	const [measurements, setMeasurements] = useState([]);
	const [selectedIngredient, setSelectedIngredient] = useState(1);
	const [selectedMeasurement, setSelectedMeasurement] = useState(1);
	const [currentInstruction, setCurrentInstruction] = useState("");
	const [currentAmount, setCurrentAmount] = useState(0);

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			async function getData() {
				return fetch("http://localhost:9090/measurements")
					.then((res) => {
						console.log(res);
						if (res.status === 200) {
							return res.json();
						} else {
							res.json()
								.then((err) => {
									throw Error(err.message);
								})
								.catch((e) => console.error(e));
						}
					})
					.then((data) => setMeasurements(data))
					.then((_) =>
						fetch("http://localhost:9090/ingredients")
							.then((res) => {
								console.log(res);
								if (res.status === 200) {
									return res.json();
								} else {
									res.json()
										.then((err) => {
											throw Error(err.message);
										})
										.catch((e) => console.error(e));
								}
							})
							.then((data) => setIngredients(data))
							.catch((e) => console.log(e))
					);
			}

			getData();
		}
		return () => {
			isMounted = false;
		};
	}, []);

	var ingIds = [];
	var ingNames = {};
	var ingOptions = [];
	var measurementIds = [];
	var measurementNames = {};
	var measurementOptions = [];

	if (ingredients.length) {
		ingredients.forEach((ing) => {
			ingIds.push(ing.ingredient_id);
			ingNames[ing.ingredient_id] = ing.ingredient_name;
			ingOptions.push(
				<option value={ing.ingredient_id}>{ing.ingredient_name}</option>
			);
		});
	}

	if (measurements.length) {
		measurements.forEach((measurement) => {
			measurementIds.push(measurement.measurement_id);
			measurementNames[measurement.measurement_id] = measurement.unit;
			measurementOptions.push(
				<option value={measurement.measurement_id}>
					{measurement.unit}
				</option>
			);
		});
	}
	return (
		<div id="new-recipe">
			<h1>Add Recipe</h1>
			{ingredients.length && measurements.length ? (
				<div className="recipe-form">
					<div className="input-group">
						<label htmlFor="recipe-name">Recipe Name</label>
						<input
							type="text"
							id="recipe-name"
							value={formState.recipeName}
							onChange={(e) =>
								updateFormState({
									type: "name",
									value: e.target.value,
								})
							}
						/>
					</div>
					<div className="input-group">
						<label htmlFor="recipe-image">Recipe Image</label>
						<input
							type="text"
							id="recipe-image"
							value={formState.recipeImg}
							onChange={(e) =>
								updateFormState({
									type: "image",
									value: e.target.value,
								})
							}
						/>
					</div>
					<div className="input-group">
						<label htmlFor="recipe-desc">Recipe Description</label>
						<textarea
							maxLength={255}
							id="recipe-desc"
							value={formState.recipeDescription}
							onChange={(e) =>
								updateFormState({
									type: "desc",
									value: e.target.value,
								})
							}
						/>
					</div>
					<div className="input-group">
						<label htmlFor="recipe-culture">Recipe Culture</label>
						<input
							type="text"
							id="recipe-culture"
							value={formState.recipeCulture}
							onChange={(e) =>
								updateFormState({
									type: "culture",
									value: e.target.value,
								})
							}
						/>
					</div>
					<div className="input-group">
						<label htmlFor="prep-time">Prep Time</label>
						<input
							type="time"
							name="prep-time"
							id="prep-time"
							value={formState.recipePrepTime}
							onChange={(e) =>
								updateFormState({
									type: "prep-time",
									value: e.target.value,
								})
							}
						/>
					</div>
					<div className="input-group">
						<label htmlFor="cook-time">Cook Time</label>
						<input
							type="time"
							name="cook-time"
							id="cook-time"
							value={formState.recipeCookTime}
							onChange={(e) =>
								updateFormState({
									type: "cook-time",
									value: e.target.value,
								})
							}
						/>
					</div>
					<ul className="ingredients-list">
						{formState.recipeIngredients.map((ing, i) => (
							<li>
								<span>
								{ing.amount}{" "}
								{measurementNames[ing.measurement_id]}{" "}
								{ingNames[ing.ingredient_id]}</span>
								<button
									className="btn filled accent"
									onClick={() =>
										updateFormState({
											type: "ingredient-remove",
											value: i,
										})
									}
								>
									remove
								</button>
							</li>
						))}
					</ul>
					<div className="ing-input">
						<label htmlFor="amount">Amount</label>
						<label htmlFor="unit">Unit</label>
						<label htmlFor="ingredient">Ingredient</label>
						<input
							type="number"
							name="amount"
							id="amount"
							value={currentAmount}
							onChange={(e) => setCurrentAmount(e.target.value)}
						/>
						<select
							name="unit"
							id="unit"
							value={selectedMeasurement}
							onChange={(e) =>
								setSelectedMeasurement(e.target.value)
							}
						>
							{measurementOptions}
						</select>
						<select
							name="ingredient"
							id="ingredient"
							value={selectedIngredient}
							onChange={(e) =>
								setSelectedIngredient(e.target.value)
							}
						>
							{ingOptions}
						</select>
					</div>
					<button
						className="btn primary filled"
						onClick={() =>
							updateFormState({
								type: "ingredient-add",
								value: {
									amount: currentAmount,
									ingredient_id: selectedIngredient,
									measurement_id: selectedMeasurement,
								},
							})
						}
					>
						Add Ingredient
					</button>

					<ol className="instructions-list">
						{formState.recipeInstructions.map((instr, i) => (
							<li>
								<span>
								{instr}</span>
								<button
									className="btn filled accent"
									onClick={() =>
										updateFormState({
											type: "instruction-remove",
											value: i,
										})
									}
								>
									remove
								</button>
							</li>
						))}
					</ol>
					<div className="input-group">
					<label htmlFor="instruction">Add Next Instruction</label>
					<input
						type="text"
						name="instruction"
						id="instruction"
						value={currentInstruction}
						onChange={(e) => setCurrentInstruction(e.target.value)}
					/>
					</div>
					<button
						className="btn primary filled"
						onClick={() =>
							updateFormState({
								type: "instruction-add",
								value: currentInstruction,
							})
						}
					>
						Add Instruction
					</button>
					<button
						className="btn primary filled"
						onClick={() =>
							fetch("http://localhost:9090/new-recipe", {
								method: "POST",
								body: JSON.stringify(formState),
								headers: {
									"Content-Type": "application/json",
								},
							})
								.then((res) => {
									if (res.status === 200) {
										return res.json();
									} else {
										res.json().then((err) => {
											alert("Failed to create recipe");
											history.push("/app/recipes");
										});
									}
								})
								.then((data) => data && history.push(data.path))
						}
					>
						Submit
					</button>
				</div>
			) : (
				<Spinner />
			)}
		</div>
	);
}

export default NewRecipe;
