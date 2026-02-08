<script lang="ts">
    import { fly } from "svelte/transition";
    import { LL } from "../../../i18n/i18n-svelte";
    import { mapEditorShortcutOverlayStore } from "../../Stores/MapEditorShortcutOverlayStore";
    import ButtonClose from "../Input/ButtonClose.svelte";

    const sections = [
        {
            title: $LL.mapEditor.shortcutOverlay.sections.tools(),
            items: [
                { label: $LL.mapEditor.shortcutOverlay.items.explore(), keys: "1" },
                { label: $LL.mapEditor.shortcutOverlay.items.areaEditor(), keys: "2" },
                { label: $LL.mapEditor.shortcutOverlay.items.entityEditor(), keys: "3" },
                { label: $LL.mapEditor.shortcutOverlay.items.wamSettings(), keys: "4" },
                { label: $LL.mapEditor.shortcutOverlay.items.trash(), keys: "5" },
                { label: $LL.mapEditor.shortcutOverlay.items.closeEditor(), keys: "`" },
            ],
        },
        {
            title: $LL.mapEditor.shortcutOverlay.sections.editing(),
            items: [
                { label: $LL.mapEditor.shortcutOverlay.items.undo(), keys: "Ctrl/Cmd + Z" },
                { label: $LL.mapEditor.shortcutOverlay.items.redo(), keys: "Ctrl/Cmd + Shift + Z" },
                { label: $LL.mapEditor.shortcutOverlay.items.delete(), keys: "Delete / Backspace" },
                { label: $LL.mapEditor.shortcutOverlay.items.copyDrag(), keys: "Ctrl/Cmd + Drag" },
            ],
        },
        {
            title: $LL.mapEditor.shortcutOverlay.sections.canvas(),
            items: [
                { label: $LL.mapEditor.shortcutOverlay.items.snapGrid(), keys: "Shift (hold)" },
                { label: $LL.mapEditor.shortcutOverlay.items.zoom(), keys: "Mouse wheel" },
            ],
        },
    ];

    function close() {
        mapEditorShortcutOverlayStore.set(false);
    }
</script>

<div class="absolute inset-0 z-[2500] pointer-events-auto flex items-center justify-center">
    <div class="absolute inset-0 bg-black/40" on:click={close} />
    <div
        class="relative bg-contrast/80 backdrop-blur-md rounded-2xl p-6 w-full max-w-2xl text-white"
        in:fly={{ x: 50, duration: 200 }}
        out:fly={{ x: 50, duration: 150 }}
    >
        <div class="absolute top-3 right-3">
            <ButtonClose on:click={close} size="sm" />
        </div>
        <div class="flex items-center justify-between mb-4">
            <h3 class="m-0 text-xl">{$LL.mapEditor.shortcutOverlay.title()}</h3>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            {#each sections as section}
                <div class="space-y-3">
                    <h4 class="m-0 text-sm uppercase tracking-wide opacity-70">{section.title}</h4>
                    <div class="space-y-2">
                        {#each section.items as item}
                            <div class="flex items-center justify-between gap-4 text-sm">
                                <span class="opacity-90">{item.label}</span>
                                <span class="rounded bg-white/10 px-2 py-1 text-xs font-mono">{item.keys}</span>
                            </div>
                        {/each}
                    </div>
                </div>
            {/each}
        </div>
        <div class="mt-4 text-xs opacity-60">{$LL.mapEditor.shortcutOverlay.closeHint()}</div>
    </div>
</div>
