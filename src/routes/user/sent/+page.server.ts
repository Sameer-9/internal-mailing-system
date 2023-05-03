import { getSentConversations } from '$lib/server/model/Common';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ parent, locals }) => {
	await parent();
	try {
		const result = await getSentConversations(locals.user?.id ?? 0);

		return {
			sent: result.rows[0]?.get_sent_conversation
		};
	} catch (err) {
		console.log(err);
		return {
			sent: []
		};
	}
};
