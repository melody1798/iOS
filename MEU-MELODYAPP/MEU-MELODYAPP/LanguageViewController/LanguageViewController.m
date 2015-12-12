//
//  LanguageViewController.m
//  MEU-MELODYAP
//
//  Created by Nancy Kashyap on 15/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CommonFunctions.h"
#import "NSIUtility.h"
#import "Constant.h"
#import "VODMoviesFeaturedViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "CustomControls.h"

@interface LanguageViewController ()

//Methods
- (IBAction)btnArablicLanguage:(id)sender;
- (IBAction)btnEnglishLanguage:(id)sender;
- (IBAction)btnDismissAction:(id)sender;

@end

@implementation LanguageViewController

@synthesize isFromSettings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([CommonFunctions isIphone] && isFromSettings) {
        [self.navigationController.navigationBar setHidden:NO];
        self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    }
    else
    {
        [self.navigationController.navigationBar setHidden:YES];
    }
    if([CommonFunctions isIphone5])
    {
        [imgBackground setImage:[UIImage imageNamed:kSelectLanguageImageNameiPhone5]];
    }
    else
    {
        [imgBackground setImage:[UIImage imageNamed:kSelectLanguageImageName]];
    }
    
    if (![CommonFunctions isIphone5]) {
        constraintTopSpaceEnglish.constant = 275;
        constraintTopSpaceArabic.constant = 275;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if ([CommonFunctions isIphone]) {
        [self.navigationController.navigationBar setHidden:NO];
    }
}

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnEnglishLanguage:(id)sender;
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"country"] length] == 0) {
        [self fetchCurrentCountry];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:kEnglish forKey:kSelectedLanguageKey];
    [userDefaults synchronize];
    
    if ([[userDefaults objectForKey:@"country"] length]!=0) {
        
        if (![CommonFunctions isIphone]) {
            
            LiveNowFeaturedViewController *objLiveNowFeaturedViewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController" bundle:nil];
            [self.navigationController pushViewController:objLiveNowFeaturedViewController animated:NO];
            [self popViewAfterLanguageSelect];
        }
        else
        {
            if (isFromSettings == YES) {
                [self goToLiveNowScreen];
            }
            else
            {
                CustomUITabBariphoneViewController *objCustomUITabBariphoneViewController = [[CustomUITabBariphoneViewController alloc] init];
                [self.navigationController pushViewController:objCustomUITabBariphoneViewController animated:YES];
            }
        }
    }
    else{
        BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
        if (locationAllowed == NO) {

        }
    }
}

- (IBAction)btnArablicLanguage:(id)sender
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"country"] length] == 0) {
        [self fetchCurrentCountry];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:kArabic forKey:kSelectedLanguageKey];
    [userDefaults synchronize];
    
    if ([[userDefaults objectForKey:@"country"] length]!=0) {
        
        if (![CommonFunctions isIphone]) {
            
            LiveNowFeaturedViewController *objLiveNowFeaturedViewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController" bundle:nil];
            [self.navigationController pushViewController:objLiveNowFeaturedViewController animated:NO];
            [self popViewAfterLanguageSelect];
        }
        else
        {
            if (isFromSettings == YES) {
                [self goToLiveNowScreen];
            }
            else
            {
                CustomUITabBariphoneViewController *objCustomUITabBariphoneViewController = [[CustomUITabBariphoneViewController alloc] init];
                [self.navigationController pushViewController:objCustomUITabBariphoneViewController animated:YES];
            }
        }
    }
    else{
        BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
        if (locationAllowed == NO) {
        }
    }
}

-(void)pushtoHome
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

//    if ([[userDefaults objectForKey:@"country"] length]!=0) {
    
        if (![CommonFunctions isIphone])
        {
            LiveNowFeaturedViewController *objLiveNowFeaturedViewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController" bundle:nil];
            [self.navigationController pushViewController:objLiveNowFeaturedViewController animated:NO];
            [self popViewAfterLanguageSelect];
        }
        else
        {
            if (isFromSettings == YES) {
                [self goToLiveNowScreen];
            }
            else
            {
                CustomUITabBariphoneViewController *objCustomUITabBariphoneViewController = [[CustomUITabBariphoneViewController alloc] init];
                [self.navigationController pushViewController:objCustomUITabBariphoneViewController animated:NO];
            }
        }
//    }
//    else
//    {
//        BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
//        if (locationAllowed == NO) {
//        }
//    }
}

- (void)popViewAfterLanguageSelect
{
    if ([_delegate respondsToSelector:@selector(changeLanguageMethod)]) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [_delegate changeLanguageMethod];
    }
}

- (void)goToLiveNowScreen
{
    LiveNowFeaturedViewController *objLiveNowFeaturedViewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController" bundle:nil];
    
    if ([CommonFunctions isIphone])
    {
        //TabBarSelectAfterLanguageChange
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarSelectAfterLanguageChange" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VODTabBarChangeLanguage" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self.navigationController pushViewController:objLiveNowFeaturedViewController animated:YES];
}

- (IBAction)btnDismissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchCurrentCountry
{
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [CommonFunctions showAlertView:nil TITLE:@"Please check your internet connection." Delegate:nil];
    }
    else
    {
        NSMutableURLRequest *requestHTTP = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://freegeoip.net/json/"]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [requestHTTP setHTTPMethod:@"GET"];
        [requestHTTP setValue: @"text/json" forHTTPHeaderField:@"Accept"];
        
        [NSURLConnection sendAsynchronousRequest:requestHTTP queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError)
            {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
                NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSString *strCountry = [responseDict valueForKey:@"country_name"];
                [[NSUserDefaults standardUserDefaults] setObject:strCountry forKey:@"country"];
                
                [self pushtoHome];
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            }
        }];
    }
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end