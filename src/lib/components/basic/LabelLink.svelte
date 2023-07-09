<script lang="ts">
	import { isSidebarOpened } from '$lib/stores/Sidebar-store';
	import { labelAction } from '$lib/stores/label-action-store';
	import { onMount } from 'svelte';

	export let id: number;
	export let active: boolean;
	export let label: string;
	export let color = '#FF0000';
	let hidden = false;

	function LabelActionClick(e: Event) {
		const clickedElement = e.target as HTMLElement;
		const { top, left, bottom } = clickedElement.getBoundingClientRect();

		labelAction.set({
			isVisible: true,
			xDirection: left + 20,
			yDirection: top - 50,
			id: id
		});
	}

	onMount(() => {
		document.addEventListener('click', (e) => {
			const element = e.target as HTMLElement;
			if (element.classList.contains('label-action')) return;
			labelAction.set({
				isVisible: false,
				xDirection: 0,
				yDirection: 0,
				id: 0
			});
		});
	});
</script>

<div
	on:mouseenter={() => (hidden = false)}
	on:mouseleave={() => (hidden = true)}
	class:active
	class="px-2 py-1 relative text-sm tooltip tooltip-right w-full flex hover:bg-[#ffffff4d] hover:rounded-3xl"
>
	<a href="/user/label/{id}">
		<div class="flex  px-2 py-1 gap-2" class:justify-center={!$isSidebarOpened}>
			<svg
				aria-label={label}
				xmlns="http://www.w3.org/2000/svg"
				fill={color}
				viewBox="0 0 24 24"
				stroke-width="1.5"
				stroke="currentColor"
				class="w-6 h-6"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M9.568 3H5.25A2.25 2.25 0 003 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 005.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 009.568 3z"
				/>
				<path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6z" />
			</svg>
			{#if $isSidebarOpened}
				<li class="list-none">
					<p class="text-ellipsis whitespace-nowrap overflow-hidden w-[90px]">{label}</p>
				</li>
			{/if}
		</div>
	</a>
	<div
		class="flex justify-center items-center label-action"
		on:keypress={(e) => LabelActionClick(e)}
		on:click={(e) => LabelActionClick(e)}
	>
		<div
			class="hover:bg-zinc-500 rounded-full hover:cursor-pointer py-1 tooltip tooltip-bottom label-action"
			data-tip="More"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				stroke-width={3.5}
				stroke="currentColor"
				class="w-6 h-4 label-action"
			>
				<path
					class="label-action"
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M12 6.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 12.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 18.75a.75.75 0 110-1.5.75.75 0 010 1.5z"
				/>
			</svg>
		</div>
	</div>
</div>

<style>
	.active {
		background-color: rgba(255, 255, 255, 0.3);
		border-radius: 6px;
	}
</style>
