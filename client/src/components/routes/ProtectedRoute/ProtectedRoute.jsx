import React from "react";

import { Redirect, Route } from "react-router-dom";

import { MainLayout } from "components";

function ProtectedRoute({ protectedComponent: Component, ...rest }) {
  return (
    <Route
      {...rest}
      render={(props) => {
        let token = localStorage.getItem("auth-token");
        console.log(token);
        console.log(token);
        //if (token) {
          return (
            <div>
              <MainLayout component={Component} />
            </div>
          );
        //} else {
//return <Redirect to="/auth" />;
        //}
      }}
    ></Route>
  );
}

export default ProtectedRoute;
