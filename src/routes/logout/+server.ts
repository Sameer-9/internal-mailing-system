import { sessionManager } from '$lib/server/config/redis';
import { redirect } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ locals, cookies, request }) => {
	if (locals && locals.isUserLoggedIn) {
		const deleteData = await sessionManager.delSession(cookies);
		if (deleteData.error) await sessionManager.deleteCookie(cookies);
	}
	throw redirect(302, '/login');
};
