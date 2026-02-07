import type { GameScene } from "../Game/GameScene";
import DOMElement = Phaser.GameObjects.DOMElement;

const VIDEO_AVATAR_SIZE = 48;

/**
 * VideoAvatar wraps a circular video element in a Phaser DOMElement
 * for displaying webcam feeds at player positions in the game world.
 *
 * Uses RELATIVE coordinates (0, -offset) so it can be added to a Character
 * container and automatically follow the player's position.
 */
export class VideoAvatar {
    private videoElement: HTMLVideoElement;
    private domElement: DOMElement;
    private container: HTMLDivElement;
    private stream: MediaStream | undefined;
    private scene: GameScene;
    private isDestroyed = false;

    constructor(scene: GameScene, flipX: boolean = true) {
        this.scene = scene;

        // Create container with circular mask and fixed size
        this.container = document.createElement("div");
        this.container.style.width = `${VIDEO_AVATAR_SIZE}px`;
        this.container.style.height = `${VIDEO_AVATAR_SIZE}px`;
        this.container.style.borderRadius = "50%";
        this.container.style.overflow = "hidden";
        this.container.style.border = "3px solid white";
        this.container.style.boxShadow = "0 2px 8px rgba(0,0,0,0.4)";
        this.container.style.backgroundColor = "#1a1a2e";

        // Create video element
        this.videoElement = document.createElement("video");
        this.videoElement.autoplay = true;
        this.videoElement.muted = true; // Mute to prevent audio feedback
        this.videoElement.playsInline = true;
        this.videoElement.style.width = "100%";
        this.videoElement.style.height = "100%";
        this.videoElement.style.objectFit = "cover";
        this.videoElement.style.transform = flipX ? "scaleX(-1)" : "scaleX(1)";

        this.container.appendChild(this.videoElement);

        // Create Phaser DOMElement centered on the character sprite position.
        // Sprites are at (0,0) with default origin (0.5, 0.5), so visual center = (0,0).
        // DOMElement origin (0.5, 0.5) centers the circle on the sprite body,
        // placing it where the avatar was, next to the companion.
        this.domElement = new DOMElement(
            scene,
            0,   // X: centered on character
            2,   // Y: slight nudge down to align with sprite body center
            this.container
        );
        this.domElement.setOrigin(0.5, 0.5);
        this.domElement.setVisible(false);
    }

    /**
     * Attach or detach a MediaStream to the video element
     */
    setStream(stream: MediaStream | undefined): void {
        if (this.isDestroyed) return;

        this.stream = stream;
        if (stream && stream.getVideoTracks().length > 0) {
            this.videoElement.srcObject = stream;
            this.domElement.setVisible(true);
            this.videoElement.play().catch((e) => {
                console.warn("VideoAvatar: Failed to play video", e);
            });
        } else {
            this.videoElement.srcObject = null;
            this.domElement.setVisible(false);
        }
    }

    /**
     * Set visibility (respects stream state)
     */
    setVisible(visible: boolean): void {
        if (this.isDestroyed) return;
        this.domElement.setVisible(visible && this.stream !== undefined);
    }

    /**
     * Set horizontal flip (mirror for local camera)
     */
    setFlipX(flip: boolean): void {
        if (this.isDestroyed) return;
        this.videoElement.style.transform = flip ? "scaleX(-1)" : "scaleX(1)";
    }

    /**
     * Check if video stream is active
     */
    hasActiveStream(): boolean {
        return this.stream !== undefined && this.stream.getVideoTracks().length > 0;
    }

    /**
     * Get the underlying DOMElement for adding to Phaser containers
     */
    getDOMElement(): DOMElement {
        return this.domElement;
    }

    /**
     * Check if destroyed
     */
    isDestroyedState(): boolean {
        return this.isDestroyed;
    }

    /**
     * Clean up all resources
     */
    destroy(): void {
        if (this.isDestroyed) return;
        this.isDestroyed = true;

        this.videoElement.srcObject = null;
        this.videoElement.remove();
        this.container.remove();
        this.domElement.destroy();
    }
}
