<script lang="ts">
    import { slide } from "svelte/transition";
    import { IconChevronRight } from "@wa-icons";

    export let title: string;
    export let defaultOpen = false;

    let isOpen = defaultOpen;

    function toggle() {
        isOpen = !isOpen;
    }
</script>

<div class="rounded-xl border border-white/10 bg-white/5">
    <button
        class="w-full flex items-center justify-between gap-2 px-3 py-2 text-left"
        on:click={toggle}
        type="button"
    >
        <span class="text-sm font-semibold tracking-wide uppercase opacity-80">{title}</span>
        <IconChevronRight class={`transition-transform ${isOpen ? "rotate-90" : ""}`} />
    </button>
    {#if isOpen}
        <div class="px-2 pb-2" transition:slide>
            <slot />
        </div>
    {/if}
</div>
