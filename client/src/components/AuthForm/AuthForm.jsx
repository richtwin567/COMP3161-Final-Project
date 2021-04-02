import React, { useState, useContext } from "react";
import { useHistory } from "react-router-dom";

import "./AuthForm.css";

function AuthForm() {
  const history = useHistory();
  const [formState, setFormState] = useState({
    login: true,
    firstName: "",
    lastName: "",
    userName: "",
    password: "",
    allergies: [],
  });

  return (
    <div id="auth-form">
      <header id="auth-header">
        <h1> Sophro Planner</h1>
        <p>Bringing you the healthiest meal plans</p>
      </header>
      <form>
        <input id="username" type="text" placeholder="Username"></input>
        <input id="password" type="password" placeholder="Password"></input>

        <div id="auth-toggle">
          {formState.login ? "Don't have" : "Already have"} an account?{" "}
          <span
            id="form-toggle"
            onClick={(e) =>
              setFormState({
                ...formState,
                login: !formState.login,
              })
            }
          >
            Sign {!formState.login ? "in" : "up"}
          </span>
        </div>
        <button className="btn auth-btn">
          {formState.login ? "Login" : "Sign Up"}
        </button>
      </form>
    </div>
  );
}

export default AuthForm;
