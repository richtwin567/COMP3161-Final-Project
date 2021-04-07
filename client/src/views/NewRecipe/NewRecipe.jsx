import "./NewRecipe.css";
import React, {useReducer} from "react";

function reducer(params) {
    
}

function NewRecipe() {

    const [formState, updateFormState] = useReducer(reducer, {
        recipeName:'',
        recipeDescription:'',
        recipeCulture:'',
        recipeIngredients:[],
        recipeInstructions:[]
    })

	return (
		<div id="new-recipe">
			<h1>Add Recipe</h1>
			<form>
				<input type="text" id="recipe-name"/>
				<input type="text" id="recipe-desc"/>
				<input type="text" id="recipe-culture"/>
				<input type="text" />
				<input type="text" />
			</form>
		</div>
	);
}

export default NewRecipe;