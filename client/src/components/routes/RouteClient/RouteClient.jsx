import React from "react";
import { Switch, Route, Redirect, BrowserRouter } from "react-router-dom";

import { MainLayout } from "components";
import {
  Auth,
  ShoppingList,
  Profile,
  RecipeCatalogue,
  MealPlan,
  MealPlanBuilder,
  Recipe,
  SearchRecipe,
  AddRecipe,
} from "views";

function RouteClient() {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/auth">
          <Auth />
        </Route>
        <Route exact path="/app/profile">
          <MainLayout component={Profile} />
        </Route>
        <Route exact path="/app/my-plan">
          <MainLayout component={MealPlan} />
        </Route>
        <Route exact path="/app/plan-generator">
          <MainLayout component={MealPlanBuilder} />
        </Route>
        <Route exact path="/app/recipes">
          <MainLayout component={RecipeCatalogue} />
        </Route>
        <Route exact path="/app/shopping-list/:id">
          <MainLayout component={ShoppingList} />
        </Route>
        <Route exact path="/app/logout">
          <Redirect to="/auth" />
        </Route>
        <Route exact path="/app/new-recipe">
          <MainLayout component={AddRecipe} />
        </Route>
        <Route path="/app/recipes/details/:id">
          <MainLayout component={Recipe} />
        </Route>
        <Route exact path="/app/recipes-search">
          <MainLayout component={SearchRecipe} />
        </Route>
        {/* //TODO not found*/}
      </Switch>
    </BrowserRouter>
  );
}

export default RouteClient;
