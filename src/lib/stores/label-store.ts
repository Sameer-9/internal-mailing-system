import type { Label } from '$lib/utils/common/types';
import { writable } from 'svelte/store';

export const labelStore = writable<Label[]>([]);
