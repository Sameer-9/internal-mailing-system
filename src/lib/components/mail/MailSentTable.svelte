<script lang="ts">
	import { sentConversations } from '$lib/stores/sent-conversations';
	import { MailSentTr } from './index';

	$: console.log($sentConversations);
</script>

<div class="text-zinc-400 font-sans table-fixed w-full min-h-[51vh]">
	{#if $sentConversations.length > 0}
		{#each $sentConversations as conv}
			<MailSentTr {...conv} />
		{/each}
	{:else}
		<div class="flex justify-center items-center py-2 bg-[#2e2e2e] mt-4">No Conversations</div>
	{/if}
</div>

<style>
	/* .grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	} */
</style>
