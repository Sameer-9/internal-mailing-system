import { getInboxConversation } from '$lib/server/model/Common';
import type { PageServerLoad } from './$types';

export const load = (async ({ locals, parent }) => {
	await parent();
	try {
		// @ts-ignore
		const result = await getInboxConversation(locals.user?.id);

		return {
			inbox: result.rows[0]?.get_inbox_conversation
		};
	} catch (err) {
		console.log(err);
	}
}) satisfies PageServerLoad;
