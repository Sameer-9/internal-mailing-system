<script>
	import { SelectedUser } from '$lib/stores/userSelection-store';
	/**
	 * @type {number}
	 */
	export let id;
	/**
	 * @type {string}
	 */
	export let firstname;
	/**
	 * @type {string}
	 */
	export let lastname;
	/**
	 * @type {string}
	 */
	export let email;
	/**
	 * @type {string}
	 */
	export let profilephoto;
	/**
	 * @type {number}
	 */
	export let type_lid;
	/**
	 * @type {number}
	 */
	export let index;

	$: selected = $SelectedUser ? $SelectedUser.some((obj) => obj.id === id) : false;

	function handleClick() {
		if (selected) return;

		const data = {
			id,
			firstname,
			lastname,
			email,
			profilephoto,
			type_lid
		};

		SelectedUser.update((prev) => {
			console.log(prev);
			if (prev) {
				prev = [...prev, data];
			} else {
				prev = [data];
			}
			return prev;
		});

		switch (type_lid) {
			case 1:
				// @ts-ignore
				document.getElementById('to').value = '';
				document.getElementById('to')?.focus();
				break;
			case 3:
				// @ts-ignore
				document.getElementById('cc').value = '';
				document.getElementById('cc')?.focus();
				break;
			case 4:
				// @ts-ignore
				document.getElementById('bcc').value = '';
				document.getElementById('bcc')?.focus();
				break;

			default:
				break;
		}
	}
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
	on:click={handleClick}
	class:bg-gray-200={index === 0 && !selected}
	class:bg-[#E1E1E1]={selected}
	role="option"
	data-id={id}
	aria-selected="false"
	class="custom-option cursor-pointer"
	class:hover:bg-gray-100={index !== 0 && !selected}
>
	<div class="h-14  flex gap-3 items-center px-4" class:text-gray-700={!selected}>
		<div>
			<img
				src={profilephoto}
				style="width: 32px; height: 32px;"
				class="rounded-full"
				alt="Profile"
			/>
		</div>
		<div>
			<div class="flex flex-col">
				<p class="text-sm">
					{firstname}
					{lastname}
				</p>
				<p class="text-xs">
					{email}
				</p>
			</div>
		</div>
		{#if selected}
			<div class="ml-auto">
				<div class="bg-white rounded-full w-7 h-7 flex items-center justify-center">
					<svg xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"
						><path d="M0 0h24v24H0V0z" fill="none" /><path
							d="M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"
						/></svg
					>
				</div>
			</div>
		{/if}
	</div>
</div>

<style>
</style>
