import { imagekit, uploadImage } from '$lib/server/config/imagekit';
import { updateProfile } from '$lib/server/model/User.js';
import { fileToBuffer } from '$lib/server/utils/util.js';
import { fail, json, error } from '@sveltejs/kit';
import type { RequestEvent } from './$types';

export async function POST({ request, locals }: RequestEvent) {
	const data = (await request.formData()) as FormData;

	console.log('DATA::::::', data);

	const profilePhoto = data.get('profile-photo') as File;

	console.log(profilePhoto);

	if (!locals.user?.id) {
		throw error(400, { message: 'Invalid Request' });
	}

	if (profilePhoto.size !== 0 && !profilePhoto.type.includes('image')) {
		throw error(400, { message: 'Invalid Image Type' });
	}

	let fileName = null;
	let fileId = '';
	if (profilePhoto.size !== 0) {
		try {
			const buffer = await fileToBuffer(profilePhoto);
			if (!buffer) {
				throw fail(400, { message: 'Invalid Image' });
			}

			fileName = crypto.randomUUID() + profilePhoto.name;
			const imageResponse = await uploadImage(fileName, buffer);
			console.log(imageResponse);

			fileName = imageResponse.url;
			fileId = imageResponse.fileId;
		} catch (err: any) {
			console.error('ERROR<><><><>', err);
			const errorMessage = err?.message ?? 'Invalid File Type';
			console.log('ERRORMESSAGE:::', errorMessage);

			throw error(400, { message: errorMessage });
		}
	}

	const obj = {
		first_name: data.get('first-name'),
		last_name: data.get('last-name'),
		designation: data.get('designation'),
		bio: data.get('bio') === '' ? null : data.get('bio'),
		profile_photo: fileName,
		file_id: fileId,
		user_lid: locals.user?.id
	};

	const dataTODb = [];
	dataTODb.push(obj);
	console.log(dataTODb);
	try {
		const res = await updateProfile(JSON.stringify(dataTODb));

		console.log(res.rows[0]);
		console.log('FILE ID:::::::::::', data.get('file-id'));

		imagekit.deleteFile(data.get('file-id') as string, (err, res) => {
			if (err) {
				console.log('ERROR', err);
			} else {
				console.log('RESPONSE:::', res);
			}
		});
	} catch (err) {
		console.log(err);
		throw error(400, 'Internal Server Error');
	}

	return json({ success: true });
}
