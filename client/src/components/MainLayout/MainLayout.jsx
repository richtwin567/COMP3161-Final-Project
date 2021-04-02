import React, { useState } from "react";
import SearchBar from "../SearchBar/SearchBar";
import SideBar from "../SideBar/SideBar";
import "./MainLayout.css"

export default function MainLayout(props) {
	const [selected, setSelected] = useState(0);

	return (
		<div id="main-layout">
			<SideBar
				user={props.user}
				selected={selected}
				setSelected={setSelected}
			/>
			<SearchBar/>
			
		</div>
	);
}
