import React, { useContext } from "react";
import { Switch, Route, Redirect, BrowserRouter } from "react-router-dom";
import { ProtectedRoute } from "components/routes";

import { logout } from "util/AuthHandler";

import { UserContext } from "context/UserContext";

import {
<<<<<<< HEAD
	Auth,
	ShoppingList,
	Profile,
	RecipeCatalogue,
	MealPlan,
	MealPlanBuilder,
	Recipe,
	SearchRecipe,
	NewRecipe,
} from "views";

function RouteClient() {
	return (
		<BrowserRouter>
			<Switch>
				{/* Authentication */}

				<Route exact path="/auth">
					<Auth />
				</Route>

				{/* Protected Routes */}

				<ProtectedRoute
					exact
					path="/app/profile"
					protectedComponent={Profile}
				/>
				<ProtectedRoute
					exact
					path="/app/my-plan"
					protectedComponent={MealPlan}
				/>
				<ProtectedRoute
					exact
					path="/app/plan-generator"
					protectedComponent={MealPlanBuilder}
				/>
				<ProtectedRoute
					exact
					path="/app/recipes"
					protectedComponent={RecipeCatalogue}
				/>
				<ProtectedRoute
					exact
					path="/app/shopping-list/:id"
					protectedComponent={ShoppingList}
				/>
				<ProtectedRoute
					path="/app/recipes/details/:id"
					protectedComponent={Recipe}
				/>
				<ProtectedRoute
					exact
					path="/app/recipes-search"
					protectedComponent={SearchRecipe}
				/>
				<ProtectedRoute
					exact
					path="/app/new-recipe"
					protectedComponent={NewRecipe}
				/>

				{/* Redirects */}
=======
  Auth,
  ShoppingList,
  Profile,
  RecipeCatalogue,
  MealPlan,
  MealPlanBuilder,
  Recipe,
  SearchRecipe,
  AddRecipe,
  NewRecipe,
} from "views";

function RouteClient() {
  return (
    <BrowserRouter>
      <Switch>
        {/* Authentication */}

        <Route exact path="/auth">
          <Auth />
        </Route>

        {/* Protected Routes */}

        <ProtectedRoute
          exact
          path="/app/profile"
          protectedComponent={Profile}
        />
        <ProtectedRoute
          exact
          path="/app/my-plan"
          protectedComponent={MealPlan}
        />
        <ProtectedRoute
          exact
          path="/app/plan-generator"
          protectedComponent={MealPlanBuilder}
        />
        <ProtectedRoute
          exact
          path="/app/recipes"
          protectedComponent={RecipeCatalogue}
        />
        <ProtectedRoute
          exact
          path="/app/shopping-list/:id"
          protectedComponent={ShoppingList}
        />
        <ProtectedRoute
          path="/app/recipes/details/:id"
          protectedComponent={Recipe}
        />
        <ProtectedRoute
          exact
          path="/app/recipes-search"
          protectedComponent={SearchRecipe}
        />
        <ProtectedRoute
          exact
          path="/app/new-recipe"
          protectedComponent={NewRecipe}
        />

        {/* Redirects */}
>>>>>>> merging-rojae

        <Route exact path="/app/logout">
          {localStorage.setItem("auth-token", "")}
          {localStorage.setItem("user", "")}
          <Redirect to="/auth" />
        </Route>
        <Route exact path="/app">
<<<<<<< HEAD
          <Redirect to="/app/recipes" />
        </Route>
        <Route exact path="/">
          <Redirect to="/app/recipes" />
        </Route>

				{/* //TODO not found*/}
			</Switch>
		</BrowserRouter>
	);
=======
          <Redirect to="/app/profile" />
        </Route>
        <Route exact path="/">
          <Redirect to="/app/profile" />
        </Route>

        {/* //TODO not found*/}
      </Switch>
    </BrowserRouter>
  );
>>>>>>> merging-rojae
}

export default RouteClient;
