<script>
	// @ts-nocheck

	import { page } from '$app/stores';
	import { inboxConversations } from '$lib/stores/inbox-conversation';
	import { toast } from '$lib/stores/toast-store';
	import { alertTypes, userActions } from '$lib/utils/common/constants';
	import { onMount } from 'svelte';
	let Window = null;
	/**
	 * @type {number}
	 */
	export let id;
	export let is_read = false;
	export let is_starred = false;
	export let sender = '';
	export let subject = '(No Subject)';
	export let message = '(No Message)';
	export let is_checked = false;
	export let date = '';
	let isHover = false;
	/**
	 * @param {string} flag
	 */
	async function updateFlag(flag) {
		let value = null;

		switch (flag) {
			case userActions.IS_STARRED:
				value = !is_starred;
				break;
			case userActions.IS_READ:
				value = !is_read;
				break;
			default:
				break;
		}

		try {
			const res = await fetch('/api/update/flag', {
				method: 'POST',
				headers: {
					contentType: 'application/json'
				},
				body: JSON.stringify({ conversation_id: id, value: value, flag: flag })
			});

			const jsonRes = await res.json();
			if (res.ok) {
				if (jsonRes.success) {
					inboxConversations.update((state) => {
						return state?.map((obj) => {
							if (id == obj.id) {
								obj[flag] = value;
							}
							return obj;
						});
					});
					toast(alertTypes.SUCCESS, jsonRes.message);
				} else if (jsonRes.warning) {
					toast(alertTypes.WARNING, jsonRes.message);
				} else {
					toast(alertTypes.ERROR, jsonRes.message);
				}
			}
		} catch (err) {
			console.log(err);
		}
	}

	onMount(() => {
		Window = window;
	});
	$: newMessage = atob(message);
	$: {
		if (newMessage.includes('<img')) {
			newMessage = '<p>(Attachment Inside)</p>';
		}
	}
</script>

<div class="cursor-pointer -z-10">
	<div
		class="flex items-center gap-2 pb-2 div-row cursor-pointer"
		on:mouseleave={() => (isHover = false)}
		on:mouseenter={() => (isHover = true)}
		class:is-read={!is_read && !is_checked}
		class:bg-[#174ea6]={is_checked}
	>
		<div class="checkbox-div" class:drag={isHover}>
			<input
				type="checkbox"
				bind:checked={is_checked}
				class="checkbox h-3 w-3 rounded-sm"
				class:active={isHover}
			/>
		</div>
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<div
			class="tooltip tooltip-bottom"
			on:click={() => updateFlag(userActions.IS_STARRED)}
			data-tip={is_starred ? 'Starred' : 'Not starred'}
		>
			<button class:active={isHover}>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill={is_starred ? 'orange' : 'none'}
					viewBox="0 0 24 24"
					stroke-width="1.5"
					stroke="currentColor"
					class="w-4 h-4"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"
					/>
				</svg>
			</button>
		</div>
		<div>
			<a href={$page.url.href}>
				<div
					class="sender-name w-24 md:w-30 sm:w-32 sm:whitespace-normal md:whitespace-nowrap min-w-[30px] text-sm"
				>
					{sender}
				</div>
			</a>
		</div>
		<div class="message flex flex-1 w-[100px]">
			<a href={$page.url.href}>
				<div class="text-sm subject">
					{subject ?? '(No Subject)'} &nbsp;-&nbsp;
				</div>
			</a>
			<span class="text-sm"
				>{@html newMessage == '' || newMessage == null ? '<p>(No Message)</p>' : newMessage}</span
			>
		</div>
		<div class="flex gap-1" class:hidden={!isHover}>
			<div
				class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-1 tooltip tooltip-bottom"
				data-tip="Archive"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="1.5"
					stroke="currentColor"
					class="w-4 h-4"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5m8.25 3v6.75m0 0l-3-3m3 3l3-3M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"
					/>
				</svg>
			</div>
			<div
				class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-1 tooltip tooltip-bottom"
				data-tip="Delete"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="1.5"
					stroke="currentColor"
					class="w-4 h-4"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
					/>
				</svg>
			</div>
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<div
				class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-1 tooltip tooltip-bottom"
				data-tip={is_read ? 'Mark as unread' : 'Mark as read'}
				on:click={() => updateFlag(userActions.IS_READ)}
			>
				{#if is_read}
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="1.5"
						stroke="currentColor"
						class="w-4 h-4"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="M21.75 9v.906a2.25 2.25 0 01-1.183 1.981l-6.478 3.488M2.25 9v.906a2.25 2.25 0 001.183 1.981l6.478 3.488m8.839 2.51l-4.66-2.51m0 0l-1.023-.55a2.25 2.25 0 00-2.134 0l-1.022.55m0 0l-4.661 2.51m16.5 1.615a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V8.844a2.25 2.25 0 011.183-1.98l7.5-4.04a2.25 2.25 0 012.134 0l7.5 4.04a2.25 2.25 0 011.183 1.98V19.5z"
						/>
					</svg>
				{:else}
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="1.5"
						stroke="currentColor"
						class="w-4 h-4"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
						/>
					</svg>
				{/if}
			</div>
		</div>
		<div
			class:text-zinc-500={!is_checked}
			class="ml-auto pr-4 font-bold text-xs whitespace-nowrap time"
		>
			{date}
		</div>
	</div>
</div>

<style>
	input[type='checkbox'] {
		outline: 2px solid rgba(255, 255, 255, 0.4);
		z-index: 4 !important;
	}

	.checkbox-div {
		margin-left: 17px;
	}

	.drag::before {
		content: '';
		background-image: url('/images/drag.png');
		position: absolute;
		display: inline-block;
		width: 20px;
		height: 20px;
		background-repeat: no-repeat;
		cursor: grab;
		z-index: -1 !important;
		left: 0;
		margin-top: 2px;
	}

	input[type='checkbox'].active {
		outline: 2px solid white !important;
	}

	button.active svg {
		stroke: white !important;
		stroke-width: 2px;
	}

	.div-row {
		/* border-bottom: 1px solid rgba(255,255,255,0.2); */
		outline-width: 1px;
		outline-style: solid;
		outline-color: rgba(255, 255, 255, 0.2);
		padding: 8px;
		position: relative;
	}

	.div-row:hover {
		box-shadow: inset 1px 0 0 rgb(255 255 255 / 20%), inset -1px 0 0 rgb(255 255 255 / 20%),
			0 0 4px 0 rgb(95 99 104 / 60%), 0 0 6px 2px rgb(95 99 104 / 60%);
		z-index: 2;
	}

	.message span {
		max-width: 360px;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.sender-name {
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}

	.subject {
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}

	.is-read {
		background-color: rgba(200, 200, 200, 0.1);
		font-family: sans-serif;
	}

	.is-read .subject,
	.is-read .sender-name,
	.is-read .time {
		color: #ffffff;
	}
</style>
