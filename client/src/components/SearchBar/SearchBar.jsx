import "./SearchBar.css";

export default function SearchBar(props) {
  return (
    <div id="searchbar">
      <form>
        <input
          type="search"
          name="recipe-name"
          id="recipe-search"
          placeholder="Search Recipes"
        />
      </form>
    </div>
  );
}
