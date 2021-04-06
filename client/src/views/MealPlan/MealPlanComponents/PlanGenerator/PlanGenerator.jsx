import React from "react";

import "./PlanGenerator.css";

function PlanGenerator({ onClick }) {
  return (
    <div id="plan-generator">
      <h4>Don’t like this meal plan?</h4>
      <button className="btn generator-btn"> Generate New Plan</button>
    </div>
  );
}

export default PlanGenerator;
