<script lang="ts">
	import { SelectedUser } from '$lib/stores/userSelection-store';

	export let id: number;
	export let firstname: string;
	export let lastname: string;
	export let email: string;
	export let profilephoto: string;
	export let type_lid: number;

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
				let to = document.getElementById('to') as HTMLInputElement;
				to.value = '';
				to.focus();
				break;
			case 3:
				let cc = document.getElementById('cc') as HTMLInputElement;
				cc.value = '';
				cc.focus();
				break;
			case 4:
				let bcc = document.getElementById('bcc') as HTMLInputElement;
				bcc.value = '';
				bcc.focus();
				break;

			default:
				break;
		}
	}
</script>

<div
	on:click={handleClick}
	on:keypress={handleClick}
	class:bg-[#E1E1E1]={selected}
	role="option"
	data-id={id}
	aria-selected="false"
	class="custom-option cursor-pointer"
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
