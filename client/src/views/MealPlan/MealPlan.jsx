import React from "react";

import "./MealPlan.css";

import HeroImage from "assets/images/hero_image.png";
import {
  PlanGenerator,
  MealCard,
  PlannerStatistics,
} from "./MealPlanComponents";

function MealPlan() {
  return (
    <div id="meal-plan-view">
      <h1>My Meal Plan</h1>
      <main id="meal-plan-grid">
        <section id="meal-plan-meals">
          <div className="meal-time">
            <h1>Breakfast</h1>
            <MealCard></MealCard>
            <MealCard></MealCard>
          </div>
          <div className="meal-time">
            <h1>Lunch</h1>
            <MealCard></MealCard>
            <MealCard></MealCard>
          </div>
          <div className="meal-time">
            <h1>Dinner</h1>
            <MealCard></MealCard>
            <MealCard></MealCard>
          </div>
        </section>
        <section id="meal-plan-utils">
          <img src={HeroImage} alt="hero-img" />
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
