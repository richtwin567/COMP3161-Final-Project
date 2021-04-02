import "./App.css";
import { BrowserRouter } from "react-router-dom";
import React from "react";

import UserProvider from "context/UserContext";
import { RouteClient } from "components/routes";
function App() {
  return (
    <UserProvider>
      <BrowserRouter>
        <RouteClient />
      </BrowserRouter>
    </UserProvider>
  );
}

export default App;
