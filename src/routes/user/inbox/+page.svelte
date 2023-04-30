<script>
	import { invalidateAll } from '$app/navigation';
	import { MailTable } from '$lib/components/mail/index.js';
	import { inboxConversations, SelectAllConversation } from '$lib/stores/inbox-conversation';
	import { userStore } from '$lib/stores/user-store';
	export let data;

	let isAllChecked = false;
	$: SelectAllConversation(isAllChecked);

	inboxConversations.set(data.inbox?.conversations);

	/**
	 * @param {any} [users_array]
	 */
	function isAvailableToInbox(users_array) {
		let isAvailable = false;
		const types = [1, 3, 4];
		for (let user of users_array) {
			console.log('TEST:::', user.user_id === $userStore.id);
			if (user.user_id === $userStore.id && types.includes(user.type_lid)) {
				isAvailable = true;
			}
		}

		return isAvailable;
	}
</script>

<div class="text-gray-400 font-semibold w-[97%] h-full rounded-md">
	<div class="grey-md rounded-tl-lg rounded-tr-3xl">
		<div class="h-12 flex text-gray-300 font-thin justify-between items-center">
			<div class="pl-3 flex text-center">
				<div class="flex items-center">
					<div
						class="hover:bg-zinc-500 p-1 rounded-md ml-2 tooltip tooltip-bottom"
						data-tip="Select All"
					>
						<input
							type="checkbox"
							bind:checked={isAllChecked}
							class="checkbox h-3 w-3 rounded-sm"
						/>
					</div>
					<div class="h-full hover:bg-zinc-500 pt-2.5 cursor-pointer">
						<img src="/images/down-arrow.png" alt="" />
					</div>
				</div>
				<div class="flex">
					<button on:click={async () => await invalidateAll()}>
						<div
							class="hover:cursor-pointer hover:bg-zinc-500 rounded-full p-2 tooltip tooltip-bottom"
							data-tip="Refresh"
						>
							<img src="/images/refresh.png" alt="Refresh" />
						</div>
					</button>
				</div>
				<div class="flex justify-center items-center ">
					<div
						class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-1 tooltip tooltip-bottom"
						data-tip="More"
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width={1.5}
							stroke="currentColor"
							class="w-6 h-6"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M12 6.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 12.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 18.75a.75.75 0 110-1.5.75.75 0 010 1.5z"
							/>
						</svg>
					</div>
				</div>
			</div>
			<div class="pr-6 flex">
				<div>
					<div class="hover:bg-zinc-500 rounded-md hover:cursor-pointer p-1">1-50 of 1700</div>
				</div>
				<div class="flex gap-2">
					<div
						class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-2 tooltip tooltip-bottom"
						data-tip="Previous Page"
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
								d="M15.75 19.5L8.25 12l7.5-7.5"
							/>
						</svg>
					</div>
					<div
						class="hover:bg-zinc-500 rounded-full hover:cursor-pointer p-2 tooltip tooltip-bottom"
						data-tip="Next Page"
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="1.5"
							stroke="currentColor"
							class="w-4 h-4"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
						</svg>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="h-[81vh] overflow-x-hidden bg-[#1b1b1b] rounded-b-3xl">
		<MailTable />
	</div>
</div>

<style>
	.grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	}

	input[type='checkbox'] {
		outline: 2px solid rgba(255, 255, 255, 0.4);
	}
</style>
