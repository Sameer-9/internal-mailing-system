<script>
	// @ts-nocheck
	import { Header, Sidebar } from '$lib/components/basic/index.js';
	import { toast, toastStore } from '$lib/stores/toast-store';

	let labelName = '';
	let labelError = null;
	let closeModalBtn;
	async function handleSubmit() {
		try {
			const res = await fetch('/api/add-label', {
				method: 'POST',
				body: JSON.stringify({ labelName: labelName })
			});
			const json = await res.json();
			if (res.ok) {
				console.log('RESPONSE:::::', json);
				labelError = null;
				closeModalBtn.click();
				labelName = '';
				toast('success', 'Label Added Successfully');
			} else {
				console.log('ERROR HANDLES::::::', json);
				toast('error', json?.message);
				labelError = json?.message;
			}
		} catch (err) {
			alert(err);
		}
	}

	$: console.log($toastStore);
</script>

{#if $toastStore?.type}
	<div class="toast toast-top toast-end z-[9999999999]">
		<div class="alert alert-{$toastStore.type}">
			<div>
				<span>{$toastStore.message}</span>
			</div>
		</div>
	</div>
{/if}
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
