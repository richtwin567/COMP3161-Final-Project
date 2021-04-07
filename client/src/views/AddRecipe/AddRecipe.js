import "./AddRecipe.css";
import React, { useState, useEffect } from "react";
import Select from "react-select";
import AddIngredient from "./AddRecipeComponents/AddIngredients";

export default function AddRecipe() {
  // name, image, preptime cooktime creationdate culture description
  const [ingredients, setIngredients] = useState([]);
  const [measurements, setMeasurements] = useState([]);
  const [ingredientMap, setIngredientMap] = useState([1]);
  useEffect(() => {
    const getIngredients = async () => {
      let res = await fetch("http://localhost:9090/ingredients");
      let data = await res.json();
      setIngredients(data);
    };
    const getMeasurements = async () => {
      let res = await fetch("http://localhost:9090/measurements");
      let data = await res.json();
      setMeasurements(data);
    };
    getMeasurements();
    getIngredients();
  }, []);

  const addIngredientComp = () => {
    let count = ingredientMap[-1] + 1;
    setIngredientMap([...ingredientMap, count]);
  };

  return (
    <div>
      {ingredients &&
        ingredientMap.map((mapNo) => {
          return (
            <AddIngredient
              key={mapNo}
              ingredients={ingredients}
              measurements={measurements}
            />
          );
        })}

      <button onClick={addIngredientComp} className="btn">
        Add
      </button>
    </div>
  );
}
