<script>
	import { isSidebarOpened } from '$lib/stores/Sidebar-store';

	export let id = '';
	export let active = '';
	export let label = '';
	export let color = '#FF0000';
	let hidden = false;
</script>

<a	
	href="/user/label/{id}"
	on:mouseenter={() => (hidden = false)}
	on:mouseleave={() => (hidden = true)}
	class="px-2 py-1 relative text-sm tooltip tooltip-right w-full"
> 
	<div
		class="flex gap-4 hover:bg-[#ffffff4d] hover:rounded-md px-2 py-1"
		class:active
		class:justify-center={!$isSidebarOpened}
	>
	<svg xmlns="http://www.w3.org/2000/svg" fill="{color}" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
		<path stroke-linecap="round" stroke-linejoin="round" d="M9.568 3H5.25A2.25 2.25 0 003 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 005.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 009.568 3z" />
		<path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6z" />
	  </svg>
		{#if $isSidebarOpened}
			<li>
				<p class="text-ellipsis whitespace-nowrap overflow-hidden w-[100px]">{label} Lorem ipsum dolor sit amet consectetur adipisicing elit. Quis impedit ad voluptates molestias accusamus. Aliquam adipisci incidunt vitae minima excepturi, maxime molestias ipsa assumenda possimus placeat in, consequuntur, sequi sapiente!</p>
			</li>
		{/if}
	</div>
</a>

<style>
	.active {
		background-color: rgba(255, 255, 255, 0.3);
		border-radius: 6px;
	}
</style>
