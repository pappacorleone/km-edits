import { writable } from "svelte/store";

export type MapEditorSaveStatus = "saved" | "saving" | "unsaved";

export const mapEditorSaveStatusStore = writable<MapEditorSaveStatus>("saved");
