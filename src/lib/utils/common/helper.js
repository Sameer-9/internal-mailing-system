import { userActions } from './constants';

/**
 * @param {string} value
 */
// @ts-ignore
export function checkValueInJsonObject(value) {
	const jsonObject = userActions;
	for (var key in jsonObject) {
		// @ts-ignore
		if (jsonObject.hasOwnProperty(key) && jsonObject[key] === value) {
			return true;
			// @ts-ignore
		} else if (typeof jsonObject[key] === 'object') {
			// @ts-ignore
			if (checkValueInJsonObject(jsonObject[key], value)) {
				return true;
			}
		}
	}
	return false;
}
