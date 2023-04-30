<script>
	import { toast } from '$lib/stores/toast-store';
	import { SelectedUser } from '$lib/stores/userSelection-store';
	import { initializeCK } from '$lib/utils/common/ckinitializer';
	import { UserOption } from '.';
	import { scale } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isCreateModalOpen } from '$lib/stores/Sidebar-store';
	import { quintOut } from 'svelte/easing';
	import { userStore } from '$lib/stores/user-store';
	import { socketIo } from '$lib/stores/socket-store';

	let isFocused = false;
	let xDirection = 0;
	let yDirection = 0;
	let isSelectFocused = false;
	let subject = '';
	/**
	 * @type {HTMLInputElement}
	 */
	let toInput;
	/**
	 * @type {any[]}
	 */
	let searchedUsers = [];
	/**
	 * @type {any}
	 */
	let editor;
	// @ts-ignore
	let editor1;

	onMount(() => {
		setTimeout(async () => {
			//logic goes here
			editor1 = await initializeCK(editor);
		}, 10);
	});

	/**
	 * @param {any} e
	 */
	function submitTypeSelect(e) {
		const clickedElement = e.target;
		const { top, left } = clickedElement.getBoundingClientRect();
		yDirection = top - 40;
		xDirection = left - 50;
		isFocused = !isFocused;
	}

	/**
	 * @param {any} e
	 * @param {number} type_lid
	 */
	function searchUsers(e, type_lid) {
		e.stopPropagation();
		const target = e.target;
		// @ts-ignore
		const query = target.value;
		// @ts-ignore
		const { top, left } = target.getBoundingClientRect();
		yDirection = top + 40;
		xDirection = left;
		if (!query || query === '') {
			isSelectFocused = false;
			return;
		}
		isSelectFocused = true;
		// @ts-ignore
		fetchUser(query, type_lid);
	}

	/**
	 * @param {string} query
	 * @param {number} type_lid
	 */
	async function fetchUser(query, type_lid) {
		try {
			isSelectFocused = true;
			const response = await fetch(`/api/get/user?query=${query}`);
			if (response.ok) {
				const jsonResponse = await response.json();
				searchedUsers = jsonResponse?.map((/** @type {any} */ e) => ({ ...e, type_lid }));
				// const text = document.querySelector('p').textContent;
				// const regex = /brown/g;
				// const highlightedText = text.replace(regex, '<mark>$&</mark>');
				// document.querySelector('p').innerHTML = highlightedText;
			} else {
				toast('error', 'Invalid Request');
				isSelectFocused = false;
			}
		} catch (err) {
			console.log(err);
			toast('error', 'Internal Server Error');
			isSelectFocused = false;
		}
	}
	$: {
		toInput && toInput.focus();
	}
	/**
	 * @param {number} id
	 * @this {any}
	 * @param {MouseEvent & { currentTarget: EventTarget & HTMLDivElement; }} e
	 */
	function handleRemoveUser(id, e) {
		// @ts-ignore
		SelectedUser.update((prev) => {
			return prev.filter((obj) => obj.id !== id);
		});
		// @ts-ignore
		e.target.closest('.input-group').querySelector('input').click();
	}

	async function sendMail() {
		// @ts-ignore
		let editorData = await editor1.getData();

		if (!$SelectedUser || $SelectedUser.length === 0) {
			toast('error', 'Please specify at least one recipient.');
			return;
		}

		if (!subject || subject.length === 0 || !editorData || editorData?.length === 0) {
			const isConfirm = confirm('Send this message without a subject or text in the body?');
			if (!isConfirm) return;
		}
		// @ts-ignore
		const base64Body = window.btoa(editorData);
		const usersArray = $SelectedUser?.map((val) => {
			return {
				user_id: val.id,
				participation_type_id: val.type_lid
			};
		});
		const jsonToSend = {
			conversation: {
				created_by: $userStore?.id,
				subject: subject === '' ? null : subject,
				sender_name: $userStore?.first_name + ' ' + $userStore?.last_name,
				body: base64Body
			},
			users_array: usersArray
		};
		console.log(jsonToSend);

		try {
			const response = await fetch('/api/send-mail', {
				method: 'POST',
				body: JSON.stringify(jsonToSend)
			});

			const resJson = await response.json();
			if (response.ok) {
				$socketIo.emit(
					'mailSentSuccess',
					JSON.stringify({ convJson: resJson, resJson: jsonToSend })
				);

				$isCreateModalOpen = false;
				SelectedUser.set([]);
				subject = '';
				// @ts-ignore
				toast('success', 'Email Sent Successfully');
			} else {
				toast('error', 'Error In Sending Mail');
			}
		} catch (err) {
			console.log(err);
			toast('error', 'Internal Server Error');
		}
	}

	let selectedIndex = 0; // set the initial selected index to null

	/**
	 * @param {KeyboardEvent & { currentTarget: EventTarget & HTMLInputElement; }} event
	 */
	function handleEvent(event) {
		if (!event.target) return;
		const divs = document.querySelectorAll('.custom-option');

		if (event.key === 'Enter') {
			// @ts-ignore
			document.querySelector('.custom-option[aria-selected="true"]')?.click();
		} else if (event.key === 'ArrowUp') {
			// highlight the previous element on "ArrowUp" key press
			if (selectedIndex !== null && selectedIndex > 0) {
				selectedIndex--;
			} else {
				selectedIndex = divs.length - 1;
			}
		} else if (event.key === 'ArrowDown') {
			// highlight the next element on "ArrowDown" key press
			if (selectedIndex !== null && selectedIndex < divs.length - 1) {
				selectedIndex++;
			} else {
				selectedIndex = 0;
			}
		} else {
			// select the clicked element
			selectedIndex = 0;
		}

		// update the selected and highlighted divs
		divs.forEach((div, index) => {
			if (index === selectedIndex) {
				div.classList.add('bg-gray-200');
				div.setAttribute('aria-selected', 'true');
			} else {
				div.classList.remove('bg-gray-200');
				div.setAttribute('aria-selected', 'false');
			}
		});
	}
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
	class="bg-[#33333360] fixed inset-0 z-[99999] overflow-y-auto grid items-center text-black"
	on:click={() => (isSelectFocused = false)}
	transition:scale={{ delay: 250, duration: 300, easing: quintOut }}
>
	<div
		class="m-auto overflow-y-auto overflow-x-hidden min-h-[90%] max-w-[70%] min-w-[70%] bg-white rounded-xl relative"
	>
		<div class="border-b-0 border-gray-500 py-2 px-3 bg-gray-100 flex justify-between">
			<p class=" font-semibold text-gray-900 font-sans">New Message</p>
			<button
				title="Save & close"
				class="font-semibold text-gray-900 font-sans"
				on:click={() => ($isCreateModalOpen = false)}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="1.5"
					stroke="currentColor"
					class="w-6 h-6"
				>
					<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
				</svg>
			</button>
		</div>
		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text bg-white mt-3 flex">
				<span class="bg-white ml-1 w-12 text-center">To</span>
				<label class="input-group items-center flex-wrap gap-1" for="u">
					<div class="hidden" />
					{#if $SelectedUser?.length > 0}
						{#each $SelectedUser as { id, firstname, lastname, profilephoto, type_lid }, idx}
							{#if type_lid === 1}
								<div
									class="hover:text-black text-gray-500 font-semibold flex gap-2 border h-8 pl-[2px] border-black rounded-3xl text-xs leading-none justify-around items-center pr-2"
								>
									<div class="w-7 h-7">
										<img
											src={profilephoto}
											class="rounded-full"
											alt="Profile"
											style="width: 27px; height: 27px;"
										/>
									</div>
									<div class="">
										{firstname}
										{lastname}
									</div>
									<div class="cursor-pointer" title="remove User">
										<div on:click={(e) => handleRemoveUser(id, e)}>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												fill="none"
												viewBox="0 0 24 24"
												stroke-width="1.5"
												stroke="currentColor"
												class="w-3 h-3"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													d="M6 18L18 6M6 6l12 12"
												/>
											</svg>
										</div>
									</div>
								</div>
							{/if}
						{/each}
					{/if}
					<span class="flex-1 bg-white p-0">
						<input
							bind:this={toInput}
							on:keyup={(e) => handleEvent(e)}
							id="to"
							type="search"
							on:input={(e) => searchUsers(e, 1)}
							on:focusin={(e) => searchUsers(e, 1)}
							on:click={(e) => searchUsers(e, 1)}
							class="input text-black font-semibold input-sm px-0 bg-white w-full focus-within:outline-none"
						/>
					</span>
				</label>
			</div>
		</div>
		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text bg-white mt-3 flex">
				<span class="bg-white ml-1 w-12 text-center">Cc</span>
				<label class="input-group items-center flex-wrap gap-1" for="u">
					<div class="hidden" />
					{#if $SelectedUser?.length > 0}
						{#each $SelectedUser as { id, firstname, lastname, profilephoto, type_lid }, idx}
							{#if type_lid === 3}
								<div
									class="hover:text-black text-gray-500 font-semibold flex gap-2 border h-8 pl-[2px] border-black rounded-3xl text-xs leading-none justify-around items-center pr-2"
								>
									<div class="w-7 h-7">
										<img
											src={profilephoto}
											class="rounded-full"
											alt="Profile"
											style="width: 27px; height: 27px;"
										/>
									</div>
									<div class="">
										{firstname}
										{lastname}
									</div>
									<div class="cursor-pointer" title="remove User">
										<div on:click={(e) => handleRemoveUser(id, e)}>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												fill="none"
												viewBox="0 0 24 24"
												stroke-width="1.5"
												stroke="currentColor"
												class="w-3 h-3"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													d="M6 18L18 6M6 6l12 12"
												/>
											</svg>
										</div>
									</div>
								</div>
							{/if}
						{/each}
					{/if}
					<span class="flex-1 bg-white p-0">
						<input
							id="cc"
							type="search"
							on:keyup={(e) => handleEvent(e)}
							on:input={(e) => searchUsers(e, 3)}
							on:focusin={(e) => searchUsers(e, 3)}
							on:click={(e) => searchUsers(e, 3)}
							class="input text-black font-semibold input-sm px-0 bg-white w-full focus-within:outline-none"
						/>
					</span>
				</label>
			</div>
		</div>
		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text bg-white mt-3 flex">
				<span class="bg-white ml-1 w-12 text-center">Bcc</span>
				<label class="input-group items-center flex-wrap gap-1" for="u">
					<div class="hidden" />
					{#if $SelectedUser?.length > 0}
						{#each $SelectedUser as { id, firstname, lastname, profilephoto, type_lid }, idx}
							{#if type_lid === 4}
								<div
									class="hover:text-black text-gray-500 font-semibold flex gap-2 border h-8 pl-[2px] border-black rounded-3xl text-xs leading-none justify-around items-center pr-2"
								>
									<div class="w-7 h-7">
										<img
											src={profilephoto}
											class="rounded-full"
											alt="Profile"
											style="width: 27px; height: 27px;"
										/>
									</div>
									<div class="">
										{firstname}
										{lastname}
									</div>
									<div class="cursor-pointer" title="remove User">
										<div on:click={(e) => handleRemoveUser(id, e)}>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												fill="none"
												viewBox="0 0 24 24"
												stroke-width="1.5"
												stroke="currentColor"
												class="w-3 h-3"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													d="M6 18L18 6M6 6l12 12"
												/>
											</svg>
										</div>
									</div>
								</div>
							{/if}
						{/each}
					{/if}
					<span class="flex-1 bg-white p-0">
						<input
							id="bcc"
							type="search"
							on:keyup={(e) => handleEvent(e)}
							on:input={(e) => searchUsers(e, 4)}
							on:focusin={(e) => searchUsers(e, 4)}
							on:click={(e) => searchUsers(e, 4)}
							class="input text-black font-semibold input-sm px-0 bg-white w-full focus-within:outline-none"
						/>
					</span>
				</label>
			</div>
		</div>

		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text">
				<input
					type="text"
					bind:value={subject}
					placeholder="Subject"
					class="input text-black bg-white w-full focus-within:outline-none"
				/>
			</div>
		</div>
		<div bind:this={editor} class="container max-w-[80%]" />

		<div class="absolute w-full bottom-3 py-2 flex justify-between items-center p-4">
			<div class="btn-group">
				<button
					on:click={sendMail}
					class="btn rounded-l-full px-6 bg-[#0B57D0] text-white hover:bg-[#0B57F0]">Send</button
				>
				<button
					class="btn rounded-r-full px-3 bg-[#0B57D0] text-white hover:bg-[#0B57F0]"
					on:click={submitTypeSelect}
				>
					{#if isFocused}
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="2.5"
							stroke="currentColor"
							class="w-4 h-4"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M4.5 15.75l7.5-7.5 7.5 7.5" />
						</svg>
					{:else}
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="2.5"
							stroke="currentColor"
							class="w-4 h-4"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M19.5 8.25l-7.5 7.5-7.5-7.5"
							/>
						</svg>
					{/if}
				</button>
			</div>
			<div>
				<button
					class="hover:bg-gray-200 rounded-full tooltip tooltip-left p-2"
					data-tip="Discard Draft"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="2.0"
						stroke="black"
						class="w-5 h-5"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
						/>
					</svg>
				</button>
			</div>
		</div>
	</div>
</div>
{#if isFocused}
	<div class="fixed z-[9999999999]" style={`left: ${xDirection}px;top: ${yDirection}px`}>
		BCYB#YCB#BCU*#BCU#Bu
	</div>
{/if}
{#if isSelectFocused}
	<div
		id="select-wrapper"
		class="fixed z-[9999999999] bg-white w-80"
		style={`left: ${xDirection}px;top: ${yDirection}px`}
		transition:scale={{ delay: 250, duration: 200, easing: quintOut }}
	>
		<div class="py-4 rounded-md">
			<ul>
				{#if searchedUsers.length > 0}
					{#each searchedUsers as { bio, ...rest }, index}
						<UserOption {...rest} />
					{/each}
				{:else}
					<div class="text-center text-black">No Users Found</div>
				{/if}
			</ul>
		</div>
	</div>
{/if}

<style>
	:global(.ck-toolbar, .ck-editor__main) {
		max-width: 100% !important;
	}

	:global(.ck.ck-editor__main) {
		margin-bottom: 150px !important;
	}

	#select-wrapper {
		box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;
	}
</style>
