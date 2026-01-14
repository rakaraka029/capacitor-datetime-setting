export interface DateTimeSettingPlugin {
    /**
     * Check if automatic time is enabled on the device.
     * 
     * @returns Promise with boolean value indicating if auto time is enabled
     * @since 1.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.timeIsAuto();
     * console.log('Auto time enabled:', result.value);
     * ```
     */
    timeIsAuto(): Promise<{ value: boolean }>;

    /**
     * Check if automatic timezone is enabled on the device.
     * 
     * @returns Promise with boolean value indicating if auto timezone is enabled
     * @since 1.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.timeZoneIsAuto();
     * console.log('Auto timezone enabled:', result.value);
     * ```
     */
    timeZoneIsAuto(): Promise<{ value: boolean }>;

    /**
     * Open the device's date and time settings screen.
     * 
     * @returns Promise that resolves when settings are opened
     * @since 1.0.0
     * 
     * @example
     * ```typescript
     * await DateTimeSetting.openSetting();
     * ```
     */
    openSetting(): Promise<void>;
}
