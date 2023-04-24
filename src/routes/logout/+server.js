import { sessionManager } from '$lib/server/config/redis';
import { json, redirect } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export const GET = async ({ locals, cookies, request }) => {
	if (locals && locals.isUserLoggedIn) {
		const deleteData = await sessionManager.delSession(cookies);
		if (deleteData.error) await sessionManager.deleteCookie(cookies);
	}
	throw redirect(302, '/login');
};
