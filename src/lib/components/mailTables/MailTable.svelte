<script>
	import { MailTr } from './index';
	import { inboxConversations } from '$lib/stores/inbox-conversation';
</script>

<div class="text-zinc-400 font-sans table-fixed w-full min-h-[51vh]">
	{#if $inboxConversations}
		{#each $inboxConversations as conversation}
			<MailTr {...conversation} />
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
