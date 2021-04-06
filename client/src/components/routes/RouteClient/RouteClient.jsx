import React from "react";
import { Switch, Route, Redirect } from "react-router-dom";

import { MainLayout } from "components";
import {
	Auth,
	ShoppingList,
	Profile,
	RecipeCatalogue,
	MealPlan,
	PlanGenerator,
	Recipe,
} from "views";

function RouteClient() {
	return (
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
				<MainLayout component={PlanGenerator} />
			</Route>
			<Route exact path="/app/recipes">
				<MainLayout component={RecipeCatalogue} />
			</Route>
			<Route exact path="/app/shopping-list">
				<MainLayout component={ShoppingList} />
			</Route>
			<Route exact path="/app/logout">
				<Redirect to="/auth" />
			</Route>
			<Route path="/app/recipes/details/:id">
				<MainLayout component={Recipe} />
			</Route>
			{/* //TODO not found*/}
		</Switch>
	);
}

export default RouteClient;
