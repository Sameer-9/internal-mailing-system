<script>
	export let isClossable = true;
</script>

<!-- The button to open modal -->
<label for="modal"><slot name="trigger" /></label>

<!-- Put this part before </body> tag -->
<input type="checkbox" id="modal" class="modal-toggle" />
<div class="modal text-zinc-200">
	<div class="modal-box ">
		<slot name="body"><!-- optional fallback --></slot>
		<div class="modal-action" class:hidden={!isClossable}>
			<label for="modal" class="btn">OK</label>
			<slot name="button"><!-- optional fallback --></slot>
		</div>
	</div>
</div>

<style>
</style>
