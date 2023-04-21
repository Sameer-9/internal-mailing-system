import { getSidebar, getUser } from '$lib/server/model/Common';

export const load = async ({ locals }) => {
	try {
		const result = await getSidebar();
		const userDetails = await getUser(2);
		console.log('USER:::::::::', locals.user);
		return {
			sidebar: result.rows,
			userDetails: userDetails.rows
		};
	} catch (err) {
		return null;
	}
};
