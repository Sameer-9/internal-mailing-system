import { findUser } from '$lib/server/model/Common';
import { fail, json } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export async function GET({ url }) {
	const query = url.searchParams.get('query');
	console.log(query);
	if (!query) throw fail(500, { message: 'Invalid Request' });
	try {
		const response = await findUser(query.toUpperCase());
		const data = response.rows;
		return json(data);
	} catch (err) {
		console.log(err);
		// @ts-ignore
		throw fail(500, err);
	}
}
