//
//  CommonFunctions.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "Reachability.h"
#import <iAd/iAd.h>

@interface CommonFunctions : NSObject
{
    UIView *_loadingView;
    UIActivityIndicatorView *_activityIndicatorView;
    Reachability *internetReach;
}

@property (nonatomic, strong) ADBannerView* adBannerView;
@property (nonatomic, strong) GADBannerView* admobBannerView;

+ (CommonFunctions*)shared;

#pragma mark - Network Reachability
-(BOOL)checkNetworkConnectivity;
+(BOOL) isIphone;
+(BOOL) isIphone5;
#pragma mark - return Removing White Spacing String
-(BOOL) isInValidString:(UITextField *)txt StringToMatch:(NSString *)stringToMatch;
+ (void)showAlertView:(NSString *)message TITLE:(NSString *) title Delegate:(id)delegate;
-(BOOL) compareStrings :(NSString *)str String2:(NSString *)str2;
+(void) pushViewController:(UINavigationController *)nav ViewController:(UIViewController *)viewController;
+(NSString *) returnDateFormat:(NSString *)strDate;
+(NSMutableArray *) returnArrayOfAlphabets;
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabet :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForDetailGenre :(NSMutableArray *) arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;

-(BOOL) isvalidPasswordLength:(UITextField *)txt StringToMatch:(NSString *)stringToMatch;

+(NSString *)getYouTubeEmbed:(NSString *)VideoPath embedRect:(CGRect)rect;
+(NSString *)returnTime:(NSString *)strDate;
+(UIView *) returnViewForHeader:(NSString *) str UITableView:(UITableView *)tblVw;
+ (void)playVideo:(NSString*)strVideoUrl ViewController:(UIViewController *) vwController;
+ (UIImage*)fetchCGContext:(UIView*)view;
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForSearch :(NSMutableArray *) arrSearch arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+(NSMutableArray *) returnOtherThanAlphabetsRecordsArrayForSearch:(NSMutableArray *) arrSearch;
+(BOOL) userLoggedIn;
-(NSMutableArray *) returnRecordsGroupByDate:(NSMutableArray *)arrRecordsLocal ArrDates:(NSMutableArray *) arrDates;
+(NSMutableArray *)returnArrayOfRecordForMusicSingersParticularAlphabet :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+(BOOL) isEnglish;
+(BOOL) isEnglishLang;
+ (NSBundle*)setLocalizedBundle;

+ (UIImage *)scaleDownSizeOfImage:(UIImage *)image Size:(CGSize)size;
//+ (BOOL)checkNetworkConnectivity;

+ (NSMutableAttributedString*)changeMinTextFont:(NSString*)lblText fontName:(NSString*)textFontName;
+ (NSString *)convertGMTDateFromLocalDate:(NSString *)gmtDateStr;
+ (NSString *)convertGMTDateFromLocalDateWithDays:(NSString *)gmtDateStr;
+ (NSString *)changeDateFormatForGMTDate:(NSString *)strDate;
+ (NSString*)changeLanguageForDays:(NSString*)dayString;
+ (NSString*)changeLanguageForMonths:(NSString*)monthString;

#pragma mark - Arabic UITableView Section indexing
+ (NSString*)returnAlphabetByIndex:(int)index;
+ (NSMutableArray *)returnArrayOfRecordForParticularAlphabetArabic :(NSMutableArray *) arrAtoZMovies arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+ (NSMutableArray*)createArabicAlphabetsArray:(NSArray*)arrAtoZMovies;
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForDetailGenreArabic:(NSMutableArray *) arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+ (NSMutableArray*)createArabicAlphabetsArrayArabic:(NSArray*)arrAtoZMovies;
+(NSMutableArray *)returnArrayOfRecordForParticularAlphabetForMusicArabic:(NSMutableArray *)arrDetailGenre arrayOfAphabetsToDisplay:(NSMutableArray *) arrAlphabets;
+ (NSMutableArray*)createArabicAlphabetsArrayMusicArabic:(NSArray*)arrDetailGenre;
+ (NSString*)convertTimeUnitToArabic:(NSString*)convertedTime;
+ (NSString*)convertTimeUnitLanguage:(NSString*)convertedTime;
+ (NSMutableArray*)returnArabicAlphabets;
//+ (NSString*)returnArabicAlphabetByIndex:(int)index arrArabicAlphabets:(NSArray*)arrArabicAlphabets;
+ (void)writeToTextFile:(NSString *) response;


#pragma mark - BrightCove URl

+ (NSString*)brightCoveExtendedUrl:(NSString*)movieUrl;
+ (NSString*)brightCoveMp4Url:(NSString*)movieExtendedUrl;

+ (ADBannerView*)addiAdBanner:(float)yOrigin delegate:(id)delegate;
+ (GADBannerView*)addAdmobBanner:(float)yOrigin;
+ (NSString*)showPostedMessageTwitter;
+ (NSString*)showPostedMessageDownload;
+ (void)addGoogleAnalyticsForView:(NSString *)viewName;

@end