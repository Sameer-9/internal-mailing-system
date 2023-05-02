<script>
	// @ts-nocheck

	import { isSidebarOpened } from '$lib/stores/Sidebar-store';
	import { userStore } from '$lib/stores/user-store';
	import { isProfileDropdownOpen } from '$lib/stores/userSelection-store';
	let inputFocus = false;
	function handleClick() {
		isSidebarOpened.set(!$isSidebarOpened);
	}
</script>

<header class="h-16 p-2 flex gap-3 text-gray-300">
	<div class="lg:w-56 w-46 md:w-64 sm:w-56 flex-none flex items-center">
		<button
			class:opened={!$isSidebarOpened}
			class="menu"
			on:click={handleClick}
			aria-label="Main Menu"
		>
			<svg width="30" height="60" viewBox="0 0 100 100">
				<path
					class="line line1"
					d="M 20,29.000046 H 80.000231 C 80.000231,29.000046 94.498839,28.817352 94.532987,66.711331 94.543142,77.980673 90.966081,81.670246 85.259173,81.668997 79.552261,81.667751 75.000211,74.999942 75.000211,74.999942 L 25.000021,25.000058"
				/>
				<path class="line line2" d="M 20,50 H 80" />
				<path
					class="line line3"
					d="M 20,70.999954 H 80.000231 C 80.000231,70.999954 94.498839,71.182648 94.532987,33.288669 94.543142,22.019327 90.966081,18.329754 85.259173,18.331003 79.552261,18.332249 75.000211,25.000058 75.000211,25.000058 L 25.000021,74.999942"
				/>
			</svg>
		</button>
		<p class="text-gray-200 font-bold text-2xl flex-1 md:min-w-[128px] lg:min-w-[128px] sm:min-w-[80px] min-w-[60px] pl-6 font-sans">
			<img src="/images/logo3.png" class="md:w-32 lg:w-32 sm:w-20 w-16 h-14 rounded-lg" alt="" />
		</p>
	</div>
	<div class="flex-1">
		<div
			class:grey-md={!inputFocus}
			class="md:w-3/4 lg:w-3/4 sm:w-full w-full max-w-[600px] min-w-[150px] bg-white h-full rounded-lg px-2 flex items-center"
			class:text-black={inputFocus}
			class:bg-white={inputFocus}
		>
			<div class="w-full h-full flex items-center">
				<div class="mt-2">
					<button>
						<svg
							focusable="false"
							height="24px"
							viewBox="0 0 24 24"
							width="24px"
							xmlns="http://www.w3.org/2000/svg"
							><path
								d="M20.49,19l-5.73-5.73C15.53,12.2,16,10.91,16,9.5C16,5.91,13.09,3,9.5,3S3,5.91,3,9.5C3,13.09,5.91,16,9.5,16 c1.41,0,2.7-0.47,3.77-1.24L19,20.49L20.49,19z M5,9.5C5,7.01,7.01,5,9.5,5S14,7.01,14,9.5S11.99,14,9.5,14S5,11.99,5,9.5z"
							/><path d="M0,0h24v24H0V0z" fill="none" /></svg
						>
					</button>
				</div>
				<div class="flex-1 pl-3">
					<input
						type="search"
						placeholder="Search..."
						class="py-2 bg-inherit w-full h-full border-none outline-none"
						on:blur={() => (inputFocus = !inputFocus)}
						on:focus={() => (inputFocus = !inputFocus)}
					/>
				</div>
				<div class="mt-2">
					<button>
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
							><path
								d="M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z"
							/></svg
						>
					</button>
				</div>
			</div>
		</div>
	</div>
	<div class="flex-none md:w-32 lg:w-32 sm:w-16 w-12 flex justify-center lg:pr-3 md:pr-3">
		<button
			class="btn btn-ghost btn-circle avatar"
			on:click={() => isProfileDropdownOpen.set(!$isProfileDropdownOpen)}
		>
			<div class="w-10 rounded-full">
				<img src={$userStore?.profile_photo} alt="profle" id="profile-photo" />
			</div>
		</button>
	</div>
</header>

<style>
	header {
		max-width: 100vw;
		max-width: 100dvw;
	}
	.menu {
		background-color: transparent;
		border: none;
		cursor: pointer;
		display: flex;
		padding: 0;
	}
	.line {
		fill: none;
		stroke: white;
		stroke-width: 6;
		transition: stroke-dasharray 600ms cubic-bezier(0.4, 0, 0.2, 1),
			stroke-dashoffset 600ms cubic-bezier(0.4, 0, 0.2, 1);
	}
	.line1 {
		stroke-dasharray: 60 207;
		stroke-width: 6;
	}
	.line2 {
		stroke-dasharray: 60 60;
		stroke-width: 6;
	}
	.line3 {
		stroke-dasharray: 60 207;
		stroke-width: 6;
	}
	.opened .line1 {
		stroke-dasharray: 90 207;
		stroke-dashoffset: -134;
		stroke-width: 6;
	}
	.opened .line2 {
		stroke-dasharray: 1 60;
		stroke-dashoffset: -30;
		stroke-width: 6;
	}
	.opened .line3 {
		stroke-dasharray: 90 207;
		stroke-dashoffset: -134;
		stroke-width: 6;
	}

	.grey-md {
		background-color: rgba(241, 243, 244, 0.24);
	}

	header svg {
		fill: currentColor;
	}

	::placeholder {
		font-weight: 600;
	}
</style>
