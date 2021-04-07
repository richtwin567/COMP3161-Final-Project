import React, { useEffect, useState } from "react";
import "./PlanGenerator.css";

function PlanGenerator({ onClick, ran }) {
  const [selected, setSelected] = useState(false);

  const addNewPlan = async (mealPlan) => {
    await fetch(`http://localhost:9090/meal-plan/new/${ran}`, {
      method: "POST",
      body: JSON.stringify({
        mealPlan: mealPlan,
      }),
    })
      .then((res) => res.json())
      .then((data) => console.log(data));
  };

  const generatePlan = async (event) => {
    event.preventDefault();
    let res = await fetch("http://localhost:9090/get-recipes");
    let recipes = await res.json();
    console.log(recipes);

    let recipe_ids = [];
    for (let recipe of recipes) {
      recipe_ids.push(recipe.recipe_id);
    }

    let mealPlan = [];
    for (let i = 0; i < 21; i++) {
      let plan = {};
      if (i < 7) {
        plan = {
          time_of_day: "Breakfast",
          serving_size: Math.floor(Math.random() * 6) + 1,
          recipe_id: recipe_ids[Math.floor(Math.random() * recipe_ids.length)],
        };
      } else if (i < 14) {
        plan = {
          time_of_day: "Lunch",
          serving_size: Math.floor(Math.random() * 6) + 1,
          recipe_id: recipe_ids[Math.floor(Math.random() * recipe_ids.length)],
        };
      } else {
        plan = {
          time_of_day: "Dinner",
          serving_size: Math.floor(Math.random() * 6) + 1,
          recipe_id: recipe_ids[Math.floor(Math.random() * recipe_ids.length)],
        };
      }
      mealPlan.push(plan);
    }
    console.log(mealPlan);
    addNewPlan(mealPlan);
  };

  return (
    <div id="plan-generator">
      <h4>Don’t like this meal plan?</h4>
      <button onClick={() => setSelected(true)} className="btn generator-btn">
        New Meal Plan
      </button>
      <div className={`show-details ${selected ? "" : "not-selected"}`}>
        <form onSubmit={(e) => generatePlan(e)}>
          <button className="btn generator-btn" type="submit">
            Generate
          </button>
          <p
            onClick={() => {
              setSelected(false);
            }}
          >
            Cancel
          </p>
        </form>
      </div>
    </div>
  );
}

export default PlanGenerator;
