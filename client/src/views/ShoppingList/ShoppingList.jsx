import React, { useEffect, useState } from "react";

import {
	ShoppingListCard,
	IngredientsList,
	IngredientsListGenerator,
} from "components";

import "./ShoppingList.css";
import { useParams } from "react-router";
import { asFraction } from "../../util/Display";

function ShoppingList() {
	const [shoppingList, setShoppingList] = useState([]);
	const { id } = useParams();

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			async function getShoppingList() {
				fetch(`http://localhost:9090/shopping-list/${id}`)
					.then((res) => res.json())
					.then((data) => setShoppingList(data));
			}

			getShoppingList();
		}
		return () => {
			isMounted = false;
		};
	}, [id]);

	var totalNeeded = 0;
	var totalInStock = 0;

	if (shoppingList.length) {
		shoppingList.forEach((el) => {
			totalNeeded += el.amount_needed;
			totalInStock += el.stock_quantity;
		});
	}

	return (
		<div id="shopping-list">
			<h1>Shopping List</h1>
			<div id="shopping-list-grid">
				<IngredientsList ingredients={shoppingList} />
				<section id="shopping-list-cards">
					<ShoppingListCard
						itemName="Total Ingredients Needed"
						itemQuantity={asFraction(totalNeeded)}
					/>
					<ShoppingListCard
						itemName="Total Ingredients in Kitchen"
						itemQuantity={asFraction(totalInStock)}
					/>
					<IngredientsListGenerator />
				</section>
			</div>
		</div>
	);
}

export default ShoppingList;
