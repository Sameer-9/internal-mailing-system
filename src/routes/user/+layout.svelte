<script>
	// @ts-nocheck
	import { Header, Sidebar } from '$lib/components/basic/index.js';
	import { MailModal } from '$lib/components/mail/index.js';
	import { labelStore } from '$lib/stores/label-store';
	import { isCreateModalOpen, sidebarArray } from '$lib/stores/Sidebar-store';
	import { socketIo } from '$lib/stores/socket-store';
	import { toast, toastStore } from '$lib/stores/toast-store';
	import { userStore } from '$lib/stores/user-store.ts';
	import { alertTypes } from '$lib/utils/common/constants';
	import { onMount } from 'svelte';
	import io from 'socket.io-client';
	import { inboxConversations } from '$lib/stores/inbox-conversation.js';

	export let data;
	let labelName = '';
	let labelError = null;
	let labelColor = '#FFFFFF';
	let closeModalBtn;

	sidebarArray.set(data.sidebar);
	userStore.set(data.userDetails[0] ?? []);
	labelStore.set(data.labelDetails ?? []);

	async function handleSubmit() {
		try {
			const res = await fetch('/api/add-label', {
				method: 'POST',
				body: JSON.stringify({ labelName: labelName, colorHex: labelColor })
			});
			const json = await res.json();
			if (res.ok) {
				console.log('RESPONSE:::::', json);
				const { idFromDB } = json;
				labelError = null;
				closeModalBtn.click();
				toast(alertTypes.SUCCESS, 'Label Added Successfully');
				labelStore.update((prevVal) => {
					prevVal = [
						...prevVal,
						{
							id: idFromDB,
							name: labelName,
							color: labelColor
						}
					];
					return prevVal;
				});
				labelName = '';
			} else {
				console.log('ERROR HANDLED::::::', json);
				toast(alertTypes.ERROR, json?.message);
				labelError = json?.message;
			}
		} catch (err) {
			alert(err);
		}
	}

	/**
	 * @type {import("socket.io-client").Socket<import("@socket.io/component-emitter").DefaultEventsMap, import("@socket.io/component-emitter").DefaultEventsMap>}
	 */
	let socket;
	let audio;
	onMount(async () => {
		// Connect to the Socket.IO server
		socket = io('http://10.130.96.136:4000');
		console.log(io.sockets?.clients());
		// Log the socket ID when connected
		socket.on('connect', () => {
			console.log(`Connected with ID ${socket.id}`);
			socket.userId = $userStore.id;

			socketIo.set(socket);

			$socketIo.on('askForUserId', () => {
				console.log('ASKING FOR USERID:::::::');
				$socketIo.emit('userIdReceived', JSON.stringify($userStore));
			});
		});

		socket.on('mailsendNotification', (data) => {
			console.log(data);
			console.log('SOCKET DATA MESSAGE RECIEVED::::::');

			if (!data) return;

			data = JSON.parse(data);

			const { convJson: resJson, resJson: convJson } = data;

			const { conversation, users_array } = convJson;

			console.log('users_array::', users_array);
			console.log('conversation::', conversation);

			const isAvailableTOInbox = isAvailableToInbox(users_array);

			console.log(isAvailableTOInbox);

			if (isAvailableTOInbox) {
				const today = new Date();
				const formattedDate = today
					.toLocaleString('en-US', { month: 'short', day: '2-digit' })
					.replace(' ', ' ');

				inboxConversations.update((prev) => {
					const newObj = {
						id: resJson.conversation_lid,
						date: formattedDate,
						sender: conversation.sender_name,
						is_read: false,
						message: conversation.body,
						subject: conversation.subject,
						is_checked: false,
						is_starred: false
					};
					return [newObj, ...prev];
				});

				toast('success', 'New Email Recieved');
				audio.play();
			}
		});
	});

	function isAvailableToInbox(users_array) {
		let isAvailable = false;
		const types = [1, 3, 4];
		for (let user of users_array) {
			console.log('TEST:::', user.user_id === $userStore.id);
			if (user.user_id === $userStore.id && types.includes(user.participation_type_id)) {
				isAvailable = true;
			}
		}

		return isAvailable;
	}
</script>

<svelte:head>
	<title>{$userStore.email} ( {$userStore.first_name} {$userStore.last_name} )</title>
</svelte:head>
{#if $isCreateModalOpen}
	<MailModal />
{/if}

{#if $toastStore?.type}
	<div class="toast toast-top toast-end z-[9999999999]">
		<div class="alert alert-{$toastStore.type}">
			<div>
				<span>{$toastStore.message}</span>
			</div>
		</div>
	</div>
{/if}
<audio src="/audios/notification.wav" bind:this={audio} />
<Header />
<main class="flex gap-5">
	<Sidebar />
	<section id="main-content" class="flex-1 transition-all ease-in-out delay-300">
		<slot />
	</section>
</main>

<input type="checkbox" id="label-modal" class="modal-toggle" />
<div class="modal modal-bottom sm:modal-middle">
	<div class="modal-box">
		<h5 class="text-xl font-bold">New Label</h5>
		<hr class="my-3" />
		<form on:submit|preventDefault={handleSubmit}>
			<div class="form-control w-full">
				<label class="label" for="label-name">
					<span class="label-text">Enter Label Name</span>
				</label>
				<input
					class:input-error={labelError}
					bind:value={labelName}
					type="text"
					id="label-name"
					name="label-name"
					placeholder="Type here"
					class="input input-bordered w-full "
				/>
				<p class="text-error">{labelError ?? ''}</p>
			</div>
			<div class="">
				<label class="label" for="label-name">
					<span class="label-text">Select Label Color</span>
				</label>
				<input
					bind:value={labelColor}
					type="color"
					id="label-color"
					name="label-color"
					class="input w-2/4"
				/>
			</div>
			<div class="modal-action">
				<label for="label-modal" bind:this={closeModalBtn} class="btn">Cancel</label>
				<button class="btn">Add</button>
			</div>
		</form>
	</div>
</div>

<style>
	:global(::-webkit-scrollbar-track) {
		-webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
		border-radius: 0px;
		background-color: rgba(241, 243, 244, 0.2);
	}

	:global(::-webkit-scrollbar) {
		width: 12px;
		background-color: #111111;
	}

	:global(::-webkit-scrollbar-thumb) {
		border-radius: 10px;
		-webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
		background-color: #696969;
	}
</style>
