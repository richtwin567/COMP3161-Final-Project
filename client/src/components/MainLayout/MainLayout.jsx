import React, { useState, useContext } from "react";
import SearchBar from "../SearchBar/SearchBar";
import SideBar from "../SideBar/SideBar";
import "./MainLayout.css";
import { UserContext } from "context/UserContext";

export default function MainLayout({ component: Component }) {
  const [searchMode, setSearchMode] = useState(false);
  const { userData } = useContext(UserContext);

  return (
    <div id="main-layout">
      <SideBar user={userData} />
      <SearchBar searching={searchMode} setSearchMode={setSearchMode} />
      <div className="content">
        <Component></Component>
      </div>
    </div>
  );
}
