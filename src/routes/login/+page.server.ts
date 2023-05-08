import { fail } from '@sveltejs/kit';
import { findByEmail } from '$lib/server/model/User.js';
import { redirect } from '@sveltejs/kit';
import { sessionManager } from '$lib/server/config/redis';
import { findUserById } from '$lib/server/model/Common';
import { Password } from '$lib/server/config/Password';
import type { Actions, PageServerLoad } from '../$types.js';

export const load = (async ({ cookies }) => {
	const userSession = await sessionManager.getSession(await cookies);

	if (userSession.data) {
		throw redirect(303, '/user/inbox');
	}
}) satisfies PageServerLoad;

export const actions: Actions = {
	login: async ({ request, cookies }) => {
		console.log('HIT:::::');
		const dataFromBrowser = Object.fromEntries(await request.formData());
		console.log(dataFromBrowser);

		const emailFromBrowser = dataFromBrowser?.email;
		const passwordFromBrowser = dataFromBrowser?.password;

		const errors = {
			email: '',
			password: '',
			message: ''
		};

		if (!emailFromBrowser) {
			errors.email = 'Email cannot be empty';
			return fail(422, errors);
		}
		if (!passwordFromBrowser) {
			errors.password = 'Password cannot be empty';
			return fail(422, errors);
		}

		const dataFromDb = await findByEmail(dataFromBrowser.email);

		if (!dataFromDb || !dataFromDb?.rows[0]) {
			errors.message = 'Invalid Credentials';
			return fail(422, errors);
		}
		const { email, password, id } = dataFromDb?.rows[0];
		const isPasswordMatched = await Password.comparePassword(password, passwordFromBrowser as string);

		if (!isPasswordMatched) {
			errors.message = 'Invalid Credentials';
			return fail(422, errors);
		}

		const userDetails = (await findUserById(id)).rows[0];

		const { data, error, message } = await sessionManager.createNewSession(cookies, {
			user: userDetails
		});

		if (error) {
			return fail(400, {
				data: { emailFromBrowser, passwordFromBrowser },
				message
			});
		}
		throw redirect(303, '/user/inbox');
	}
};
