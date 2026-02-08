<script lang="ts">
    import { LL } from "../../../i18n/i18n-svelte";
    import { IconTrash } from "@wa-icons";
</script>

<div class="flex flex-col items-center justify-center gap-3 text-center">
    <div class="flex h-12 w-12 items-center justify-center rounded-full bg-white/10">
        <IconTrash font-size="20" />
    </div>
    <div class="text-lg">{$LL.mapEditor.entityEditor.trashTool.delete()}</div>
    <div class="text-sm opacity-60">{$LL.mapEditor.entityEditor.trashTool.shortcutHint()}</div>
</div>

<style lang="scss">
</style>
