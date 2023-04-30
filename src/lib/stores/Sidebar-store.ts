import type { Sidebar } from '$lib/utils/common/types';
import { writable } from 'svelte/store';

export const isSidebarOpened = writable<boolean>(true);

export const sidebarArray = writable<Sidebar[]>([]);

export const isCreateModalOpen = writable<boolean>(false);
