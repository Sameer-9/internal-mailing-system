<script lang="ts">
	import { RouteLoader } from '$lib/components/basic';
	import { toastStore } from '$lib/stores/toast-store';
	import '../app.css';
</script>

<RouteLoader />
{#if $toastStore?.type}
	<div class="toast toast-top toast-end z-[9999999999]">
		<div class="alert alert-{$toastStore.type}">
			<div>
				<span>{$toastStore.message}</span>
			</div>
		</div>
	</div>
{/if}
<slot />
