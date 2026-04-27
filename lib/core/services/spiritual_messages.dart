import '../../features/prayer/presentation/bloc/settings/settings_state.dart';

enum PrayerName {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get displayName {
    switch (this) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.sunrise:
        return 'Sunrise';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }

  static PrayerName fromString(String value) {
    return PrayerName.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PrayerName.fajr,
    );
  }
}

class SpiritualMessage {
  final String notificationPrefix;
  final String quote;
  final String source;

  const SpiritualMessage({
    required this.notificationPrefix,
    required this.quote,
    required this.source,
  });
}

class SpiritualMessages {
  static const _foundationFajr = SpiritualMessage(
    notificationPrefix: 'Time for Fajr',
    quote: 'Indeed, those who believe and do good deeds, the Most Merciful will grant them affection.',
    source: 'Quran 19:96',
  );

  static const _foundationDhuhr = SpiritualMessage(
    notificationPrefix: 'Time for Dhuhr',
    quote: 'O My servants who have wronged yourselves, do not lose hope in Allah\'s mercy. Allah forgives all sins.',
    source: 'Quran 39:53',
  );

  static const _foundationAsr = SpiritualMessage(
    notificationPrefix: 'Time for Asr',
    quote: 'Say: "O My servants who have transgressed against themselves, do not despair of Allah\'s mercy."',
    source: 'Quran 39:53',
  );

  static const _foundationMaghrib = SpiritualMessage(
    notificationPrefix: 'Time for Maghrib',
    quote: 'And repenting, and worshipping Him, and bowing, and prostrating - we have been made obedient.',
    source: 'Quran 22:77',
  );

  static const _foundationIsha = SpiritualMessage(
    notificationPrefix: 'Time for Isha',
    quote: 'The door of repentance is open until the sun rises.',
    source: 'Hadith - Bukhari',
  );

  static const _strengtheningFajr = SpiritualMessage(
    notificationPrefix: 'Time for Fajr',
    quote: 'The most beloved deeds to Allah are the regular ones, even if they are few.',
    source: 'Hadith - Bukhari',
  );

  static const _strengtheningDhuhr = SpiritualMessage(
    notificationPrefix: 'Time for Dhuhr',
    quote: 'Be constant in prayer, for whoever prays regularly stands before Allah with a great rank.',
    source: 'Hadith - Tirmidhi',
  );

  static const _strengtheningAsr = SpiritualMessage(
    notificationPrefix: 'Time for Asr',
    quote: 'The one who is patient and forgives - that is of the matters requiring determination.',
    source: 'Quran 42:43',
  );

  static const _strengtheningMaghrib = SpiritualMessage(
    notificationPrefix: 'Time for Maghrib',
    quote: 'Maintain your consistency, for indeed the consistent worshipper is rewarded with completeness.',
    source: 'Hadith - Ibn Majah',
  );

  static const _strengtheningIsha = SpiritualMessage(
    notificationPrefix: 'Time for Isha',
    quote: 'Indeed, the one who observes consistent worship, Allah will make his work succeed.',
    source: 'Quran - interpreted',
  );

  static const _growthFajr = SpiritualMessage(
    notificationPrefix: 'Time for Fajr',
    quote: 'Indeed, prayer has been commanded upon the believers at fixed times.',
    source: 'Quran 4:103',
  );

  static const _growthDhuhr = SpiritualMessage(
    notificationPrefix: 'Time for Dhuhr',
    quote: 'Guard strictly your prayers, especially the middle prayer.',
    source: 'Quran 2:238',
  );

  static const _growthAsr = SpiritualMessage(
    notificationPrefix: 'Time for Asr',
    quote: 'The covenant of prayer is clearly established - do not neglect it.',
    source: 'Hadith - Nasai',
  );

  static const _growthMaghrib = SpiritualMessage(
    notificationPrefix: 'Time for Maghrib',
    quote: 'Establishing prayer is the criterion for whether a person\'s Islam is good or bad.',
    source: 'Hadith - Tirmidhi',
  );

  static const _growthIsha = SpiritualMessage(
    notificationPrefix: 'Time for Isha',
    quote: 'The five daily prayers are a trust from Allah - guard them well.',
    source: 'Hadith - Abu Dawud',
  );

  static SpiritualMessage getMessage(IntentLevel intent, PrayerName prayer) {
    return switch (intent) {
      IntentLevel.foundation => switch (prayer) {
        PrayerName.fajr => _foundationFajr,
        PrayerName.sunrise => _foundationFajr,
        PrayerName.dhuhr => _foundationDhuhr,
        PrayerName.asr => _foundationAsr,
        PrayerName.maghrib => _foundationMaghrib,
        PrayerName.isha => _foundationIsha,
      },
      IntentLevel.strengthening => switch (prayer) {
        PrayerName.fajr => _strengtheningFajr,
        PrayerName.sunrise => _strengtheningFajr,
        PrayerName.dhuhr => _strengtheningDhuhr,
        PrayerName.asr => _strengtheningAsr,
        PrayerName.maghrib => _strengtheningMaghrib,
        PrayerName.isha => _strengtheningIsha,
      },
      IntentLevel.growth => switch (prayer) {
        PrayerName.fajr => _growthFajr,
        PrayerName.sunrise => _growthFajr,
        PrayerName.dhuhr => _growthDhuhr,
        PrayerName.asr => _growthAsr,
        PrayerName.maghrib => _growthMaghrib,
        PrayerName.isha => _growthIsha,
      },
    };
  }

  static SpiritualMessage getMessageForPrayer(IntentLevel intent, String prayerName) {
    final prayer = PrayerName.fromString(prayerName);
    return getMessage(intent, prayer);
  }

  static String buildNotificationBody(String prayerName, IntentLevel intent) {
    final spiritual = getMessageForPrayer(intent, prayerName);
    return '${spiritual.notificationPrefix} — ${spiritual.quote}\n\n${spiritual.source}';
  }

  static String buildNotificationTitle(String prayerName) {
    return 'Time for $prayerName';
  }

  static String buildUpgradeMessage(IntentLevel currentIntent, int streak) {
    return switch (currentIntent) {
      IntentLevel.foundation => switch (streak) {
        >= 7 => 'You\'ve been consistent for $streak days. Your next path is waiting.',
        _ => 'Keep going — $streak days closer to your next milestone.',
      },
      IntentLevel.strengthening => switch (streak) {
        >= 21 => 'You\'ve built strong momentum. Ready for the next level?',
        _ => 'Stay consistent — $streak days of commitment.',
      },
      IntentLevel.growth => 'You\'re at the highest level. Keep fulfilling your covenant.',
    };
  }

  static String buildStreakReminder(IntentLevel intent, int streak) {
    return switch (intent) {
      IntentLevel.foundation => 'Your $streak day streak is precious. Just show up today.',
      IntentLevel.strengthening => '$streak days strong. Your consistency is noticed.',
      IntentLevel.growth => '$streak days of excellence. Maintain your standard.',
    };
  }
}