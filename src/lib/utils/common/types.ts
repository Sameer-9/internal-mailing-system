export type User = {
	id: number;
	firstname: string | undefined;
	lastname: string | undefined;
	email: string | undefined;
	profilephoto: string | undefined;
	type_lid: number;
};

export type Conversation = {
	id: number;
	subject: string;
	sender: string;
	message: string;
	date: string;
	is_read: boolean;
	is_starred: boolean;
	is_checked: boolean;
	sent_users: string;
};

export type Sidebar = {
	id: number;
	name: string;
	url: string;
	icon: string;
};

export type Toast = {
	type: string | null;
	message: string | null;
};

export type UserArray = {
	user_id: number;
	participation_type_id: number;
};

export type Label = {
	id: number;
	name: string;
	color: string;
};
