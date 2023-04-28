import * as fs from 'fs';

export async function fileToBuffer(file: File): Promise<Buffer | null> {
	const val = (await file.stream().getReader().read()).value;
	if (!val) return null;
	return Buffer.from(val);
}
