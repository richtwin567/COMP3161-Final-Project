// React Imports
import React, { useState, useEffect, createContext } from "react";

// Initialize Context for global state management
export const IngredientsContext = createContext();

function IngredientsProvider() {
  const [ingredients, setIngredients] = useState([]);
}

export default IngredientsProvider;
