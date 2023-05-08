import { userActions } from './constants';

export function checkValueInJsonObject(value: string) {
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

export function getRange(num: number) {
	const start = Math.floor(num / 50) * 50 + 1;
	const end = Math.max(start + 49, num);
	return { start, end };
}
