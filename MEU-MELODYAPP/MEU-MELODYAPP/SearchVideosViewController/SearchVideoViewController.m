//
//  SearchVideoViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SearchVideoViewController.h"
#import "Constant.h"
#import "SearchLiveNowVideos.h"
#import "SearchTableViewCell.h"
#import "CommonFunctions.h"
#import "MBProgressHUD.h"
#import "LiveNowCustomCell.h"
#import "UIImageView+WebCache.h"
#import "ChannelDetailViewViewController.h"
#import "AppDelegate.h"

#define LIVENOWSEARCH       0
#define CHANNELSEARCH       1
#define VODSEARCH           2

@interface SearchVideoViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView*   tblVwSearchResult;
    IBOutlet UIButton*      btnLiveNow;
    IBOutlet UIButton*      btnUpcoming;
    IBOutlet UILabel*       lblSearch;
    IBOutlet UITextField*   txtSearch;
    NSInteger               iChannelSearchType;
    NSMutableArray*         days;
    NSMutableDictionary*    groupedEvents;      //Group upcoming data
    IBOutlet UILabel*       lblNoResult;
    IBOutlet UILabel*       lblCancel;
    NSInteger               iSearchCategory;
}

@property (strong, nonatomic) NSArray*      arrSearchResponse; //store service data response.
@property (strong, nonatomic) NSString*     strSearch;

- (IBAction)btnSearchTypeAction:(id)sender;
- (IBAction)btnCancelAction:(id)sender;

@end

@implementation SearchVideoViewController

@synthesize iSectionType;

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

    //iAd
    if ([CommonFunctions isIphone]) {
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    }
    [self.navigationController.navigationBar setHidden:YES];
    self.contentSizeForViewInPopover = CGSizeMake(462, 666);
    
    iChannelSearchType = 1;
    lblNoResult.hidden = YES;
    
    [self resetViewAccordingToSearchSection];  //update UI according to channel/VOD search
    
    //Set UI
    [self setUIFonts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [self resetViewAccordingToSearchSection];
    [self setLocalizedText];        //Localize text
    [tblVwSearchResult reloadData];
}

- (void)resetViewAccordingToSearchSection
{
    if (iSectionType == 2) {
        btnLiveNow.hidden = YES;
        btnUpcoming.hidden = YES;
        CGRect tblSearchFrame = tblVwSearchResult.frame;
        tblSearchFrame.origin.y = btnLiveNow.frame.origin.y;
        tblSearchFrame.size.height = tblSearchFrame.size.height + btnLiveNow.frame.origin.y-80;
        tblVwSearchResult.frame = tblSearchFrame;
    }
}

#pragma mark - IBAction Methods

- (IBAction)btnSearchTypeAction:(id)sender
{
    //Show activity indicator.
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    SearchLiveNowVideos *objSearchLiveNowVideos = [SearchLiveNowVideos new];
    iChannelSearchType = [sender tag];
    if ([sender tag] == 1) {  //Live search
        [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_inactive.png"] forState:UIControlStateNormal];
        [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_active.png"] forState:UIControlStateNormal];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            
            [objSearchLiveNowVideos searchChannelsLiveNow:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"false"];
        else
            [objSearchLiveNowVideos searchChannelsLiveNow:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"true"];
    }
    else{ //Upcoming search
        [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_inactive.png"] forState:UIControlStateNormal];
        [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_active.png"] forState:UIControlStateNormal];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"false"];
        else
            [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"true"];
    }
}

- (IBAction)btnCancelAction:(id)sender
{
    //Cancel search and dismiss keypad.
    [txtSearch resignFirstResponder];
}

#pragma mark - Search Method
- (void)handleSearchText:(NSString*)searchString searchCat:(int)searchCat
{
    btnLiveNow.hidden = YES;
    btnUpcoming.hidden = YES;
    
    self.strSearch = [NSString stringWithFormat:@"%@", searchString];
    
    iSearchCategory = searchCat;
    switch (searchCat) {
        case 0:
        {
            btnLiveNow.hidden = NO;
            btnUpcoming.hidden = NO;
            [self searchInChannel:searchString]; //Search in channel
            break;
        }
        case 1:
        {
            btnLiveNow.hidden = NO;
            btnUpcoming.hidden = NO;
            [self searchInChannel:searchString]; //Search in channel
            break;
        }
        case 2:
            [self searchInVOD:searchString];     //Search in VOD
            break;
        default:
            break;
    }
}

- (BOOL)checkEnglishLanguage
{
    //Englisg language check
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        return YES;
    return NO;
}

-(void)searchInLiveNowFeatured:(NSString*)searchString arrToSearch:(NSArray*)arrLiveNowFeatured
{
    if ([searchString length] == 0) {
       // isSearching = NO;
    }
    
    //check search condition for iPhone
    NSMutableArray *arrSearchedData = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrLiveNowFeatured count]; i++) {
        SearchLiveNowVideo *objSearchLiveNowVideo = (SearchLiveNowVideo*) [arrLiveNowFeatured objectAtIndex:i];
        if ([[self checkEnglishLanguage]?objSearchLiveNowVideo.videoName_en:objSearchLiveNowVideo.videoName_ar rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            if (![arrSearchedData containsObject:objSearchLiveNowVideo]) {
                [arrSearchedData addObject:objSearchLiveNowVideo];
            }
        }
        else{
            if ([[self checkEnglishLanguage]?objSearchLiveNowVideo.videoName_en:objSearchLiveNowVideo.videoName_ar rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
                if (![arrSearchedData containsObject:objSearchLiveNowVideo]) {
                    [arrSearchedData addObject:objSearchLiveNowVideo];
                }
            }
        }
    }
    
    if ([arrSearchedData count] == 0){
        lblNoResult.hidden = NO;
        CGRect lblNoResultFrame = lblNoResult.frame;
        lblNoResultFrame.origin.y = btnLiveNow.frame.origin.y;
        lblNoResult.frame = lblNoResultFrame;
    }
    else
        lblNoResult.hidden = YES;
    
    self.arrSearchResponse = [arrSearchedData copy];
    [tblVwSearchResult reloadData];
}

-(void)searchInChannel:(NSString*)searchString
{
    //Before search check internet conenction.
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        SearchLiveNowVideos *objSearchLiveNowVideos = [SearchLiveNowVideos new];
        
        if (iChannelSearchType == 0 || iChannelSearchType == 1) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                
                [objSearchLiveNowVideos searchChannelsLiveNow:self selector:@selector(searchVideosServerResponse:) channelName:searchString isArb:@"false"];
            else
                [objSearchLiveNowVideos searchChannelsLiveNow:self selector:@selector(searchVideosServerResponse:) channelName:searchString isArb:@"true"];
        }
        else{
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                
                [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:searchString isArb:@"false"];
            else
                [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:searchString isArb:@"true"];
        }
    }
}

-(void)searchInVOD:(NSString*)searchString
{
    //VOD search
    SearchLiveNowVideos *objSearchLiveNowVideos = [SearchLiveNowVideos new];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:searchString isArb:@"false"];
    else
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:searchString isArb:@"true"];
}

#pragma mark - Upcoming search group data
- (void)sortDataByDate:(NSArray*)sortedDateArray
{
    days = [NSMutableArray array];
    groupedEvents = [NSMutableDictionary dictionary];
    
    for (SearchLiveNowVideo *objSearchLiveNowVideo in sortedDateArray)
    {
        NSString *dato = [CommonFunctions convertGMTDateFromLocalDateWithDays:objSearchLiveNowVideo.upcomingVideoDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *gmtDate = [formatter dateFromString: dato];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *newDate = [formatter stringFromDate:gmtDate];
        gmtDate = [formatter dateFromString:newDate];
        
        if (![days containsObject:gmtDate] && gmtDate!=nil)
        {
            [days addObject:gmtDate];
            [groupedEvents setObject:[NSMutableArray arrayWithObject:objSearchLiveNowVideo] forKey:gmtDate];
        }
        else
        {
            [((NSMutableArray*)[groupedEvents objectForKey:gmtDate]) addObject:objSearchLiveNowVideo];
        }
    }
    
    days = [[days sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    
    [tblVwSearchResult reloadData];
}

#pragma mark - Server response method
- (void)searchVideosServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    self.arrSearchResponse = [[NSArray alloc] initWithArray:arrResponse];
    [tblVwSearchResult reloadData];
    
    if ([arrResponse count] == 0) {
        
        groupedEvents = nil;
        lblNoResult.hidden = YES;
        [tblVwSearchResult reloadData];
        if (iChannelSearchType == 2) {
            lblNoResult.hidden = NO;
        }
        if (iChannelSearchType == 1 && iSectionType == 1) {
            
            [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_inactive.png"] forState:UIControlStateNormal];
            [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_active.png"] forState:UIControlStateNormal];
            SearchLiveNowVideos *objSearchLiveNowVideos = [SearchLiveNowVideos new];
            iChannelSearchType = 2;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                
                [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"false"];
            else
                [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:self.strSearch isArb:@"true"];
        }
    }
    else{
        lblNoResult.hidden = YES;        
        if (iChannelSearchType == 2 && iSectionType == 1)
        {
            [self sortDataByDate:arrResponse];  //Sort data by date
        }
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (iChannelSearchType == 2 && iSectionType == 1)
        return [days count];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (iChannelSearchType == 2  && iSectionType == 1)
        return [[groupedEvents objectForKey:[days objectAtIndex:section]] count];

    return [self.arrSearchResponse count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([CommonFunctions isIphone]) {
        static NSString *cellIdentifier = @"cell";
        LiveNowCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveNowCustomCell" owner:self options:Nil] firstObject];
        }
        
        SearchLiveNowVideo *objSearchLiveNowVideo;
        
        if (iChannelSearchType == 2)
        {
            objSearchLiveNowVideo = [[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        }
        else
        {
            objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
        }

        NSString *strGMTTime = [[CommonFunctions convertGMTDateFromLocalDate:objSearchLiveNowVideo.upcomingVideoDay] uppercaseString];
        cell.lblTime.text = strGMTTime;
        @try
        {
            if([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                cell.lblChannelName.text = objSearchLiveNowVideo.videoName_en;
            else
                cell.lblChannelName.text = objSearchLiveNowVideo.videoName_ar;
        }
        @catch (NSException *exception)
        {
            cell.lblChannelName.text = kEmptyString;
        }
        
        [cell.imgLiveNowChannel sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.videoThumb] placeholderImage:[UIImage imageNamed:@""]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchcell1"];
        if(cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchTableViewCell" owner:self options:Nil] firstObject];
        }
        
        if (iSearchCategory == CHANNELSEARCH || iSearchCategory == LIVENOWSEARCH) {
            
            SearchLiveNowVideo *objSearchLiveNowVideo;
            
            if (iChannelSearchType == 2)
            {
                objSearchLiveNowVideo = [[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                [cell setCellValueUpcomingVideos:objSearchLiveNowVideo];
            }
            else{
                objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
                [cell setCellValue:objSearchLiveNowVideo];
            }
        }
        else if (iSearchCategory == VODSEARCH) {
            SearchLiveNowVideo *objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
            [cell setCellValue:objSearchLiveNowVideo];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![CommonFunctions isIphone]) {
        
        if (iSearchCategory == CHANNELSEARCH) {
            
            if ([_delegate respondsToSelector:@selector(playSelectedChannelProgram:channelLogo:)]) {
                
                SearchLiveNowVideo *objSearchLiveNowVideo;
                if (iChannelSearchType == 2)
                {
                    //Play upcoming video
                    objSearchLiveNowVideo = [[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                    [_delegate playSelectedChannelProgram:objSearchLiveNowVideo.upcomingChannelName channelLogo:objSearchLiveNowVideo.channelName];
                }
                else
                {
                    objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
                    [_delegate playSelectedChannelProgram:objSearchLiveNowVideo.upcomingChannelName  channelLogo:objSearchLiveNowVideo.channelName];
                }
            }
        }
        else if (iSearchCategory == LIVENOWSEARCH){
            SearchLiveNowVideo *objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
            
            if ([_delegate respondsToSelector:@selector(playSelectedUpcomingChannel:)]) {
                [_delegate playSelectedUpcomingChannel:objSearchLiveNowVideo];
            }
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        SearchLiveNowVideo *objSearchLiveNowVideo;
        if (iChannelSearchType == 2)
        {
            objSearchLiveNowVideo = [[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        }
        else
        {
            objSearchLiveNowVideo = [self.arrSearchResponse objectAtIndex:indexPath.row];
        }
        appDelegate.channelName = objSearchLiveNowVideo.channelName;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetTabbarSelectedIndex" object:nil];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    if (iChannelSearchType == 2 && groupedEvents != nil)
    {
        header = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, 30)];
        header.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
        [header addSubview:headerLabel];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont fontWithName:kProximaNova_Regular size:[CommonFunctions isIphone]?14.0:18.0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss EEEE";
        NSString *strDate = [formatter stringFromDate:[days objectAtIndex:section]];
                             
        [headerLabel setText:[self changeDateFormat:strDate]];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (iChannelSearchType == 2 && groupedEvents != nil)
        return 30;
    return 0;
}

#pragma mark - UI Methods

-(NSString *)changeDateFormat:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEEE"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
   // int hour = [components hour];
    
    dateFormatter.dateFormat=@"MMMM";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        dateFormatter.dateFormat=@"MMM";
    }
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        dateFormatter.dateFormat=@"EEE";
    }
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        
        strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day];
    }
    else
    {
        strFormattedDate = [NSString stringWithFormat:@"%d, %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
    }
    
    return strFormattedDate;
}

- (void)setUIFonts
{
    btnLiveNow.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?12.0:18.0];
    btnUpcoming.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?12.0:18.0];
    lblSearch.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?13.0:20.0];
    lblNoResult.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone]?15.0:20.0];
}

- (void)setLocalizedText
{
    lblSearch.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil] uppercaseString];
    [btnLiveNow setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil] uppercaseString]forState:UIControlStateNormal];
    [btnUpcoming setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString] forState:UIControlStateNormal];
    lblNoResult.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"nil" table:nil];
    lblCancel.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cancel" value:@"nil" table:nil];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length]==0) {
        [txtSearch resignFirstResponder];
        return YES;
    }
    iSectionType = 1;
    [self handleSearchText:textField.text searchCat:0];
    [txtSearch resignFirstResponder];
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