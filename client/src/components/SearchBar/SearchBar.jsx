import { useContext } from "react";
import { useHistory, useLocation } from "react-router";
import { SearchContext } from "../../context/SearchContext";
import { Search } from "../Icons";
import "./SearchBar.css";

export default function SearchBar() {
	const { searchVal, setSearchVal } = useContext(SearchContext);
	const history = useHistory();
	console.log(history);
	const loc = useLocation();
	console.log(loc);
	return (
		<div id="searchbar">
			<form>
				<Search fill={'var(--grey1)'}/>
				<input
					type="search"
					name="recipe-name"
					id="recipe-search"
					value={searchVal}
					onChange={(e) => setSearchVal(e.target.value)}
					onFocus={() => {
						if (
							loc.pathname !== "/app/recipes-search"
						) {
							history.push("/app/recipes-search");
						}
					}}
				/>
			</form>
		</div>
	);
}
