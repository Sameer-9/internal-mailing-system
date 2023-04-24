// Import the necessary packages
import http from 'http';
import { Server } from 'socket.io';
import { socketResponse } from './SocketServer.js';
// Create a new HTTP server
const server = http.createServer();

import crypto from 'crypto';

console.log(crypto.randomBytes(128).toString('base64'));
// Create a new Socket.IO server
const io = new Server(server, {
	cors: {
		origin: '*', // Allow requests from this origin
		methods: ['GET', 'POST'] // Allow these HTTP methods
	}
});

// Listen for connections from clients
io.on('connection', (socket) => {
	console.log(`A client connected with ID ${socket.id}`);
	socketResponse(socket);
});

// Start the server
const port = 4000;

server.listen(port, () => {
	console.log(`Server started on port ${port}`);
});
