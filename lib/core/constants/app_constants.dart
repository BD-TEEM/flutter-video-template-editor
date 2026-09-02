class AppConstants {
  static const String appName = 'News Template Maker';
  static const String appVersion = '1.0.0';
  
  // Video Resolutions
  static const String resolutionLow = '720x1280';
  static const String resolutionFullHD = '1080x1920';
  static const int resolutionLowWidth = 720;
  static const int resolutionLowHeight = 1280;
  static const int resolutionFullHDWidth = 1080;
  static const int resolutionFullHDHeight = 1920;
  
  // Video Duration
  static const int defaultVideoDuration = 15; // seconds
  static const int minVideoDuration = 3;
  static const int maxVideoDuration = 60;
  
  // Audio
  static const double defaultVolume = 1.0;
  static const double maxVolume = 2.0; // 200%
  static const double minVolume = 0.0;
  
  // Frame Types
  static const String frameTypeNewsHeadline = 'news_headline';
  static const String frameTypeFestivalCard = 'festival_card';
  static const String frameTypeTrendingShort = 'trending_short';
  static const String frameTypeCustom = 'custom';
  
  // Template Categories
  static const List<String> templateCategories = [
    'News Headlines',
    'Festival Cards',
    'Trending Shorts',
    'Custom Layouts',
  ];
  
  // Export Quality
  static const String qualityHigh = 'high';
  static const String qualityMedium = 'medium';
  static const String qualityLow = 'low';
  
  // Cloud Services
  static const String cloudRemoveBgApiEndpoint = 'https://api.remove.bg/v1.0';
  static const String firebaseStorageBucket = 'news-template-maker.appspot.com';
  
  // Timeout Durations
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration renderTimeout = Duration(minutes: 10);
  
  // Database Box Names
  static const String projectsBoxName = 'projects';
  static const String settingsBoxName = 'settings';
  static const String templatesBoxName = 'templates';
  static const String draftsBoxName = 'drafts';
  static const String favoritesBoxName = 'favorites';
}
