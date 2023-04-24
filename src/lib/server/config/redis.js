import { RedisSessionStore } from '@ethercorps/sveltekit-redis-session';
import Redis from 'ioredis';
import { SECRET, REDIS_URL } from '$env/static/private';
import { dev } from '$app/environment';

// Now we will create new Instance for RedisSessionStore
const options = {
	redisClient: new Redis(REDIS_URL),
	secret: SECRET,
	useTTL: true,
	encrypted: true,
	cookieName: crypto.randomUUID(),
	cookiesOptions: {
		path: '/',
		httpOnly: true,
		sameSite: true,
		secure: !dev, // From SvelteKit "$app/environment"
		maxAge: 60 * 60 * 24 // You have to define time in seconds and it's also used for redis key expiry time
	},
	serializer: JSON
};
// These are the required options to use RedisSessionStore.
export const sessionManager = new RedisSessionStore(options);
