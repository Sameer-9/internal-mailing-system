// @ts-nocheck
import client from '../config/db';
const table = 'public.user';

export const insert = ({ password, email }) => {
	const statement = {
		text: `INSERT INTO ${table}(password,email) VALUES($1,$2,$3)`,
		values: [username, password, email]
	};
	return client.query(statement);
};

export const findById = (id) => {
	const statement = {
		text: `SELECT * FROM ${table} WHERE id = $1`,
		values: [id]
	};
	return client.query(statement);
};

export const findByEmail = (email) => {
	const statement = {
		text: `SELECT * FROM ${table} WHERE email = $1`,
		values: [email]
	};
	console.log(statement);
	return client.query(statement);
};

export const getUserLabel = (userId) => {
	const statement = {
		text: `SELECT id,user_lid, name, color_hex as color FROM user_label WHERE user_lid = $1 AND active = true ORDER BY id DESC;`,
		values: [userId]
	};
	console.log(statement);
	return client.query(statement);
};

export const addLabel = (userId, labelName, colorHex) => {
	const statement = {
		text: `SELECT * FROM add_label($1,$2,$3)`,
		values: [userId, labelName, colorHex]
	};
	console.log(statement);
	return client.query(statement);
};

export const getUserLabelById = (userId, id) => {
	const statement = {
		text: `SELECT id,user_lid, name, color_hex as color FROM user_label WHERE user_lid = $1 AND active = true AND id = $2`,
		values: [userId, id]
	};
	console.log(statement);
	return client.query(statement);
};

export const deleteLabel = (userId, labelId) => {
	const statement = {
		text: `SELECT * FROM delete_label($1,$2)`,
		values: [userId, labelId]
	};
	console.log(statement);
	return client.query(statement);
};
