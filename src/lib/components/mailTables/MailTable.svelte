<script>
	import { MailTr } from './index';
	import { inboxConversations } from '$lib/stores/inbox-conversation';
</script>

<div class="text-zinc-400 font-sans table-fixed w-full min-h-[51vh]">
	{#each $inboxConversations as conversation}
		<MailTr {...conversation}/>
	{/each}
</div>

<style>
	/* .grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	} */
</style>
