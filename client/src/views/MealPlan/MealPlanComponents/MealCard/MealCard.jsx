import React, { useState, useEffect } from "react";
import "./MealCard.css";

function MeanCard({
  recipe_name,
  serving_size,
  prep_time,
  image_url,
  culture,
  ingredients,
}) {
  const [selected, setSelected] = useState(false);
  const [calories, setCalories] = useState(0);
  function showDetails() {
    setSelected(!selected);
  }

  useEffect(() => {
    // let calorieCount = 0;
    // for (let i of ingredients) {
    //   calorieCount += i.amount * i.calorie_count;
    // }
    // setCalories(calorieCount);
    console.log(ingredients);
  }, []);

  return (
    <div id="menu-item-card">
      <div className="menu-item">
        <div>
          <img src={image_url} alt="test" />
        </div>
        <div>
          <div>
            <div className="general-info">
              <h4>{recipe_name}</h4>
              <p>{calories}kcal</p>
            </div>
            <div className="details">
              <p
                className={`show-details ${!selected ? "" : "selected-text"}`}
                onClick={showDetails}
              >
                Details
              </p>
              <label>
                {" "}
                <input type="checkbox" name="" id="" /> Prepared
              </label>
            </div>
          </div>
          <div className={`detailed-info ${!selected ? "not-selected" : ""}`}>
            <div>
              <p className="info-heading">Servings</p>
              <p className="content">3</p>
            </div>
            <div>
              <p className="info-heading">Culture</p>
              <p className="content">{culture}</p>
            </div>
            <div>
              <p className="info-heading">Prep Time</p>
              <p className="content">{prep_time}</p>
            </div>
            <div>
              <p className="info-heading">Serving Size</p>
              <p className="content">{serving_size}</p>
            </div>
          </div>
        </div>
        <div>
          <p>Price: $</p>
        </div>
      </div>
    </div>
  );
}

export default MeanCard;
