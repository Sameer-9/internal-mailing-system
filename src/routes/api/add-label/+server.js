import { error, json } from '@sveltejs/kit';

export const POST = async ({ cookies, request }) => {
	const res = await request.json();
	console.log(res);

	if (res?.labelName === '' || !res?.labelName) {
		console.log('INSIDE ERROR');
		throw error(500, {
			message: 'Invalid Name'
		});
	}
	return json({ success: true });
};
