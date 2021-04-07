import React, { useState, useEffect, useContext } from "react";
import { useHistory } from "react-router-dom";
import { loginUser, registerUser } from "../../util/AuthHandler";
import { UserContext } from "context/UserContext";

import "./AuthForm.css";

function AuthForm() {
	const history = useHistory();
	const { setUserData } = useContext(UserContext);
	const [formState, setFormState] = useState({
		login: true,
		firstName: "",
		lastName: "",
		username: "",
		password: "",
		passwordConfirm: "",
		allergies: [],
	});

	const [allergyOptions, setAllergyOptions] = useState([]);

	useEffect(() => {
		let isMounted = true;

		if (isMounted) {
			async function getAllergies() {
				return fetch("http://localhost:9090/allergies")
					.then((res) => res.json())
					.then((data) =>
						setAllergyOptions(
							data.map((v) => (
								<option value={v.allergy_id}>
									{v.allergy_name}
								</option>
							))
						)
					)
					.catch((e) => console.log(e));
			}
			if (!formState.login) {
				getAllergies();
			}
		}
		return () => {
			isMounted = false;
		};
	}, [formState.login]);

	function validateForSignup() {
		if (formState.password !== formState.passwordConfirm) {
			alert("Passwords do not match");
			return false;
		}
		return true;
	}

	async function submit(e) {
		let userData = {};

		if (formState.login) {
			userData = await loginUser(formState, e);
		} else {
			if (validateForSignup()) {
				userData = await registerUser(formState, e);
			}
		}
		if ("error" in userData) {
			alert(userData.error);
		} else {
			setUserData(userData);
			history.push("/app");
		}
	}

	return (
		<div id="auth-form">
			<header id="auth-header">
				<h1> Sophro Planner</h1>
				<p>Bringing you the healthiest meal plans</p>
			</header>
			<form>
				{!formState.login && (
					<input
						type="text"
						id="firstname"
						name="firstname"
						placeholder="First name"
						value={formState.firstName}
						onChange={(e) =>
							setFormState((prev) => ({
								...prev,
								firstName: e.target.value,
							}))
						}
					/>
				)}
				{!formState.login && (
					<input
						type="text"
						id="lastname"
						name="lastname"
						placeholder="Last name"
						value={formState.lastName}
						onChange={(e) =>
							setFormState((prev) => ({
								...prev,
								lastName: e.target.value,
							}))
						}
					/>
				)}
				<input
					id="username"
					type="text"
					value={formState.username}
					placeholder="Username"
					onChange={(e) =>
						setFormState((prev) => ({
							...prev,
							username: e.target.value,
						}))
					}
				></input>
				<input
					value={formState.password}
					id="password"
					type="password"
					placeholder="Password"
					onChange={(e) =>
						setFormState((prev) => ({
							...prev,
							password: e.target.value,
						}))
					}
				></input>
				{!formState.login && (
					<input
						type="password"
						name="password-confirm"
						id="password-confim"
						placeholder="Confirm Password"
						onChange={(e) =>
							setFormState((prev) => ({
								...prev,
								passwordConfirm: e.target.value,
							}))
						}
					/>
				)}
				{!formState.login && (
					<select
						name="allergies"
						multiple
						value={formState.allergies}
						onChange={(e) =>
							setFormState((prev) => ({
								...prev,
								allergies:
									prev.allergies.indexOf(e.target.value) ===
									-1
										? prev.allergies.concat(e.target.value)
										: prev.allergies.filter(
												(v) => v !== e.target.value
										  ),
							}))
						}
						id="allergies-selection"
					>
						{allergyOptions}
					</select>
				)}
				<div id="auth-toggle">
					{formState.login ? "Don't have" : "Already have"} an
					account?{" "}
					<span
						id="form-toggle"
						onClick={(e) =>
							setFormState({
								...formState,
								login: !formState.login,
							})
						}
					>
						Sign {!formState.login ? "in" : "up"}
					</span>
				</div>
				<button className="btn auth-btn" onClick={(e) => submit(e)}>
					{formState.login ? "Login" : "Sign Up"}
				</button>
			</form>
		</div>
	);
}

export default AuthForm;
