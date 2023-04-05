import client from '$lib/server/config/db';

export const updateIsStarred = (
	/** @type {number} */ id,
	/** @type {boolean} */ isStarred,
	/** @type {number} */ user_id
) => {
	const statement = {
		text: `UPDATE conversation_participant SET is_starred = $1, 
				modified_date = CURRENT_TIMESTAMP, modified_by = $3
			    WHERE conversation_lid = $2 AND user_lid = $3`,
			   values: [isStarred, id, user_id]
	};
	return client.query(statement);
};

export const updateIsRead = (
	/** @type {number} */ id,
	/** @type {boolean} */ isRead,
	/** @type {number} */ user_id
) => {
	const statement = {
		text: `UPDATE message_recepient SET is_read = $1, 
				modified_date = CURRENT_TIMESTAMP, modified_by = $3
			    WHERE message_lid 
				IN(SELECT id FROM message WHERE conversation_lid = $2)
				AND user_lid = $3;`,
			   values: [isRead, id, user_id]
	};
	console.log(statement);
	return client.query(statement);
};
