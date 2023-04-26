import { writable } from 'svelte/store';

export const SelectedUser = writable<User[]>();

export const isProfileDropdownOpen = writable<boolean>(false);
