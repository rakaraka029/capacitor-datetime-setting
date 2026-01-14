import { WebPlugin } from '@capacitor/core';

import type { DateTimeSettingPlugin } from './definitions';

export class DateTimeSettingWeb extends WebPlugin implements DateTimeSettingPlugin {
    async timeIsAuto(): Promise<{ value: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async timeZoneIsAuto(): Promise<{ value: boolean }> {
        throw this.unimplemented('Not implemented on web.');
    }

    async openSetting(): Promise<void> {
        throw this.unimplemented('Not implemented on web.');
    }
}
