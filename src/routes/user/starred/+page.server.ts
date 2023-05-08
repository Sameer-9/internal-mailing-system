import { getStarredConversations } from '$lib/server/model/Common';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, parent }) => {
	await parent();
	try {
		const result = await getStarredConversations(locals.user?.id, 0);

		return {
			title: 'Starred',
			starred: result.rows[0]?.get_starred_conversation
		};
	} catch (err) {
		console.log(err);
		throw error(500, 'Internal Server Error');
	}
};
