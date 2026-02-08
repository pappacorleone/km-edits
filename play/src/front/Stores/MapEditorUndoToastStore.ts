import { writable } from "svelte/store";

export type MapEditorUndoToast = {
    message: string;
    commandId?: string;
};

export const mapEditorUndoToastStore = writable<MapEditorUndoToast | null>(null);
