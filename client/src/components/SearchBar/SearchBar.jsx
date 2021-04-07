import { useContext } from "react";
import { useHistory } from "react-router";
import { Link } from "react-router-dom";
import { SearchContext } from "../../context/SearchContext";
import { Search } from "../Icons";
import "./SearchBar.css";

export default function SearchBar() {
	const { searchVal, setSearchVal } = useContext(SearchContext);
	const history = useHistory();

	const searching = history.location.pathname === "/app/recipes-search";
	return (
		<div id="searchbar">
			<form>
				<Link to="/app/recipes-search">
					<Search fill={"var(--grey1)"} />
				</Link>
				{searching ? (
					<input
						autoFocus
						type="search"
						name="recipe-name"
						id="recipe-search"
						value={searchVal}
						onChange={(e) => setSearchVal(e.target.value)}
					/>
				) : (
					<Link to="/app/recipes-search">
						<p>Click to Search</p>
					</Link>
				)}
			</form>
		</div>
	);
}
