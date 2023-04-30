import type { Toast } from '$lib/utils/common/types';
import { writable } from 'svelte/store';

export const toastStore = writable<Toast>();

let timeoutId: NodeJS.Timeout | undefined | number | string;
export function toast(_type: string, _message: string) {
	toastStore.update((_) => {
		return {
			type: _type,
			message: _message
		};
	});
	clearTimeout(timeoutId);
	timeoutId = setTimeout(removeToast, 3000);
}

function removeToast() {
	toastStore.update((_) => {
		return {
			type: null,
			message: null
		};
	});
}
