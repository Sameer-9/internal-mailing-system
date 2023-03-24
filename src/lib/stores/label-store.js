import { writable } from 'svelte/store';

export const labelStore = writable([
	{
		id: 1,
		name: 'default Label',
		color: '#FF0000'
	}
]);
