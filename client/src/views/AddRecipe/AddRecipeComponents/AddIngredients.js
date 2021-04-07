import React, { useEffect, useState } from "react";
import Select from "react-select";
import "../AddRecipe.css";

export default function AddIngredient({ ingredients, measurements }) {
  let ingredient = [];
  ingredients.map((ing) => {
    ingredient.push({ value: ing.ingredient_name, label: ing.ingredient_name });
  });
  let measurement = [];
  measurements.map((meas) => {
    measurement.push({ value: meas.unit, label: meas.unit });
  });

  const [selectedOptionIng, setSelectedOptionIng] = useState();
  const [selectedOptionMeas, setSelectedOptionMeas] = useState();
  const [amount, setAmount] = useState(1);

  function handleChangeIng(option) {
    setSelectedOptionIng(option);
  }
  function handleChangeMeas(option) {
    setSelectedOptionMeas(option);
  }

  function customTheme(theme) {
    return {
      ...theme,
      colors: {
        ...theme.colors,
        primary25: "rgba(147, 119, 226, 0.5)",
      },
    };
  }
  const customStyles = {
    control: (base) => ({
      ...base,
      boxShadow: "0 2px 4px rgba(0, 0, 0, 0.25)",
    }),
    dropdownIndicator: (base) => ({
      ...base,
      color: "black",
    }),
  };

  return (
    <div>
      <div className="add">
        <Select
          styles={customStyles}
          value={selectedOptionIng}
          onChange={handleChangeIng}
          theme={customTheme}
          options={ingredient}
          components={{
            IndicatorSeparator: () => null,
          }}
          label="ingredients"
        />
        <input
          type="number"
          step="1"
          name="amount"
          value={amount}
          onChange={(e) => {
            setAmount(e.target.value);
          }}
        />
        <Select
          styles={customStyles}
          value={selectedOptionMeas}
          onChange={handleChangeMeas}
          theme={customTheme}
          options={measurement}
          components={{
            IndicatorSeparator: () => null,
          }}
          label="measurements"
        />
      </div>
    </div>
  );
}
