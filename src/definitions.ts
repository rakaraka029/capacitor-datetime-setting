/**
 * Result from comprehensive date/time change detection
 */
export interface DateTimeChangeResult {
    /**
     * Type of change detected
     */
    changeType: 'noChange' | 'timeOnly' | 'dateOnly' | 'dateAndTime';

    /**
     * Time difference in seconds
     */
    timeDifference: number;

    /**
     * Whether the date component changed
     */
    dateChanged: boolean;

    /**
     * Whether the time component changed
     */
    timeChanged: boolean;

    /**
     * Whether automatic date/time is enabled
     */
    isAutoDateTimeEnabled: boolean;

    /**
     * Previous date timestamp (Unix epoch, may be null on first check)
     */
    previousDate?: number;

    /**
     * Current date timestamp (Unix epoch)
     */
    currentDate: number;
}

export interface DateTimeSettingPlugin {
    // ===== Date/Time Change Detection =====

    /**
     * Detects if the device's date/time has been manually changed.
     * Uses network time comparison for accuracy when available.
     * 
     * @returns Promise with boolean indicating if change was detected
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.detectDateTimeChange();
     * if (result.changed) {
     *   console.log('Date/time has been changed!');
     * }
     * ```
     */
    detectDateTimeChange(): Promise<{ changed: boolean }>;

    /**
     * Comprehensive date and time change detection with detailed analysis.
     * Distinguishes between date-only, time-only, and combined changes.
     * 
     * @returns Promise with detailed change result
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.detectComprehensiveDateTimeChange();
     * console.log('Change type:', result.changeType);
     * console.log('Date changed:', result.dateChanged);
     * console.log('Time changed:', result.timeChanged);
     * ```
     */
    detectComprehensiveDateTimeChange(): Promise<DateTimeChangeResult>;

    /**
     * Detects specifically if only the date has been changed while time remains similar.
     * Useful for detecting manual date changes when auto date/time is disabled.
     * 
     * @returns Promise with boolean indicating if date-only change was detected
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.detectDateOnlyChange();
     * if (result.changed) {
     *   console.log('Only the date was changed!');
     * }
     * ```
     */
    detectDateOnlyChange(): Promise<{ changed: boolean }>;

    /**
     * Comprehensive date and time change detection with automatic notifications.
     * Shows user notifications when changes are detected.
     * 
     * @returns Promise with detailed change result
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.detectAndNotifyDateTimeChanges();
     * // User will see notification if changes detected
     * console.log('Change type:', result.changeType);
     * ```
     */
    detectAndNotifyDateTimeChanges(): Promise<DateTimeChangeResult>;

    // ===== Time Utilities =====

    /**
     * Get the device's current local time.
     * 
     * @returns Promise with Unix timestamp
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.getLocalTime();
     * const date = new Date(result.timestamp * 1000);
     * console.log('Current local time:', date);
     * ```
     */
    getLocalTime(): Promise<{ timestamp: number }>;

    /**
     * Fetch accurate UTC time from internet time server.
     * 
     * @returns Promise with Unix timestamp from internet
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * try {
     *   const result = await DateTimeSetting.getInternetUTCTime();
     *   const date = new Date(result.timestamp * 1000);
     *   console.log('Internet UTC time:', date);
     * } catch (error) {
     *   console.error('Failed to fetch internet time:', error);
     * }
     * ```
     */
    getInternetUTCTime(): Promise<{ timestamp: number }>;

    /**
     * Convert local time to UTC.
     * 
     * @param options - Object containing the timestamp to convert
     * @returns Promise with UTC timestamp
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const localTimestamp = Date.now() / 1000;
     * const result = await DateTimeSetting.convertToLocalTime({ 
     *   timestamp: localTimestamp 
     * });
     * console.log('UTC timestamp:', result.timestamp);
     * ```
     */
    convertToLocalTime(options: { timestamp: number }): Promise<{ timestamp: number }>;

    // ===== Timestamp Management =====

    /**
     * Set the stored timestamp for future change detection.
     * 
     * @param options - Object containing the timestamp to store
     * @returns Promise that resolves when timestamp is stored
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const currentTimestamp = Date.now() / 1000;
     * await DateTimeSetting.setStoredTimestamp({ 
     *   timestamp: currentTimestamp 
     * });
     * ```
     */
    setStoredTimestamp(options: { timestamp: number }): Promise<void>;

    /**
     * Get the currently stored timestamp.
     * 
     * @returns Promise with stored timestamp (null if not set)
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * const result = await DateTimeSetting.getStoredTimestamp();
     * if (result.timestamp) {
     *   const date = new Date(result.timestamp * 1000);
     *   console.log('Stored timestamp:', date);
     * } else {
     *   console.log('No timestamp stored');
     * }
     * ```
     */
    getStoredTimestamp(): Promise<{ timestamp: number | null }>;

    /**
     * Reset the detector (clears all stored data and cache).
     * 
     * @returns Promise that resolves when reset is complete
     * @since 2.0.0
     * 
     * @example
     * ```typescript
     * await DateTimeSetting.resetDetector();
     * console.log('Detector has been reset');
     * ```
     */
    resetDetector(): Promise<void>;
}
