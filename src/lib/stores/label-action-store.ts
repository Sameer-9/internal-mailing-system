import { writable } from 'svelte/store';

export const labelAction = writable({
	isVisible: false,
	xDirection: 0,
	yDirection: 0,
	id: 0
});
