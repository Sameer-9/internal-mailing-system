import { writable } from 'svelte/store';

export const isSidebarOpened = writable(true);

export const sidebarArray = writable([]);

export const isCreateModalOpen = writable(false);
