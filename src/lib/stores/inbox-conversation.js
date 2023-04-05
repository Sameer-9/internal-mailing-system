import { writable } from 'svelte/store';

export const inboxConversations = writable();

/**
 * @param {any} conversationObject
 */
export function updateInboxConversation(conversationObject) {
	inboxConversations.update((state) => {
		return state?.map((/** @type {{ id: any; }} */ obj) => {
			if (conversationObject?.id == obj?.id) {
				obj = conversationObject;
			}
			return obj;
		});
	});
}

export function SelectAllConversation(is_checked = false) {
	inboxConversations.update((state) => {
		return state?.map((/** @type {{ is_checked: boolean; }} */ obj) => {
			obj.is_checked = is_checked;
			return obj;
		});
	});
}
