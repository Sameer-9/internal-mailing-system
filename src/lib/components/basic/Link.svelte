<script>
	import { isSidebarOpened } from '$lib/stores/Sidebar-store';
	// import { fade, fly, slide } from 'svelte/transition';

	export let url = '';
	export let imgUrl = '';
	export let label = '';
	export let active = false;
	let hidden = true;
</script>

<a
	href={url}
	on:mouseenter={() => (hidden = false)}
	on:mouseleave={() => (hidden = true)}
	class="px-2 py-1 relative text-sm tooltip tooltip-right"
>
	<div
		class="flex gap-4 hover:bg-[#ffffff4d] hover:rounded-2xl px-2 py-1 "
		class:active
		class:justify-center={!$isSidebarOpened}
	>
		{#if imgUrl}
			<img src={imgUrl} alt={label} />
		{/if}
		{#if $isSidebarOpened}
			<li>
				<p>{label}</p>
			</li>
		{/if}
	</div>
	<!-- {#if !hidden}
		<div
			in:fly={{ x: 100, duration: 300 }}
			out:fade
			class="fixed right-0 translate-x-full ml-3 top-2 md-transparent px-2 z-[999999999] bg-red-800"
		>
			{label}
		</div>
	{/if} -->
</a>

<style>
	.active {
		background-color: rgba(255, 255, 255, 0.3);
		border-radius: 16px;
	}
</style>
