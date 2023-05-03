import type { Conversation } from '$lib/utils/common/types';
import { writable } from 'svelte/store';

export const starredConversations = writable<Conversation[]>([]);

export function SelectAllStarredConversation(is_checked = false) {
	starredConversations.update((state) => {
		return state?.map((obj) => {
			obj.is_checked = is_checked;
			return obj;
		});
	});
}
