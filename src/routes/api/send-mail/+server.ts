import { sendMail } from '$lib/server/model/Common';
import { error, json } from '@sveltejs/kit';
import type { RequestEvent } from './$types';

export const POST = async ({ cookies, request }: RequestEvent) => {
	try {
		const res = await request.json();
		console.log(res);

		if (!res) {
			console.log('INSIDE ERROR');
			throw error(500, {
				message: 'Invalid Request'
			});
		}
		const result = await sendMail(res);
		return json(result.rows[0]?.create_conversation);
	} catch (err) {
		console.log(err);
		throw error(500, {
			message: 'Internal Server Error'
		});
	}
};
