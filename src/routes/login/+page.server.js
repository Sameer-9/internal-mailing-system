import { fail } from '@sveltejs/kit';
import { findByEmail } from '$lib/server/model/User.js';
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ cookies }) {
	if (cookies.get('user')) {
		throw redirect(303, '/user/inbox');
	}
}

/** @type {import('./$types').Actions} */
export const actions = {
	login: async ({ request, cookies }) => {
		console.log('HIT:::::');
		const data = Object.fromEntries(await request.formData());
		console.log(data);

		const errors = {
			email: '',
			password: '',
			message: ''
		};

		if (!data?.email) {
			errors.email = 'Email cannot be empty';
			return fail(422, errors);
		}
		if (!data?.password) {
			errors.password = 'Password cannot be empty';
			return fail(422, errors);
		}

		const dataFromDb = await findByEmail(data.email);

		if (!dataFromDb || !dataFromDb?.rows[0]) {
			errors.message = 'Invalid Credentials';
			return fail(422, errors);
		}
		const { email, password } = dataFromDb?.rows[0];

		if (data.password !== password) {
			errors.message = 'Invalid Credentials';
			return fail(422, errors);
		}
		cookies.set('user', email, {
			path: '/',
			httpOnly: true,
			sameSite: 'strict',
			secure: true,
			maxAge: 60 * 60 * 24 * 7
		});
		throw redirect(303, '/user/inbox');
	}
};
