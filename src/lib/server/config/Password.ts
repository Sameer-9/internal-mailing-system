import { scrypt, randomBytes, timingSafeEqual } from 'crypto';
import { promisify } from 'util';
import { PASSWORD_SALT } from '$env/static/private';
// scrypt is callback based so with promisify we can await it
const scryptAsync = promisify(scrypt);

export class Password {
	static async hashPassword(password: string) {
		const buf = (await scryptAsync(password, PASSWORD_SALT, 64)) as Buffer;
		return `${buf.toString('hex')}.${PASSWORD_SALT}`;
	}

	static async comparePassword(storedPassword: string, suppliedPassword: string): Promise<boolean> {
		// split() returns array
		const [hashedPassword, salt] = storedPassword.split('.');
		// we need to pass buffer values to timingSafeEqual
		const hashedPasswordBuf = Buffer.from(hashedPassword, 'hex');
		// we hash the new sign-in password
		const suppliedPasswordBuf = (await scryptAsync(suppliedPassword, salt, 64)) as Buffer;
		// compare the new supplied password with the stored hashed password
		return timingSafeEqual(hashedPasswordBuf, suppliedPasswordBuf);
	}
}
