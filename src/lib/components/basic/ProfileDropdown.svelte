<script>
	import { userStore } from '$lib/stores/user-store';
	import { backInOut } from 'svelte/easing';
	import { scale } from 'svelte/transition';
</script>

<div
	id="profile-dropdown"
	class="fixed rounded-2xl md:right-[50px] sm:right-14 right-14 lg:right-[45px] z-[9999999999] top-16 lg:w-80 md:w-64 w-52 bg-white min-h-[220px] text-gray-800 shadow"
	transition:scale={{ delay: 0, duration: 600, easing: backInOut }}
>
	<div class="bg-gray-100 rounded-2xl min-h-[100px]  border border-b-2 outline-gray-200 flex">
		<div class="flex-none w-20 flex justify-center items-center">
			<div class="btn btn-lg btn-ghost btn-circle avatar">
				<div class="w-full rounded-full">
					<img src={$userStore?.profile_photo} alt="profle" />
				</div>
			</div>
		</div>
		<div class="flex-1 flex justify-center items-center">
			<div class="flex flex-col">
				<div
					class="lg:text-xl text-sm md:text-lg font-semibold break-words"
					style="line-height: 1.5;"
				>
					{$userStore.first_name}
					{$userStore.last_name}
				</div>
				<div
					class="badge badge-[#2e2e2e] sm:text-[7px] md:text-sm lg:text-sm text-[7px] text-white break-words"
					style="line-height: 1;"
				>
					{$userStore.email}
				</div>
				<div class="flex gap-1 items-center pt-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="1.5"
						stroke="currentColor"
						class="w-4 h-4"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 00.75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 00-3.413-.387m4.5 8.006c-.194.165-.42.295-.673.38A23.978 23.978 0 0112 15.75c-2.648 0-5.195-.429-7.577-1.22a2.016 2.016 0 01-.673-.38m0 0A2.18 2.18 0 013 12.489V8.706c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 013.413-.387m7.5 0V5.25A2.25 2.25 0 0013.5 3h-3a2.25 2.25 0 00-2.25 2.25v.894m7.5 0a48.667 48.667 0 00-7.5 0M12 12.75h.008v.008H12v-.008z"
						/>
					</svg>
					<p
						class="font-semibold font-serif text-xs text-gray-600 break-words"
						style="line-height: 1;"
					>
						{$userStore.designation}
					</p>
				</div>
			</div>
		</div>
	</div>
	<ul class="menu menu-compact dropdown-content mt-3 p-2  rounded-box w-full">
		<li>
			<a class="flex gap-3" href="/user/update-profile"
				><img src="/images/profile.png" class="w-6 h-6" alt="Update Profile" /> Profile
			</a>
		</li>
		<li>
			<a href="/logout" class="flex gap-3"
				><img src="/images/logout.png" class="w-6 h-6" alt="Logout" />Logout</a
			>
		</li>
	</ul>
</div>

<style>
	#profile-dropdown::before {
		content: '';
		position: absolute;
		top: -7px;
		left: 90%;
		transform: translateX(-50%) rotate(-45deg);
		width: 15px;
		height: 15px;
		background-color: rgb(243 244 246 / var(--tw-bg-opacity));
	}
</style>
