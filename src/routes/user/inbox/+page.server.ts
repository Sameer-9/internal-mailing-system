import { getInboxConversation } from '$lib/server/model/Common';
import type { PageServerLoad } from './$types.js';

export const load: PageServerLoad = async ({ locals, parent }) => {
	await parent();
	try {
		const result = await getInboxConversation(locals.user?.id ?? 0);

		return {
			inbox: result.rows[0]?.get_inbox_conversation
		};
	} catch (err) {
		console.log(err);
	}
};
