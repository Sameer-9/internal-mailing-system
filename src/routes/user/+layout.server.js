import { sessionManager } from '$lib/server/config/redis.js';
import { getSidebar, getUser } from '$lib/server/model/Common';
import { redirect } from '@sveltejs/kit';

// @ts-ignore
export const load = async ({ locals, cookies, event }) => {
	const userSession = await sessionManager.getSession(await cookies);
	console.log('USERSESSION:::::::', userSession);
	if (userSession.error) {
		throw redirect(303, '/login');
	}

	if (!locals.isUserLoggedIn) {
		throw redirect(303, '/login');
	}

	try {
		const result = await getSidebar();
		// @ts-ignore
		const userDetails = await getUser(locals.user?.id);
		return {
			sidebar: result.rows,
			userDetails: userDetails.rows
		};
	} catch (err) {
		return null;
	}
};
