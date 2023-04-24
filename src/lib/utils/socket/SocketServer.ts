import type { Socket } from 'socket.io';
import type { DefaultEventsMap } from 'socket.io/dist/typed-events';

type NumberToStringObject = {
	[key: number]: string;
};

const sessionMap: NumberToStringObject = {};

export const socketResponse = async function (
	socket: Socket<DefaultEventsMap, DefaultEventsMap, DefaultEventsMap, any>
) {
	socket!.emit('askForUserId');

	socket!.on('userIdReceived', (userId: number) => {
		sessionMap[userId] = socket!.id;

		console.log('USERS:::', sessionMap);
	});
};
