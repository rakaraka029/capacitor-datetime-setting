import { registerPlugin } from '@capacitor/core';

import type { DateTimeSettingPlugin } from './definitions';

const DateTimeSetting = registerPlugin<DateTimeSettingPlugin>('DateTimeSetting', {
    web: () => import('./web').then(m => new m.DateTimeSettingWeb()),
});

export * from './definitions';
export { DateTimeSetting };
