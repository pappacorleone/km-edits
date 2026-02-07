import type { Readable, Unsubscriber } from "svelte/store";
import { derived, get } from "svelte/store";
import type { GameScene } from "../Game/GameScene";
import type { RemotePlayer } from "./RemotePlayer";
import { videoStreamStore } from "../../Stores/PeerStore";
import type { VideoBox } from "../../Space/Space";
import type { Streamable } from "../../Stores/StreamableCollectionStore";
import { videoAvatarEnabledStore } from "../../Stores/VideoAvatarStore";

// Cache for video streams per player to prevent recreating MediaStream objects
const playerStreamCache: Map<number, { stream: MediaStream | undefined; trackIds: string[] }> = new Map();

/**
 * VideoAvatarManager manages the linking of remote players to their video streams.
 * It watches the video stream store and automatically enables video avatars
 * for remote players who have active video streams.
 */
export class VideoAvatarManager {
    private playerSubscriptions: Map<number, Unsubscriber> = new Map();
    private videoStoreUnsubscriber: Unsubscriber | undefined;
    private scene: GameScene;

    constructor(scene: GameScene) {
        this.scene = scene;
    }

    /**
     * Start watching video streams and linking them to players
     */
    start(): void {
        // Watch the video stream store for changes
        this.videoStoreUnsubscriber = videoStreamStore.subscribe(() => {
            // When video streams change, update all linked players
            this.updateAllPlayerVideoStreams();
        });
    }

    /**
     * Stop watching video streams
     */
    stop(): void {
        this.videoStoreUnsubscriber?.();
        this.videoStoreUnsubscriber = undefined;
    }

    /**
     * Link a remote player to their video stream
     */
    linkRemotePlayerToVideo(player: RemotePlayer): void {
        // Create a derived store that finds this player's video stream
        const playerVideoStreamStore = this.createVideoStreamStoreForPlayer(player.userId);

        // Enable video avatar for this player (not mirrored, since it's remote)
        player.enableVideoAvatar(playerVideoStreamStore, false);

        // Store the unsubscriber for cleanup
        // Note: The subscription is managed by the Character class
    }

    /**
     * Unlink a remote player from their video stream
     */
    unlinkPlayer(player: RemotePlayer): void {
        player.disableVideoAvatar();
        const unsubscriber = this.playerSubscriptions.get(player.userId);
        if (unsubscriber) {
            unsubscriber();
            this.playerSubscriptions.delete(player.userId);
        }
        // Clean up cache for this player
        playerStreamCache.delete(player.userId);
    }

    /**
     * Create a derived store that extracts the video stream for a specific player
     * Only provides stream when video avatar feature is enabled
     * Caches the MediaStream reference to prevent flickering
     */
    private createVideoStreamStoreForPlayer(userId: number): Readable<MediaStream | undefined> {
        // Initialize cache for this player
        if (!playerStreamCache.has(userId)) {
            playerStreamCache.set(userId, { stream: undefined, trackIds: [] });
        }

        return derived(
            [videoStreamStore, videoAvatarEnabledStore],
            ([$videoStreamStore, $videoAvatarEnabled]) => {
                const cache = playerStreamCache.get(userId)!;

                // Return undefined if video avatar feature is disabled
                if (!$videoAvatarEnabled) {
                    cache.stream = undefined;
                    cache.trackIds = [];
                    return undefined;
                }

                // Find the video box for this user by extracting userId from spaceUserId
                for (const [spaceUserId, videoBox] of $videoStreamStore.entries()) {
                    const extractedUserId = this.extractUserIdFromSpaceUserId(spaceUserId);
                    if (extractedUserId === userId) {
                        const newStream = this.extractVideoStreamWithCache(videoBox, cache);
                        return newStream;
                    }
                }

                cache.stream = undefined;
                cache.trackIds = [];
                return undefined;
            }
        );
    }

    /**
     * Extract userId from spaceUserId
     * SpaceUserId format: {roomUrl}_{userId}
     */
    private extractUserIdFromSpaceUserId(spaceUserId: string): number | undefined {
        const lastUnderscoreIndex = spaceUserId.lastIndexOf("_");
        if (lastUnderscoreIndex === -1) {
            return undefined;
        }
        const userIdStr = spaceUserId.substring(lastUnderscoreIndex + 1);
        const userId = parseInt(userIdStr, 10);
        return isNaN(userId) ? undefined : userId;
    }

    /**
     * Extract video-only MediaStream from a VideoBox with caching
     * Only creates new MediaStream if tracks have changed
     */
    private extractVideoStreamWithCache(
        videoBox: VideoBox,
        cache: { stream: MediaStream | undefined; trackIds: string[] }
    ): MediaStream | undefined {
        const streamable = get(videoBox.streamable);
        if (!streamable) {
            cache.stream = undefined;
            cache.trackIds = [];
            return undefined;
        }

        if (streamable.media.type === "webrtc" || streamable.media.type === "livekit") {
            const stream = get(streamable.media.streamStore);
            if (stream) {
                const videoTracks = stream.getVideoTracks();
                if (videoTracks.length > 0) {
                    // Only recreate if tracks changed
                    const newTrackIds = videoTracks.map((t) => t.id);
                    if (JSON.stringify(newTrackIds) !== JSON.stringify(cache.trackIds)) {
                        cache.stream = new MediaStream(videoTracks);
                        cache.trackIds = newTrackIds;
                    }
                    return cache.stream;
                }
            }
        }

        cache.stream = undefined;
        cache.trackIds = [];
        return undefined;
    }

    /**
     * Update video streams for all linked players
     * Called when the video stream store changes
     */
    private updateAllPlayerVideoStreams(): void {
        // The derived stores in each player will automatically update
        // when videoStreamStore changes, so we don't need to do anything here
        // This method is kept for potential future optimizations
    }

    /**
     * Clean up all subscriptions
     */
    destroy(): void {
        this.stop();
        for (const unsubscriber of this.playerSubscriptions.values()) {
            unsubscriber();
        }
        this.playerSubscriptions.clear();
        // Clear all stream caches
        playerStreamCache.clear();
    }
}
