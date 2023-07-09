<script lang="ts">
	import { isSidebarOpened } from '$lib/stores/Sidebar-store';

	export let url: string;
	export let imgUrl: string;
	export let label: string;
	export let active = false;
	let hidden = true;
</script>

<div
	on:mouseenter={() => (hidden = false)}
	on:mouseleave={() => (hidden = true)}
	class:active
	class="px-2 my-1 w-full relative text-sm tooltip tooltip-bottom hover:bg-[#ffffff4d] hover:rounded-2xl"
	class:pl-4={$isSidebarOpened}
	data-tip={label}
>
	<a href={url}>
		<div class="flex gap-4  px-2 py-1 " class:justify-center={!$isSidebarOpened}>
			{#if imgUrl}
				<img src={imgUrl} width="20" alt={label} loading="lazy" />
			{/if}
			{#if $isSidebarOpened}
					<p>{label}</p>
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
</div>

<style>
	.active {
		background-color: rgba(255, 255, 255, 0.3);
		border-radius: 16px;
	}
</style>
