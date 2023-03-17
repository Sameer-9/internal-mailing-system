<script>
// @ts-nocheck

	import { Link, Modal } from '$lib/components/basic/index.js';
	import { page } from '$app/stores';
	import { enhance } from '$app/forms';

	const dummyData = [
		{
			url: '/user/inbox',
			label: 'Inbox',
			icon: '/images/inbox.png'
		},
		{
			url: '/user/starred',
			label: 'Starred',
			icon: '/images/star.png'
		},
		{
			url: '/user/sent',
			label: 'Sent',
			icon: '/images/sent.png'
		},
		{
			url: '/user/drafts',
			label: 'Drafts',
			icon: '/images/draft.png'
		},
		{
			url: '/user/scheduled',
			label: 'Scheduled',
			icon: '/images/scheduled.png'
		},
		{
			url: '/user/spam',
			label: 'Spam',
			icon: '/images/spam.png'
		},
		{
			url: '/user/trash',
			label: 'trash',
			icon: '/images/trash.png'
		}
	];
</script>

<aside class="h-full text-white">
	<button class="px-5 py-4 bg-white text-gray-500 font-semibold rounded-2xl">
		<div class="flex gap-2">
			<img src="/images/pencil.png" width="20" alt="Compose" />
			<p>Compose</p>
		</div>
	</button>
	<div class="pt-5">
		<ul
			class="gap-1 flex flex-col font-bold text-gray-300 w-full"
			data-sveltekit-preload-data="hover"
		>
			{#each dummyData as data}
				<Link
					active={$page.route?.id?.includes(data.url)}
					label={data.label}
					url={data.url}
					imgUrl={data.icon}
				/>
			{/each}
			<div class="pl-3 pt-4 text-lg font-sans flex justify-between">
				<p>Label</p>
				
                <Modal isClossable={false}>
                    <div slot="trigger">
                        <div class="tooltip tooltip-bottom" data-tip="Add Label">
                            <div class="add-label">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                    stroke-width="1.5"
                                    stroke="currentColor"
                                >
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    <div slot="body" class="text-zinc-800">
                        <h5>Add Label</h5>
                        <form action="/api/add-label" method="post" use:enhance>
                            <label for="label-name" class="label-text-alt text-zinc-800">Please Enter a new Label Name</label>
                            <input type="text" name="label-name" id="label-name" class="input-md input-ghost w-full bg-inherit border border-gray-600">
                            <div class="flex gap-4 mt-4 justify-end">
                                <label for="modal" class="btn btn-sm">
                                    Cancel
                                </label>
                                <button type="submit" class="btn btn-sm btn-success">
                                    Submit
                                </button>
                            </div>
                        </form>
                    </div>
                </Modal>
			</div>
		</ul>
	</div>
</aside>

<style>
	aside {
		width: 224px !important;
	}

	.add-label {
		position: relative;
		z-index: 1 !important;
		cursor: pointer;
		height: 30px;
		width: 30px;
	}

	.add-label::before {
		content: '';
		color: white;
		display: inline-block;
		position: absolute;
		width: 30px;
		height: 30px;
		-moz-border-radius: 50%;
		border-radius: 50%;
		background-color: rgba(255, 255, 255, 0.4);
		opacity: 0.8;
		right: 0;
		top: 0;
		bottom: 0;
		z-index: -2;
		visibility: hidden;
	}

	.add-label:hover.add-label::before {
		visibility: visible;
	}
</style>
            