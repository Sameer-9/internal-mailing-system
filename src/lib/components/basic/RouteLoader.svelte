<script lang="ts">
	import { afterNavigate, beforeNavigate } from '$app/navigation';
	import { routeLoading } from '$lib/stores/loading-store';

	let timeout: NodeJS.Timeout;

	beforeNavigate(() => {
		// delay for loads > 250ms
		timeout = setTimeout(() => {
			routeLoading.set(true);
		}, 0);
	});

	afterNavigate(() => {
		// show for at least 400ms
		clearTimeout(timeout);
		setTimeout(() => {
			routeLoading.set(false);
		}, 400);
	});
</script>

<div
	class="gradient-loader fixed w-full top-0 left-0 h-1 opacity-0 -translate-x-full transition-all bg-gradient-to-r from-orange-500 via-purple-500 to-pink-500"
	class:show={$routeLoading}
/>

<style>
	.show {
		opacity: 1;
		--tw-translate-x: 0px;
		transform: translate(var(--tw-translate-x), var(--tw-translate-y)) rotate(var(--tw-rotate))
			skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x))
			scaleY(var(--tw-scale-y));
	}

	.gradient-loader {
		background-size: 200% 200%;
		animation: gradiant-move 1s infinite;
	}
	@keyframes gradiant-move {
		0% {
			background-position: left;
		}
		50% {
			background-position: right;
		}
		100% {
			background-position: left;
		}
	}
</style>
