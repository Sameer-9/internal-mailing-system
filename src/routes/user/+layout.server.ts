import { sessionManager } from '$lib/server/config/redis.js';
import { getSidebar, getUser } from '$lib/server/model/Common';
import { getUserLabel } from '$lib/server/model/User.js';
import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from '../$types';

// @ts-ignore
export const load = (async ({ locals, cookies, event }) => {
	const userSession = await sessionManager.getSession(await cookies);

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

		const labelStore = await getUserLabel(locals.user?.id);

		return {
			sidebar: result.rows,
			userDetails: userDetails.rows,
			labelDetails: labelStore.rows
		};
	} catch (err) {
		return null;
	}
}) satisfies PageServerLoad;
