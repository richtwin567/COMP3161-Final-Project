import React, { useState } from "react";
import SearchBar from "../SearchBar/SearchBar";
import SideBar from "../SideBar/SideBar";
import "./MainLayout.css";

export default function MainLayout(props) {
	const [selected, setSelected] = useState(0);
	const [searchMode, setSearchMode] = useState(false);

	return (
		<div id="main-layout">
			<SideBar
				user={props.user}
				selected={selected}
				setSelected={setSelected}
			/>
			<SearchBar searching={searchMode} setSearchMode={setSearchMode} />
		</div>
	);
}
