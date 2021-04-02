import "./App.css";
import { BrowserRouter, Switch, Route } from "react-router-dom";
import Login from "./views/Login/Login";
import MainLayout from "./components/MainLayout/MainLayout";
import React, { useState } from "react";

function App() {
	const [user, setUser] = useState({});

	return (
		<div className="App">
			<BrowserRouter>
				<Switch>
					<Route exact path="/login">
						<Login />
					</Route>
					<Route path="/app">
						<MainLayout user={user} />
					</Route>
          {/* //TODO not found*/ }
				</Switch>
			</BrowserRouter>
		</div>
	);
}

export default App;
