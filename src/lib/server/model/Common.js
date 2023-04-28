import client from '$lib/server/config/db';

export const getSidebar = () => {
	const query = `Select * from folder_type where active = true`;
	return client.query(query);
};

export const getUser = (/** @type {number} */ userId) => {
	const statement = {
		text: `SELECT pu.id as user_id,pu.first_name,pu.last_name,pu.email,ui.* from public.user pu
                INNER JOIN user_info ui ON pu.id = ui.user_lid where pu.id = $1 AND pu.active = true`,
		values: [userId]
	};
	return client.query(statement);
};

export const getInboxConversation = (/** @type {number} */ userId) => {
	const statement = {
		text: `SELECT get_inbox_conversation($1)`,
		values: [userId]
	};
	return client.query(statement);
};

export const findUser = (/** @type {string} */ username) => {
	const statement = {
		text: `SELECT pu.id,pu.first_name as firstName, pu.last_name as lastName, pu.email, ui.profile_photo as profilePhoto, ui.bio 
			   FROM public.user pu
			   INNER JOIN user_info ui 
			   ON pu.id = ui.user_lid
			   WHERE UPPER(CONCAT(pu.first_name, ' ', pu.last_name, ' ' ,pu.email)) like $1 LIMIT 6`,
		values: ['%' + username + '%']
	};
	return client.query(statement);
};

export const findUserById = (/** @type {number} */ id) => {
	const statement = {
		text: `SELECT pu.id,pu.first_name as firstName, pu.last_name as lastName, pu.email, ui.profile_photo as profilePhoto,ui.bio 
			   FROM public.user pu
			   INNER JOIN user_info ui 
			   ON pu.id = ui.user_lid
			   WHERE pu.id = $1`,
		values: [id]
	};
	return client.query(statement);
};

export const sendMail = (/** @type {object} */ json) => {
	const statement = {
		text: `SELECT create_conversation($1)`,
		values: [json]
	};
	return client.query(statement);
};
