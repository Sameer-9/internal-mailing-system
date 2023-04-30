<script lang="ts">
	import { applyAction } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	import { toast } from '$lib/stores/toast-store';
	import { userStore } from '$lib/stores/user-store';
	import { isProfileDropdownOpen } from '$lib/stores/userSelection-store';
	import { alertTypes } from '$lib/utils/common/constants';
	import { onMount } from 'svelte';
	import { quintIn } from 'svelte/easing';
	import { slide } from 'svelte/transition';

	let showImage = false;
	$: profilePhoto = $userStore.profile_photo;
	let isPhotoChanges = false;
	let loading = false;
	let success = false;

	onMount(() => {
		$isProfileDropdownOpen = false;
	});

	function handleImageChange(e: Event) {
		const target = e.target as HTMLInputElement;

		if (!target.files) return;

		if (!target.files[0].type.includes('image')) {
			toast(alertTypes.ERROR, 'Only Images Are Accepted');
			return;
		}

		profilePhoto = window.URL.createObjectURL(target.files[0]);
		isPhotoChanges = true;
	}

	async function handleSubmit(event: SubmitEvent) {
		if (loading) return;

		loading = true;

		try {
			const target = event.target as HTMLFormElement;
			const data = new FormData(target);

			const response = await fetch(target.action, {
				method: 'POST',
				body: data
			});

			/** @type {import('@sveltejs/kit').ActionResult} */
			const result = await response.json();

			if (response.ok) {
				loading = false;
				success = true;
				toast(alertTypes.SUCCESS, 'Profile Updated Successfully');
				setTimeout(() => {
					success = false;
				}, 1000);
			} else {
				toast(alertTypes.ERROR, result.message as string);
			}
			await invalidateAll();
			applyAction(result);
		} catch (error) {
			console.log('ERROR:::::::::::::::::', error);
			loading = false;
		}
	}
</script>

<div class="text-gray-400 font-semibold w-[97%] h-full rounded-md">
	<div class="grey-md rounded-t-3xl">
		<div class="h-12 flex text-gray-300 font-thin justify-center items-center">
			<div class="text-center text-xl font-semibold">Update Profile</div>
		</div>
	</div>
	<div class="h-[81vh] overflow-x-hidden overflow-y-auto pb-10 bg-[#1b1b1b] rounded-b-3xl">
		<form on:submit|preventDefault={handleSubmit} action="/api/update/profile" method="post">
			<div class="h-[25vh] flex justify-center items-center">
				<input type="hidden" name="file-id" bind:value={$userStore.file_id} />
				<label
					on:mouseenter={() => (showImage = true)}
					on:mouseleave={() => (showImage = false)}
					for="profile-photo-edit"
					class="profile-edit cursor-pointer overflow-hidden z-[9999] relative rounded-full w-32 h-32"
				>
					<img class="w-32 h-32 bg-gray-400" src={profilePhoto} alt="Profile" />
					{#if showImage}
						<div
							class="bg-[rgba(32,33,36,.6)] absolute z-[9999999] bottom-0 w-full flex justify-center"
						>
							<img
								transition:slide={{ delay: 0, duration: 250, easing: quintIn }}
								src="/icons/camera-icon.png"
								width="30"
								alt=""
								class=""
							/>
						</div>
					{/if}
				</label>
				<input
					bind:value={profilePhoto}
					on:change={handleImageChange}
					type="file"
					accept="image/*"
					name="profile-photo"
					class="hidden"
					id="profile-photo-edit"
				/>
			</div>

			<div class="text-slate-200 flex justify-center pt-8">
				<div class="flex w-3/4 flex-col gap-10">
					<div class="relative h-11 w-full min-w-[200px]">
						<input
							placeholder="First Name"
							class="peer h-full w-full border-b border-blue-gray-200 bg-transparent pt-4 pb-1.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border-blue-gray-200 focus:border-sky-500 focus:outline-0 disabled:border-0 disabled:bg-blue-gray-50"
							id="first-name"
							name="first-name"
							value={$userStore.first_name}
						/>
						<label
							for="first-name"
							class="after:content[' '] pointer-events-none absolute left-0 -top-2.5 flex h-full w-full select-none text-sm font-normal leading-tight text-blue-gray-500 transition-all after:absolute after:-bottom-2.5 after:block after:w-full after:scale-x-0 after:border-b-2 after:border-sky-500 after:transition-transform after:duration-300 peer-placeholder-shown:leading-tight peer-placeholder-shown:text-blue-gray-500 peer-focus:text-sm peer-focus:leading-tight peer-focus:text-sky-500 peer-focus:after:scale-x-100 peer-focus:after:border-sky-500 peer-disabled:text-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500"
						>
							First Name
						</label>
					</div>
					<div class="relative h-11 w-full min-w-[200px]">
						<input
							placeholder="Last Name"
							class="peer h-full w-full border-b border-blue-gray-200 bg-transparent pt-4 pb-1.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border-blue-gray-200 focus:border-sky-500 focus:outline-0 disabled:border-0 disabled:bg-blue-gray-50"
							id="last-name"
							name="last-name"
							value={$userStore.last_name}
						/>
						<label
							for="last-name"
							class="after:content[' '] pointer-events-none absolute left-0 -top-2.5 flex h-full w-full select-none text-sm font-normal leading-tight text-blue-gray-500 transition-all after:absolute after:-bottom-2.5 after:block after:w-full after:scale-x-0 after:border-b-2 after:border-sky-500 after:transition-transform after:duration-300 peer-placeholder-shown:leading-tight peer-placeholder-shown:text-blue-gray-500 peer-focus:text-sm peer-focus:leading-tight peer-focus:text-sky-500 peer-focus:after:scale-x-100 peer-focus:after:border-sky-500 peer-disabled:text-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500"
						>
							Last Name
						</label>
					</div>
					<div class="relative h-11 w-full min-w-[200px]">
						<input
							placeholder="Designation"
							class="peer h-full w-full border-b border-blue-gray-200 bg-transparent pt-4 pb-1.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border-blue-gray-200 focus:border-sky-500 focus:outline-0 disabled:border-0 disabled:bg-blue-gray-50"
							id="designation"
							name="designation"
							value={$userStore.designation}
						/>
						<label
							for="designation"
							class="after:content[' '] pointer-events-none absolute left-0 -top-2.5 flex h-full w-full select-none text-sm font-normal leading-tight text-blue-gray-500 transition-all after:absolute after:-bottom-2.5 after:block after:w-full after:scale-x-0 after:border-b-2 after:border-sky-500 after:transition-transform after:duration-300 peer-placeholder-shown:leading-tight peer-placeholder-shown:text-blue-gray-500 peer-focus:text-sm peer-focus:leading-tight peer-focus:text-sky-500 peer-focus:after:scale-x-100 peer-focus:after:border-sky-500 peer-disabled:text-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500"
						>
							Designation
						</label>
					</div>
					<div class="relative h-11 w-full min-w-[200px]">
						<input
							placeholder="Bio"
							class="peer h-full w-full border-b border-blue-gray-200 bg-transparent pt-4 pb-1.5 font-sans text-sm font-normal text-blue-gray-700 outline outline-0 transition-all placeholder-shown:border-blue-gray-200 focus:border-sky-500 focus:outline-0 disabled:border-0 disabled:bg-blue-gray-50"
							id="bio"
							name="bio"
							value={$userStore.bio}
						/>
						<label
							for="bio"
							class="after:content[' '] pointer-events-none absolute left-0 -top-2.5 flex h-full w-full select-none text-sm font-normal leading-tight text-blue-gray-500 transition-all after:absolute after:-bottom-2.5 after:block after:w-full after:scale-x-0 after:border-b-2 after:border-sky-500 after:transition-transform after:duration-300 peer-placeholder-shown:leading-tight peer-placeholder-shown:text-blue-gray-500 peer-focus:text-sm peer-focus:leading-tight peer-focus:text-sky-500 peer-focus:after:scale-x-100 peer-focus:after:border-sky-500 peer-disabled:text-transparent peer-disabled:peer-placeholder-shown:text-blue-gray-500"
						>
							Bio
						</label>
					</div>

					<button
						class:btn-disabled={loading}
						class="btn btn-info btn-outline text-black font-semibold"
					>
						{#if loading}
							<img src="/svg/button-loader.svg" alt="Loading" class="w-full h-full" />
						{:else if success}
							<img src="/images/success-apng.apng" alt="Success" class="w-10 h-12" />
						{:else}
							Update
						{/if}
					</button>
				</div>
			</div>
		</form>
	</div>
</div>

<style>
	.grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	}

	label.profile-edit {
		transition: transform 300ms ease-in-out;
	}
	label.profile-edit:hover {
		transform: scale(1.04);
	}
</style>
