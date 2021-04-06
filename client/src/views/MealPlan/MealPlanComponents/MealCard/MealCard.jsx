import React, { useState } from "react";
import "./MealCard.css";

function MeanCard() {
  const [selected, setSelected] = useState(false);
  function showDetails() {
    setSelected(!selected);
  }

  return (
    <div id="menu-item-card">
      <div className="menu-item">
        <div>
          <img
            src="https://www.helpguide.org/wp-content/uploads/table-with-grains-vegetables-fruit-768.jpg"
            alt="test"
          />
        </div>
        <div>
          <div>
            <div className="general-info">
              <h4>Fancy Meal Plan</h4>
              <p>4.6kcal</p>
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
              <p className="content">Italian</p>
            </div>
            <div>
              <p className="info-heading">Prep Time</p>
              <p className="content">1 hour</p>
            </div>
            <div>
              <p className="info-heading">Serving Size</p>
              <p className="content">Small</p>
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
