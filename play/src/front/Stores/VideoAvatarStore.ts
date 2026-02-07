import { writable } from "svelte/store";
import { localUserStore } from "../Connection/LocalUserStore";

/**
 * Store that controls whether video avatars are enabled.
 * When enabled, player webcam feeds will be shown at player positions on the map
 * instead of traditional sprite avatars.
 */
function createVideoAvatarEnabledStore() {
    // Default to enabled, but respect user's stored preference
    const storedValue = localUserStore.getVideoAvatarEnabled();
    const { subscribe, set } = writable<boolean>(storedValue ?? true);

    return {
        subscribe,
        enable: () => {
            set(true);
            localUserStore.setVideoAvatarEnabled(true);
        },
        disable: () => {
            set(false);
            localUserStore.setVideoAvatarEnabled(false);
        },
        toggle: () => {
            const current = localUserStore.getVideoAvatarEnabled() ?? true;
            const newValue = !current;
            set(newValue);
            localUserStore.setVideoAvatarEnabled(newValue);
        },
    };
}

export const videoAvatarEnabledStore = createVideoAvatarEnabledStore();
