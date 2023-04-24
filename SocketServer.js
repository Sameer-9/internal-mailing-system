const sessionMap = {};

export const socketResponse = async function (socket, io) {
	socket.emit('askForUserId');

	socket.on('userIdReceived', (user) => {
		const userJson = JSON.parse(user);

		sessionMap[userJson.id] = socket.id;
	});

	socket.on('mailSentSuccess', (data) => {
		if (!data) return;
		data = JSON.parse(data);
		const { convJson, resJson } = data;
		console.log(convJson);
		console.log(resJson);

		const { users_array } = resJson;

		const matchedUsers = [];
		console.log('USERS:::', sessionMap);
		console.log('RESUSERS::::::::', users_array);
		for (let resUser of users_array) {
			if (sessionMap[resUser?.user_id]) {
				matchedUsers.push(sessionMap[resUser.user_id]);
			}
		}
		console.log('MATCHED USERS:::::::::', matchedUsers);

		io.sockets.to(matchedUsers).emit('mailsendNotification', JSON.stringify(data));
	});
};
