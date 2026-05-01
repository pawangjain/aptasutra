class Constants {
  // Test Build No. = TEST_VERSION_DATE
  static const String TEST_VERSION_DATE = '20260318_1230';

  /// Flag to use production server or test server urls
  static const bool IS_PRODUCTION_BUILD = true;

    static const String AKONNECT_APP_URL = 'https://akonnect.org/app';
  static const String DADA_BHAGWAN_APP_URL = 'https://www.dadabhagwan.org/app';
  static const String DADA_BHAGWAN_ORG_URL = 'https://www.dadabhagwan.org';
  static const String DBF_YOUTUBE_CHANNEL_URL = 'https://www.youtube.com/dadabhagwanfoundation';

    static const String footerTextForShare =
      //'Shared via AKonnect (https://akonnect.org/app) \n' +
      //'Main Website : https://dadabhagwan.org';
      'Shared from Akonnect \n$AKONNECT_APP_URL'
      '\n$DADA_BHAGWAN_ORG_URL''\n$DBF_YOUTUBE_CHANNEL_URL';
}
