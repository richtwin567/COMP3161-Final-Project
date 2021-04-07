import React from "react";
import { Link } from "react-router-dom";
import "./SideBar.css";

export default function SideBar(props) {
	console.log(props);
	const links = [
		{ path: "recipes", label: "Recipes" },
		{ path: "profile", label: "My Profile" },
		{ path: "my-plan", label: "My Meal Plan" },
		{ path: "plan-generator", label: "Meal Plan Generator" },
		{ path: `shopping-list/${props.user?.id}`, label: "Shopping List" },
		{ path: "logout", label: "Logout" },
	];

	const items = links.map((item, i) => (
		<Link
			key={i}
			to={`/app/${item.path}`}
			className={
				window.location.pathname === `/app/${item.path}`
					? "selected"
					: undefined
			}
		>
			{item.label}
		</Link>
	));

	return (
		<div id="side-bar">
			<div className="section">
				<h1>
					Hi, {props.user?.first_name + " " + props.user?.last_name}
				</h1>
				<Link className="btn" to="/app/new-recipe">
					New Recipe
				</Link>
			</div>
			<div className="separator">General</div>
			<div className="links">{items.slice(0, -1)}</div>
			<div className="separator">Controls</div>
			<div className="controls"> {items[items.length - 1]}</div>
		</div>
	);
}
