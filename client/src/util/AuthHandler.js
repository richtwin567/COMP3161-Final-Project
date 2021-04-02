import axios from "axios";
import { Redirect } from "react-router-dom";

const API_ENDPOINT = "";

/**
 * Registers a user along with their allergies
 * @param {*} e
 * @param {object} formState
 */
export async function registerUser(e, formState) {
  // Prevent the form from refreshing the page
  e.preventDefault();

  // Destructure form's state object
}

/**
 * Logs the user in to the system and stores the JWT in local storage
 * @param {*} e
 * @param {*} formState
 * @return {object} An object containing the JWT and user details
 */
export async function loginUser(e, formState) {
  // Prevent the form from refreshing the page
  e.preventDefault();

  // Destructure form's state object
  const { username, password } = formState;

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
    localStorage.setItem("auth-token", loginResponse.data.authToken);
    return {
      token: token,
      user: userData,
    };
  } catch (err) {
    console.log(err.response.data.msg);
    return {
      error: "Failed to authenticate user",
    };
  }
}

/**
 * Checks if the JWT is still valid
 * @return {object} If the token is valid
 * @return {JSXElement} The user is redirected if the token is invalid
 */
async function checkToken(token) {
  // Check if the token stored is valid
  let tokenResponse = {};
  try {
    tokenResponse = await axios.post(API_ENDPOINT + "/checkToken", null, {
      headers: { "x-access-token": token },
    });
    return tokenResponse;
  } catch (error) {
    // If the token is invalid the user is redirected to the auth page
    localStorage.setItem("auth-token", "");
    return <Redirect to="/auth"></Redirect>;
  }
}

/**
 * Checks if a user is logged in
 * @param {function} setUserData
 */
export async function checkLoggedIn(setUserData) {
  let token = localStorage.getItem("auth-token");

  // If no token is found, the token is set to an empty string
  if (token === null) {
    localStorage.setItem("auth-token", "");
    token = "";
  }

  const tokenResponse = await checkToken(token);

  // Retrieve user if the token is valid
  let userResponse = {};
  try {
    if (tokenResponse.data.isValidToken) {
      userResponse = await axios.get(API_ENDPOINT + "/user", {
        headers: { "x-access-token": token },
      });
    } else {
      localStorage.setItem("auth-token", "");
    }
  } catch (err) {
    localStorage.setItem("auth-token", "");
  }

  // Set the state of the user context to have the token and user
  setUserData({
    token: token,
    user: userResponse.data,
  });
}
