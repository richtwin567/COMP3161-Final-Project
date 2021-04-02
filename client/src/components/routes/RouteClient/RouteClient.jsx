import React from "react";
import { Switch, Route, Redirect } from "react-router-dom";

import { MainLayout } from "components";
import { Auth } from "views";

function RouteClient() {
  return (
    <Switch>
      <Route exact path="/auth">
        <Auth />
      </Route>
      <Route path="/app">
        <MainLayout />
      </Route>
      {/* //TODO not found*/}
    </Switch>
  );
}

export default RouteClient;
