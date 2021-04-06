import React, { useEffect, useState } from "react";
import RecipeCard from "./RecipeCard/RecipeCard";
import "./RecipeCatalogue.css";

function RecipeCatalogue() {
	const [recipes, setRecipes] = useState([]);

	const [loadMore, setLoadMore] = useState(0);

	useEffect(() => {
		let isMounted = true;

		async function getRecipes(params) {
			fetch("http://localhost:9090/recipes", {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ loadMore: loadMore }),
			})
				.then((res) => res.json())
				.then((data) => {
					console.log(data);
					setRecipes((prev) => prev.concat(data));
				})
				.catch((e) => console.log(e));
		}
		if (isMounted) {
			getRecipes();
		}

		return () => {
			isMounted = false;
		};
	}, [loadMore]);

	const recipeList = recipes.map((recipe) => (
		<RecipeCard recipe={recipe} key={recipe.recipe_id} />
	));

	return (
		<div id="recipes">
			<h1 className="page-title">Recipes</h1>
			<div className="recipe-list">
				{recipeList}

				<button
					className="btn filled primary"
					onClick={() => setLoadMore((prev) => prev + 1)}
				>
					Load More
				</button>
			</div>
		</div>
	);
}

export default RecipeCatalogue;
