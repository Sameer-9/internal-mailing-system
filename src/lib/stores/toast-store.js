import { writable } from 'svelte/store';

export const toastStore = writable({
	type: '',
	message: ''
});
/**
 * @type {string | number | NodeJS.Timeout | undefined}
 */
let timeoutId;
export function toast(_type = '', _message = '') {
	toastStore.update(({ type, message }) => {
		return {
			type: _type,
			message: _message
		};
	});
	clearTimeout(timeoutId);
	timeoutId = setTimeout(removeToast, 3000);
}

function removeToast() {
	toastStore.update(({ type, message }) => {
		return {
			type: '',
			message: ''
		};
	});
}
