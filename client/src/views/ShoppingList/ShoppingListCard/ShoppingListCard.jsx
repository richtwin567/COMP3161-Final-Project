import React from "react";

import "./ShoppingListCard.css";

function ShoppingListCard({ itemName, itemQuantity }) {
  return (
    <div className="shopping-list-card">
      <h4> {itemName}</h4>
      <h1> {itemQuantity}</h1>
    </div>
  );
}

export default ShoppingListCard;
