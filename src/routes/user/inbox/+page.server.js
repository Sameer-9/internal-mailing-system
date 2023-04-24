import { Password } from '$lib/server/config/Password';
import { getInboxConversation } from '$lib/server/model/Common';

export async function load({ locals, parent }) {
	await parent();
	try {
		console.log(locals.user);
		// @ts-ignore
		const result = await getInboxConversation(locals.user?.id);

		return {
			inbox: result.rows[0]?.get_inbox_conversation
		};
	} catch (err) {
		console.log(err);
	}
}
