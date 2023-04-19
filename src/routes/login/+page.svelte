<script>
	import { enhance } from '$app/forms';
	export let form;
	let showPassword = false;
	$: form && console.log(form);
</script>

<div class="bg-slate-700 w-full h-[100vh] m-0 flex items-center justify-center overflow-y-auto">
	<div
		class="md:w-3/4 sm:w-full h-full flex  sm:flex-col-reverse md:flex-row items-center justify-center"
	>
		<div class="bg-[#FFFFFF] md:rounded-l-lg md:w-2/4 max-sm:w-full h-[90%]">
			<div class="pt-16 w-3/4 m-auto">
				<h1 class="text-3xl text-gray-800 font-semibold font-sans">Welcome Back</h1>
				<p class="text-gray-600 text-xs mt-3">Welcome back! please enter your details.</p>
				<div class="pt-3">
					<form action="?/login" method="post" use:enhance>
						<label for="username" class="label">
							<span class="label-text">Username</span>
						</label>
						<input
							id="email"
							class="input bg-white text-black input-bordered w-full max-w-xs"
							type="email"
							name="email"
							placeholder="Enter your Email"
						/>
						<p class="text-error text-sm">{form?.email ?? ''}</p>
						<label class="label mt-2" for="password">
							<span class="label-text">Password</span>
						</label>
						<div class="relative inline-block w-full max-w-xs">
							<input
								id="password"
								class="input bg-white text-black w-full max-w-xs input-bordered "
								type={showPassword ? 'text' : 'password'}
								name="password"
								placeholder={showPassword ? 'Enter Password' : '••••••••••'}
							/>
							<button type="button" on:click={() => (showPassword = !showPassword)}>
								<i class="absolute right-0 top-0 p-3">
									{#if showPassword}
										<svg
											xmlns="http://www.w3.org/2000/svg"
											fill="none"
											viewBox="0 0 24 24"
											stroke-width="1.5"
											stroke="currentColor"
											class="w-6 h-6"
										>
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
											/>
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
											/>
										</svg>
									{:else}
										<svg
											xmlns="http://www.w3.org/2000/svg"
											fill="none"
											viewBox="0 0 24 24"
											stroke-width="1.5"
											stroke="currentColor"
											class="w-6 h-6"
										>
											<path
												stroke-linecap="round"
												stroke-linejoin="round"
												d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"
											/>
										</svg>
									{/if}
								</i>
							</button>
						</div>
						<p class="text-error text-sm">{form?.password ?? ''}</p>
						<p
							class="w-full mt-2 max-w-xs font-bold text-right text-sm text-purple-500 hover:text-purple-700"
						>
							<a href="/forgot-password">Forgot password</a>
						</p>
						<button class="w-full mt-2 max-w-xs btn bg-purple-500 hover:bg-purple-700"
							>Sign In</button
						>
						<p class="text-error text-center font-semibold">{form?.message ?? ''}</p>
					</form>

					<p class="text-center text-sm pt-5">
						Don't have an account? <a class="text-purple-500 font-bold" href="/register">Sign Up</a>
					</p>
				</div>
			</div>
		</div>
		<div class="img md:w-2/4 md:h-[90%] sm:h-[30%] md:rounded-r-lg" />
	</div>
	<!-- <img src="/images/login-bg2.png" alt="Login Background"> -->
</div>

<style>
	.img {
		background-image: url('/images/login-bg2.png');
		background-position: center;
		background-repeat: no-repeat;
		background-size: cover;
	}
</style>
