<script>
	// @ts-nocheck
	import { Header, Sidebar } from '$lib/components/basic/index.js';
</script>

<Header />
<div class="p-2 flex gap-3">
	<Sidebar />
	<div id="main-content" class="flex-1">
		<slot />
	</div>
</div>

<style>
	#main-content {
		max-width: calc(100% - 224px);
	}
</style>
