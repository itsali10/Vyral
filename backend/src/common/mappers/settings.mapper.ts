import { UserSettings } from '../../entities/user-settings.entity';

export function toSettingsView(settings: UserSettings) {
  return {
    showLikesPublicly: settings.showLikesPublicly,
    notifLikes: settings.notifLikes,
    notifComments: settings.notifComments,
    notifFollowers: settings.notifFollowers,
    notifTrending: settings.notifTrending,
    dataSaver: settings.dataSaver,
    hapticsEnabled: settings.hapticsEnabled,
    exploreGridCompact: settings.exploreGridCompact,
    accentColor: settings.accentColor,
    defaultFeedTab: settings.defaultFeedTab,
    mutedWords: settings.mutedWords ?? [],
  };
}
