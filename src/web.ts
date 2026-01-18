import { WebPlugin } from '@capacitor/core';

import type { DateTimeSettingPlugin, DateTimeChangeResult } from './definitions';

export class DateTimeSettingWeb extends WebPlugin implements DateTimeSettingPlugin {
    async isDateTimeChanged(): Promise<{ changed: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async isDateTimeChangedSimple(): Promise<{ changed: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    // Date/Time Change Detection
    async detectDateTimeChange(): Promise<{ changed: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async detectComprehensiveDateTimeChange(): Promise<DateTimeChangeResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    async detectDateOnlyChange(): Promise<{ changed: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async detectAndNotifyDateTimeChanges(): Promise<DateTimeChangeResult> {
        throw this.unimplemented('Not implemented on web.');
    }

    // Time Utilities
    async getLocalTime(): Promise<{ timestamp: number }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async getInternetUTCTime(): Promise<{ timestamp: number }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async convertToLocalTime(options: { timestamp: number }): Promise<{ timestamp: number }> {
        throw this.unimplemented('Not implemented on web.');
    }

    // Timestamp Management
    async setStoredTimestamp(options: { timestamp: number }): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }

    async getStoredTimestamp(): Promise<{ timestamp: number | null }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async resetDetector(): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }
}
