import React, { useContext } from "react";
import { Redirect, Route } from "react-router-dom";
import { MainLayout } from "components";

function ProtectedRoute({ protectedComponent: Component, ...rest }) {
  return (
    <Route
      {...rest}
      render={(props) => {
        const token = JSON.parse(sessionStorage.getItem("auth-token"));
        const user = JSON.parse(sessionStorage.getItem("user"));
        if (token) {
          return (
            <div>
              <MainLayout component={Component} />
            </div>
          );
        } else {
return <Redirect to="/auth" />;
        }
      }}
      />
  )
}

export default ProtectedRoute;
