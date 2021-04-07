import React from "react";
import { asFraction } from "util/Display";

import "./IngredientsList.css";

function IngredientsList(props) {
  const ingredients = props.ingredients.flatMap((ing) => [
    <p>{ing.ingredient_name}</p>,
    <p>{asFraction(ing.stock_quantity)}</p>,
    <p>{asFraction(ing.amount_needed)}</p>,
    <hr className="ingredients-list-separator" />,
  ]);

  return (
    <div id="ingredients-list">
      <h4>Ingredients Needed This Week</h4>
      <hr className="ingredients-list-separator" />
      <div id="ingredients-section">
        <h5 className="list-heading">Ingredient</h5>
        <h5 className="list-heading">Stock Quantity</h5>
        <h5 className="list-heading">Amount Needed</h5>

        {ingredients}
      </div>
    </div>
  );
}

export default IngredientsList;
