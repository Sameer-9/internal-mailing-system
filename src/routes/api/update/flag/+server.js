import { updateIsRead, updateIsStarred } from '$lib/server/model/Conversation';
import { userActions } from '$lib/utils/common/constants';
import { checkValueInJsonObject } from '$lib/utils/common/helper';

/** @type {import('../star/$types').RequestHandler} */
export async function POST({ request, locals }) {
	const { conversation_id, value, flag } = await request.json();

	const { user_id } = locals.user;
	console.log("FLAG:::::::::::", flag);
	console.log("value:::::::::::", value);
	if(!checkValueInJsonObject(flag)) {
		return new Response(
			JSON.stringify({
				success: false,
				error: true,
				warning: false,
				message: "Invalid Request!"
			})
		);
	}

	try {
		let res = null;

		switch (flag) {
			case userActions.IS_STARRED:
				res = await updateIsStarred(conversation_id, value, user_id);
				break;

			case userActions.IS_READ:
				res = await updateIsRead(conversation_id, value, user_id);
				break;
		
			default:
				break;
		}

		if(!res) {
			JSON.stringify({
				success: false,
				error: false,
				warning: true,
				message: "Couldn't Update, try again later!"
			})
		}

		if (res?.rowCount === 1) {
			return new Response(
				JSON.stringify({
					success: true,
					error: false,
					warning: false,
					message: 'Success !!'
				})
			);
		} else {
			return new Response(
				JSON.stringify({
					success: false,
					error: false,
					warning: true,
					message: "Couldn't Update, try again later!"
				})
			);
		}
	} catch (err) {
		console.log(err);
		return new Response(
			JSON.stringify({
				success: false,
				error: true,
				warning: false,
				message: err ?? 'Internal Server Error'
			})
		);
	}
}
