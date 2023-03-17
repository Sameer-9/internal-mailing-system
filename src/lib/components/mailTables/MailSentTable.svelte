<script>
	import { MailSentTr } from './index';
</script>

<table class="text-zinc-400 font-sans table-fixed w-full min-h-[75vh]">
	<MailSentTr isStarred={true} />
	<MailSentTr />
	<MailSentTr isStarred={true} />
	<MailSentTr />
	<MailSentTr isStarred={true} />
	<MailSentTr />
	<MailSentTr />
	<MailSentTr />
	<MailSentTr />
	<MailSentTr />
</table>
<div class="table-last-child w-full h-24 grey-md" />

<style>
	.grey-md {
		background-color: rgba(241, 243, 244, 0.2);
	}

	.table-last-child {
		border-bottom-right-radius: 20px;
		border-bottom-left-radius: 20px;
	}
</style>
