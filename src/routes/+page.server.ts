import { sessionManager } from '$lib/server/config/redis.js';
import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load = (async ({ locals, cookies }) => {
	const userSession = await sessionManager.getSession(await cookies);

	if (userSession.error) {
		throw redirect(303, '/login');
	}

	if (!locals.isUserLoggedIn) {
		throw redirect(303, '/login');
	} else {
		throw redirect(303, '/user/inbox');
	}
}) satisfies PageServerLoad;
