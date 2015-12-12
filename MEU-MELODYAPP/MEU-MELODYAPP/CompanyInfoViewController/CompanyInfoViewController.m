//
//  CompanyInfoViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 22/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CompanyInfoViewController.h"
#import "CompanyInfo.h"
#import "UIImageView+WebCache.h"
#import "CustomControls.h"
#import "SettingViewController.h"
#import "popoverBackgroundView.h"
#import "SearchVideoViewController.h"
#import "LanguageViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"
#import "FeedbackViewController.h"
#import "MovieDetailViewController.h"
#import "FAQViewController.h"
#import "VODSearchController.h"

@interface CompanyInfoViewController () <UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, UIPopoverControllerDelegate>
{
    IBOutlet UIImageView*       imgVwCompanyLogo;   //Meu company logo
    IBOutlet UILabel*           lblCompanyInfoType; //termsofconditions/privacy policy
    IBOutlet UITextView*        txtVwCompanyInfo;   //content textview
    SettingViewController*      objSettingViewController;
    UIPopoverController*        popOverSearch;
    SearchVideoViewController*  objSearchVideoViewController;
    LoginViewController*        objLoginViewController;
    VODSearchController*        objVODSearchController;
}

@property (strong, nonatomic) UISearchBar*  searchBarVOD;
@property (strong, nonatomic) NSString*     strCompanyLogo;
@property (strong, nonatomic) NSString*     strCompanyDesc;

@end

@implementation CompanyInfoViewController

@synthesize iInfoType;

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
    
    //iad
    if ([CommonFunctions isIphone]) {
        [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - 50 delegate:self]];
    }
    else
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];

    [self setNavigationBarButtons]; //Add navigation bar buttons
    [self setUI];   //setup UI
    
    [self fetchCompanyInfo:iInfoType];   //fetch data from server
}

- (void)fetchCompanyInfo:(int)infoType
{
    CompanyInfo *objCompanyInfo = [CompanyInfo new];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        [objCompanyInfo fetchCompanyInformation:self selector:@selector(companyInfoServerResponse:) isArb:@"false" infoType:infoType];
    else
        [objCompanyInfo fetchCompanyInformation:self selector:@selector(companyInfoServerResponse:) isArb:@"true" infoType:infoType];
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    
    if (![CommonFunctions isIphone]) {
        
        self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
    }
}

#pragma mark - Navigationbar buttons actions
- (void)settingsBarButtonItemAction
{
    objSettingViewController = [[SettingViewController alloc] init];
    objSettingViewController.delegate = self;
    popOverSearch = [[UIPopoverController alloc] initWithContentViewController:objSettingViewController];
    popOverSearch.popoverBackgroundViewClass = [popoverBackgroundView class];
    
    [popOverSearch setDelegate:self];
    
    CGRect rect;
    rect.origin.x = 370;
    if (IS_IOS7_OR_LATER && ![CommonFunctions userLoggedIn])
        rect.origin.y = 85;
    else if (IS_IOS7_OR_LATER && [CommonFunctions userLoggedIn])
        rect.origin.y = 85;
    else
        rect.origin.y = 20;
    
    rect.size.width = 350;
    rect.size.height = 399;
    if ([CommonFunctions userLoggedIn]) {
        rect.size.height = 470;
    }
    else
        rect.size.height = 430;
    
    [popOverSearch presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
}

- (void)searchBarButtonItemAction
{
    objVODSearchController = [[VODSearchController alloc] initWithNibName:@"VODSearchController" bundle:nil];
    [self.navigationController pushViewController:objVODSearchController animated:NO];
    objVODSearchController = nil;
}

- (void)backBarButtonItemAction
{
    if ([CommonFunctions isIphone])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UI Methods
- (void)setUI
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        txtVwCompanyInfo.textAlignment = NSTextAlignmentJustified;
    else
        txtVwCompanyInfo.textAlignment = NSTextAlignmentLeft;

    lblCompanyInfoType.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?16:22.0];
    txtVwCompanyInfo.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?13:16.0];
    
    if (iInfoType == (int)companyPrivacyPolicy)
        
        lblCompanyInfoType.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"privacypolicy" value:@"" table:nil];
    else
        lblCompanyInfoType.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"termsofuse" value:@"" table:nil];
}

- (void)showSearchPopOver
{
    objSearchVideoViewController = [[SearchVideoViewController alloc] initWithNibName:@"SearchVideoViewController" bundle:nil];
    objSearchVideoViewController.iSectionType = 2;
    objSearchVideoViewController.delegate = self;
    
    popOverSearch = [[UIPopoverController alloc] initWithContentViewController:objSearchVideoViewController];
    popOverSearch.popoverBackgroundViewClass = [popoverBackgroundView class];
    [popOverSearch setDelegate:self];
    popOverSearch.passthroughViews = [NSArray arrayWithObject:self.searchBarVOD];
    
    CGRect rect;
    rect.origin.x = -50;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        rect.origin.y = 40;
    else
        rect.origin.y = 350;
    
    rect.size.width = 450;
    rect.size.height = 661;
    
    [popOverSearch presentPopoverFromRect:rect inView:self.searchBarVOD permittedArrowDirections:0 animated:YES];
}

#pragma mark - Server Response

- (void)companyInfoServerResponse:(CompanyInfo*)objCompanyInfo
{
    [imgVwCompanyLogo sd_setImageWithURL:[NSURL URLWithString:objCompanyInfo.companyLogoUrl] placeholderImage:[UIImage imageNamed:@"sign_up_logo_top.png"]];
    
    [self setUI];
    [self setTextData:objCompanyInfo.companyInfo];  //Set data on UI
}

- (void)setTextData:(NSString*)str
{
    [txtVwCompanyInfo setText:str];
}

#pragma mark - Play VOD search program

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    //Handle VOD Search result.
    MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
    objMovieDetailViewController.strMovieId = videoId;
    [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
}

#pragma mark - Settings Delegate

- (void)userSucessfullyLogout
{
    //Logout user
    [popOverSearch dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
}

- (void)changeLanguage
{
    //Show change language view controller.
    [popOverSearch dismissPopoverAnimated:YES];
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    objLanguageViewController.delegate = self;
    [self presentViewController:objLanguageViewController animated:YES completion:nil];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginView];
}

- (void)changeLanguageMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    [self fetchCompanyInfo:iInfoType];
}

- (void)changeLanguageFromLiveNow
{
    [self fetchCompanyInfo:iInfoType];
}

- (void)showLoginView
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

- (void)companyInfoSelected:(int)infoType
{
    iInfoType = infoType;
    [popOverSearch dismissPopoverAnimated:YES];
    [self fetchCompanyInfo:infoType];
}

- (void)sendFeedback
{
    [popOverSearch dismissPopoverAnimated:YES];
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    [popOverSearch dismissPopoverAnimated:YES];
    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQViewController animated:YES];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [objSearchVideoViewController handleSearchText:self.searchBarVOD.text searchCat:2];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //If iAd fails.
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

#pragma mark - Memory Management methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end