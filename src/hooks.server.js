import { sessionManager } from '$lib/server/config/redis';

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	const userSession = await sessionManager.getSession(await event.cookies);

	event.locals = {
		isUserLoggedIn: false,
		user: null
	};

	if (userSession.error) {
		console.log(userSession);
		await sessionManager.deleteCookie(await event.cookies);
		return resolve(event);
	}
	if (userSession && userSession.data) {
		event.locals = {
			isUserLoggedIn: true,
			user: userSession.data?.user
		};
	}
	return resolve(event);
}
