import React from "react";

import TodoListIcon from "assets/images/to_do_list.png";
import "./IngredientsListGenerator.css";

function IngredientsListGenerator() {
  return (
    <div id="ingredients-list-generator">
      <h3>Supermarket List</h3>
      <img src={TodoListIcon} />
      <p>
        Generate a pdf of all the items that need to be purchased for the week
        at the supermarket.
      </p>
      <button className="btn generator-btn">Generate List</button>
    </div>
  );
}

export default IngredientsListGenerator;
