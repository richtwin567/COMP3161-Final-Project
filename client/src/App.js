import "./App.css";
import React from "react";

import UserProvider from "context/UserContext";
import { RouteClient } from "components/routes";
function App() {
  return (
    <UserProvider>
        <RouteClient />
    </UserProvider>
  );
}

export default App;
