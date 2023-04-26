import { sessionManager } from '$lib/server/config/redis';
import { addLabel } from '$lib/server/model/User';
import { error, fail, json, redirect } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export const POST = async ({ cookies, request, locals }) => {
	const res = await request.json();
	console.log(res);
	if (!res) {
		throw error(400, {
			message: 'Invalid Request'
		});
	}

	const { labelName, colorHex } = res;
	if (labelName === '' || !labelName) {
		console.log('INSIDE ERROR');
		throw error(400, {
			message: 'Invalid Label Name'
		});
	}
	try {
		const resFromDb = await addLabel(locals.user?.id, labelName, colorHex);

		if (resFromDb.rowCount !== 1) {
			throw error(500, {
				message: 'Internal Server Error'
			});
		}

		const _res = resFromDb.rows[0].add_label;
		console.log(_res);
		return json({ success: true, _res });
	} catch (error) {
		console.log(error);
		throw fail(500, { message: 'Error' });
	}
};
