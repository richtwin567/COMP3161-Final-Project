import React from "react";

import "./ProgressBar.css";

const fillerStyles = {
  height: "100%",
  width: `${(props) => props.completed}%`,
  backgroundColor: "#1E88E5",
  borderRadius: "inherit",
};

function ProgressBar(props) {
  return (
    <div className="progress-bar">
      <div className="progress-bar-bar">{console.log(props.completed)}</div>
    </div>
  );
}

export default ProgressBar;
