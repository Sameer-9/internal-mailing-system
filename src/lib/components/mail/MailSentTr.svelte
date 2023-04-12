<script>
	export let isStarred = false;
	export let isRead = false;
	let isHover = false;
</script>

<tr
	class="p-2 max-w-[100%] grid grid-flow-col-dense hover:cursor-pointer"
	on:mouseleave={() => (isHover = false)}
	on:mouseenter={() => (isHover = true)}
	class:is-read={isRead}
>
	<td class="w-10 flex" class:drag={isHover}>
		<div class="checkbox-div">
			<input type="checkbox" class="checkbox h-3 w-3 rounded-sm" class:active={isHover} />
		</div>
	</td>
	<td class="ml-2">
		<button
			class="tooltip tooltip-bottom"
			data-tip={isStarred ? 'Starred' : 'Not starred'}
			class:active={isHover}
			on:click={() => (isStarred = !isStarred)}
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill={isStarred ? 'orange' : 'none'}
				viewBox="0 0 24 24"
				stroke-width="1.5"
				stroke="currentColor"
				class="w-4 h-4"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"
				/>
			</svg>
		</button>
	</td>
	<td> &nbsp;&nbsp; </td>
	<td
		class="sender-name w-24 md:w-40 sm:w-32 sm:whitespace-normal md:whitespace-nowrap min-w-[70px] text-sm"
		>To: Sender Name LONG vsadvbslvbsdvbksbvksvklvksdb</td
	>
	<td> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
	<td class="message">
		<div class="flex">
			<div class="subject text-sm">ex est quam delectus doloremque eum earum sed. Nemo, eaque.</div>
			<span>&nbsp;&nbsp;&nbsp; &dash; &nbsp;&nbsp;&nbsp;</span>
			<span class="text-sm"
				>Lorem ipsum dolor sit, amet consectetur adipisicing elit. Necessitatibus magni iste vero
				velit aspernatur dolore labore quod asperiores quae recusandae,</span
			>
		</div>
	</td>
	<td> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
	<td class="flex gap-1" class:hidden={!isHover}>
		<div
			class="hover:bg-zinc-500 rounded-full hover:cursor-pointer px-1 tooltip tooltip-bottom"
			data-tip="Archive"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				stroke-width="1.5"
				stroke="currentColor"
				class="w-5 h-5"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M20.25 7.5l-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 2.25 0 01-2.247-2.118L3.75 7.5m8.25 3v6.75m0 0l-3-3m3 3l3-3M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z"
				/>
			</svg>
		</div>
		<div
			class="hover:bg-zinc-500 rounded-full hover:cursor-pointer px-1 tooltip tooltip-bottom"
			data-tip="Delete"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				stroke-width="1.5"
				stroke="currentColor"
				class="w-5 h-5"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
				/>
			</svg>
		</div>
		<div
			class="hover:bg-zinc-500 rounded-full hover:cursor-pointer px-1 tooltip tooltip-bottom"
			data-tip="Mark as read"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				stroke-width="1.5"
				stroke="currentColor"
				class="w-5 h-5"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
				/>
			</svg>
		</div>
	</td>
	<td> &nbsp;&nbsp;&nbsp; </td>
	<td class="float-right pr-4 font-bold text-xs text-zinc-500 whitespace-nowrap time">Mar 15</td>
</tr>

<style>
	input[type='checkbox'] {
		outline: 2px solid rgba(255, 255, 255, 0.4);
		z-index: 4 !important;
	}

	.checkbox-div {
		margin-left: 17px;
	}

	.drag::before {
		content: '';
		background-image: url('/images/drag.png');
		position: absolute;
		display: inline-block;
		width: 20px;
		height: 20px;
		background-repeat: no-repeat;
		cursor: grab;
		z-index: -1 !important;
		left: 0;
		margin-top: 2px;
	}

	input[type='checkbox'].active {
		outline: 2px solid white !important;
	}

	button.active svg {
		stroke: white !important;
		stroke-width: 1.5px;
	}

	tr {
		/* border-bottom: 1px solid rgba(255,255,255,0.2); */
		outline-width: 1px;
		outline-style: solid;
		outline-color: rgba(255, 255, 255, 0.2);
		padding: 8px;
		position: relative;
	}

	tr:hover {
		box-shadow: inset 1px 0 0 rgb(255 255 255 / 20%), inset -1px 0 0 rgb(255 255 255 / 20%),
			0 0 4px 0 rgb(95 99 104 / 60%), 0 0 6px 2px rgb(95 99 104 / 60%);
		z-index: 2;
	}

	.message {
		max-width: 100%;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.sender-name {
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}

	.is-read {
		background-color: rgba(241, 243, 244, 0.2);
		font-weight: 700;
		font-family: sans-serif;
	}

	.is-read .subject,
	.is-read .sender-name,
	.is-read .time {
		color: white;
	}
</style>
