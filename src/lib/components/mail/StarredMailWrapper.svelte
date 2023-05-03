<script>
	import { starredConversations } from '$lib/stores/starred-conversations';
	import { MailTr } from '.';
</script>

<div class="text-zinc-400 font-sans table-fixed w-full min-h-[51vh]">
	{#if $starredConversations.length > 0}
		{#each $starredConversations as conversation}
			<MailTr {...conversation} />
		{/each}
	{:else}
		<div class="flex justify-center items-center py-2 bg-[#2e2e2e] mt-4">
			No Starred Conversations
		</div>
	{/if}
</div>

<style>
	/* .grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	} */
</style>
