import client from '$lib/server/config/db';

export const getSidebar = () => {
	const query = `Select * from folder_type where active = true`;
	return client.query(query);
};

export const getUser = (userId: number) => {
	const statement = {
		text: `SELECT pu.id as user_id,pu.first_name,pu.last_name,pu.email,ui.* from public.user pu
                INNER JOIN user_info ui ON pu.id = ui.user_lid where pu.id = $1 AND pu.active = true`,
		values: [userId]
	};
	return client.query(statement);
};

export const getInboxConversation = (userId: number, offset: number) => {
	const statement = {
		text: `SELECT get_inbox_conversation($1,$2, $3)`,
		values: [userId, offset, 50]
	};
	return client.query(statement);
};

export const getStarredConversations = (userId: number, offset: number) => {
	const statement = {
		text: `SELECT get_starred_conversation($1, $2, $3)`,
		values: [userId, offset, 50]
	};
	return client.query(statement);
};

export const getSentConversations = (userId: number, offset: number) => {
	const statement = {
		text: `SELECT get_sent_conversation($1, $2, $3)`,
		values: [userId, offset, 50]
	};
	return client.query(statement);
};

export const findUser = (username: string) => {
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

export const findUserById = (id: number) => {
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

export const sendMail = (json: any) => {
	const statement = {
		text: `SELECT create_conversation($1)`,
		values: [json]
	};
	return client.query(statement);
};
