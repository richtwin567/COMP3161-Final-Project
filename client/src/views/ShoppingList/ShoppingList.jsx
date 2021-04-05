import React from "react";

import {
  ShoppingListCard,
  IngredientsList,
  IngredientsListGenerator,
} from "components";

import "./ShoppingList.css";

// TODO - Use Context for this
const ingredientsList = [];
const ingredientsInStock = [];

function ShoppingList() {
  return (
    <div id="shopping-list">
      <h1>Shopping List</h1>
      <div id="shopping-list-grid">
        <section id="shopping-list-list">
          <IngredientsList />
        </section>
        <section id="shopping-list-cards">
          <ShoppingListCard
            itemName="Total Ingredients"
            itemQuantity={ingredientsList.length}
          />
          <ShoppingListCard
            itemName="Ingredients in Kitchen"
            itemQuantity={ingredientsInStock.length}
          />
          <IngredientsListGenerator />
        </section>
      </div>
    </div>
  );
}

export default ShoppingList;
