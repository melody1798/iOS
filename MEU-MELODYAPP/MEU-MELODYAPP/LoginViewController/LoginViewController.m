//
//  LoginViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LoginViewController.h"
#import "LiveNowFeaturedViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Constant.h"
#import "LoginUserInfo.h"
#import "NSIUtility.h"
#import "SignUpViewController.h"
#import "SignUpUser.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "WatchListMovies.h"
#import <Social/Social.h>

static float kAnimateDutarion = 0.5;
static int originalTopPosition = 0.0;

@interface LoginViewController () <UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton*      btnLogin;
    IBOutlet UIButton*      btnSignUp;
    IBOutlet UIButton*      btnFacebookLogin;
    IBOutlet UITextField*   txtFieldUserName;
    IBOutlet UITextField*   txtFieldPassword;
    IBOutlet UIImageView*   imgVwUserName;
    IBOutlet UIImageView*   imgVwPassword;
    UITextField*            txtCurrentActive;
    LoginUserInfo*          objLoginUserInfo;
    SignUpUser*             objSignUpUser;
    IBOutlet UIButton*      btnForgotPassword;
    IBOutlet UILabel*       lblOrText;
    SignUpViewController*   objSignUpViewController;
}

@property (strong, nonatomic) NSArray*              arrFriendList;

- (IBAction)btnResignKeypadAction:(id)sender;
- (IBAction)btnLoginAction:(id)sender;
- (IBAction)btnFacebookLoginAction:(id)sender;
- (IBAction)btnForgotPasswordAction:(id)sender;
- (IBAction)btnSignUpAction:(id)sender;
- (IBAction)btnCloseAction:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    [self.navigationController.navigationBar setHidden:YES];
    [self customizeWithFonts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setLocalizedText];
    [self.navigationController.navigationBar setHidden:YES];
}

#pragma mark - Set UI
-(void) setUI
{
    if(iPhone4WithIOS7)
    {
        CGRect rect = lblOr.frame;
        rect.origin.y -= 15;
        [lblOr setFrame:rect];
    }
}

- (void)setLocalizedText
{
    [btnLogin setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"login" value:@"" table:nil] forState:UIControlStateNormal];
    [btnSignUp setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"sign up" value:@"" table:nil] forState:UIControlStateNormal];
    [btnForgotPassword setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"forgot your password" value:@"" table:nil] forState:UIControlStateNormal];
    [btnFacebookLogin setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"loginwithfacebook" value:@"" table:nil] forState:UIControlStateNormal];
    
    [txtFieldUserName setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"email" value:@"" table:nil]];
    [txtFieldPassword setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"password" value:@"" table:nil]];
    
    [lblOrText setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"or" value:@"" table:nil]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - Customize UI
- (void)customizeWithFonts
{
    btnLogin.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 14.0 : 20.0];
    btnSignUp.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 14.0 : 20.0];
    btnForgotPassword.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 11.0 : 20.0];
    [lblOr setFont:[UIFont fontWithName:kProximaNova_Regular size:10.0]];
    if([CommonFunctions isIphone5])
    {
        if ([txtFieldUserName respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldUserName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"username" attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldPassword respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: color}];
        }
    }
}


#pragma mark - IBActions
- (IBAction)btnForgotPasswordAction:(id)sender
{
    if([CommonFunctions isIphone5])
        [UIView animateWithDuration:kAnimateDutarion animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, originalTopPosition, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"enter email" value:@"" table:nil] message:nil delegate:self cancelButtonTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"ok" value:@"" table:nil] otherButtonTitles:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cancel" value:@"" table:nil], nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        if ([alertTextField.text length] == 0) {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:kEmailErrorMessage value:@"" table:nil]];
        }
        else if(![NSIUtility validateEmailWithString:alertTextField.text])
        {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please enter valid email" value:@"" table:nil]];
        }
        else{
            if (objLoginUserInfo == nil) {
                objLoginUserInfo = [LoginUserInfo new];
            }
//            [objLoginUserInfo ForgotPassword:self selector:@selector(forgotPasswordServerResponse:) parameters:[NSDictionary dictionaryWithObject:alertTextField.text forKey:@"Email"]];
            
            NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";
            [objLoginUserInfo ForgotPassword:self selector:@selector(forgotPasswordServerResponse:) parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:alertTextField.text, isArb, nil] forKeys:[NSArray arrayWithObjects:@"Email", @"isArb", nil]]];
        }
    }
}

- (void)forgotPasswordServerResponse:(NSDictionary*)dict
{
    
}

- (IBAction)btnResignKeypadAction:(id)sender{
    
    [txtCurrentActive resignFirstResponder];
}

- (IBAction)btnLoginAction:(id)sender
{
    txtFieldUserName.text = [txtFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    txtFieldPassword.text = [txtFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Check validations before login.
    if ([txtFieldUserName.text length] == 0)
    {
        [NSIUtility showAlertView:nil message:kEmailErrorMessage];
    }
    else if(![NSIUtility validateEmailWithString:txtFieldUserName.text])
    {
        [NSIUtility showAlertView:nil message:kValidEmailErrorMessage];
    }
    else if ([txtFieldPassword.text length] == 0)
    {
        [NSIUtility showAlertView:nil message:kPasswordErrorMessage];
    }
    else if([NSIUtility validateEmailWithString:txtFieldUserName.text])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        NSString *uuidString = [NSString stringWithString:(__bridge NSString *)
                          uuidStringRef];
        CFRelease(uuidStringRef);
        
        
//        NSString *uuidString = @"";
//        CFUUIDRef uuid = CFUUIDCreate(NULL);
//        if (uuid)
//        {
//            uuidString = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
//            CFRelease(uuid);
//        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:uuidString forKey:@"udid"];
        [defaults synchronize];
        
        NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";
        NSDictionary *dictParameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtFieldUserName.text, txtFieldPassword.text, uuidString, isArb,nil] forKeys:[NSArray arrayWithObjects:@"Email", @"Password", @"DeviceID", @"isArb", nil]];
        
        if (objLoginUserInfo == nil)
        {
            objLoginUserInfo = [LoginUserInfo new];
        }
        [objLoginUserInfo loginUser:self selector:@selector(loginResponse:) parameters:dictParameters];
    }
}

- (IBAction)btnCloseAction:(id)sender
{
    if([CommonFunctions isIphone])
    {
        _delegate = Nil;
    }
    [self closeView];
}

- (void)closeView
{
    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setFrame:CGRectMake(0, windowHeight, self.view.frame.size.width, windowHeight)];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    if([CommonFunctions isIphone])
    {
        if(_delegate)
        {
            SuppressPerformSelectorLeakWarning([_delegate performSelector:_selector withObject:nil]);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - validate
-(BOOL) validate
{
    if([[CommonFunctions shared] isInValidString:txtFieldUserName StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kUserNameErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    else if([[CommonFunctions shared] isInValidString:txtFieldPassword StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kPasswordErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    
    return YES;
}

- (void)loginResponse:(NSDictionary *)response
{
    if ([[response objectForKey:@"Error"] intValue] == 0)
    {
        [self closeView];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]) {
            
            //Fetch watchlist to show counter in navigation bar
            WatchListMovies *objWatchListMovies = [WatchListMovies new];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"] forKey:@"userId"];
            [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
        }
        
        if ([CommonFunctions isIphone]) {
            if(_delegateUpdateMovie)
                [_delegateUpdateMovie updateMovieDetailViewAfterLogin];
        }
        
        if ([_delegateUpdateMovie respondsToSelector:@selector(updateMovieDetailViewAfterLogin)]) {
            [_delegateUpdateMovie updateMovieDetailViewAfterLogin];
        }
    }
}

- (void)watchListServerResponse:(NSArray*)arrResponse
{
    //Reset Watchlist counter.
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.iWatchListCounter = (int)[arrResponse count];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWatchListMovieCounter" object:nil];
}

- (IBAction)btnFacebookLoginAction:(id)sender
{
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    /* else
     {
     if (FBSession.activeSession.state == FBSessionStateOpen
     || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
     
     [self performSelector:@selector(getUserFacebookBasicInfo) withObject:nil afterDelay:0.0];
     }
     else {
     
     //            [FBSession openActiveSessionWithPublishPermissions:@[@"email,user_friends,user_about_me,user_birthday,user_education_history,user_hometown,user_interests,user_likes,user_location, user_photos, user_relationships,user_relationship_details,user_religion_politics,user_status,user_website,user_work_history"] defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
     
     [FBSession openActiveSessionWithPublishPermissions:@[@"user_friends,email"] defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
     if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)) {
     
     [self getUserFacebookBasicInfo];
     
     } else if (error) {
     
     //  [MBProgressHUD hideHUDForView:self.view animated:NO];
     [self handleError:error];
     }
     }];
     }
     }*/
    else
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            [FBSession openActiveSessionWithPublishPermissions:@[@"user_friends,email"] defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)) {
                    
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self performSelector:@selector(getUserFacebookBasicInfo) withObject:nil afterDelay:0.0];
                } else if (error) {
                    
                    //  [MBProgressHUD hideHUDForView:self.view animated:NO];
                    [self handleError:error];
                }
            }];
        }
        
        else
        {
            NSArray *fbPermissions = @[@"user_friends, email"];
            [FBSession setActiveSession: [[FBSession alloc] initWithPermissions:fbPermissions]];
            [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          switch (status) {
                                              case FBSessionStateOpen:
                                                  
                                                  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                  [self performSelector:@selector(getUserFacebookBasicInfo) withObject:nil afterDelay:0.0];
                                                  break;
                                              case FBSessionStateOpenTokenExtended:
                                                  
                                                  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                  [self performSelector:@selector(getUserFacebookBasicInfo) withObject:nil afterDelay:0.0];
                                                  break;
                                              case FBSessionStateClosedLoginFailed: {
                                                  [self handleError:error];
                                              }
                                                  break;
                                              default:
                                                  break;
                                          }
                                      }];
        }
    }
}

- (IBAction)btnSignUpAction:(id)sender
{
    // [self closeView];
    [self showSignUpView];
}

- (void)showSignUpView
{
    if (objSignUpViewController.view.superview) {
        return;
    }
    objSignUpViewController = nil;
    objSignUpViewController = [[SignUpViewController alloc] init];
    //  objLoginViewController.delegate = self;
    [self presentViewController:objSignUpViewController animated:YES completion:nil];
}

#pragma mark - Fetch Facebook user info
- (void)getUserFacebookBasicInfo
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
        } else {
            if (result) {
                NSDictionary *resultDict = (NSDictionary *)result;
                [self fetchFacbookFriends:resultDict];
            }
        }
    }];
}

- (void)fetchFacbookFriends:(NSDictionary*)resultDict
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    [FBRequestConnection startWithGraphPath:@"me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              self.arrFriendList = [[NSArray alloc] initWithArray:[result objectForKey:@"data"]];
                              [self login:resultDict];
                          }];
}

- (void)facebookLoginServerResponse:(NSDictionary*)response
{
    if ([[response objectForKey:@"Error"] intValue] == 0) {
        
        [self closeView];
        
        if ([_delegateUpdateMovie respondsToSelector:@selector(updateMovieDetailViewAfterLogin)]) {
            [_delegateUpdateMovie updateMovieDetailViewAfterLogin];
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]) {
            WatchListMovies *objWatchListMovies = [WatchListMovies new];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"] forKey:@"userId"];
            
            [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
        }
    }
}

- (void)login:(NSDictionary*)resultDict
{
    NSString *strGender;
    
    //Set values for gender selection.
    if ([[resultDict objectForKey:@"gender"] isEqualToString:@"male"]) {
        strGender = @"1";
    }
    else{
        strGender = @"2";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@ %@",[resultDict objectForKey:@"first_name"],[resultDict objectForKey:@"last_name"]] forKey:kUserNameKey];
    
    NSString *uuidString = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        uuidString = (__bridge NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uuidString forKey:@"udid"];
    [defaults synchronize];
    
    //Array change
    NSMutableArray *arrFb = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.arrFriendList count]; i++) {
        
        NSDictionary *dictFriend = [self.arrFriendList objectAtIndex:i];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[resultDict objectForKey:@"id"], [dictFriend objectForKey:@"id"], [dictFriend objectForKey:@"name"], nil] forKeys:[NSArray arrayWithObjects:@"UserID", @"FriendID", @"FriendName", nil]];
        
        [arrFb addObject:dict];
    }
    
    
    NSDictionary *dictParameters = [[NSDictionary alloc] init];
    NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";

    
    @try
    {
        dictParameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[resultDict objectForKey:@"first_name"], [resultDict objectForKey:@"last_name"], [resultDict objectForKey:@"email"], strGender, @"birthday", [resultDict objectForKey:@"id"], uuidString, @"CurrentCity", @"HomeTown", @"Website", @"Education", @"Personal_Description", arrFb, isArb, nil] forKeys:[NSArray arrayWithObjects:@"FirstName", @"LastName", @"Email", @"Gender", @"DateOfBirth", @"facebookId", @"DeviceID", @"CurrentCity", @"HomeTown", @"Website", @"Education", @"Personal_Description", @"FacebookFriends", @"isArb", nil]];
    }
    @catch (NSException *exception)
    {
        dictParameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[resultDict objectForKey:@"first_name"], [resultDict objectForKey:@"last_name"], [resultDict objectForKey:@"email"], strGender, @"birthday", [resultDict objectForKey:@"id"], uuidString, @"CurrentCity", @"HomeTown", @"Website", @"Education", @"Personal_Description", arrFb, isArb, nil] forKeys:[NSArray arrayWithObjects:@"FirstName", @"LastName", @"Email", @"Gender", @"DateOfBirth", @"facebookId", @"DeviceID", @"CurrentCity", @"HomeTown", @"Website", @"Education", @"Personal_Description", @"FacebookFriends", @"isArb", nil]];
    }
    
    objSignUpUser = [SignUpUser new];
    [objSignUpUser signUpFacebookUser:self selector:@selector(facebookLoginServerResponse:) parameters:dictParameters];
}

- (void)handleError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    NSString *alertText;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        
        alertText = [FBErrorUtility userMessageForError:error];
        //  [self showMessage:alertText withTitle:alertTitle];
        [CommonFunctions showAlertView:alertText TITLE:nil Delegate:nil];
    } else {
        // If the user cancelled login, do nothing
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            DLog(@"User cancelled login");
            
            // Handle session closures that happen outside of the app
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
            
            [CommonFunctions showAlertView:alertText TITLE:nil Delegate:nil];
            
            // Here we will handle all other errors
        } else {
            // Show the user an error message
            [CommonFunctions showAlertView:alertText TITLE:nil Delegate:nil];
        }
    }
    // Clear this token
    //  [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([CommonFunctions isIphone])
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if(textField == txtFieldPassword)
            return (newLength > 20) ? NO : YES;
        return (newLength > 50) ? NO : YES;
    }
    else
        return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([CommonFunctions isIphone])
        [btnForgotPassword setUserInteractionEnabled:NO];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:ACTIVE_TEXT_PLACEHOLDER}];
    
    txtCurrentActive = textField;
    if (textField == txtFieldUserName) {
        imgVwUserName.image = [UIImage imageNamed:kUserTextField_Active];
    }
    if (textField == txtFieldPassword) {
        imgVwPassword.image = [UIImage imageNamed:kPasswordTextField_Active];
    }
    
    if([CommonFunctions isIphone])
        if(self.view.frame.origin.y==0)
            [UIView animateWithDuration:kAnimateDutarion animations:^{
                [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - (![CommonFunctions isIphone5] ? 85:70), self.view.frame.size.width, self.view.frame.size.height)];
            }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: INACTIVE_TEXT_PLACEHOLDER}];
    
    if (textField == txtFieldUserName) {
        imgVwUserName.image = [UIImage imageNamed:kUserTextField_InActive];
    }
    if (textField == txtFieldPassword) {
        imgVwPassword.image = [UIImage imageNamed:kPasswordTextField_InActive];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if([CommonFunctions isIphone])
        [UIView animateWithDuration:kAnimateDutarion animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, originalTopPosition, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    [btnForgotPassword setUserInteractionEnabled:YES];
    return YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtCurrentActive resignFirstResponder];
    if([CommonFunctions isIphone])
        [UIView animateWithDuration:kAnimateDutarion animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, originalTopPosition, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    [btnForgotPassword setUserInteractionEnabled:YES];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end