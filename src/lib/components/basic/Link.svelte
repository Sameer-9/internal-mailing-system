<script>
	import { fade, fly } from 'svelte/transition';

	export let url = '';
	export let imgUrl = '';
	export let label = '';
	export let active = false;
	let hidden = true;
</script>

<a
	class:active
	href={url}
	on:mouseenter={() => (hidden = false)}
	on:mouseleave={() => (hidden = true)}
	class="hover:bg-zinc-700 hover:rounded-2xl px-2 py-1 relative"
>
	<div class="flex gap-4">
		<img src={imgUrl} alt={label} />
		<li>
			{label}
		</li>
	</div>
	{#if !hidden}
		<div
			in:fly={{ x: 100, duration: 300 }}
			out:fade
			class="absolute right-0 translate-x-full ml-3 top-2 md-transparent px-2"
		>
			{label}
		</div>
	{/if}
</a>

<style>
	.md-transparent {
		background-color: rgba(255, 255, 255, 0.2);
	}

	.active {
		background-color: rgba(255, 255, 255, 0.3);
		border-radius: 10px;
	}
</style>
