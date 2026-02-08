<script lang="ts">
    import { LL } from "../../../i18n/i18n-svelte";
    import { gameManager } from "../../Phaser/Game/GameManager";
    import { mapEditorCanRedoStore, mapEditorCanUndoStore } from "../../Stores/MapEditorUndoRedoStore";
    import { mapEditorSaveStatusStore } from "../../Stores/MapEditorSaveStatusStore";
    import { IconArrowBackUp } from "@wa-icons";

    function undo() {
        gameManager.getCurrentGameScene().getMapEditorModeManager().undoCommand();
    }

    function redo() {
        gameManager.getCurrentGameScene().getMapEditorModeManager().redoCommand();
    }
</script>

<div class="flex items-center justify-between gap-2 border-t border-white/10 pt-2 text-sm">
    <div class="flex items-center gap-2">
        <button
            class="h-8 w-8 rounded flex items-center justify-center hover:bg-white/10 disabled:opacity-40 disabled:cursor-not-allowed"
            on:click={undo}
            disabled={!$mapEditorCanUndoStore}
            type="button"
            aria-label={$LL.mapEditor.statusBar.undo()}
        >
            <IconArrowBackUp font-size={16} />
        </button>
        <button
            class="h-8 w-8 rounded flex items-center justify-center hover:bg-white/10 disabled:opacity-40 disabled:cursor-not-allowed"
            on:click={redo}
            disabled={!$mapEditorCanRedoStore}
            type="button"
            aria-label={$LL.mapEditor.statusBar.redo()}
        >
            <IconArrowBackUp font-size={16} class="rotate-180" />
        </button>
    </div>
    <div class="flex items-center gap-2 rounded-full bg-white/5 px-2 py-1 text-xs">
        {#if $mapEditorSaveStatusStore === "saved"}
            <span class="inline-block h-2 w-2 rounded-full bg-emerald-400" />
            <span>{$LL.mapEditor.statusBar.saved()}</span>
        {:else if $mapEditorSaveStatusStore === "saving"}
            <span class="inline-block h-2 w-2 rounded-full bg-sky-400 animate-pulse" />
            <span>{$LL.mapEditor.statusBar.saving()}</span>
        {:else}
            <span class="inline-block h-2 w-2 rounded-full bg-amber-400" />
            <span>{$LL.mapEditor.statusBar.unsavedChanges()}</span>
        {/if}
    </div>
</div>
