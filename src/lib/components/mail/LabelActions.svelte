<script>
	import { labelAction } from '$lib/stores/label-action-store';
	import { labelStore } from '$lib/stores/label-store';
	import { toast } from '$lib/stores/toast-store';

	async function handleRemoveLabel() {
		console.log($labelAction.id);
		const id = $labelAction.id;

		if (id === 0) {
			toast('warning', 'Error In Removing Label Try Again After Refreshing!');
			return;
		}
		try {
			const response = await fetch('/api/delete/label', {
				method: 'delete',
				body: JSON.stringify({ labelId: id })
			});

			if (response.ok) {
				const jsonResponse = await response.json();

				console.log(jsonResponse);

				labelStore.update((prev) => {
					return prev.filter((val) => val.id !== id);
				});

				console.log(jsonResponse);
                toast(jsonResponse.status == 200 ? 'success' : 'error', jsonResponse.message)
                
			} else {
				toast('warning', 'Error In Removing Label Try Again After Refreshing!');
			}
		} catch (error) {
			console.log(error);
			toast('error', 'Internal Server Error');
		}
	}
</script>

<div
	class="fixed bg-white w-24 h-20 z-[9999999999] rounded-md text-gray-700"
	style={`left: ${$labelAction.xDirection}px;top: ${$labelAction.yDirection}px`}
>
	<ul class="flex flex-col gap-1 px-2 pt-2">
		<li>Edit</li>
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<li on:click={handleRemoveLabel}>Remove</li>
	</ul>
</div>

<style>
	li:hover {
		background-color: rgba(219, 217, 217, 0.3);
		cursor: pointer;
	}

	li {
		padding: 2px 5px;
		border-radius: 10px;
	}
</style>
