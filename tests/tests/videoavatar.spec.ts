import { expect, test } from "@playwright/test";
import { getPage } from "./utils/auth";
import Menu from "./utils/menu";

test.describe("VideoAvatar Feature", () => {
    test("Should display video avatar when camera is enabled", async ({ browser, browserName }) => {
        // Skip on webkit due to camera permission limitations
        test.skip(browserName === "webkit", "WebKit has camera permission limitations");

        // Create a user on the starter map
        await using page = await getPage(
            browser,
            "Alice",
            "/_/global/maps.workadventure.localhost/starter/map.json"
        );

        // Wait for the game to fully load
        await expect(page.getByTestId("camera-button")).toBeVisible({ timeout: 30_000 });

        // Turn on the camera
        await Menu.turnOnCamera(page);

        // Wait a moment for the video stream to initialize
        await page.waitForTimeout(3000);

        // Take a screenshot for debugging
        await page.screenshot({ path: 'test-results/videoavatar-debug.png', fullPage: true });

        // Log all video elements on the page
        const videoCount = await page.locator('video').count();
        console.log(`Found ${videoCount} video elements on page`);

        // Log all div elements with border-radius
        const circularDivs = await page.locator('div').evaluateAll((divs) => {
            return divs.filter(div => {
                const style = window.getComputedStyle(div);
                return style.borderRadius === '50%' || div.style.borderRadius === '50%';
            }).map(div => ({
                id: div.id,
                className: div.className,
                style: div.getAttribute('style'),
            }));
        });
        console.log('Circular divs found:', JSON.stringify(circularDivs, null, 2));

        // The VideoAvatar creates a container div with specific styling
        // It should be visible when camera is on
        const videoAvatarContainer = page.locator('div[style*="border-radius: 50%"][style*="overflow: hidden"]');

        // Check if video avatar container exists and contains a video element
        await expect(videoAvatarContainer.first()).toBeVisible({ timeout: 10_000 });

        // Verify video element is playing inside the container
        const videoElement = videoAvatarContainer.locator("video").first();
        await expect(videoElement).toBeVisible({ timeout: 5_000 });

        // Verify the video has a source (srcObject is set)
        const hasVideoSource = await videoElement.evaluate((video: HTMLVideoElement) => {
            return video.srcObject !== null && (video.srcObject as MediaStream).getVideoTracks().length > 0;
        });
        expect(hasVideoSource).toBe(true);

        console.log("✓ VideoAvatar is visible with active video stream");
    });

    test("Should hide video avatar when camera is disabled", async ({ browser, browserName }) => {
        // Skip on webkit due to camera permission limitations
        test.skip(browserName === "webkit", "WebKit has camera permission limitations");

        // Create a user on the test map
        await using page = await getPage(
            browser,
            "Bob",
            publicTestMapUrl("tests/E2E/empty.json", "videoavatar-toggle")
        );

        // Wait for the game to fully load
        await expect(page.getByTestId("camera-button")).toBeVisible({ timeout: 30_000 });

        // Turn on the camera first
        await Menu.turnOnCamera(page);
        await page.waitForTimeout(2000);

        // Verify video avatar is visible
        const videoAvatarContainer = page.locator('div[style*="border-radius: 50%"][style*="overflow: hidden"]');
        await expect(videoAvatarContainer.first()).toBeVisible({ timeout: 10_000 });

        console.log("✓ VideoAvatar visible with camera on");

        // Now turn off the camera
        await Menu.turnOffCamera(page);
        await page.waitForTimeout(1000);

        // Video avatar should be hidden or have no video source
        const videoElement = videoAvatarContainer.locator("video").first();

        // Either the container is hidden or the video has no source
        const isHiddenOrNoSource = await videoElement.evaluate((video: HTMLVideoElement) => {
            // Check if video element is not visible or has no source
            const style = window.getComputedStyle(video.parentElement!);
            const isHidden = style.display === "none" || style.visibility === "hidden";
            const hasNoSource = video.srcObject === null ||
                (video.srcObject as MediaStream).getVideoTracks().length === 0;
            return isHidden || hasNoSource;
        }).catch(() => true); // If element doesn't exist, consider it hidden

        expect(isHiddenOrNoSource).toBe(true);

        console.log("✓ VideoAvatar hidden with camera off");
    });

    test("Should show video avatar as circular element above player", async ({ browser, browserName }) => {
        // Skip on webkit due to camera permission limitations
        test.skip(browserName === "webkit", "WebKit has camera permission limitations");

        // Create a user on the test map
        await using page = await getPage(
            browser,
            "Eve",
            publicTestMapUrl("tests/E2E/empty.json", "videoavatar-style")
        );

        // Wait for the game to fully load
        await expect(page.getByTestId("camera-button")).toBeVisible({ timeout: 30_000 });

        // Turn on the camera
        await Menu.turnOnCamera(page);
        await page.waitForTimeout(2000);

        // Find the video avatar container
        const videoAvatarContainer = page.locator('div[style*="border-radius: 50%"][style*="overflow: hidden"]').first();
        await expect(videoAvatarContainer).toBeVisible({ timeout: 10_000 });

        // Verify the styling matches VideoAvatar.ts specifications
        const styles = await videoAvatarContainer.evaluate((el: HTMLElement) => {
            const computed = window.getComputedStyle(el);
            return {
                borderRadius: computed.borderRadius,
                overflow: computed.overflow,
                width: computed.width,
                height: computed.height,
            };
        });

        // VideoAvatar.ts defines VIDEO_AVATAR_SIZE = 48
        expect(styles.borderRadius).toBe("50%");
        expect(styles.overflow).toBe("hidden");
        expect(styles.width).toBe("48px");
        expect(styles.height).toBe("48px");

        console.log("✓ VideoAvatar has correct circular styling (48x48px, border-radius 50%)");
    });
});
