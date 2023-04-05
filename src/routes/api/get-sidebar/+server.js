import { error, json } from '@sveltejs/kit';
import { getSidebar } from '$lib/server/model/Common';

export const GET = async () => {
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
