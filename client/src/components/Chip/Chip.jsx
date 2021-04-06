import React from "react";
import "./Chip.css";

export default function Chip(props) {
	return <div className={"chip " +props.className ?? ''}>{props.children}</div>;
}
