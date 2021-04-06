import React, { useContext, useEffect, useState } from "react";
import { SearchContext } from "../../context/SearchContext";
import RecipeCard from "../../components/RecipeCard/RecipeCard";
import "./SearchRecipe.css";
import { useHistory } from "react-router";

function SearchRecipe() {
	const [recipes, setRecipes] = useState([]);

	const [loadMore, setLoadMore] = useState(0);

	const history = useHistory();
	const { searchVal, setSearchVal } = useContext(SearchContext);

	async function getRecipes(shouldClear) {
		fetch(`http://localhost:9090/recipes-search?recipe_name=${searchVal}`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({ loadMore: loadMore }),
		})
			.then((res) => res.json())
			.then((data) =>
				shouldClear
					? setRecipes(data)
					: setRecipes((prev) => prev.concat(data))
			)
			.catch((e) => console.log(e));
	}

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			getRecipes(false);
		}

		return () => {
			isMounted = false;
		};
	}, [loadMore]);

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			setLoadMore(0);
			getRecipes(true);
		}

		return () => {
			isMounted = false;
		};
	}, [searchVal]);

	const recipeList = recipes.map((recipe, i) => (
		<RecipeCard recipe={recipe} key={i} />
	));

	return (
		<div id="recipes">
			<button
				className="btn outline primary"
				onClick={() => history.goBack()}
			>
				Back
			</button>
			<h1 className="page-title">
				Searching for {searchVal || "anything"}
			</h1>
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
				<h2 className="recipe-list">
					No results found for {searchVal}
				</h2>
			)}
		</div>
	);
}

export default SearchRecipe;
