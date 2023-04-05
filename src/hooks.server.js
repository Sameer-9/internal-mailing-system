import { getUser } from '$lib/server/model/Common';

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	const res = await getUser(2);

	event.locals.user = res.rows[0];

	const response = await resolve(event);

	return response;
}
