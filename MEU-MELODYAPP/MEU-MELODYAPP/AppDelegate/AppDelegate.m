//
//  AppDelegate.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "AppDelegate.h"
#import "LanguageViewController.h"
#import "CustomNavBar.h"
#import "Constant.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CommonFunctions.h"
#import "LiveNowFeaturedViewController.h"
#import "ChannelsViewController.h"
#import "VODSearchViewController.h"
#import "CustomControls.h"
#import "CommonFunctions.h"
#import "MBProgressHUD.h"
#import "GAIDictionaryBuilder.h"
#import "ACTReporter.h"

@implementation AppDelegate

@synthesize iWatchListCounter;
@synthesize fImageWidth;
@synthesize fImageHeight;
@synthesize navigationController;
@synthesize isEnableOrientation;
@synthesize isFromSearch;
@synthesize channelName;
@synthesize videoStartTime;
@synthesize isConnectedToDevice;
@synthesize intOrientation;
@synthesize objPlayerOverlay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setLocationValue];        //Set default values.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    _arrayOfAlphabets = [[NSMutableArray alloc] init];
    _arrayOfAlphabets = [[CommonFunctions returnArrayOfAlphabets] mutableCopy];
    _arrayOfAlphabets_ar = [[CommonFunctions returnArabicAlphabets] mutableCopy];

    UIViewController *objviewController;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey]) {
        if ([CommonFunctions isIphone]) {
            CustomUITabBariphoneViewController *objCustomUITabBariphoneViewController = [[CustomUITabBariphoneViewController alloc] init];
            [self.navigationController pushViewController:objCustomUITabBariphoneViewController animated:NO];
            [self.window setRootViewController:self.navigationController];
        }
        else
        {
            objviewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController" bundle:nil];
            [navigationController setViewControllers:@[objviewController] animated:NO];
            [self.window setRootViewController:navigationController];
        }
    }
    else{
        objviewController = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:nil];
        [navigationController setViewControllers:@[objviewController] animated:NO];
        [self.window setRootViewController:navigationController];
    }

    if([CommonFunctions isIphone])
        [self.navigationController setNavigationBarHidden:YES];
    
    [self googleAnalyticsLogs];     //Google analytics log events.

    [self.window setBackgroundColor:color_Background];
    [self.window makeKeyAndVisible];
    
    
    [AppsFlyerTracker sharedTracker].appleAppID = @"976960771"; // The Apple app ID. Example 34567899
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"CxRJvv6TPkDiGJXoEhNGx5";
    
    [ACTConversionReporter reportWithConversionID:@"960071792" label:@"MCXCCNf5yGAQ8JDmyQM" value:@"1.00" isRepeatable:NO];
    return YES;
}

- (void)googleAnalyticsLogs
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 1;
    [[[GAI sharedInstance] defaultTracker] setAllowIDFACollection:YES];
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticCode];
}

- (void)setLocationValue
{
    intOrientation = 0;
    iWatchListCounter = 0;
    
    //Remove Current location before updating. To fetch user current location each time.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"country"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"country"];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -90) forBarMetrics:UIBarMetricsDefault];
}

- (void)setnavigationBarImage
{
    UINavigationBar *navigationBar = [[self navigationController] navigationBar];
    if IS_IOS7_OR_LATER
        [navigationBar setBackgroundImage:[UIImage imageNamed:kNavigationBarImageName_ios7] forBarMetrics:UIBarMetricsDefault];
    if(![CommonFunctions isIphone])
    {
        UINavigationBar *navigationBar = [[self navigationController] navigationBar];
        if IS_IOS7_OR_LATER
            [navigationBar setBackgroundImage:[UIImage imageNamed:kNavigationBarImageName_ios7] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunch]; //***** THIS LINE IS MANDATORY *****
    
    // (Optional) to get AppsFlyer's attribution data you can use AppsFlyerTrackerDelegate as follow . Note that the callback will fail as long as the appleAppID and developer key are not set properly.
    [AppsFlyerTracker sharedTracker].delegate = self; //Delegate methods below
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)checkOrientation:(int)intOrientation1
{
    if (intOrientation1 == 0)
    {
        
    }
    else
    {
        
    }
}

@end