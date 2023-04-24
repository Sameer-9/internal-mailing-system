import { updateIsRead, updateIsStarred } from '$lib/server/model/Conversation';
import { userActions } from '$lib/utils/common/constants';
import { checkValueInJsonObject } from '$lib/utils/common/helper';
import { fail } from 'assert';

export async function POST({ request, locals }) {
	const { conversation_id, value, flag } = await request.json();

	const { id } = locals.user;

	if (!checkValueInJsonObject(flag)) {
		return new Response(
			JSON.stringify({
				success: false,
				error: true,
				warning: false,
				message: 'Invalid Request!'
			})
		);
	}

	try {
		let res = null;

		switch (flag) {
			case userActions.IS_STARRED:
				res = await updateIsStarred(conversation_id, value, id);
				break;

			case userActions.IS_READ:
				res = await updateIsRead(conversation_id, value, id);
				break;

			default:
				break;
		}

		if (!res) {
			JSON.stringify({
				success: false,
				error: false,
				warning: true,
				message: "Couldn't Update, try again later!"
			});
		}

		if (res?.rowCount && res?.rowCount > 0) {
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
		throw fail(JSON.stringify(err));
	}
}
