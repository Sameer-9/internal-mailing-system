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
