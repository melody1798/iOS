//
//  Constant.h
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 16/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#ifndef MEU_MELODYAP_Constant_h
#define MEU_MELODYAP_Constant_h

#endif

#undef NSLocalizedString
#define NSLocalizedString(key, _comment) [[Language sharedInstance] localizedString:key]

#define kLocalizedString(key) [[[GlobalPref sharedInstance] currLangBundal] localizedStringForKey:(key) value:@"" table:nil]

#pragma mark - Websrevice Url

//#define kBaseUrl                    @"http://api.meu-melodyap.netsolutions.in/api/"
//#define kBaseUrl                    @"http://api.meu-melodyapstaging.netsolutions.in/api/"
//#define kBaseUrl                    @"http://devapi.meu-melodyap.netsolutions.in/api/"
#define kBaseUrl                      @"http://api.melodynow.net/api/"
//#define kBaseUrl                      @"http://api.demo.melodynow.net/api/"

//#define KApiBaseurl                 @"api.meu-melodyap.netsolutions.in"
//#define KApiBaseurl                 @"api.meu-melodyapstaging.netsolutions.in"
//#define KApiBaseurl                 @"devapi.meu-melodyap.netsolutions.in"
#define KApiBaseurl                   @"api.melodynow.net"
//#define KApiBaseurl                   @"api.demo.melodynow.net"


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while(0)

#define kLoginService               @"login/Authentication"
#define kSignUpService              @"user/SaveUser"
#define kForgorPasswordService      @"user/ForgotPassword"
#define kLogoutService              @"user/Logout"

#define kChannelsService            @"Channel/GetAllChannels"
#define kChannelUpcomingMovies      @"Channel/GetUpcomingVideos"

#define kLiveNowFeaturedService     @"livenow/GetFeaturedMovies"
#define kLiveNowLiveMovies          @"LiveNow/GetLiveMovies"


#define kVODFeaturedMoviesService   @"VOD/GetFeaturedMovies"

#define kVODMoviesFeaturedService   @"Movies/GetFeaturedMovies"
#define kVODMoviesAtoZService       @"Movies/AllMovies"

#define kVODMoviesCollectionList    @"Movies/GetCollection"
#define kVODMoviesCollectionMoviesList    @"Collection/CollectionMovies"

#define kVODMoviesGenresService     @"movies/GetGenre"
#define kVODMoviesGenresDetailsService     @"Geners/GenreMovies"

#define kVODMusicGenre              @"music/GetGenre"
#define kVODMusicVideos           @"music/GetMusicVideos"
#define kVODMusicFeatured           @"music/GetFeaturedMovies"

#define kVODMusicSingers            @"music/GetSingers"
#define kSingerMovies               @"Artist/ArtistMovies"

#define kVideoDetail                @"Movies/GetMoviesById"

#define kWatchListSave              @"WatchList/Save"
#define kWatchListFetch             @"WatchList/GetWatchListMovies"
#define kWatchListDelete            @"WatchList/Delete"
#define kLastViewedSave              @"LastViewed/SaveRecentMovie"
#define kLastViewedFetch             @"LastViewed/GetLastViewedMovie"

#define kChannelsService             @"Channel/GetAllChannels"
#define kChannelUpcomingMovies       @"Channel/GetUpcomingVideos"

#define kSearchVOD                   @"VOD/SearchMovies"
#define kSearchChannel               @"Channel/ChannelSearch"    //For livenow
#define kSearchChannelUpcoming       @"Channel/UpcomingSearch"   //Upcoming search programname is parameter
#define kChannelDetailByName         @"Channel/GetChannelDetailByName"

#define kAllSeries                   @"Series/AllSeries"
#define kFeaturedEpisodes            @"series/GetFeaturedEpisodes"
#define kSeriesGenres                @"series/GetGenre"
#define kSeriesGenresDetail          @"Geners/GenreSeries"

#define kSeriesEpisodes              @"Series/GetSeriesEpisodes"
#define kSeriesSeasons               @"Series/GetSeriesSeasons"
#define kSeriesDetail                @"Series/GetSeriesById"
#define kVODCollections              @"VOD/GetCollection"

#define kCompanyInfo                 @"Information/GetCompanyInformation"
#define kSendFeedback                @"Feedback/Save"
#define kFAQInfo                     @"FAQ/GetAllquestions"


#pragma mark - Control frames

#define kAppNavBarHeightForIphone 55.0

#define kAppNavBarHeight 78.0
#define kSegmentControlHeight 36.0

#define kSegmentControlHeightForiphone 55.0


#pragma mark - Control images

#define kNavigationBarImageName_ios6    @"NavBar_ios6.png"
#define kNavigationBarImageName_ios7    @"NavBar_ios7.png"

#define kNavigationBarImageNameiPhone    @"top_bar~iphone.png"


#define kSegmentBackgroundImageNameiPad     @"Segment_Bar_Bg"

#define kSegmentBackgroundImageName     @"Segment_Bar_Bg~iphone"
#define kSegmentMoviesBackgroundImageName     @"movies_submenu_bar_bg"
#define kSegmentMusicBackgroundImageName     @"music_submenu_bar_bg"


#define kPopOverImage                   @"popover_border"

#define kUserTextField_InActive     @"username_txt_inactive"
#define kUserTextField_Active       @"username_txt_active"
#define kPasswordTextField_InActive @"password_txt_inactive"
#define kPasswordTextField_Active   @"password_txt_active"

#pragma mark - Custom fonts

#define kAlphabets @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define kProximaNova_Regular            @"ProximaNova-Regular"
#define kProximaNova_SemiBold           @"ProximaNova-Semibold"
#define kProximaNova_Bold               @"ProximaNova-Bold"
#define kProximaNova_SemiboldItalic     @"ProximaNova-SemiboldItalic"
#define kProximaNova_BoldIt             @"ProximaNova-BoldIt"
#define kProximaNova_ExtraBold          @"ProximaNova-Extrabold"
#define kProximaNova_Black              @"ProximaNova-Black"
#define kProximaNova_Light              @"ProximaNova-Light"


#pragma mark - Image names

#define kSelectLanguageImageName @"select_language_bg~iphone"
#define kSelectLanguageImageNameiPhone5 @"select_language_bg_i5~iphone"

#define kSettingButtonImageName @"setting_icon~iphone"


#pragma mark - Error messages and common strings

#define kUnderConstructionErrorMessage @"Under Construction"

#define kEmptyString @""
//#define kOK  @"OK"
#define kOK [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"ok" value:@"" table:nil]


//slow server response
#define kServerErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"slow server response" value:@"" table:nil]
#define kSearchErrorMessage @"Please enter video name to be searched"
#define kVideoSearchErrorMessage @"Please enter video name to be searched"

#define kUserNameErrorMessage @"Please enter User name"


/*#define kFirstNameErrorMessage @"Please enter First Name"
#define kLastNameErrorMessage @"Please enter Last Name"
#define kEmailErrorMessage @"Please enter Email"
#define kValidEmailErrorMessage @"Please enter valid Email"
#define kPasswordErrorMessage @"Please enter Password"
#define kConfirmPasswordErrorMessage @"Please enter Confirm Password"
#define kPasswordAndConfirmPwdErrorMessage @"Password and Confirm Password does not match"
#define kSelectGenderErrorMessage @"Please select gender"
#define kPasswordLengthErrorMessage @"Password should be between 6-20 character."
#define kSelectDateErrorMessage @"Please select date of birth"
*/

#define kFirstNameErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter First Name" value:@"" table:nil]
#define kLastNameErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter Last Name" value:@"" table:nil]
#define kEmailErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter Email" value:@"" table:nil]
#define kValidEmailErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter valid Email"  value:@"" table:nil]
#define kPasswordErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter Password" value:@"" table:nil]
#define kConfirmPasswordErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter Confirm Password"   value:@"" table:nil]
#define kPasswordAndConfirmPwdErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Password and Confirm Password does not match" value:@"" table:nil]
#define kSelectGenderErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please select gender"  value:@"" table:nil]
#define kPasswordLengthErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Password should be between 6-20 character." value:@"" table:nil]
#define kSelectDateErrorMessage [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please select date of birth" value:@"" table:nil]

#define iPhone4WithIOS6 ((!IS_IOS7_OR_LATER && [CommonFunctions isIphone] && (![CommonFunctions isIphone5])))
#define iPhone5WithIOS7 ((IS_IOS7_OR_LATER && [CommonFunctions isIphone] && ([CommonFunctions isIphone5])))
#define iPhone4WithIOS7 ((IS_IOS7_OR_LATER && [CommonFunctions isIphone] && (![CommonFunctions isIphone5])))
#define iPhone5WithIOS6  (!IS_IOS7_OR_LATER && [CommonFunctions isIphone] && [CommonFunctions isIphone5])


#pragma mark- tabbar images
#define kTabBarHomeImageName @"vod_tabbar_bottom_link01_inactive~iphone.png"
#define kTabBarCategoriesImageName @"vod_tabbar_bottom_link02_inactive~iphone.png"
#define kTabBarSearchImageName @"vod_tabbar_bottom_link03_inactive~iphone.png"
#define kTabBarWatchlistImageName @"vod_tabbar_bottom_link04_inactive~iphone.png"
#define kTabBarLiveNowImageName @"vod_tabbar_bottom_link05_inactive~iphone.png"

#define kTabBarHomeImageNameActive @"vod_tabbar_bottom_link01_active~iphone.png"
#define kTabBarCategoriesImageNameActive @"vod_tabbar_bottom_link02_active~iphone.png"
#define kTabBarSearchImageNameActive @"vod_tabbar_bottom_link03_active~iphone.png"
#define kTabBarWatchlistImageNameActive @"vod_tabbar_bottom_link04_active~iphone.png"
#define kTabBarLiveNowImageNameActive @"vod_tabbar_bottom_link05_active~iphone.png"

#define kTabBarBackgroundImageName @"vod_tabbar_bottom_links_bg~iphone"
#define kTabBarSelectionIndicatorImageName @"vod_tabbar_bottom_links_active~iphone"

#pragma mark - Custom Font Colors

//#define YELLOW_COLOR [UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:28.0/255.0 alpha:1.0]
#define YELLOW_COLOR [UIColor colorWithRed:220.0/255.0 green:160.0/255.0 blue:3.0/255.0 alpha:1.0]
#define color_Background [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]
#define color_CategoryCell_Background [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]

#define ACTIVE_TEXT_PLACEHOLDER [UIColor colorWithRed:38.0/255.0 green:134.0/255.0 blue:250.0/255.0 alpha:1.0]

#define INACTIVE_TEXT_PLACEHOLDER [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0]

#pragma mark -
#define IS_IOS7_OR_LATER     ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define kAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate])
#define kCommonFunction [CommonFunctions shared]

#define arrSignedInUserSettingsOptions [NSArray arrayWithObjects:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"signed in as" value:@"" table:nil],  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"change language" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"send feedback" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"frequently ques" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"terms use" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"privacy policy" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"logout" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"appversion" value:@"" table:nil], nil]


#define arrLogedOutUserSettingsOptions [NSArray arrayWithObjects: [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"login" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"change language" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"send feedback" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"frequently ques" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"terms use" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"privacy policy" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"appversion" value:@"" table:nil], nil]

#pragma mark - Language selection

#define kArabic         @"ar"
#define kEnglish        @"en"
#define kSelectedLanguageKey    @"SelectedLanguage"

#pragma mark - User Access Token keys

#define kAccessTokenKey   @"accessToken"
#define kUserIDKey        @"userId"
#define kUserNameKey        @"userName"

//#define NSLog   //

#define bCoveAccessToken     @"oFwMVv5-Fq9_xbiKByN7Xtw70T4p8rp72xsaykG17LxFw8u9TscquA.."

#define kGoogleAnalyticCode  @"UA-60690659-3"
#define kAdmobAppId          @"ca-app-pub-3843794018935978/2978173649"
#pragma mark - Sign up validations
#define kSignupAgeRequired   0

#define kAutoHideCastButtonTime   5
