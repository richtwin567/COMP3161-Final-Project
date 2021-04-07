import React from "react";
import { AuthForm } from "components";

import "./Auth.css";

function Auth() {
  let token = localStorage.getItem("auth-token");

  return (
    <div id="auth">
      {console.log(token)}
      {console.log("Check for token")}
      <AuthForm></AuthForm>
    </div>
  );
}

export default Auth;
