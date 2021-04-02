import React, { useState, useContext } from "react";
import { useHistory } from "react-router-dom";

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

  return <div>Auth Form</div>;
}

export default AuthForm;
