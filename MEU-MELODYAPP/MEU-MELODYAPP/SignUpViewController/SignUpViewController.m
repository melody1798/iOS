//
//  SignUpViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpUser.h"
#import "CustomControls.h"
#import "Constant.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"

@interface SignUpViewController () <UITextFieldDelegate>
{
    IBOutlet UITextField*     txtFieldFirstName;
    IBOutlet UITextField*     txtFieldLastName;
    IBOutlet UITextField*     txtFieldEmail;
    IBOutlet UITextField*     txtFieldPassword;
    IBOutlet UITextField*     txtFieldConfirmPassword;
    IBOutlet UITextField*     txtFieldMonth;
    IBOutlet UITextField*     txtFieldDay;
    IBOutlet UITextField*     txtFieldYear;
    IBOutlet UIButton*        btnSignUp;
    IBOutlet UILabel*         lblAgree;
    IBOutlet UILabel*         lblMale;
    IBOutlet UILabel*         lblFemale;
    IBOutlet UIButton*        btnMaleGender;
    IBOutlet UIButton*        btnFemaleGender;
    UITextField*              txtFieldCurrent;
    IBOutlet UIView*          viewPickerVw;
    IBOutlet UIDatePicker*    pickerDate;
    NSString*                 strGender;
}

- (IBAction)btnGenderAction:(id)sender;
- (IBAction)btnSignUpAction:(id)sender;
- (IBAction)btnResignKeyPadAction:(id)sender;
- (IBAction)btnDoneAction;
- (IBAction)btnSelectDateAction;
- (IBAction)btnCloseAction:(id)sender;

@end

@implementation SignUpViewController
static int offsetToLift = 93;
static int offsetToLiftForIOS6 = 130;
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
    
    checkBoxChecked = true;

    [self setLocalizedText];
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppDelegate.navigationController setNavigationBarHidden:NO];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    [self setFontsAndTitles];
    
    if([CommonFunctions isIphone])
        [self.navigationController.navigationBar setHidden:YES];
    //By default gender selected
    strGender = [NSString stringWithFormat:@"0"];
    
    if(!IS_IOS7_OR_LATER && [CommonFunctions isIphone])
    {
        CGRect rect = imgBackground.frame;
        rect.origin.y += 35;
        [imgBackground setFrame:rect];
        
        rect = imgLogo.frame;
        rect.origin.y -= 20;
        [imgLogo setFrame:rect];
    }
    
    
    [self initUI];
}


#pragma Setup UI
-(void) initUI
{
    if([CommonFunctions isIphone5])
    {
        if ([txtFieldFirstName respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"first name" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldLastName respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"last name" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldEmail respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"email" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldPassword respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"password" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldConfirmPassword respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldConfirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"confirm password" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldMonth respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldMonth.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"month" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldDay respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldDay.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"day" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
        
        if ([txtFieldYear respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            UIColor *color = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            txtFieldYear.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"year" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)setLocalizedText
{
    [txtFieldFirstName setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"first name" value:@"" table:nil]];
    [txtFieldLastName setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"last name" value:@"" table:nil]];
    [txtFieldEmail setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"email" value:@"" table:nil]];
    [txtFieldPassword setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"password" value:@"" table:nil]];
    [txtFieldConfirmPassword setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"confirm password" value:@"" table:nil]];
    [txtFieldMonth setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"month" value:@"" table:nil]];
    [txtFieldDay setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"day" value:@"" table:nil]];
    [txtFieldYear setPlaceholder:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"year" value:@"" table:nil]];

    [lblAgree setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"signup agreement" value:@"" table:nil]];
    [btnSignUp setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"sign up" value:@"" table:nil] forState:UIControlStateNormal];
    
    [lblMale setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"i am male" value:@"" table:nil]];
    [lblFemale setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"i am female" value:@"" table:nil]];
    
    
    [lblbGender setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"GenderText" value:@"" table:nil]];

    
    [lblDateOfBirth setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"DateOfBirthText" value:@"" table:nil]];

}

#pragma mark - NavigationBar button action
- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Fonts
- (void)setFontsAndTitles
{
    btnSignUp.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?17.0:20.0];
    lblAgree.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?8.0:17.0];
    lblMale.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?10.0:17.0];
    lblFemale.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?10.0:17.0];
}

#pragma mark - IBAction Methods
- (IBAction)btnGenderAction:(id)sender
{
    checkBoxChecked = true;
    strGender = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    if (sender == btnMaleGender) {
        [btnMaleGender setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"radio_btn_active~iphone":@"radio_btn_active"] forState:UIControlStateNormal];
        [btnFemaleGender setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"radio_btn_inactive~iphone":@"radio_btn_inactive"] forState:UIControlStateNormal];
    }
    else{
        [btnMaleGender setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"radio_btn_inactive~iphone":@"radio_btn_inactive"] forState:UIControlStateNormal];
        [btnFemaleGender setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"radio_btn_active~iphone":@"radio_btn_active"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnResignKeyPadAction:(id)sender
{
    [self hightlightDOBTextArea:NO];
    [txtFieldCurrent resignFirstResponder];
    [viewPickerVw removeFromSuperview];
}

- (IBAction)btnDoneAction
{
    [self hightlightDOBTextArea:NO];
    [viewPickerVw removeFromSuperview];
    
    //Date picker date
    NSDate *birthday  = [pickerDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *componentsYear = [gregorian components:(NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:birthday];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    if (age < kSignupAgeRequired) {

        [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"signup age validation" value:@"" table:nil]];
    }
    else{
        //Set value in date month year fields
        txtFieldMonth.text = [NSString stringWithFormat:@"%ld", (long)[componentsYear month]];
        txtFieldDay.text = [NSString stringWithFormat:@"%ld", (long)[componentsYear day]];
        txtFieldYear.text = [NSString stringWithFormat:@"%ld", (long)[componentsYear year]];
    }
}

- (IBAction)btnSignUpAction:(id)sender
{
    if([self validate])
    {
        if (![kCommonFunction checkNetworkConnectivity])
        {
            [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
        }
        else
        {
            [btnSignUp setUserInteractionEnabled:NO];
            NSString *strDOB = [NSString stringWithFormat:@"%@/%@/%@", txtFieldMonth.text, txtFieldDay.text, txtFieldYear.text];
            NSString *isArb = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"false":@"true";

            
            NSDictionary *dictParameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtFieldFirstName.text, txtFieldLastName.text, txtFieldEmail.text, txtFieldPassword.text, strGender, strDOB, isArb, nil] forKeys:[NSArray arrayWithObjects:@"FirstName", @"LastName", @"Email", @"Password", @"Gender", @"DateOfBirth", @"isArb", nil]];
            
            SignUpUser* objSignUpUser = [SignUpUser new];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [objSignUpUser signUpUser:self selector:@selector(serverResponse:) parameters:dictParameters];
        }
    }
}

- (IBAction)btnSelectDateAction
{
    [txtFieldCurrent resignFirstResponder];
    [self hightlightDOBTextArea:YES];
    
    [viewPickerVw setFrame:CGRectMake(0, self.view.frame.size.height-viewPickerVw.frame.size.height , viewPickerVw.frame.size.width, viewPickerVw.frame.size.height)];
    [self.view addSubview:viewPickerVw];
}

- (IBAction)btnCloseAction:(id)sender
{
    [self closeSignUpView];
}

- (void)closeSignUpView
{
//    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
//    [UIView animateWithDuration:0.5 animations:^{
//        [self.view setFrame:CGRectMake(0, windowHeight, self.view.frame.size.width, windowHeight)];
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - validate
-(BOOL) validate
{
    if([[CommonFunctions shared] isInValidString:txtFieldFirstName StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kFirstNameErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    else if([[CommonFunctions shared] isInValidString:txtFieldLastName StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kLastNameErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    else if([[CommonFunctions shared] isInValidString:txtFieldEmail StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kEmailErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    if(![NSIUtility validateEmailWithString:txtFieldEmail.text])
    {
        [NSIUtility showAlertView:nil message:kValidEmailErrorMessage];
        return NO;
    }
    else if([[CommonFunctions shared] isInValidString:txtFieldPassword StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kPasswordErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    
    else if([[CommonFunctions shared] isInValidString:txtFieldConfirmPassword StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kConfirmPasswordErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    else if([[CommonFunctions shared] isvalidPasswordLength:txtFieldPassword StringToMatch:txtFieldPassword.text]){
        [CommonFunctions showAlertView:kPasswordLengthErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
    else if(![[CommonFunctions shared] compareStrings:txtFieldPassword.text String2:txtFieldConfirmPassword.text])
    {
        [CommonFunctions showAlertView:kPasswordAndConfirmPwdErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
//    else if([[CommonFunctions shared] isInValidString:txtFieldMonth StringToMatch:kEmptyString])
//    {
//        [CommonFunctions showAlertView:kSelectDateErrorMessage TITLE:kEmptyString Delegate:self];
//        return NO;
//    }
    else if(![[CommonFunctions shared] compareStrings:txtFieldPassword.text String2:txtFieldConfirmPassword.text])
    {
        [CommonFunctions showAlertView:kPasswordAndConfirmPwdErrorMessage TITLE:kEmptyString Delegate:self];
        return NO;
    }
//    if(!checkBoxChecked)
//    {
//        [CommonFunctions showAlertView:kSelectGenderErrorMessage TITLE:kEmptyString Delegate:self];
//        return NO;
//    }
    return YES;
}

- (void)hightlightDOBTextArea:(BOOL)isHighlight
{
    NSString *strImgName;
    UIColor *colorPlaceHolder;
    
    if (txtFieldCurrent!=nil) {
        
        UIView *subView = [self.view viewWithTag:txtFieldCurrent.tag];
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView *imgVw = (UIImageView*)subView;
            imgVw.image = [UIImage imageNamed:@"sign_up_txt_inactive"];
        }
        
        
        txtFieldCurrent.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtFieldCurrent.placeholder attributes:@{NSForegroundColorAttributeName:INACTIVE_TEXT_PLACEHOLDER}];
    }
    
    if (isHighlight) {
        strImgName = @"sign_up_txt_active";
        colorPlaceHolder = ACTIVE_TEXT_PLACEHOLDER;
    }
    else{
        strImgName = @"sign_up_txt_inactive";
        colorPlaceHolder = INACTIVE_TEXT_PLACEHOLDER;
    }
    UIView *subVw = [self.view viewWithTag:txtFieldMonth.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:strImgName];
    }
    subVw = [self.view viewWithTag:txtFieldDay.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:strImgName];
    }
    subVw = [self.view viewWithTag:txtFieldYear.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:strImgName];
    }
    
    txtFieldMonth.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtFieldMonth.placeholder attributes:@{NSForegroundColorAttributeName:colorPlaceHolder}];
    txtFieldDay.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtFieldDay.placeholder attributes:@{NSForegroundColorAttributeName:colorPlaceHolder}];
    txtFieldYear.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtFieldYear.placeholder attributes:@{NSForegroundColorAttributeName:colorPlaceHolder}];
}

#pragma mark - Server Response
- (void)serverResponse:(NSDictionary*)dictResponse
{
    if ([[dictResponse objectForKey:@"Error"] intValue] == 0) {
        
        [self closeSignUpView];
    }
    else
    {
        [btnSignUp setUserInteractionEnabled:YES];
    }
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([CommonFunctions isIphone])
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if((textField == txtFieldPassword) || (textField == txtFieldConfirmPassword))
            return (newLength > 20) ? NO : YES;
        return (newLength > 50) ? NO : YES;
    }
    else
        return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hightlightDOBTextArea:NO];
    [viewPickerVw removeFromSuperview];
    
    UIView *subVw = [self.view viewWithTag:textField.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"sign_up_txt_active"];
    }
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:ACTIVE_TEXT_PLACEHOLDER}];
    txtFieldCurrent = textField;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    UIView *subVw = [self.view viewWithTag:textField.tag];
    if ([subVw isKindOfClass:[UIImageView class]]) {
        UIImageView *imgVw = (UIImageView*)subVw;
        imgVw.image = [UIImage imageNamed:@"sign_up_txt_inactive"];
    }
    
    [btnDatePicker setUserInteractionEnabled:YES];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:INACTIVE_TEXT_PLACEHOLDER}];
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [btnDatePicker setUserInteractionEnabled:NO];
    if([CommonFunctions isIphone])
    {
        CGRect rect = self.view.frame;
        if(rect.origin.y==0)
        {
            rect.origin.y -= [CommonFunctions isIphone5] ? offsetToLift:(IS_IOS7_OR_LATER?offsetToLift:offsetToLiftForIOS6);
            [UIView animateWithDuration:0.5 animations:^{
                [self.view setFrame:rect];
            }];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([CommonFunctions isIphone])
    {
        [btnDatePicker setUserInteractionEnabled:YES];
    }
}


- (BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if([CommonFunctions isIphone])
    {
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view setFrame:rect];
        }];
        [btnDatePicker setUserInteractionEnabled:YES];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UIView Delegate method
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtFieldCurrent resignFirstResponder];
    if([CommonFunctions isIphone])
    {
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view setFrame:rect];
        }];
    }
}

@end