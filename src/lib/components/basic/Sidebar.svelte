<script>
	// @ts-nocheck
	import { isCreateModalOpen, isSidebarOpened, sidebarArray } from '$lib/stores/Sidebar-store';
	import { LabelLink, Link } from '$lib/components/basic/index.js';
	import { LabelActions } from '$lib/components/mail/index.js';
	import { page } from '$app/stores';
	import { labelStore } from '$lib/stores/label-store';
	import { onMount } from 'svelte';
	import { labelAction } from '$lib/stores/label-action-store';

	onMount(() => {
		// const width = window.innerWidth;
		// 	if (width <= 750) {
		// 		isSidebarOpened.set(false);
		// 	} else {
		// 		isSidebarOpened.set(true);
		// 	}

		window.addEventListener('resize', function (e) {
			// if(window.innerWidth)
			const width = window.innerWidth;
			if (width <= 750) {
				isSidebarOpened.set(false);
			} else {
				isSidebarOpened.set(true);
			}
		});
	});
</script>

<aside class="h-full text-white min-w-[60px]" class:w-[224px]={$isSidebarOpened}>
	<div class="border-b-2 border-zinc-400 pb-4 pl-4">
		<button
			class="px-5 py-4 bg-white text-gray-500 font-semibold rounded-2xl"
			on:click={() => ($isCreateModalOpen = true)}
		>
			<div class="flex gap-2">
				<img src="/images/pencil.png" width="20" alt="Compose" />
				{#if $isSidebarOpened}
					<p>Compose</p>
				{/if}
			</div>
		</button>
	</div>
	<div class="pt-3" id="overflow-sidebar">
		<ul class="gap-1 flex flex-col font-bold text-gray-300 w-[90%]">
			{#each $sidebarArray as data}
				<Link
					active={$page.route?.id?.includes(data.url)}
					label={data.name}
					url={data.url}
					imgUrl={data.icon}
				/>
			{/each}

			<div class="pl-3 pt-2 text-lg flex font-sans justify-between">
				{#if $isSidebarOpened}
					<pe>Label</pe>
				{/if}
				<label for="label-modal">
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
				</label>
			</div>
			<div class="p-0 text-sm w-full">
				<ul class="gap-1 flex flex-col font-bold text-gray-300 w-full pl-5">
					{#each $labelStore as label}
						<LabelLink
							id={label?.id}
							active={$page.route?.id?.includes(label.id)}
							label={label?.name ?? ''}
							color={label?.color ?? ''}
						/>
					{/each}
				</ul>
			</div>
		</ul>
	</div>
</aside>

{#if $labelAction.isVisible}
	<LabelActions />
{/if}

<style>
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

	#overflow-sidebar {
		padding-bottom: 30px;
		max-height: 75vh;
		min-height: 75vh;
		display: flex;
		flex-direction: column;
		overflow-y: auto;
		overflow-x: hidden;
	}

	::-webkit-scrollbar-track {
		cursor: pointer;
		-webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
		border-radius: 0px;
		background-color: rgba(241, 243, 244, 0.2);
	}

	::-webkit-scrollbar {
		width: 6px;
		background-color: #111111;
		cursor: pointer;
	}

	::-webkit-scrollbar-thumb {
		cursor: pointer;
		border-radius: 10px;
		-webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
		background-color: #696969;
	}
</style>
