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
		text: `SELECT user_lid, name, color_hex as color FROM user_label WHERE user_lid = $1 AND active = true;`,
		values: [userId]
	};
	console.log(statement);
	return client.query(statement);
};

export const addLabel = (userId, labelName, colorHex) => {
	const statement = {
		text: `INSERT INTO user_label(user_lid, name, color_hex, created_by)
				VALUES($1,$2,$3,$1);`,
		values: [userId, labelName, colorHex]
	};
	console.log(statement);
	return client.query(statement);
}