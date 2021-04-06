import React from "react";
import { ProgressBar } from "components";

import "./PlannerStatistics.css";

function PlannerStatistics({
  noCalories,
  totalCalories,
  mealsPrepared,
  totalMeals,
}) {
  return (
    <div id="planner-statistics">
      <h4>Planner Statistics </h4>
      <article className="statistic">
        <div className="statistic-text">
          <p> Calories </p>
          <p>
            {noCalories}cal / {totalCalories}cal
          </p>
        </div>
        <ProgressBar completed={noCalories} backgroundColor={"1E88E5"} />
      </article>
      <article className="statistic">
        <div className="statistic-text">
          <p>Meals Prepared</p>
          <p>
            {mealsPrepared} / {totalMeals}
          </p>
        </div>
        <ProgressBar completed={"2"} backgroundColor={"1E88E5"} />
      </article>
    </div>
  );
}

export default PlannerStatistics;
