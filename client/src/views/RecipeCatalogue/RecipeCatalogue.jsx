import React, { useEffect, useState } from "react";
import RecipeCard from "../../components/RecipeCard/RecipeCard";
import Spinner from "../../components/Spinner/Spinner";
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
				.then((data) => {
					console.log(data);
					if (data.length) {
						setRecipes((prev) => prev.concat(data));
					}
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

	console.log(recipes);

	var recipeList = [];
	if (recipes.length) {
		recipeList = recipes.map((recipe, i) => (
			<RecipeCard recipe={recipe} key={i} />
		));
	}

	return (
		<div id="recipes">
			<h1 className="page-title">Recipes</h1>
			{recipeList.length ? (
				<div className="recipe-list">
					{recipeList}

					<button
						className="btn filled primary"
						onClick={() => setLoadMore((prev) => prev + 1)}
					>
						Load More
					</button>
				</div>
			) : (
				<Spinner />
			)}
		</div>
	);
}

export default RecipeCatalogue;
