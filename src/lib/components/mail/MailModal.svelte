<script>
	import { toast } from '$lib/stores/toast-store';
	import { SelectedUser } from '$lib/stores/userSelection-store';
	import { initializeCK } from '$lib/utils/common/ckinitializer';
	import { validate_slots } from 'svelte/internal';
	import { UserOption } from '.';
	
	// @ts-nocheck
	import { onMount } from 'svelte';

	let isFocused = false;
	let xDirection = 0;
	let yDirection = 0;
	let isSelectFocused = false;
	/**
	 * @type {any[]}
	 */
	let searchedUsers = [];
	/**
	 * @type {any}
	 */
	let editor;
	let editor1;
	onMount(async () => {
		editor1 = await initializeCK(editor);
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
	 */
	function searchUsers(e) {
		e.stopPropagation();
		// @ts-ignore
		const query = this.value;
		// @ts-ignore
		const { top, left } = this.getBoundingClientRect();
		yDirection = top + 40;
		xDirection = left;
		if(!query || query === '') {
			isSelectFocused = false;	
			return;
		} 
		isSelectFocused = true;
		// @ts-ignore
		fetchUser(query)
	}
	
	/**
	 * @param {string} query
	 */
	async function fetchUser(query) {

		try{
			isSelectFocused = true;
			const response = await fetch(`/api/get/user?query=${query}`);
			if(response.ok) {
				const jsonResponse = await response.json();
				console.log(jsonResponse);
				searchedUsers = jsonResponse;
				// const text = document.querySelector('p').textContent;
				// const regex = /brown/g;
				// const highlightedText = text.replace(regex, '<mark>$&</mark>');
				// document.querySelector('p').innerHTML = highlightedText;
			} else {
				toast('error', 'Invalid Request');
				isSelectFocused = false;
			}
		} catch(err) {
			console.log(err);
			toast('error', 'Internal Server Error');
			isSelectFocused = false;
		}
	}

	/**
	 * @param {number} id
	 * @this {any}
	 * @param {MouseEvent & { currentTarget: EventTarget & HTMLDivElement; }} e
	 */
	function handleRemoveUser(id,e) {
		
		// @ts-ignore
		console.log("THIS:::::::",e.target.closest('.input-group').querySelector('input'));
		SelectedUser.update((prev) => {
			return prev.filter(obj => obj.id !== id);
		})
		// @ts-ignore
		e.target.closest('.input-group').querySelector('input').click()
	}
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="bg-[#33333360] fixed inset-0 z-[99999] overflow-y-auto grid items-center text-black" on:click={() => isSelectFocused = false}>
	<div
		class="m-auto overflow-y-auto overflow-x-hidden min-h-[90%] max-w-[70%] min-w-[70%] bg-white rounded-xl relative"
	>
		<div class="border-b-0 border-gray-500 py-2 px-3 bg-gray-100 flex justify-between">
			<p class=" font-semibold text-gray-900 font-sans">New Message</p>
			<button title="Save & close" class="font-semibold text-gray-900 font-sans">
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
				<span class="bg-white ml-2 w-8 text-center">To</span>
				<label class="input-group items-center flex-wrap gap-1" for="u">
					<div class="hidden"></div>
					{#if $SelectedUser?.length > 0}
					
					{#each $SelectedUser as {id, firstname, lastname, profilephoto}, idx}
						<div class="hover:text-black text-gray-500 font-semibold flex gap-2 border h-6 pl-[2px] border-black rounded-3xl text-xs leading-none justify-around items-center pr-2">
							<div class="w-5 h-5">
								<img src={profilephoto} class="rounded-full" alt="Profile" style="width: 20px; height: 20px;">
							</div>
							<div class="">
								{firstname} {lastname}
							</div>
							<div class="cursor-pointer" title="remove User">
								<div on:click={(e) => handleRemoveUser(id,e)}>
									<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-3 h-3">
										<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
									</svg>							  
								</div>
							</div>
						</div>
					{/each}

					{/if}
					<span class="flex-1 bg-white">
						<input
						type="search"
						on:input={searchUsers}
						on:focusin={searchUsers}
						on:click={searchUsers}
						class="input text-black font-semibold input-sm bg-white w-full focus-within:outline-none"
						/>
					</span>
				</label>
			</div>
		</div>
		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text">
				<label class="input-group" for="k">
					<span class="bg-white">Cc</span>
					<input
						type="search"
						on:input={searchUsers}
						on:focusin={searchUsers}
						on:click={searchUsers}
						class="input input-sm text-black font-semibold bg-white w-full focus-within:outline-none"
					/>
				</label>
			</div>
		</div>
		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text">
				<label class="input-group" for="y">
					<span class="bg-white">Bcc</span>
					<input
						type="search"
						on:input={searchUsers}
						on:focusin={searchUsers}
						on:click={searchUsers}
						class="input input-sm text-black font-semibold bg-white w-full focus-within:outline-none"
					/>
				</label>
			</div>
		</div>

		<div class="border-b-0 border-gray-500 bg-gray-100">
			<div class="text-gray-500 cursor-text">
				<input
					type="text"
					placeholder="Subject"
					class="input text-black font-semibold bg-white w-full focus-within:outline-none"
				/>
			</div>
		</div>
		<div bind:this={editor} class="container max-w-[80%]" />

		<div class="absolute w-full bottom-3 py-2 flex justify-between items-center p-4">
			<div class="btn-group">
				<button class="btn rounded-l-full px-6 bg-[#0B57D0] text-white hover:bg-[#0B57F0]"
					>Send</button
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
	<div id="select-wrapper" class="fixed z-[9999999999] bg-white w-80" style={`left: ${xDirection}px;top: ${yDirection}px`}>
		<div class="py-4 rounded-md">
				<ul>
					{#if searchedUsers.length > 0}
						{#each searchedUsers as user,index}
							<UserOption {...user} index={index}/>
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
