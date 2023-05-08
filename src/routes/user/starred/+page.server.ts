import { getStarredConversations } from '$lib/server/model/Common';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, parent }) => {
	await parent();
	try {
		const result = await getStarredConversations(locals.user?.id);

		return {
			title: 'Starred',
			starred: result.rows[0]?.get_starred_conversation
		};
	} catch (err) {
		console.log(err);
	}
};
