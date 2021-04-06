import React, { useEffect, useState } from "react";
import { useParams } from "react-router";
import { Link } from "react-router-dom";
import "./Recipe.css";
import * as mathjs from "mathjs";
import * as moment from "moment";

function Recipe({ props }) {
	const { id } = useParams();
	const [recipeData, setRecipeData] = useState({});

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			fetch(`http://localhost:9090/recipes/details/${id}`)
				.then((res) => res.json())
				.then((data) => setRecipeData(data))
				.catch((e) => console.log(e));
		}
		return () => {
			isMounted = false;
		};
	}, [id]);

	var instructions = [];
	var ingredients = [];
	var totalCalories = 0;
	var totalTime = 0;

	if (Object.keys(recipeData).length) {
		totalTime = moment
			.duration(recipeData.cook_time)
			.add(moment.duration(recipeData.prep_time)).minutes();
		instructions = recipeData.instructions.map((instr) => (
			<div className="step">
				<p className="step-number">Step {instr.step_number}</p>
				<p className="instruction-details">
					{instr.instruction_details}
				</p>
			</div>
		));

		ingredients = recipeData.ingredient_measurements.map((ing) => {
			var whole = parseInt(ing.amount);
			var fraction = mathjs.fraction((ing.amount - whole).toFixed(2));
			return (
				<li className="ingredient">
					{whole} {mathjs.format(fraction, { fracton: "ratio" })}{" "}
					{ing.unit} {ing.ingredient_name}
				</li>
			);
		});

		recipeData.ingredient_measurements.forEach(
			(el) => (totalCalories += el.calorie_count)
		);
	}

	return (
		<div id="recipe-details">
			<Link className="btn primary outline" to="/app/recipes">
				Back
			</Link>
			{Object.keys(recipeData).length && (
				<div className="details">
					<div className="section-1">
						<h1 className="page-title">{recipeData.recipe_name}</h1>
						<h3>Description</h3>
						<p className="desc">{recipeData.description}</p>
						<div className="stats">
							<div className="stat-group">
								<p className="stat-val">
									{recipeData.ingredient_measurements.length}
								</p>
								<p className="stat-label">ingredients</p>
							</div>
							<div className="separator vertical"></div>
							<div className="stat-group">
								<p className="stat-val">{totalTime}</p>
								<p className="stat-label">minutes</p>
							</div>
							<div className="separator vertical"></div>
							<div className="stat-group">
								<p className="stat-val">{totalCalories}</p>
								<p className="stat-label">calories</p>
							</div>
						</div>
					</div>
					<img
						src={recipeData.image_url}
						alt={recipeData.recipe_name}
						className="recipe-img"
					/>
					<hr />
					<div className="instructions-section">
						<h3>Instructions</h3>
						<div className="instructions">{instructions}</div>
					</div>
					<div className="allergy-info"></div>
					<div className="tags"></div>
					<div className="ingredients-section">
						<h3>Ingredients</h3>
						<ul className="ingredients">{ingredients}</ul>
					</div>
				</div>
			)}
		</div>
	);
}

export default Recipe;
