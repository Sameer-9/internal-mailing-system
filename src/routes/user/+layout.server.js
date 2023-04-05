import { error, json } from '@sveltejs/kit';
import { getSidebar, getUser } from '$lib/server/model/Common';

export const load = async () => {
	try {
		const result = await getSidebar();
		const userDetails = await getUser(1);
		return {
			sidebar: result.rows,
			userDetails: userDetails.rows
		};
	} catch (err) {
		return null;
	}
};
