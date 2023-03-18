import { writable } from 'svelte/store';

export const toastStore = writable({
	type: null,
	message: null
});

export function toast(_type = null, _message = null) {
	toastStore.update(({ type, message }) => {
		return {
			type: _type,
			message: _message
		};
	});

	setTimeout(removeToast, 3000);
}

function removeToast() {
	toastStore.update(({ type, message }) => {
		return {
			type: null,
			message: null
		};
	});
}
