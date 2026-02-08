<script lang="ts">
    import { onDestroy } from "svelte";
    import { LL } from "../../../i18n/i18n-svelte";
    import { mapEditorUndoToastStore } from "../../Stores/MapEditorUndoToastStore";
    import { gameManager } from "../../Phaser/Game/GameManager";

    let timeoutId: ReturnType<typeof setTimeout> | undefined;

    $: if ($mapEditorUndoToastStore) {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        timeoutId = setTimeout(() => mapEditorUndoToastStore.set(null), 5000);
    }

    function close() {
        mapEditorUndoToastStore.set(null);
    }

    function undo() {
        gameManager.getCurrentGameScene().getMapEditorModeManager().undoCommand();
        close();
    }

    onDestroy(() => {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
    });
</script>

{#if $mapEditorUndoToastStore}
    <div class="absolute bottom-4 left-4 z-[2200] pointer-events-auto">
        <div class="flex items-center gap-3 rounded-lg bg-contrast/80 backdrop-blur-md px-3 py-2 text-sm text-white">
            <span>{$mapEditorUndoToastStore.message}</span>
            <button class="btn btn-secondary h-7 px-3 text-xs" on:click={undo} type="button">
                {$LL.mapEditor.undoToast.undo()}
            </button>
            <button class="h-7 w-7 rounded hover:bg-white/10" on:click={close} type="button">×</button>
        </div>
    </div>
{/if}
