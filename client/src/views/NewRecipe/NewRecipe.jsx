import "./NewRecipe.css";
import React, { useReducer, useState, useEffect } from "react";

function reducer({ prev }) {}

function NewRecipe() {
	const [formState, updateFormState] = useReducer(reducer, {
		recipeName: "",
		recipeDescription: "",
		recipeCulture: "",
		recipePrepTime: "",
		recipeCookTime: "",
		recipeIngredients: [],
		recipeInstructions: [],
	});

	const [ingredients, setIngredients] = useState([]);

	const [measurements, setMeasurements] = useState([]);

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			async function getMeasurements() {
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
					.catch((e) => console.log(e));
			}

			async function getIngredients() {
				return fetch("http://localhost:9090/ingredients")
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
					.catch((e) => console.log(e));
			}

			getIngredients();
			getMeasurements();
		}
		return () => {
			isMounted = false;
		};
	}, []);

	return (
		<div id="new-recipe">
			<h1>Add Recipe</h1>
			<form>
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
					<label htmlFor="recipe-desc">Recipe Description</label>
					<input
						type="text"
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
				<input type="text" />
				<input type="text" />
			</form>
		</div>
	);
}

export default NewRecipe;
