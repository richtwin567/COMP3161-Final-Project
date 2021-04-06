import React, { useState, useContext } from "react";
import SearchBar from "../SearchBar/SearchBar";
import SideBar from "../SideBar/SideBar";
import "./MainLayout.css";
import { UserContext } from "context/UserContext";
import { SearchContext } from "../../context/SearchContext";

export default function MainLayout({ component: Component }) {
	const { userData } = useContext(UserContext);

	const [searchVal, setSearchVal] = useState("");

	return (
		<div id="main-layout">
			<SideBar user={userData} />
			<SearchContext.Provider value={{ searchVal, setSearchVal }}>
				<SearchBar />
			</SearchContext.Provider>
			<div className="content">
				<SearchContext.Provider value={{ searchVal, setSearchVal }}>
					<Component></Component>
				</SearchContext.Provider>
			</div>
		</div>
	);
}
