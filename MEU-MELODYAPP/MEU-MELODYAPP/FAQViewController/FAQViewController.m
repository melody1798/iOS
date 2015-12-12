//
//  FAQViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 17/10/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FAQViewController.h"
#import "CommonFunctions.h"
#import "CustomControls.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "SeriesEpisodesViewController.h"
#import "MovieDetailViewController.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "LanguageViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "QuestionAnswers.h"
#import "QuestionAnswer.h"
#import "VODSearchController.h"

@interface FAQViewController () <UITableViewDataSource, UITableViewDelegate, ChannelProgramPlay, UIPopoverControllerDelegate, UISearchBarDelegate, SettingsDelegate, LanguageSelectedDelegate>
{
    IBOutlet UITableView*           tblFAQ;
    IBOutlet UILabel*               lblNoRecordFound;
    SearchVideoViewController*      objSearchVideoViewController;
    UIPopoverController*            popOverSearch;
    SettingViewController*          objSettingViewController;
    VODSearchController*            objVODSearchController;
}

@property (strong, nonatomic) UISearchBar*      searchBarVOD;
@property (strong, nonatomic) NSMutableArray    *arrExpandTracker;          //Track expand/shrink tableview cell
@property (strong, nonatomic) NSMutableArray    *arrQuesAns;    //maintain ques/ans

@end

@implementation FAQViewController

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
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];

    [self setNavigationBarButtons]; //Set navigation button
    
    lblNoRecordFound.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?14.0:22.0];

    //Call service to fetch FAQ
    QuestionAnswers *objQuestionAnswers = [QuestionAnswers new];
    [objQuestionAnswers fetchFAQInformation:self selector:@selector(faqInfoServerResponse:) isArb:@"true"];
}

#pragma mark - Server Response
- (void)faqInfoServerResponse:(NSMutableArray*)arrResponse
{
    //Handle server response.
    self.arrQuesAns = [[NSMutableArray alloc] initWithArray:arrResponse];
    if ([self.arrQuesAns count] == 0) {
        lblNoRecordFound.hidden = NO;
    }
    
    self.arrExpandTracker = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.arrQuesAns count]; i++) {
        [self.arrExpandTracker addObject:@"0"];  //At start up shrink all the row tableview
    }
    
    [tblFAQ reloadData];
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = nil;
    if (![CommonFunctions isIphone]) {
        
        self.navigationItem.rightBarButtonItems = @[ [CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
    }
}

#pragma mark - UINavigationBar Button Action

- (void)backBarButtonItemAction
{
    if ([CommonFunctions isIphone])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)settingsBarButtonItemAction
{
    //Show settings pop over
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

- (void)showSearchPopOver
{
    //Search pop for iPad
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

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrQuesAns count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.arrExpandTracker objectAtIndex:section] isEqualToString:@"1"])
        return 1;
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    
    UILabel *lblAns = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, tblFAQ.frame.size.width-80, 80)];
    QuestionAnswer *objQuestionAnswer = (QuestionAnswer*) [self.arrQuesAns objectAtIndex:indexPath.section];
    
    float lblHeight;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        lblHeight = [self getTextHeight:objQuestionAnswer.ans_en AndFrame:lblAns.frame fontSize:18.0];
        lblAns.text = objQuestionAnswer.ans_en;
    }
    else
    {
        lblHeight = [self getTextHeight:objQuestionAnswer.ans_ar AndFrame:lblAns.frame fontSize:18.0];
        lblAns.text = objQuestionAnswer.ans_ar;
    }

    lblAns.lineBreakMode = NSLineBreakByWordWrapping;
    [lblAns setFrame:CGRectMake(70, 5, tblFAQ.frame.size.width-80, lblHeight)];
    lblAns.numberOfLines = lblHeight/18.0;
    lblAns.textColor = [UIColor whiteColor];
    lblAns.backgroundColor = [UIColor clearColor];
    [cell addSubview:lblAns];
    cell.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:27.0/255.0 blue:27.0/255.0 alpha:1.0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set dynamic height according to ques/ans text height.
    if ([[self.arrExpandTracker objectAtIndex:indexPath.section] isEqualToString:@"1"])
    {
        UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:18.0];
        float heightLbl;
        
        QuestionAnswer *objQuestionAnswer = (QuestionAnswer*) [self.arrQuesAns objectAtIndex:indexPath.section];
        NSString *str;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            str = objQuestionAnswer.ans_en;
        else
            str = objQuestionAnswer.ans_ar;
            
        if (IS_IOS7_OR_LATER) {
            heightLbl = [self getTextHeight:str AndFrame:CGRectMake(5, 5, tblFAQ.frame.size.width-80, 40) fontSize:18.0];
        }
        else
        {
            CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(tblFAQ.frame.size.width-80, 40) lineBreakMode:NSLineBreakByWordWrapping];
            heightLbl = ceilf(size.height);
        }
        return MAX(heightLbl, 40.0);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //Set ques height that display in header.
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:20.0];
    float heightLbl;
    
    QuestionAnswer *objQuestionAnswer = (QuestionAnswer*) [self.arrQuesAns objectAtIndex:section];
    NSString *str;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        str = objQuestionAnswer.ques_en;
    else
        str = objQuestionAnswer.ques_ar;
    
    if (IS_IOS7_OR_LATER) {
        heightLbl = [self getTextHeight:str AndFrame:CGRectMake(5, 5, tblFAQ.frame.size.width-80, 40) fontSize:20.0];
        heightLbl = heightLbl+10;
    }
    else
    {
        CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(tblFAQ.frame.size.width-80, 40) lineBreakMode:NSLineBreakByWordWrapping];
        heightLbl = ceilf(size.height) + 40.0;
    }
    return MAX(heightLbl, 40.0);
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Set header for displaying questions.
    UIView *vwHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tblFAQ.frame.size.width, 40)];
    vwHeader.tag = section;
    [vwHeader setBackgroundColor:[UIColor blackColor]];
    
    UIButton *btnQuesNum = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    [btnQuesNum setBackgroundImage:[UIImage imageNamed:@"sign_up_submit_btn.png"] forState:UIControlStateNormal];
    [btnQuesNum setTitle:[NSString stringWithFormat:@"%d", (int)section+1] forState:UIControlStateNormal];
    btnQuesNum.userInteractionEnabled = NO;
    btnQuesNum.layer.cornerRadius = 5.0;
    btnQuesNum.layer.masksToBounds = YES;
    [vwHeader addSubview:btnQuesNum];
    
    QuestionAnswer *objQuestionAnswer = (QuestionAnswer*) [self.arrQuesAns objectAtIndex:section];
    NSString *str;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        str = objQuestionAnswer.ques_en;
    else
        str = objQuestionAnswer.ques_ar;
    
    UILabel *lblQues = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, tblFAQ.frame.size.width-80, 20)];
    float lblHeight = [self getTextHeight:str AndFrame:lblQues.frame fontSize:20.0];

    lblQues.lineBreakMode = NSLineBreakByWordWrapping;
    [lblQues setFrame:CGRectMake(70, 5, tblFAQ.frame.size.width-80, lblHeight)];
    lblQues.numberOfLines = lblHeight/20.0;
    lblQues.textColor = [UIColor whiteColor];
    lblQues.backgroundColor = [UIColor clearColor];
    lblQues.text = str;
    lblQues.font = [UIFont fontWithName:kProximaNova_Regular size:20.0];
    [vwHeader addSubview:lblQues];
    
    //Add tap gesture on table view header.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandQues:)];
    [vwHeader addGestureRecognizer:recognizer];
    
    return vwHeader;
}

- (void)expandQues:(UITapGestureRecognizer*)recognizer
{
    //Expand the selected table view row.
    BOOL isExtend = [[self.arrExpandTracker objectAtIndex:recognizer.view.tag] boolValue];
    isExtend = !isExtend;
    [self.arrExpandTracker replaceObjectAtIndex:recognizer.view.tag withObject:[NSString stringWithFormat:@"%d", isExtend]];
    
    [tblFAQ reloadData];
}

- (float) getTextHeight:(NSString*)str AndFrame:(CGRect)frame fontSize:(float)fontSize
{
    //Calculate text height for ques/ans.
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:fontSize];
    CGFloat heightLbl;
    if (IS_IOS7_OR_LATER) {
        
        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX) options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
        
        frame.size.height = ceilf(CGRectGetHeight(rect));
        heightLbl = ceilf(frame.size.height) + 30;
        
    } else {
        CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(tblFAQ.frame.size.width-80, 40) lineBreakMode:NSLineBreakByWordWrapping];
        heightLbl = ceilf(size.height) + 30;
    }
    return MAX(heightLbl, 40.0);
}


#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Search on Vod (iPad)
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

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController
{
    //While dismissing pop over, remove search bar from navigation bar.
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
    
    return YES;
}

#pragma mark - Channel Play Delegate Method
//Handle VOD search data in FAQ controller.

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    
    //Handle user event and navigation to particular viewcontroller
    if (isSeries == NO) {         //If search result is series, navigation to movies detail screen.
        MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
        objMovieDetailViewController.strMovieId = videoId;
        [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
    }
    else{
        //If search result is series, navigation to series screen.
        SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
        objSeriesEpisodesViewController.strSeriesId = videoId;
        objSeriesEpisodesViewController.seriesUrl = @"";
        
        objSeriesEpisodesViewController.seriesName_en = seriesName;
        objSeriesEpisodesViewController.seriesName_ar = seriesName;
        objSeriesEpisodesViewController.seriesUrl = seriesThumb;
        
        [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
    }
}

#pragma mark - Settings Delegate
- (void)userSucessfullyLogout
{
    //Handle logout and pop to live TV controller. iPad
    [popOverSearch dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
}

- (void)changeLanguage
{
    //Show language screen.
    [popOverSearch dismissPopoverAnimated:YES];
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    objLanguageViewController.delegate = self;
    [self presentViewController:objLanguageViewController animated:YES completion:nil];
}

- (void)loginUser
{
    //Show login screen.
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginView];
}

- (void)changeLanguageMethod
{
    //If language is change then reload data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    [tblFAQ reloadData];
}

- (void)reloadFAQTblVw
{
    [tblFAQ reloadData];
}

- (void)changeLanguageFromLiveNow
{
    [tblFAQ reloadData];
}

- (void)showLoginView
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] init];
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

- (void)companyInfoSelected:(int)infoType
{
    //Show compnay info privacy policy/ terms of conditions.
    [popOverSearch dismissPopoverAnimated:YES];
    CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] initWithNibName:@"CompanyInfoViewController" bundle:nil];
    objCompanyInfoViewController.iInfoType = infoType;
    [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
}

- (void)sendFeedback
{
    //Show feedback form.
    [popOverSearch dismissPopoverAnimated:YES];
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    //If tap again FAQ, then dismiss pop over because it is already open.
    [popOverSearch dismissPopoverAnimated:YES];
}

#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //In case of iAd fails, display Admob.
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end