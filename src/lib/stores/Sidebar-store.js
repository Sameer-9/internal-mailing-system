import { writable } from 'svelte/store';

export const isSidebarOpened = writable(true);

export const sidebarArray = writable([]);
