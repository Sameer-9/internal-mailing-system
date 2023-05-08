import { getInboxConversation } from '$lib/server/model/Common';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types.js';

export const load: PageServerLoad = async ({ locals, parent }) => {
	await parent();
	try {
		const result = await getInboxConversation(locals.user?.id ?? 0, 0);

		return {
			title: 'Inbox',
			inbox: result.rows[0]?.get_inbox_conversation
		};
	} catch (err) {
		console.log(err);
		throw error(400, 'Internal Server Error');
	}
};
