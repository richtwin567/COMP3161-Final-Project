import React from "react";

import "./MealPlan.css";

import { PlanGenerator, Meal, PlannerStatistics } from "./MealPlanComponents";

function MealPlan() {
  return (
    <div id="meal-plan-view">
      <h1>My Meal Plan</h1>
      <main id="meal-plan-grid">
        <section id="meal-plan-meals">Meals</section>
        <section id="meal-plan-utils">
          <img src="" alt="hero-img" />
          <PlannerStatistics
            noCalories="10"
            totalCalories="20"
            mealsPrepared="3"
            totalMeals="5"
          />
          <PlanGenerator />
        </section>
      </main>
    </div>
  );
}

export default MealPlan;
