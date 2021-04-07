// React Imports
import React, { useState, useEffect, createContext } from "react";

// Module imports
import { checkLoggedIn } from "util/AuthHandler";

// Initializing Context for global state management
export const UserContext = createContext();

function UserProvider({ children }) {
  const [userData, setUserData] = useState({
    token: "",
    user: {},
  });

  useEffect(() => {
    sessionStorage.setItem("auth-token", JSON.stringify(userData.token));
    sessionStorage.setItem("user", JSON.stringify(userData.user));
  }, [userData]);

  return (
    <UserContext.Provider value={{ userData, setUserData }}>
      {children}
    </UserContext.Provider>
  );
}

export default UserProvider;
