import { writable } from 'svelte/store';

export const userStore = writable<UserStore>();

interface UserStore {
	id: number;
	first_name: string;
	last_name: string;
	email: string;
	profile_photo: string;
	designation: string;
	bio: string;
	file_id: string;
}
