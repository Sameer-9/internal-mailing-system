import pkg from 'pg';
const { Client } = pkg;

const client: pkg.Client = new Client({
	host: 'localhost',
	port: 5432,
	user: 'postgres',
	password: 'root',
	database: 'mail_db'
});

(async () => {
	await client.connect();
})();
export default client;
