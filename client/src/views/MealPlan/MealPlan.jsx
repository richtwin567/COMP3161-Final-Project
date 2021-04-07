import React, { useEffect, useState } from "react";
import "./MealPlan.css";

import HeroImage from "assets/images/hero_image.png";
import {
  PlanGenerator,
  MealCard,
  //PlannerStatistics,
} from "./MealPlanComponents";

export default function MealPlan() {
  const [ingredientsInfo, setIngredientsInfo] = useState({
    breakfast: 0,
    lunch: 0,
    dinner: 0,
  });
  const [mealPlans, setMealPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [test, setTest] = useState(false);

  const attachIngredients = () => {
    const getIngredientsForMeal = async (rid) => {
      let res = await fetch(`http://localhost:9090/ingredients-filter/${rid}`);
      let data = await res.json();
      return data;
    };
    let fdgyjbn = mealPlans;
    fdgyjbn.map(async (mealPlan) => {
      mealPlan["ingredients"] = await getIngredientsForMeal(mealPlan.recipe_id);
    });
    setMealPlans([...fdgyjbn]);
    setTest(true);
    console.log(mealPlans);
  };

  const getMealPlans = async () => {
    let res = await fetch("http://localhost:9090/meal-plan");
    let data = await res.json();
    console.log(data);
    setMealPlans(data);
    setLoading(false);
  };
  useEffect(() => {
    getMealPlans();
  }, []);
  useEffect(() => {
    if (!loading) {
      attachIngredients();
    }
  }, [loading]);

  return (
    <div id="meal-plan-view">
      <h1>My Meal Plan</h1>
      <main id="meal-plan-grid">
        <section id="meal-plan-meals">
          <div className="meal-time">
            <h1>Breakfast</h1>
            {console.log(mealPlans)}
            {test &&
              mealPlans.map((mealPlan) => {
                if (mealPlan.time_of_day === "Breakfast") {
                  return (
                    <MealCard
                      key={mealPlan.meal_id}
                      recipe_name={mealPlan.recipe_name}
                      serving_size={mealPlan.serving_size}
                      prep_time={mealPlan.prep_time}
                      image_url={mealPlan.image_url}
                      culture={mealPlan.culture}
                      ingredients={mealPlans.ingredients}
                    />
                  );
                }
              })}
          </div>
          <div className="meal-time">
            <h1>Lunch</h1>
            {mealPlans &&
              mealPlans.map((mealPlan) => {
                if (mealPlan.time_of_day === "Lunch") {
                  return (
                    <MealCard
                      key={mealPlan.meal_id}
                      recipe_name={mealPlan.recipe_name}
                      serving_size={mealPlan.serving_size}
                      prep_time={mealPlan.prep_time}
                      image_url={mealPlan.image_url}
                      culture={mealPlan.culture}
                      ingredients={mealPlan.ingredients}
                    />
                  );
                }
              })}
          </div>
          <div className="meal-time">
            <h1>Dinner</h1>
            {mealPlans &&
              mealPlans.map((mealPlan) => {
                if (mealPlan.time_of_day === "Dinner") {
                  return (
                    <MealCard
                      key={mealPlan.meal_id}
                      recipe_name={mealPlan.recipe_name}
                      serving_size={mealPlan.serving_size}
                      prep_time={mealPlan.prep_time}
                      image_url={mealPlan.image_url}
                      culture={mealPlan.culture}
                      ingredients={mealPlan.ingredients}
                    />
                  );
                }
              })}
          </div>
        </section>
        <section id="meal-plan-utils">
          <img src={HeroImage} alt="hero-img" />
          {/* <PlannerStatistics
            noCalories="10"
            totalCalories="20"
            mealsPrepared="3"
            totalMeals="5"
          /> */}
          <PlanGenerator />
        </section>
      </main>
    </div>
  );
}
