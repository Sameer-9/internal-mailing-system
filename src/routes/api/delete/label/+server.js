import { deleteLabel } from '$lib/server/model/User';
import { fail, json } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export async function DELETE({ request, cookies, locals }) {
	try {
		const userId = locals.user?.id;
		const { labelId } = await request.json();

		const dbResponse = await deleteLabel(userId, labelId);

		console.log('dbResponse::::::::', dbResponse.rows[0].delete_label);

		return json(dbResponse.rows[0].delete_label);
	} catch (error) {
		console.log(error);
		throw fail(400, { message: 'Internal Server Error' });
	}
}
