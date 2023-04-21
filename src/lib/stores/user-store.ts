import { writable } from 'svelte/store';

export const userStore = writable<UserStore>();

interface UserStore {
	id: Number;
	first_name: String;
	last_name: String;
	email: string;
	profile_photo: String;
	designation: String;
}
