import { error, json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getStarredConversations } from '$lib/server/model/Common';

export const GET: RequestHandler = async ({ url, params, locals }) => {
	const offset = url.searchParams.has('offset')
		? (url.searchParams.get('offset') as unknown as number)
		: 0;
	try {
		const result = await getStarredConversations(locals.user?.id ?? 0, offset);

		return json(result.rows[0].get_starred_conversation);
	} catch (err) {
		throw error(500, 'Internal Server Error');
	}
};
