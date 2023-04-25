import { writable } from 'svelte/store';

export const labelStore = writable<Label[]>([]);

interface Label {
	id: Number;
	name: String;
	color: String;
}
