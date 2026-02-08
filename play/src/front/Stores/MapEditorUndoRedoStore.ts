import { writable } from "svelte/store";

export const mapEditorCanUndoStore = writable<boolean>(false);
export const mapEditorCanRedoStore = writable<boolean>(false);
