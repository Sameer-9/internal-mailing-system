import { sessionManager } from '$lib/server/config/redis.js';
import { fail, redirect } from '@sveltejs/kit';

export const load = async ({ cookies }) => {
	const userSession = await sessionManager.getSession(await cookies);

	if (userSession.data) {
		throw redirect(303, '/user/inbox');
	}
}

export const actions = {

	register: async ({}) => {
		const errors = {
			email: '',
			password: '',
			message: ''
		};
		
		return fail(422, errors);

	}
}