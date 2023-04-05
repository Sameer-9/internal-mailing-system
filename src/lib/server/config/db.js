import { Client } from 'pg';

const client = new Client({
	host: 'localhost',
	port: 5432,
	user: 'postgres',
	password: 'ROOT',
	database: 'mail_db'
});

client.connect();
export default client;
