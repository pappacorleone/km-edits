import type { AreaDataPropertiesKeys, EntityDataPropertiesKeys } from "@workadventure/map-editor";

export type PropertyEntry = {
    property: AreaDataPropertiesKeys | EntityDataPropertiesKeys;
    subProperty?: string;
};

export type PropertyCategory = {
    key: "communication" | "contentMedia" | "navigation" | "behavior" | "extensions";
    entries: PropertyEntry[];
};

export const propertyCategories: PropertyCategory[] = [
    {
        key: "communication",
        entries: [
            { property: "jitsiRoomProperty" },
            { property: "livekitRoomProperty" },
            { property: "matrixRoomPropertyData" },
            { property: "speakerMegaphone" },
            { property: "listenerMegaphone" },
        ],
    },
    {
        key: "contentMedia",
        entries: [
            { property: "openWebsite" },
            { property: "openWebsite", subProperty: "youtube" },
            { property: "openWebsite", subProperty: "klaxoon" },
            { property: "openWebsite", subProperty: "googleDrive" },
            { property: "openWebsite", subProperty: "googleDocs" },
            { property: "openWebsite", subProperty: "googleSheets" },
            { property: "openWebsite", subProperty: "googleSlides" },
            { property: "openWebsite", subProperty: "eraser" },
            { property: "openWebsite", subProperty: "excalidraw" },
            { property: "openWebsite", subProperty: "cards" },
            { property: "openWebsite", subProperty: "tldraw" },
            { property: "openFile" },
            { property: "playAudio" },
        ],
    },
    {
        key: "navigation",
        entries: [{ property: "start" }, { property: "exit" }, { property: "focusable" }],
    },
    {
        key: "behavior",
        entries: [
            { property: "silent" },
            { property: "highlight" },
            { property: "personalAreaPropertyData" },
            { property: "restrictedRightsPropertyData" },
            { property: "tooltipPropertyData" },
        ],
    },
    {
        key: "extensions",
        entries: [{ property: "extensionModule" }],
    },
];
