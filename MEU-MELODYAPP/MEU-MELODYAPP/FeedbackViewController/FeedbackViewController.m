//
//  FeedbackViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 24/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommonFunctions.h"
#import "CompanyInfo.h"
#import "CustomControls.h"
#import "SettingViewController.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "LanguageViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MovieDetailViewController.h"
#import "CompanyInfoViewController.h"
#import "NSIUtility.h"
#import "FAQViewController.h"
#import "VODSearchController.h"

@interface FeedbackViewController () <ChannelProgramPlay, SettingsDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, LanguageSelectedDelegate, UITextFieldDelegate, UITextViewDelegate, SettingsDelegate>
{
    IBOutlet UIButton*          btnSendFeedback;
    IBOutlet UIButton*          btnCancel;
    IBOutlet UILabel*           lblFeedback;
    IBOutlet UILabel*           lblComposeEmail;
    IBOutlet UITextField*       txtFieldSubject;
    IBOutlet UITextView*        txtVwFeedback;
    SettingViewController*      objSettingViewController;
    UIPopoverController*        popOverSearch;
    SearchVideoViewController*  objSearchVideoViewController;
    LoginViewController*        objLoginViewController;
    VODSearchController*        objVODSearchController;
}

@property (strong, nonatomic) UISearchBar*  searchBarVOD;

- (IBAction)btnSendFeedback:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnResignKeypad:(id)sender;

@end

@implementation FeedbackViewController

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
    
    //Add iAd
    if ([CommonFunctions isIphone]) {
        [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - 50 delegate:self]];
    }
    else
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-60 delegate:self]];

    [self setNavigationBarButtons]; //Set navigation button
    [self setUI];       //Set UI to set font and localized language.
}

- (void)setUI
{
    btnSendFeedback.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?17.0:22.0];
    btnCancel.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?17.0:22.0];
    lblFeedback.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?17:22.0];
    txtFieldSubject.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?14:22.0];
    
    txtVwFeedback.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?15.0:30.0];
    [lblFeedback setFont:[UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?16:22.0]];
    [lblComposeEmail setFont:[UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?14:22.0]];
    
    [lblFeedback setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"feedback" value:@"" table:nil]];
    [btnCancel setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cancel" value:@"" table:nil] forState:UIControlStateNormal];
    [btnSendFeedback setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"send" value:@"" table:nil] forState:UIControlStateNormal];
    
    txtFieldSubject.placeholder = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"subject" value:@"" table:nil];
    lblComposeEmail.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"compose mail" value:@"" table:nil];
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
    //Show settings pop over.
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
    if ([CommonFunctions isIphone]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - Feedback server response
- (void)feedbackServerResponse:(NSDictionary*)dictResponse
{
    //Handle feedback server response.
    [txtFieldSubject resignFirstResponder];
    [txtVwFeedback resignFirstResponder];
    
    if ([[dictResponse objectForKey:@"error"] integerValue] == 0) {
        txtFieldSubject.text = @"";
        txtVwFeedback.text = @"";
        lblComposeEmail.hidden = NO;
    }
}

#pragma mark - IBAction Methods
- (IBAction)btnSendFeedback:(id)sender
{
    //Send feedback to server.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
    {
        NSString *strSubject = txtFieldSubject.text;
        if ([txtFieldSubject.text length] == 0) {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter subject" value:@"" table:nil]];
            return;
        }
        if ([txtVwFeedback.text length] == 0) {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter content" value:@"" table:nil]];
            return;
        }
        NSString *strContent = txtVwFeedback.text;
        if ([txtVwFeedback.text length] == 0) {
            strContent = @" ";
        }
        
        [txtFieldSubject resignFirstResponder];
        [txtVwFeedback resignFirstResponder];
        
        //UserId ,Subject ,Content
        //Send values to send feedback.
        CompanyInfo *objCompanyInfo = [CompanyInfo new];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], strSubject, strContent, nil] forKeys:[NSArray arrayWithObjects:@"UserId", @"Subject", @"Content", nil]];
        
        [objCompanyInfo sendFeedback:self selector:@selector(feedbackServerResponse:) parmeters:dict];
    }
    else
    {
        //Show login view if user is not logged in.
        [self showLoginView];
    }
}

- (IBAction)btnCancel:(id)sender
{
    if ([CommonFunctions isIphone]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //If cancel then no feedback send.
        if ([_delegate respondsToSelector:@selector(cancelSendingFeedback)]) {
            [_delegate cancelSendingFeedback];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)btnResignKeypad:(id)sender
{
    [txtFieldSubject resignFirstResponder];
    [txtVwFeedback resignFirstResponder];
}

#pragma mark - Play VOD search program

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    //Handle VOD search result an dnavigate to movie detail screen.
    MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
    objMovieDetailViewController.strMovieId = videoId;
    [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
}

#pragma mark - Settings Delegate
- (void)userSucessfullyLogout
{
    //Logout user.
    [popOverSearch dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
}

- (void)changeLanguage
{
    //Show language viewcontroller.
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

    [self setUI];
}

- (void)changeLanguageFromLiveNow
{
    [self setUI];
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
    [popOverSearch dismissPopoverAnimated:YES];
    
    CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] initWithNibName:@"CompanyInfoViewController" bundle:nil];
    objCompanyInfoViewController.iInfoType = infoType;
    [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
}

- (void)sendFeedback
{
    [popOverSearch dismissPopoverAnimated:YES];
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
    //Handle search in VOD
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


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *subVw = [self.view viewWithTag:textField.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"sign_up_txt_active"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *subVw = [self.view viewWithTag:textField.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"sign_up_txt_inactive"];
    }
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    lblComposeEmail.hidden = YES;
    UIView *subVw = [self.view viewWithTag:textView.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"comment_active"];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0)
        lblComposeEmail.hidden = NO;
    else
        lblComposeEmail.hidden = YES;
    
    UIView *subVw = [self.view viewWithTag:textView.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"comment_inactive"];
    }
}

#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //If iAd fails, load admob.
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

#pragma mark - Memory Management Method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end