import type { Conversation } from '$lib/utils/common/types';
import { writable } from 'svelte/store';

export const sentConversations = writable<Conversation[]>([]);

export function SelectAllSentConversation(is_checked = false) {
	sentConversations.update((state) => {
		return state?.map((obj) => {
			obj.is_checked = is_checked;
			return obj;
		});
	});
}
