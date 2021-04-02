import React from "react";

import { Redirect, Route } from "react-router-dom";

function ProtectedRoute({ component: Component, ...rest }) {
  return (
    <Route
      {...rest}
      render={(props) => {
        let token = localStorage.getItem("auth-token");
        console.log(token);
        if (token) {
          return (
            <div>
              <Component {...props} />
            </div>
          );
        } else {
          return <Redirect to="/auth" />;
        }
      }}
    ></Route>
  );
}

export default ProtectedRoute;
