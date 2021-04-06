import React from "react";
import { Link } from "react-router-dom";
import './RecipeCard.css';

export default function RecipeCard({recipe}) {
    console.log(recipe);
	return (
		<div className="recipe-card">
			<img
				src={recipe.image_url}
				alt={recipe.recipe_name}
				className="recipe-card-img"
			/>
			<div className="recipe-card-info">
				<h2 className="recipe-card-title">{recipe.recipe_name}</h2>
				<p className="recipe-card-calories">{recipe.calories}</p>
				<p className="recipe-card-culture">{recipe.culture}</p>
			</div>
			<Link to={`/recipes/details/${recipe.recipe_id}`} className="btn primary filled">View Recipe</Link>
		</div>
	);
}
