//
//  SettingViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 09/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SettingViewController.h"
#import "CategoriesCustomCell.h"
#import "CustomControls.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"
#import "LiveNowFeaturedViewController.h"
#import "LanguageViewController.h"
#import "LoginUserInfo.h"
#import "NSIUtility.h"
#import "LoginViewController.h"
#import "FeedbackViewController.h"
#import "CompanyInfoViewController.h"
#import "FAQViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CommonFunctions.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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


    [self setFonts];
    
    if (![CommonFunctions isIphone] && !IS_IOS7_OR_LATER) {
        self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    }
    else{
        if ([CommonFunctions userLoggedIn])
            self.contentSizeForViewInPopover = CGSizeMake(320, 470);
        else
            self.contentSizeForViewInPopover = CGSizeMake(320, 430);
    }
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppDelegate.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(settingsBarButtonItemAction)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    if ([CommonFunctions isIphone]) {
        [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - 50 delegate:self]];
    }
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabbarLiveNow" object:nil];

    lblHeader.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"settings" value:@"" table:nil];
    [tblSettings reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
}

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 1;
}

- (void)removeMelodyButton
{
    for (int i = 0; i < [[self.navigationController.navigationBar subviews] count]; i++) {
        
        if ([[[self.navigationController.navigationBar subviews] objectAtIndex:i] isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)[[self.navigationController.navigationBar subviews] objectAtIndex:i];
            if (btn.tag == 5000) {
                [[[self.navigationController.navigationBar subviews] objectAtIndex:i] removeFromSuperview];
            }
        }
    }
}

-(void) refreshTableView
{
    [tblSettings reloadData];
}

#pragma mark - Set Fonts
-(void) setFonts
{
    [lblHeader setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
}

#pragma mark - Pop To last Controller
-(void) settingsBarButtonItemAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabbarLiveNow" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![CommonFunctions isIphone]) {
        return 52;
    }
    return 49;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([CommonFunctions userLoggedIn])
        return [arrSignedInUserSettingsOptions count];
    else
        return [arrLogedOutUserSettingsOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([CommonFunctions isIphone]) {
        static NSString *cellIdentifier = @"cell";
        CategoriesCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell==nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoriesCustomCell" owner:self options:nil] firstObject];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if([CommonFunctions userLoggedIn])
        {
            cell.lblCategories.text = [arrSignedInUserSettingsOptions objectAtIndex:indexPath.row];
            if(indexPath.row == 0)
                cell.lblCategories.text = [NSString stringWithFormat:@"%@: %@",[arrSignedInUserSettingsOptions objectAtIndex:indexPath.row],[[NSUserDefaults standardUserDefaults] valueForKey:kUserNameKey]];
        }
        else
            cell.lblCategories.text = [arrLogedOutUserSettingsOptions objectAtIndex:indexPath.row];
        
        cell.lblCategories.text = cell.lblCategories.text;
        
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        UIImageView *imgVwCellBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 52)];
        imgVwCellBack.backgroundColor = [UIColor clearColor];
        imgVwCellBack.image = [UIImage imageNamed:@"channel_list_cell_bg"];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        lbl.backgroundColor = [UIColor clearColor];
        if([CommonFunctions userLoggedIn])
        {
            lbl.text = [[arrSignedInUserSettingsOptions objectAtIndex:indexPath.row] uppercaseString];
            if(indexPath.row == 0)
                lbl.text = [[NSString stringWithFormat:@"%@ %@",[arrSignedInUserSettingsOptions objectAtIndex:indexPath.row],[[NSUserDefaults standardUserDefaults] valueForKey:kUserNameKey]] uppercaseString];
        }
        else
            lbl.text = [[[arrLogedOutUserSettingsOptions objectAtIndex:indexPath.row] uppercaseString] uppercaseString];
        
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
        [cell.contentView addSubview:imgVwCellBack];
        [cell.contentView addSubview:lbl];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    if(![CommonFunctions userLoggedIn])
    {
        switch (indexPath.row)
        {
            case 0:
            {
                if([CommonFunctions isIphone])
                {
                    [self showLoginView];
                }
                else if ([_delegate respondsToSelector:@selector(loginUser)]) {
                    
                    [_delegate loginUser];
                }
                break;
            }
            case (int)changeLanguageForGeneralUser:
            {
                [tblSettings reloadData];
                if (![CommonFunctions isIphone]) {
                    if ([_delegate respondsToSelector:@selector(changeLanguage)]) {
                        
                        [_delegate changeLanguage];
                    }
                }
                else
//                    [CommonFunctions pushViewController:self.navigationController ViewController:objLanguageViewController];
                    objLanguageViewController.isFromSettings = YES;
                    [self.navigationController pushViewController:objLanguageViewController animated:YES];

                break;
            }
            case (int)FAQ:
            {
                FAQViewController *objFAQViewController = [[FAQViewController alloc] init];

                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    if ([CommonFunctions isIphone])
                        [self.navigationController pushViewController:objFAQViewController animated:YES];
                    else
                    {
                        if ([_delegate respondsToSelector:@selector(FAQCallBackMethod)])
                            [_delegate FAQCallBackMethod];
                    }
                }

                break;
            }
                
            case (int)sendFeedback:
            {
                if (![CommonFunctions isIphone]) {
                    if ([_delegate respondsToSelector:@selector(sendFeedback)]) {
                        
                        [_delegate sendFeedback];
                    }
                }
                else
                {
                    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
                    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
                }
                break;
            }
            case (int)companyTermsCondition:
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    if (![CommonFunctions isIphone]) {
                        
                        if ([_delegate respondsToSelector:@selector(companyInfoSelected:)]) {
                            [_delegate companyInfoSelected:(int)companyTermsCondition];
                        }
                    }
                    else
                    {
                        CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] init];
                        objCompanyInfoViewController.iInfoType = (int)companyTermsCondition;
                        [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
                    }
                }
                break;
            }
                
            case (int)companyPrivacyPolicy:
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    if (![CommonFunctions isIphone]) {
                        
                        if ([_delegate respondsToSelector:@selector(companyInfoSelected:)]) {
                            [_delegate companyInfoSelected:(int)companyPrivacyPolicy];
                        }
                    }
                    else
                    {
                        CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] init];
                        objCompanyInfoViewController.iInfoType = (int)companyPrivacyPolicy;
                        [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
                    }
                }
                break;
            }
            default:
               // [CommonFunctions showAlertView:kUnderConstructionErrorMessage TITLE:kEmptyString Delegate:self];
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case (int)profile:
                break;
            case (int)changeLanguage:
            {
                [tblSettings reloadData];

                if (![CommonFunctions isIphone]) {
                    if ([_delegate respondsToSelector:@selector(changeLanguage)]) {
                        [_delegate changeLanguage];
                    }
                }
                else
                    objLanguageViewController.isFromSettings = YES;
                    [self.navigationController pushViewController:objLanguageViewController animated:YES];
                break;
            }
            case (int)FAQ:
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
                    if ([CommonFunctions isIphone])
                        [self.navigationController pushViewController:objFAQViewController animated:YES];
                    else
                    {
                        if ([_delegate respondsToSelector:@selector(FAQCallBackMethod)])
                            [_delegate FAQCallBackMethod];
                    }
                }
                break;
            }
            case (int)logout:
            {
                [FBSession.activeSession closeAndClearTokenInformation];
                [FBSession.activeSession close];
                [FBSession setActiveSession:nil];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *dict;
                @try
                {
                    dict = [NSDictionary dictionaryWithObject:[defaults objectForKey:@"udid"] forKey:@"DeviceID"];
                }
                @catch (NSException *exception)
                {
                    dict = [NSDictionary dictionaryWithObject:@"123" forKey:@"DeviceID"];
                }
                LoginUserInfo *objLoginUserInfo = [LoginUserInfo new];
                [objLoginUserInfo logoutUser:self selector:@selector(logoutServerResponse:) parameters:dict];
                break;
            }
            case (int)sendFeedback:
            {
                if (![CommonFunctions isIphone]) {
                    if ([_delegate respondsToSelector:@selector(sendFeedback)]) {
                        
                        [_delegate sendFeedback];
                    }
                }
                else
                {
                    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
                    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
                }
                break;
            }
            case (int)companyTermsCondition:
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    if (![CommonFunctions isIphone]) {
                        if ([_delegate respondsToSelector:@selector(companyInfoSelected:)]) {
                            [_delegate companyInfoSelected:(int)companyTermsCondition];
                        }
                    }
                    else
                    {
                        CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] init];
                        objCompanyInfoViewController.iInfoType = (int)companyTermsCondition;
                        [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
                    }
                }
                break;
            }
                
            case (int)companyPrivacyPolicy:
            {
                
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    if (![CommonFunctions isIphone]) {
                        
                        if ([_delegate respondsToSelector:@selector(companyInfoSelected:)]) {
                            [_delegate companyInfoSelected:(int)companyPrivacyPolicy];
                        }
                    }
                    else
                    {
                        CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] init];
                        objCompanyInfoViewController.iInfoType = (int)companyPrivacyPolicy;
                        [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
                    }
                }
                break;
            }

            default:
               // [CommonFunctions showAlertView:kUnderConstructionErrorMessage TITLE:kEmptyString Delegate:self];
                break;
        }
    }
}

#pragma mark - Server Response
- (void)logoutServerResponse:(NSArray*)arrResponse
{
    //LiveNowFeaturedViewController *objLiveNowFeaturedViewController = [[LiveNowFeaturedViewController alloc] init];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIDKey];
    
//    if (![CommonFunctions isIphone])
    {
        
        if ([_delegate respondsToSelector:@selector(userSucessfullyLogout)]) {
            [_delegate userSucessfullyLogout];
        }
        
        [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"user logged out" value:@"" table:nil]];
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.iWatchListCounter = 0;
        
        [tblSettings reloadData];
    }
    
//    if ([CommonFunctions isIphone])
//    {
//        [CommonFunctions pushViewController:self.navigationController ViewController:objLiveNowFeaturedViewController];
//    }
}

#pragma mark - Show Login Screen
- (void)showLoginView
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegate = self;
    objLoginViewController.selector = @selector(refreshTableView);
    
    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    [objLoginViewController.view setFrame:CGRectMake(0, windowHeight, self.view.frame.size.width, windowHeight)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:objLoginViewController.view];
    [UIView animateWithDuration:0.5f animations:^{
        [objLoginViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, windowHeight)];
    } completion:nil];
}


#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:self.view.frame.size.height - 50]];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end