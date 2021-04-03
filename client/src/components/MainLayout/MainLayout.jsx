import React, { useState, useContext } from "react";
import SearchBar from "../SearchBar/SearchBar";
import SideBar from "../SideBar/SideBar";
import "./MainLayout.css";
import { UserContext } from "context/UserContext";

export default function MainLayout(props) {
	const [selected, setSelected] = useState(0);
	const [searchMode, setSearchMode] = useState(false);
	const { userData } = useContext(UserContext);

	return (
		<div id="main-layout">
			<SideBar
				user={userData}
				selected={selected}
				setSelected={setSelected}
			/>
			<SearchBar searching={searchMode} setSearchMode={setSearchMode} />
			<div className="content"></div>
		</div>
	);
}
