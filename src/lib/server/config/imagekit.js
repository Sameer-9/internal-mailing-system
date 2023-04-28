import { IMAGEKIT_PRIVATE_KEY, IMAGE_KIT_URL } from '$env/static/private';
import { PUBLIC_IMAGEKIT_PUBLIC_KEY } from '$env/static/public';
import ImageKit from 'imagekit';

const imagekit = new ImageKit({
	publicKey: PUBLIC_IMAGEKIT_PUBLIC_KEY,
	privateKey: IMAGEKIT_PRIVATE_KEY,
	urlEndpoint: IMAGE_KIT_URL
});

export { imagekit };
