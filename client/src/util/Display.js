import * as mathjs from "mathjs";

export function asFraction(num) {
	var whole = parseInt(num);
	var fraction = mathjs.fraction((num - whole).toFixed(2));
	var format = `${whole} ${
		fraction.n !== 0 && fraction.n !== 1 && fraction.d !== 1
			? mathjs.format(fraction, { fracton: "ratio" })
			: ""
	}`;
	return format;
}
