import axios from "axios";
import { Redirect } from "react-router-dom";

const API_ENDPOINT = "http://localhost:9090";

/**
 * Registers a user along with their allergies
 * @param {*} e
 * @param {object} formState
 */
export async function registerUser(formState, e = undefined) {
  // Prevent the form from refreshing the page
  e?.preventDefault();

  const res = await axios.post(API_ENDPOINT + "/signup", formState);

  if (res.status === 200 || res.status === 202) {
    return loginUser(formState);
  }

  return {};

  // Destructure form's state object
}

/**
 * Logs the user in to the system and stores the JWT in local storage
 * @param {*} e
 * @param {*} formState
 * @return {object} An object containing the JWT and user details
 */
export async function loginUser(formState, e = undefined) {
  // Prevent the form from refreshing the page
  e?.preventDefault();

  // Destructure form's state object
  const { username, password } = formState;
  console.log(formState);
  // Post request to log the user in
  try {
    const loginResponse = await axios.post(API_ENDPOINT + "/login", {
      username: username,
      password: password,
    });

    // Retrieve token and user data from response
    const token = loginResponse.data.token;
    const userData = loginResponse.data.user;

    // Store the JWT token
    sessionStorage.setItem("auth-token", token);

    const userObj = {
      token: token,
      user: userData,
    };

    return userObj;
  } catch (err) {
    return {
      error: "Failed to authenticate user",
    };
  }
}

/**
 * Checks if a user is logged in
 * @param {function} setUserData
 */
export async function checkLoggedIn(setUserData) {
  let token = sessionStorage.getItem("auth-token");

  // If no token is found, the token is set to an empty string
  if (token === null) {
    sessionStorage.setItem("auth-token", "");
    token = "";
  }

  // Set the state of the user context to have the token and user
  setUserData({
    token: token,
  });
}

export function logout(setUserData) {
  sessionStorage.setItem("auth-token", "");
  setUserData({
    token: "",
    user: {},
  });

  return <Redirect to="/auth" />;
}
