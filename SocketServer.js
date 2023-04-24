const sessionMap = {};

export const socketResponse = async function (socket) {
	socket.emit('askForUserId');

	socket.on('userIdReceived', (user) => {
		const userJson = JSON.parse(user);

		sessionMap[Number(userJson.id)] = socket.id;

		console.log('USERS:::', sessionMap);
	});
};
