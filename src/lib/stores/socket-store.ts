import type { Socket } from 'socket.io-client';
import type { DefaultEventsMap } from 'socket.io/dist/typed-events';
import { writable } from 'svelte/store';

export const socketIo = writable<Socket<DefaultEventsMap, DefaultEventsMap>>();
