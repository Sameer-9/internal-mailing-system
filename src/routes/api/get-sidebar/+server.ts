import { error, json } from '@sveltejs/kit';
import { getSidebar } from '$lib/server/model/Common';
import type { RequestEvent } from './$types';

export const GET = async ({ request }: RequestEvent) => {
	try {
		const result = await getSidebar();
		const resultJson = result.rows;
		return json(resultJson);
	} catch (err) {
		throw error(500, {
			message: 'Error in getting Sidebar'
		});
	}
};
