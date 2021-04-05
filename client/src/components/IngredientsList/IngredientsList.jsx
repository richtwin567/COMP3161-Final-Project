import React, { useState, useEffect } from "react";

import "./IngredientsList.css";

function IngredientsList() {
  const [ingredients, setIngredients] = useState([]);
  const [loading, setLoading] = useState(false);
  return (
    <div>
      {loading ? (
        <div id="loader"> Loading...</div>
      ) : (
        <div id="ingredients-list">
          <h4>Ingredients Needed This Week</h4>
          <hr className="ingredients-list-separator" />
          <div id="ingredients-list-header">
            <ul>
              <li>Ingredient ID</li>
              <li>Ingredient Name</li>
              <li>In Stock</li>
            </ul>
          </div>
          {ingredients.map((ingredient) => (
            <div className="ingredient-list-row">
              <ul></ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default IngredientsList;
