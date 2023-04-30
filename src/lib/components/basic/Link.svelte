<script>
	import { isSidebarOpened } from '$lib/stores/Sidebar-store';
	import { fade, fly } from 'svelte/transition';
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
	class:active
	class="px-2 my-1 relative text-sm tooltip tooltip-bottom hover:bg-[#ffffff4d] hover:rounded-2xl"
	class:pl-4={$isSidebarOpened}
	data-tip={label}
>
	<div class="flex gap-4  px-2 py-1 " class:justify-center={!$isSidebarOpened}>
		{#if imgUrl}
			<img src={imgUrl} width="20" alt={label} />
		{/if}
		{#if $isSidebarOpened}
			<li>
				<p>{label}</p>
			</li>
		{/if}
	</div>
	<!-- {#if !hidden}
		<div
			in:fly={{ x: -100, duration: 300 }}
			out:fade
			class="fixed right-10 translate-x-full ml-3 top-2 md-transparent px-2 z-[999999999] bg-red-800"
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
