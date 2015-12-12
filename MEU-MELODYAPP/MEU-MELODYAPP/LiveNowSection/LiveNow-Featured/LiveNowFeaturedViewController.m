    //
//  LiveNowFeaturedViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowFeaturedViewController.h"
#import "Constant.h"
#import "LiveNowFeaturedCollectionCell.h"
#import "LiveFeaturedListViewController.h"
#import "popoverBackgroundView.h"
#import "CustomControls.h"
#import "LiveNowFeaturedVideos.h"
#import "VODFeaturedViewController.h"
#import "CustomTabBar.h"
#import "VODMoviesFeaturedViewController.h"
#import "CustomNavBar.h"
#import "NSIUtility.h"
#import "VODMusicViewController.h"
#import "SeriesAllViewController.h"
#import "VODCollectionViewController.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerViewController.h"
#import "SearchLiveNowVideos.h"
#import "SearchLiveNowVideo.h"
#import "SearchVideoViewController.h"
#import "LiveNowCustomCell.h"
#import "ChannelCustomCell.h"
#import "CommonFunctions.h"
#import "CustomUITabBariphoneViewController.h"
#import "AppDelegate.h"
#import "ChannelsViewController.h"
#import "ChannelDetailView.h"
#import "MelodyHitsCustomCell.h"
#import "WatchListMovies.h"
#import "LoginViewController.h"
#import "Channels.h"
#import "UpcomingVideos.h"
#import "UpcomingVideo.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "FAQViewController.h"
#import "CastingVideos.h"

@interface LiveNowFeaturedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate, RowSelectionFromPopOverViewDelegate, UISearchBarDelegate, UITabBarControllerDelegate,UITableViewDataSource,UITableViewDelegate,videoPlayLiveList, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, ChannelUrlFullScreenModeDelegate, CancelFeedbackFormDelegate, ADBannerViewDelegate, tabbarIndexDelegate, UpdateMovieDetailOnLoginDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView*                viewSegmentControl;
    IBOutlet UISegmentedControl*    segmentedControl;
    IBOutlet UIScrollView*          scrollViewBanner;
    IBOutlet UIPageControl*         pageControl;
    IBOutlet UICollectionView*      collectionVwGrid;
    UIPopoverController*            popOverListView;
    UITabBarController*             tabController;
    IBOutlet UILabel*               lblLiveNowText;
    IBOutlet UIImageView*           imgVwBackBanner;
    IBOutlet UILabel*               lblListVWText;
    IBOutlet UIButton*              btnListView;
    ChannelDetailView*              objChannelDetailView;
    LoginViewController*            objLoginViewController;
    SearchVideoViewController*      objSearchVideoViewController;
    BOOL                            isChannelDetailOpen;
    BOOL                            isCompnayInfoOpen;
    BOOL                            isFAQOpen;
    CompanyInfoViewController*      objCompanyInfoViewController;
    FeedbackViewController*         objFeedbackViewController;
    FAQViewController*              objFAQViewController;
    IBOutlet UILabel*               lblNoVideoFoundCollectionView;
    ChannelsViewController*         objChannelsViewController;
    IBOutlet UIView*                vWBanner;
    IBOutlet UIImageView*           imgVwPrev;
    IBOutlet UIImageView*           imgVwNext;
    IBOutlet UIImageView*           imgChannelLiveBg;

    BOOL firstSearch;
    CastingVideos*                  objCastingVideo;
    CustomControls*                 objCustomControls;
    MPMoviePlayerViewController*    mpMoviePlayerViewController;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
}

@property (strong, nonatomic) UISearchBar*                  searchBar;
@property (weak, nonatomic) IBOutlet UILabel*               lblNoVideoFoundBannerView;
@property (strong, nonatomic) NSArray*                      arrLiveFeaturedVideos;
@property (strong, nonatomic) NSArray*                      arrLiveChannelVideos;
@property (strong, nonatomic) UIPopoverController*          popOverListView;

@property (weak, nonatomic) IBOutlet UILabel*               lblLiveChannelMovieName;
@property (weak, nonatomic) IBOutlet UILabel*               lblLiveChannelMovieTime;
@property (weak, nonatomic) IBOutlet UIImageView*           imgLiveChannelMovieThumb;
@property (strong, nonatomic) NSString*                     strChannelUrl;
@property (strong, nonatomic) NSString*                     strLiveVideoName_en;
@property (strong, nonatomic) NSString*                     strLiveVideoName_ar;
@property (strong, nonatomic) NSString*                     strLiveVideoChannelUrlForCast;
@property (assign, nonatomic) BOOL                          isCastingButtonHide;
@property (assign, nonatomic) BOOL                          bIsLoad;
@property (assign, nonatomic) BOOL                          bIsOpenMediaPlayer;

- (IBAction)changePage:(id)sender;
- (IBAction)btnListViewPressed:(id)sender;
- (IBAction)btnGenreAction:(id)sender;

@end

@implementation LiveNowFeaturedViewController

@synthesize popOverListView;

#define kOriginalRectForLiveNowTable CGRectMake(0,308,320,214)
#define kOriginalRectForSegmentControl CGRectMake(0,0,320,29)
#define kOriginalRectForScrollViewBanner CGRectMake(12,2,296,166)
#define kOriginalRectForHeaderChannelView CGRectMake(-20,-20,360,86)
#define kOriginalRectForSearchHeaderView CGRectMake(0,0,320,41)
#define kOriginalRectForSearchLabel CGRectMake (0,10,87,31)
#define kOriginalRectForWebView CGRectMake (13,90,295,165)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![CommonFunctions isIphone])
    {
        [self addTabbar];
        [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - 122 delegate:self]];
    }
    else
    {
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    }
    
    [self initUI];
    
    if (IS_IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //Add observer to pop to VOD section.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLiveNowAfterLogout) name:@"PopToLiveNowAfterLogout" object:nil];
    
    [self.view bringSubviewToFront:tblLiveNow]; //For iPhone
    [self.view bringSubviewToFront:segmentedControl]; //For iPhone
    
    segmentedControl.selectedSegmentIndex = 0;  //Default segment index set to 0.
    
    AppDelegate *objAppdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppdelegate.navigationController setNavigationBarHidden:NO]; //Hide navigation bar.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [CommonFunctions addGoogleAnalyticsForView:@"Live TV"];
    
    imgVwNext.image = nil;
    imgVwPrev.image = nil;
    pageControl.numberOfPages = 0; //Reset page control.
    
    [self setLocalizedText];
    [self.navigationController.navigationBar setHidden:NO];
    if(![CommonFunctions isIphone])
    {
        segmentedControl.selectedSegmentIndex = 0;
        self.navigationItem.leftBarButtonItem = nil;
        if (isCompnayInfoOpen || isChannelDetailOpen || isFAQOpen) {
            
            if (isChannelDetailOpen)
                segmentedControl.selectedSegmentIndex = 1;
            self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
        }
        
        if (isChannelDetailOpen == NO) {
            [self getLiveNowFeaturedVideos];    //Fetch live TV data programs
        }
        
        [objFeedbackViewController.view removeFromSuperview]; //If feedback view opens then remove from Live TV
        [self.navigationController.navigationBar setHidden:NO];
    }
    else
    {
        //Set localized data.
        [lblChannel setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil]];
        [lblSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil]];
        [lblLiveNowSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil]];
        [lblUpcomingSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil]];
        
        if(![CommonFunctions userLoggedIn])
        {
            [userLoggedInButton setHidden:NO];
        }
        
        if(segmentedControl.selectedSegmentIndex==0)
        {
            userLoggedInButton.hidden = YES;
            
            
            if (self.bIsOpenMediaPlayer == NO) {
                [self getLiveNowFeaturedVideos];
            }
            self.bIsOpenMediaPlayer = NO;
        }
        if (segmentedControl.selectedSegmentIndex == 1) {
            
            if (selectedChannel) {
                lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil];
            }
            [lblMovieName setText:[CommonFunctions isEnglish]?self.strLiveVideoName_en:self.strLiveVideoName_ar];

            NSString *strTime = lblMovieTime.text;
            lblMovieTime.text = [CommonFunctions convertTimeUnitLanguage:strTime];
            if ([strTime length]!=0) {
                _imgLiveChannelMovieThumb.hidden = NO;
                imgChannelLiveBg.hidden = NO;
                lblMovieTime.textAlignment = NSTextAlignmentLeft;
                lblMovieName.hidden = NO;
                lblMovieTime.hidden = NO;
            }
            
            imgLiveNow.image = nil;
            [imgVwChannelLogo removeFromSuperview];
            imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 55, 48)];
            imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
            [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];
            [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
            
            [tblLiveNow reloadData];
        }
        if (segmentedControl.selectedSegmentIndex == 2) {
            [tblLiveNow reloadData];
        }
    }
    
    if(![CommonFunctions isIphone])
    {
        [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - 122 delegate:self]];
    }
    else
    {
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    }
    //    CGRect rect = vBanner.frame;
    //Get real time data to google analytics
}

#pragma mark - Get Channels
-(void) getChannels
{
    Channels *objChannels = [[Channels alloc] init];
    [objChannels fetchChannels:self selector:@selector(ReponseForGetChannelsService:)];
}

#pragma mark - init UI

- (void)setLocalizedText
{
    lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
    lblLiveNowHeaderText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
    lblNoChannels.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    lblSearchNoVideos.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    
    lblListVWText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"listview" value:@"" table:nil];
    
    if(![CommonFunctions isIphone])
    {
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"vod" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    }
    else
    {
        [segmentedControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] forSegmentAtIndex:0];
        [segmentedControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil] forSegmentAtIndex:1];
        [segmentedControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil] forSegmentAtIndex:2];
        [segmentedControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"vod" value:@"" table:nil] forSegmentAtIndex:3];
    }
    
    lblNoVideoFoundCollectionView.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"no video found" value:@"" table:nil];
    self.lblNoVideoFoundBannerView.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"no video found" value:@"" table:nil];
}

-(void) initUI
{
    arrChannelVideos = [[NSMutableArray alloc] init];
    arrChannels = [[NSMutableArray alloc] init];
    arrsearchLiveNowVideos = [[NSMutableArray alloc] init];
    arrDates = [[NSMutableArray alloc] init];
    self.navigationItem.hidesBackButton = YES;
    
    [self registerCollectionViewCell];
    [self addSegmentedView];
    [self setSegmentedControlAppreance];
    
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    if(![CommonFunctions isIphone])
    {
        self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:[CommonFunctions isIphone] ? kSettingButtonImageName:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
        
        CGRect rect = vwchannel.frame;
        if(!iPhone4WithIOS6)
            rect.origin.y += 65;
        [vwchannel setFrame:rect];
        [vwSearch setFrame:rect];
        [self.view addSubview:vwchannel];
        [self.view addSubview:vwSearch];
        [vwSearch bringSubviewToFront:btnSearch];
        
        if(iPhone4WithIOS6)
        {
            rect = vwLiveNowHeader.frame;
            rect.origin.y -= 65;
            rect.size.height += 12;
            [vwLiveNowHeader setFrame:rect];
            rect = _imgLiveChannelMovieThumb.frame;
            rect.origin.y += 26;
            rect.size.height -= 40;
            [_imgLiveChannelMovieThumb setFrame:rect];
            [self.view bringSubviewToFront:vwLiveNowHeader];
            [self.view bringSubviewToFront:channelImage];
        }
        
        if(iPhone4WithIOS7)
        {
            rect = _imgLiveChannelMovieThumb.frame;
            rect.origin.y -= 5;
            rect.size.height -= 35;
            [_imgLiveChannelMovieThumb setFrame:rect];
            rect = lblNoVideoFoundCollectionView.frame;
            rect.origin.y -= 50;
            [lblNoVideoFoundCollectionView setFrame:rect];
            
            rect = vwLiveNowHeader.frame;
            rect.origin.y += 15;
            rect.size.height += 5;
            [vwLiveNowHeader setFrame:rect];
            
            rect = _imgLiveChannelMovieThumb.frame;
            rect.origin.y += 10;
            [_imgLiveChannelMovieThumb setFrame:rect];
        }
        
        if(iPhone5WithIOS7)
        {
            rect = _imgLiveChannelMovieThumb.frame;
            rect.origin.y += 7;
            [_imgLiveChannelMovieThumb setFrame:rect];
        }
    }
    [self setUIFonts];
}

#pragma mark - GetLiveNowFeatured Videos
-(void)getLiveNowFeaturedVideos
{
    segmentedControl.selectedSegmentIndex = 0;
    if (![kCommonFunction checkNetworkConnectivity]) //Check network connection.
    {
        if ([self.arrLiveChannelVideos count]==0)
            self.lblNoVideoFoundBannerView.hidden = NO;
        
        if ([self.arrLiveFeaturedVideos count]==0)
            lblNoVideoFoundCollectionView.hidden = NO;
        
        [self setBannerView:NO];
        [collectionVwGrid reloadData];
        [tblLiveNow reloadData];
    }
    else
    {
        //Fetch Live Now-Featured

        [MBProgressHUD showHUDAddedTo:vWBanner animated:YES];
        LiveNowFeaturedVideos *objLiveNowFeaturedVideos = [LiveNowFeaturedVideos new];
        [objLiveNowFeaturedVideos fetchLiveFeaturedVideos:self selector:@selector(liveNowFeaturedVideoResponse:)];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        LiveNowFeaturedVideos *objLiveNowFeaturedVideo = [LiveNowFeaturedVideos new];
        [objLiveNowFeaturedVideo fetchLiveMovies:self selector:@selector(liveChannelVideo:)];
    }
}

- (void)setUIFonts
{
    [txtSearch setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    [lblLiveNowSearch setFont:[UIFont fontWithName:kProximaNova_Bold size:11.0]];
    lblUpcomingSearch.font = [UIFont fontWithName:kProximaNova_Bold size:11.0];
    lblSearch.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    [lblLiveNowHeaderText setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    lblChannel.font = [UIFont fontWithName:kProximaNova_Bold size:17.0];
    lblLiveNowText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    lblListVWText.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    self.lblNoVideoFoundBannerView.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:22.0];
    lblNoChannels.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:22.0];
    lblSearchNoVideos.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:22.0];
    lblNoVideoFoundCollectionView.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:22.0];
    self.lblNoVideoFoundBannerView.hidden = YES;
}

#pragma mark - Group Upcoming Data

- (void)GroupUpcomingData:(NSArray*)arrUpcomingData
{
    [self sortDataByDateUpcomingSearch:arrUpcomingData];
}

- (void)sortDataByDateUpcomingSearch:(NSArray*)sortedDateArray
{
    daysForSearch = [NSMutableArray array];
    groupedEventsSearch = [NSMutableDictionary dictionary];
    
    for (SearchLiveNowVideo *objSearchLiveNowVideo in sortedDateArray)
    {
        NSString *dato = [CommonFunctions convertGMTDateFromLocalDateWithDays:objSearchLiveNowVideo.upcomingVideoDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *gmtDate = [formatter dateFromString: dato];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *newDate = [formatter stringFromDate:gmtDate];
        gmtDate = [formatter dateFromString:newDate];
        
        
        if (![daysForSearch containsObject:gmtDate] && gmtDate!=nil)
        {
            [daysForSearch addObject:gmtDate];
            [groupedEventsSearch setObject:[NSMutableArray arrayWithObject:objSearchLiveNowVideo] forKey:gmtDate];
        }
        else
        {
            [((NSMutableArray*)[groupedEventsSearch objectForKey:gmtDate]) addObject:objSearchLiveNowVideo];
        }
    }
    
    daysForSearch = [[daysForSearch sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
}

- (void)sortDataByDate:(NSArray*)sortedDateArray
{
    days = [NSMutableArray array];
    groupedEvents = [NSMutableDictionary dictionary];
    
    for (UpcomingVideo *objUpcomingVideo in sortedDateArray)
    {
        NSString *dato = [CommonFunctions convertGMTDateFromLocalDateWithDays:objUpcomingVideo.upcomingDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *gmtDate = [formatter dateFromString: dato];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *newDate = [formatter stringFromDate:gmtDate];
        gmtDate = [formatter dateFromString:newDate];
        
        
        if (![days containsObject:gmtDate] && gmtDate!=nil)
        {
            [days addObject:gmtDate];
            [groupedEvents setObject:[NSMutableArray arrayWithObject:objUpcomingVideo] forKey:gmtDate];
        }
        else
        {
            [((NSMutableArray*)[groupedEvents objectForKey:gmtDate]) addObject:objUpcomingVideo];
        }
    }
    
    days = [[days sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
}

- (BOOL)compareDates:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

#pragma mark - Group Upcoming Data

- (void)GroupUpcomingDataChannel:(NSArray*)arrUpcomingData
{
    [self sortDataByDateUpcoming:arrUpcomingData];
}

- (void)sortDataByDateUpcoming:(NSArray*)sortedDateArray
{  days = [NSMutableArray array];
    groupedEvents = [NSMutableDictionary dictionary];
    
    for (UpcomingVideo *objUpcomingVideo in sortedDateArray)
    {
        NSString *dato = [CommonFunctions convertGMTDateFromLocalDateWithDays:objUpcomingVideo.upcomingDay];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *gmtDate = [formatter dateFromString: dato];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *newDate = [formatter stringFromDate:gmtDate];
        gmtDate = [formatter dateFromString:newDate];
        
        if (![days containsObject:gmtDate] && gmtDate!=nil)
        {
            [days addObject:gmtDate];
            [groupedEvents setObject:[NSMutableArray arrayWithObject:objUpcomingVideo] forKey:gmtDate];
        }
        else
        {
            [((NSMutableArray*)[groupedEvents objectForKey:gmtDate]) addObject:objUpcomingVideo];
        }
    }
    
    days = [[days sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
}

#pragma mark - Server response
-(void) ReponseForChannelVideos:(UpcomingVideos *)objUpcomingVideos
{
    lastSelectedIndex = 1;
    strChannelLogoUrl = [NSString stringWithFormat:@"%@", objUpcomingVideos.channelLogoUrl];
    
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 55, 48)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
    
    segmentedControl.selectedSegmentIndex = 1;
    _imgLiveChannelMovieThumb.image = nil;
    if (objUpcomingVideos.liveVideoStartTime!=nil) {
        _imgLiveChannelMovieThumb.hidden = NO;
        imgChannelLiveBg.hidden = NO;
        lblMovieTime.textAlignment = NSTextAlignmentLeft;
        lblMovieName.hidden = NO;
        lblMovieTime.hidden = NO;
        
        self.strLiveVideoName_en = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_en];
        self.strLiveVideoName_ar = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_ar];

        [_imgLiveChannelMovieThumb sd_setImageWithURL:[NSURL URLWithString:objUpcomingVideos.liveVideoThumbnail] placeholderImage:nil];
        [lblMovieName setText:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objUpcomingVideos.liveVideoName_en:objUpcomingVideos.liveVideoName_ar];
        NSString *strGMTTime = [[CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideos.liveVideoStartTime] uppercaseString];
        lblMovieTime.text = strGMTTime;
    }
    else
    {
        lblMovieTime.hidden = NO;
        lblMovieTime.textAlignment = NSTextAlignmentCenter;
        lblMovieTime.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No live show found for this channel." value:@"" table:nil];
    }
    [tblLiveNow setHidden:YES];
    arrChannelVideos = [objUpcomingVideos.arrUpcomingVideos mutableCopy];
    if ([CommonFunctions isIphone]) {
        [self GroupUpcomingDataChannel:objUpcomingVideos.arrUpcomingVideos];
    }
    [vwchannel setHidden:YES];
    
    if([arrChannelVideos count] > 0)
    {
        [tblLiveNow setHidden:NO];
    }
    else
    {
        [lblNoVideoFoundCollectionView setHidden:NO];
    }
    
    [_imgLiveChannelMovieThumb setHidden:NO];
    imgLiveNow.hidden = NO;
    
    if (objUpcomingVideos.liveVideoName_en != nil) {
        lblMovieName.hidden = NO;
        lblMovieTime.hidden = NO;
        imgVwLiveMovie.hidden = NO;
        lblMovieTime.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        lblMovieTime.textAlignment = NSTextAlignmentCenter;
        lblMovieTime.hidden = NO;
        lblMovieTime.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No live show found for this channel." value:@"" table:nil];
    }
    [imgVwLiveMovie sd_setImageWithURL:[NSURL URLWithString:objUpcomingVideos.liveVideoThumbnail]];
    lblMovieName.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:18.0)];
    lblMovieTime.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:18.0)];
    lblMovieName.textColor = YELLOW_COLOR;
    lblMovieTime.textColor = [UIColor whiteColor];
    [scrollViewBanner setHidden:YES];
    [pageControl setHidden:YES];
    [vwLiveNowHeader setHidden:NO];
    selectedChannel = YES;
    [self setTableViewFrameDefaultFrames];
    [vwSearch setHidden:YES];
    
    [self showOrHideControls];
    [tblLiveNow reloadData];
}

-(void) ReponseForGetChannelsService:(NSMutableArray *)arrChannelsLocal
{
    //Handle channel response.
    arrChannels = [arrChannelsLocal mutableCopy];
    
    if([arrChannels count] > 0)
    {
        [tblLiveNow setHidden:NO];
        [lblNoChannels setHidden:YES];
        [self.view bringSubviewToFront:tblLiveNow];
    }
    else
    {
        [tblLiveNow setHidden:YES];
        [lblNoChannels setHidden:NO];
    }
    [tblLiveNow reloadData];
}

- (void)watchListServerResponse:(NSArray*)arrResponse
{
    //Reset Watchlist counter.
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.iWatchListCounter = (int) [arrResponse count];
}

- (void)liveNowFeaturedVideoResponse:(NSMutableArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:vWBanner animated:NO];

    [tblLiveNow setHidden:NO];
    self.arrLiveFeaturedVideos = [[NSArray alloc] initWithArray:arrResponse];
    [pageControl setHidden:NO];
    [scrollViewBanner setHidden:NO];
    
    self.lblNoVideoFoundBannerView.hidden = YES;
    pageControl.numberOfPages = [self.arrLiveFeaturedVideos count];
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundBannerView.hidden = NO;
    }
    
    [self setBannerView:NO];
    [collectionVwGrid reloadData];
    [tblLiveNow reloadData];
}

- (void)liveChannelVideo:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [lblNoVideoFoundCollectionView setHidden:YES];
    self.arrLiveChannelVideos = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrLiveChannelVideos count] == 0) {
        [self.view bringSubviewToFront:lblNoVideoFoundCollectionView];
        [lblNoVideoFoundCollectionView setHidden:NO];
    }
    if ([CommonFunctions isIphone]) {
        [tblLiveNow setHidden:NO];
    }
    [tblLiveNow reloadData];
    [collectionVwGrid reloadData];
}

- (void)searchVideosServerResponse:(NSArray*)arrResponse
{
    [btnLiveNow setHidden:NO];
    [lblLiveNowSearch setHidden:NO];
    [btnUpcoming setHidden:NO];
    [lblUpcomingSearch setHidden:NO];
    
    arrsearchLiveNowVideos = [arrResponse mutableCopy];
    
    if(upComingSelected)
    {
        [arrDates removeAllObjects];
        [self GroupUpcomingData:arrResponse];
    }
    
    else if (arrsearchLiveNowVideos.count == 0 && firstSearch) // when livenow videos is empty
    {
        firstSearch = NO;
        upComingSelected = true;
        [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_grey_btn.png"] forState:UIControlStateNormal];
        [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_live_upcoming_btn_active.png"] forState:UIControlStateNormal];
        
        SearchLiveNowVideos *objSearchLiveNowVideos = [[SearchLiveNowVideos alloc] init];
        [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:txtSearch.text isArb:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?@"true":@"false"];
        
        return;
    }
    
    if(![CommonFunctions isIphone])
    {
        //Reload
    }
    else
    {
        if([arrsearchLiveNowVideos count]>0)
        {
            [tblLiveNow setHidden:NO];
            [tblLiveNow reloadData];
        }
        else
        {
            [tblLiveNow setHidden:YES];
            [lblSearchNoVideos setHidden:NO];
        }
    }
    
    firstSearch = NO;
}

#pragma mark - Navigationbar buttons actions
- (void)settingsBarButtonItemAction
{
    [txt resignFirstResponder];
    
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    
    if ([CommonFunctions isIphone]) {
        
        [imgVwChannelLogo removeFromSuperview];
        [CommonFunctions pushViewController:self.navigationController ViewController:objSettingViewController];
    }
    else
    {
        objSettingViewController.delegate = self;
        popOverListView = [[UIPopoverController alloc] initWithContentViewController:objSettingViewController];
        popOverListView.popoverBackgroundViewClass = [popoverBackgroundView class];
        
        [popOverListView setDelegate:self];
        
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

        [popOverListView presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
    }
}

- (void)searchBarButtonItemAction
{
    if (self.searchBar == nil) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(510, 15, 237, 42)];
        self.searchBar.delegate = self;
        self.searchBar.tintColor = [UIColor darkGrayColor];
        [self.navigationController.navigationBar addSubview:self.searchBar];
        [self.searchBar becomeFirstResponder];
        for (UIView *subView in self.searchBar.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                
                [[(UITextField *) subView valueForKey:@"textInputTraits"] setValue:[UIColor blackColor] forKey:@"insertionPointColor"];
            }
        }
        
        if(![CommonFunctions isIphone])
            [self showChannelSearchPopOver];
    }
}

- (void)btnMelodyIconAction
{
    if ([CommonFunctions isIphone])
    {
        AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        for(UIViewController *controller in objAppDelegate.navigationController.viewControllers)
            if([controller isKindOfClass:[CustomUITabBariphoneViewController class]])
                [objAppDelegate.navigationController popToViewController:controller animated:NO];
    }
    else
    {
        if (isChannelDetailOpen == NO) {
            [self addTabbar];
        }
    }
}

#pragma mark - Register Collection view cell
- (void)registerCollectionViewCell
{
    [collectionVwGrid registerNib:[UINib nibWithNibName:@"LiveNowFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"livenowfeaturecell"];
}

#pragma mark - UISegmentedControl

- (IBAction)segmentedIndexChanged
{
    [imgVwChannelLogo removeFromSuperview];
    
    if(![CommonFunctions isIphone])
    {
        isChannelDetailOpen = NO;
        [objFeedbackViewController.view removeFromSuperview];
        [objChannelDetailView removeFromSuperview];
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        if (segmentedControl.selectedSegmentIndex == 1) {
            
            [self.popOverListView dismissPopoverAnimated:NO];
            
            if (![kCommonFunction checkNetworkConnectivity])
            {
            }
            else
                [self addChannelPopOver];
        }
        else
        {
            if (segmentedControl.selectedSegmentIndex == 2)
            {
                //Add tabbar for VOD section
                [self addTabbar];
            }
        }
    }
    // Else case if for Iphone
    else
    {
        _imgLiveChannelMovieThumb.hidden = YES;
        _lblLiveChannelMovieName.hidden = YES;
        _lblLiveChannelMovieTime.hidden = YES;
        imgChannelLiveBg.hidden = YES;
        
        imgLiveNow.image = [UIImage imageNamed:@"live_now_bar.png"];

        lblMovieName.hidden = YES;
        lblMovieTime.hidden = YES;
        imgVwLiveMovie.hidden = YES;
        
        CGRect rect = kOriginalRectForLiveNowTable;
        CustomUITabBariphoneViewController *objCustomUITabBariphoneViewController = [[CustomUITabBariphoneViewController alloc] init];
        if(segmentedControl.selectedSegmentIndex != 3)
            [self setDefaultSegmentUI];
        switch (segmentedControl.selectedSegmentIndex)
        {
            case 0:
                userLoggedInButton.hidden = YES;
                lastSelectedIndex = 0;
                [vwchannel setHidden:YES];
                [vwSearch setHidden:YES];
                [self getLiveNowFeaturedVideos];
                break;
                
            case 1:
            {
                if (selectedChannel) {
                    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 55, 48)];
                    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
                    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];
                    
                    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
                }                
                imgLiveNow.image = nil;

                lastSelectedIndex = 1;
                self.lblNoVideoFoundBannerView.hidden = YES;
                
                [lblNoChannels setHidden:YES];
                [tblLiveNow setHidden:YES];
                [vwchannel setHidden:NO];
                [vwSearch setHidden:YES];
                [self.view bringSubviewToFront:tblLiveNow];
                
                if(iPhone5WithIOS7)
                {
                    rect.origin.x += 5;
                    rect.origin.y -= 200;
                    rect.size.height += 197;
                    rect.size.width -= 5;
                    [tblLiveNow setFrame:rect];
                }
                if(iPhone4WithIOS7)
                {
                    rect.origin.x += 5;
                    rect.origin.y -= 200;
                    rect.size.height += 109;
                    [tblLiveNow setFrame:rect];
                    rect = kOriginalRectForHeaderChannelView;
                    rect.origin.y += 10;
                    [channelHeaderView setFrame:rect];
                }
                if(iPhone4WithIOS6)
                {
                    rect.origin.x += 5;
                    rect.origin.y -= 267;
                    rect.size.height += 102;
                    [tblLiveNow setFrame:rect];
                    rect = kOriginalRectForHeaderChannelView;
                    rect.origin.y -= 10;
                    rect.size.height += 10;
                    [channelHeaderView setFrame:rect];
                }
                [self getChannels];
                break;
            }
            case 2:
                
                [tblLiveNow reloadData];
                [lblNoVideoFoundCollectionView setHidden:YES];

                [lblLiveNowSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil]];
                [lblUpcomingSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil]];
                [lblSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil]];
                
                lastSelectedIndex = 2;
                [tblLiveNow setHidden:YES];
                [vwchannel setHidden:YES];
                [vwSearch setHidden:NO];
                
                [btnLiveNow setHidden:YES];
                [lblLiveNowSearch setHidden:YES];
                [btnUpcoming setHidden:YES];
                [lblUpcomingSearch setHidden:YES];
                
                if(iPhone5WithIOS7)
                {
                    rect.origin.y -= 150;
                    rect.size.height += 147;
                    [tblLiveNow setFrame:rect];
                }
                if(iPhone4WithIOS7)
                {
                    rect.origin.y -= 165;
                    rect.size.height += 75;
                    [tblLiveNow setFrame:rect];
                    rect = kOriginalRectForSearchHeaderView;
                    rect.origin.y += 20;
                    [searchHeaderView setFrame:rect];
                }
                if(iPhone4WithIOS6)
                {
                    rect.origin.y -= 220;
                    rect.size.height += 60;
                    [tblLiveNow setFrame:rect];
                    rect = kOriginalRectForHeaderChannelView;
                    rect.origin.y += 10;
                    [channelHeaderView setFrame:rect];
                }
                [self searchClicked:nil];
                break;
                
            case 3:
                [segmentedControl setSelectedSegmentIndex:lastSelectedIndex];
                [self.navigationController pushViewController:objCustomUITabBariphoneViewController animated:NO];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - SetDefaultSegmentUI
-(void) setDefaultSegmentUI
{
    [userLoggedInButton setHidden:NO];
    self.navigationItem.leftBarButtonItem  = Nil;
    CGRect rect = lblLiveNowText.frame;
    rect.origin.x = 0;
    [lblLiveNowText setFrame:rect];
    lblLiveNowText.textAlignment = NSTextAlignmentCenter;
    [channelImage setHidden:YES];
    searchDetail = false;
    [vwLiveNowHeader setHidden:YES];
    [_imgLiveChannelMovieThumb setHidden:YES];
   
    if (![CommonFunctions isIphone5]) {
        [lblSearch setFrame:kOriginalRectForSearchLabel];
    }
    
    [lblSearchNoVideos setHidden:YES];
    lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
    playingSearchVideo = NO;
    selectedChannel = NO;
    [tblLiveNow reloadData];
    [self setTableViewFrameDefaultFrames];
    [vwchannel setHidden:YES];
    rect = kOriginalRectForLiveNowTable;
    NSLog(@"%@", NSStringFromCGRect(rect));
    [lblChannel setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil]];
}

- (IBAction)btnGenreAction:(id)sender
{
    if([CommonFunctions isIphone])
    {
        if (isChannelDetailOpen)
        {
            segmentedControl.selectedSegmentIndex = 1;
            [self segmentedIndexChanged];
            isChannelDetailOpen = NO;
        }
        
        else
        {
            if (segmentedControl.selectedSegmentIndex !=1)
            {
                segmentedControl.selectedSegmentIndex = 1;
                [self segmentedIndexChanged];
            }
        }
    }
    
    else //ipad
    {
        segmentedControl.selectedSegmentIndex = 1;
        if (![kCommonFunction checkNetworkConnectivity])
        {
        }
        else
            [self addChannelPopOver];
    }
}

#pragma mark - Channel PopOver
- (void)addChannelPopOver
{
    if ([self.popOverListView  isPopoverVisible]) {
        [self.popOverListView  dismissPopoverAnimated:NO];
    }
    
    objChannelsViewController = nil;
    objChannelsViewController = [[ChannelsViewController alloc] initWithNibName:@"ChannelsViewController" bundle:nil];
    objChannelsViewController.delegate = self;
    
    UIPopoverController *popOverChannel = [[UIPopoverController alloc] initWithContentViewController:objChannelsViewController];
    self.popOverListView = popOverChannel;
    self.popOverListView.popoverBackgroundViewClass = [popoverBackgroundView class];
    
    [self.popOverListView setDelegate:self];
    
    
    CGRect rect;
    rect.origin.x = 90;
    rect.origin.y = 0;
    rect.size.width = 160;
    rect.size.height = 87;
    CGRect rect1 = objChannelsViewController.view.frame;
    
    [self.popOverListView setPopoverContentSize:CGSizeMake(rect1.size.width, 295)];
    [self.popOverListView presentPopoverFromRect:rect inView:segmentedControl permittedArrowDirections:0 animated:YES];
}

#pragma mark - Channel TaleView Row Selection Delegate
- (void)returnTableViewSelectedRow:(Channel*)objChannel
{
    [objChannelDetailView removeFromSuperview];
    
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-41, 1, 82, 72)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
    
    [self.popOverListView dismissPopoverAnimated:YES];
    [btnListView setImage:[UIImage imageNamed:@"list_view_inactive"] forState:UIControlStateNormal];
    
    isChannelDetailOpen = YES;
    objChannelDetailView = [ChannelDetailView customView];
    objChannelDetailView.delegate = self;
    [objChannelDetailView setFrame:CGRectMake(0, 92, 768, self.view.frame.size.height-segmentedControl.frame.size.height-78-20-15-60)];
    [self.view addSubview:objChannelDetailView];
    
    [objChannelDetailView setUIAppearance];
    [objChannelDetailView fetchChannelDetails:objChannel];    //Call method to fetch channel details
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
}

- (void)playChannelUrlInFullScreenMode:(NSString*)channelUrl
{
    [self playVideo:channelUrl];
}

- (void)updateChannelLogoFromSearch:(NSString*)channelLogo
{
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-41, 1, 82, 72)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:channelLogo] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
}

#pragma mark - Navigation Bar Button Action
-(void)backBarButtonItemActionForSearchiPhone
{
    segmentedControl.selectedSegmentIndex = 2;
    [self segmentedIndexChanged];
    [self searchClicked:nil];
}

-(void)backBarButtonItemActioniPhone
{
    segmentedControl.selectedSegmentIndex = 1;
    [self segmentedIndexChanged];
}

- (void)backBarButtonItemAction
{
    self.navigationItem.leftBarButtonItem = nil;
    
    [imgVwChannelLogo removeFromSuperview];
    [objChannelDetailView removeFromSuperview];
    isChannelDetailOpen = NO;
    isCompnayInfoOpen = NO;
    isFAQOpen = NO;
    segmentedControl.selectedSegmentIndex = 0;
    [objCompanyInfoViewController.view removeFromSuperview];
    [objFeedbackViewController.view removeFromSuperview];
    [objFAQViewController.view removeFromSuperview];
}

- (void)playChannelVideo:(NSString*)videoUrl
{
    [self playVideo:videoUrl];
}

#pragma mark - Tabbar Methods
- (void)addTabbar
{
    tabController = [[CustomTabBar alloc] init];
    
    //Set Featured ViewController
    VODFeaturedViewController *objVODFeaturedViewController = [[VODFeaturedViewController alloc] initWithNibName:@"FlickrMainViewController" bundle:nil];
    UINavigationController *navigationVODFeatured = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationVODFeatured setViewControllers:@[objVODFeaturedViewController] animated:NO];
    
    //Set Movies viewController
    VODMoviesFeaturedViewController *objVODMoviesFeaturedViewController = [[VODMoviesFeaturedViewController alloc] initWithNibName:@"VODMoviesFeaturedViewController" bundle:nil];
    UINavigationController *navigationMoviesFeatured = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationMoviesFeatured setViewControllers:@[objVODMoviesFeaturedViewController] animated:NO];
    
    //Set Series ViewController
    SeriesAllViewController *objSeriesAllViewController = [[SeriesAllViewController alloc] initWithNibName:@"SeriesAllViewController" bundle:nil];
    UINavigationController *navigationSeriesAllViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationSeriesAllViewController setViewControllers:@[objSeriesAllViewController] animated:NO];
    
    //Set Music ViewController
    VODMusicViewController *objVODMusicViewController = [[VODMusicViewController alloc] initWithNibName:@"VODMusicViewController" bundle:nil];
    UINavigationController *navigationVODMusic = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationVODMusic setViewControllers:@[objVODMusicViewController] animated:NO];
    
    
    //Set VOD Collection
    VODCollectionViewController *objVODCollectionViewController = [[VODCollectionViewController alloc] initWithNibName:@"VODCollectionViewController" bundle:nil];
    UINavigationController*navigationVODCollection = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationVODCollection setViewControllers:@[objVODCollectionViewController] animated:NO];
    
    tabController.delegate = self;
    [self.navigationController.navigationBar setHidden:YES];
    
    [tabController setViewControllers:@[navigationVODFeatured, navigationMoviesFeatured, navigationSeriesAllViewController,  navigationVODMusic, navigationVODCollection]];
    [self.navigationController pushViewController:tabController animated:NO];
}

- (void)setTabBarIndex:(int)selectedSegmentIndex
{
    if (selectedSegmentIndex == 5) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else {
    UINavigationController *indexNavController = (UINavigationController *)[[tabController viewControllers] objectAtIndex:selectedSegmentIndex];
    [indexNavController popToRootViewControllerAnimated:NO];
    
    switch (selectedSegmentIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        {
            tabController.selectedIndex = selectedSegmentIndex;
            break;
        }
        default:
            break;
    }
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    return NO;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

    
}

#pragma mark - UI Methods
- (void)setBannerView:(BOOL)channelSelected
{
    NSMutableArray *arrVideos = [[NSMutableArray alloc] init];
    if(!channelSelected)
        
        for (int i=0; i<[self.arrLiveFeaturedVideos count]; i++)
        {
            [arrVideos addObject:[self.arrLiveFeaturedVideos objectAtIndex:i]];
        }
    else
        arrVideos = [arrChannelVideos mutableCopy];
    
    for (UIView *view in scrollViewBanner.subviews)
    {
        [view removeFromSuperview];
    }
    NSInteger xOrigin = 0;
    if([CommonFunctions isIphone] && ([arrVideos count] > 0))
    {
        scrollViewBanner.layer.borderWidth = 2;
        scrollViewBanner.layer.borderColor = [[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] CGColor];
    }
    for (int i = 0; i < [arrVideos count]; i++)
    {
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [arrVideos objectAtIndex:i];
        if ([arrVideos count] == 2)
        {
            imgVwPrev.image = nil;
            [imgVwNext sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en]];
        }
        
        CGRect scrollViewFrame = scrollViewBanner.frame;
        scrollViewFrame.origin.x = xOrigin;
        scrollViewFrame.origin.y = 0;
        
        UIView *viewBanner = [[UIView alloc] initWithFrame:scrollViewFrame];
        viewBanner.backgroundColor = [UIColor clearColor];
        
        //Set image on banner  638 236
        UIImageView *imageBanner = [[UIImageView alloc] initWithFrame:CGRectMake(([CommonFunctions isIphone]? 0:65), 0, scrollViewFrame.size.width-([CommonFunctions isIphone]? 2:130), scrollViewFrame.size.height-([CommonFunctions isIphone]? 0:0))];
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appdelegate.fImageWidth = imageBanner.frame.size.width;
        appdelegate.fImageHeight = imageBanner.frame.size.height;
        
        imageBanner.backgroundColor = [UIColor clearColor];
        if(![CommonFunctions isIphone])
            imageBanner.contentMode = UIViewContentModeScaleAspectFill;
        
        [imageBanner sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:[UIImage imageNamed:@"abc"]];
        
        [viewBanner addSubview:imageBanner];
        
        //Add Play button
        UIButton *btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(([CommonFunctions isIphone]? scrollViewBanner.frame.size.width - 30:imageBanner.center.x-21), ([CommonFunctions isIphone]? scrollViewBanner.frame.size.height - 34:imageBanner.frame.size.height/2-21), [CommonFunctions isIphone]? 19:42, [CommonFunctions isIphone]? 19:42)];
        
        [btnPlay setImage:[UIImage imageNamed:[CommonFunctions isIphone]?@"play_btn~iphone":@"play_btn~ipad"] forState:UIControlStateNormal];
        btnPlay.tag = i;
        [btnPlay addTarget:self action:@selector(btnPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        
        btnPlay.contentMode = UIViewContentModeCenter;
        
        if([CommonFunctions isIphone])
            [viewBanner bringSubviewToFront:btnPlay];
        
        //Set labels on banner
        CGRect infoView;
        infoView.origin.x = imageBanner.frame.origin.x;
        infoView.origin.y = imageBanner.frame.size.height-47;
        infoView.size.width = imageBanner.frame.size.width;
        infoView.size.height = 47;
        
        if ([CommonFunctions isIphone]) {
            
            infoView.origin.y = imageBanner.frame.size.height-37;
            infoView.size.height = 35;
        }
        UIView *viewVideoInfo = [[UIView alloc] initWithFrame:infoView];
        
        viewVideoInfo.backgroundColor = [UIColor blackColor];
        viewVideoInfo.alpha = 0.85;
        
        UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 35, 35)];
        imageLogo.contentMode = UIViewContentModeScaleToFill;
        [imageLogo sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:nil];
        
        if (![CommonFunctions isIphone]) {
            UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 1, viewVideoInfo.frame.size.height-6)];
            lblSeperator.backgroundColor = [UIColor darkGrayColor];
            [viewVideoInfo addSubview:lblSeperator];
        }
        
        if(![CommonFunctions isIphone])
            [viewVideoInfo addSubview:imageLogo];
        
        UILabel *lblMovieNameBanner = [[UILabel alloc] initWithFrame:CGRectMake([CommonFunctions isIphone]? scrollViewBanner.frame.origin.x+38:(imageLogo.frame.origin.x+imageLogo.frame.size.width+15), [CommonFunctions isIphone]?2:5, [CommonFunctions isIphone]?[UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width-88:[UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width-125, 23)];
        lblMovieNameBanner.backgroundColor = [UIColor clearColor];
        lblMovieNameBanner.textColor = YELLOW_COLOR;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            [lblMovieNameBanner setText:objLiveNowFeaturedVideo.videoName_en];
        else
            [lblMovieNameBanner setText:objLiveNowFeaturedVideo.videoName_ar];
        
        lblMovieNameBanner.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 15.0:22.0)];
        [viewVideoInfo addSubview:lblMovieNameBanner];
        
        UILabel *lblMovieTimeBanner = [[UILabel alloc] initWithFrame:CGRectMake([CommonFunctions isIphone]? scrollViewBanner.frame.origin.x+38:(imageLogo.frame.origin.x+imageLogo.frame.size.width+15), [CommonFunctions isIphone]?lblMovieNameBanner.frame.size.height-8:lblMovieNameBanner.frame.size.height, [UIScreen mainScreen].bounds.size.width - imageLogo.frame.size.width, 23)];
        lblMovieNameBanner.backgroundColor = [UIColor clearColor];
        
        lblMovieTimeBanner.text = [self changeDateFormatForDays:[self convertGMTDateFromLocalDateWithDaysL:objLiveNowFeaturedVideo.videoTime_en]];

        lblMovieTimeBanner.textColor = [UIColor whiteColor];
        lblMovieTimeBanner.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:16.0)];
        [lblMovieTimeBanner setBackgroundColor:[UIColor clearColor]];
        
        if([CommonFunctions isIphone])
        {
            UIImageView *imageLogoSmall = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            CGSize size = CGSizeZero;
            if (IS_IOS7_OR_LATER)
                size = [lblMovieTimeBanner.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kProximaNova_SemiBold size:12.0],NSFontAttributeName, nil]];
            else
                size = [lblMovieTimeBanner.text sizeWithFont:[UIFont fontWithName:kProximaNova_SemiBold size:12.0]];
            CGRect rect = imageLogoSmall.frame;
            rect.origin.x = lblMovieTimeBanner.frame.origin.x + size.width + 2;
            rect.origin.y = lblMovieTimeBanner.frame.origin.y + 7;
            rect.size.width = 10;
            rect.size.height = 10;
            
            CGRect imgFrame = rect;
            imgFrame.origin.x = 10;
            imgFrame.origin.y = 3;
            imgFrame.size.width = 30;
            imgFrame.size.height = 30;

            [imageLogoSmall setFrame:imgFrame];
            [imageLogoSmall sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:[UIImage imageNamed:nil]];

            [viewVideoInfo addSubview:imageLogoSmall];
        }
        
        [viewVideoInfo addSubview:lblMovieTimeBanner];
        [viewBanner addSubview:viewVideoInfo];
        [viewBanner bringSubviewToFront:viewVideoInfo];
        [viewBanner bringSubviewToFront:btnPlay];
        [scrollViewBanner addSubview:viewBanner];
        
        xOrigin+= scrollViewBanner.frame.size.width;
        [scrollViewBanner setContentSize:CGSizeMake(viewBanner.frame.size.width * (i+1), 0)];
    }
}

- (NSString *)convertGMTDateFromLocalDateWithDaysL:(NSString *)gmtDateStr
{
    NSDateFormatter *serverFormatter = [[NSDateFormatter alloc] init];
    [serverFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [serverFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDate *theDate = [serverFormatter dateFromString:gmtDateStr];
    NSDateFormatter *userFormatter = [[NSDateFormatter alloc] init];
    [userFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [userFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *dateConverted = [userFormatter stringFromDate:theDate];
    
    return dateConverted;
}

- (NSString*)changeDateFormatForDays:(NSString*)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateFromString;
    dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
    int hour = (int)[components hour];
    int mins = (int)[components minute];
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if (hour > 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d PM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour-12, mins];
        }
        else if (hour == 12)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d PM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
        else if (hour == 0)
        {
            hour = 12;
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d AM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
        else
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d, %02d:%02d AM", [CommonFunctions changeLanguageForDays:dayString], [CommonFunctions changeLanguageForMonths:monthString], day, hour, mins];
        }
    }
    else
    {
        if (hour > 12)
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour-12, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else if (hour == 12)
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else if (hour == 0)
        {
            hour = 12;
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"pm" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
        else
        {
            NSString *dayMonth = [NSString stringWithFormat:@",%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
            NSString *Time = [NSString stringWithFormat:@"%02d:%02d %@", hour, mins, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"am" value:@"" table:nil]];
            NSString *final = [NSString stringWithFormat:@"%@ %@", Time, dayMonth];
            strFormattedDate = final;
        }
    }
    return strFormattedDate;
}

-(NSString *)changeDateFormat:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
    int hour = (int)[components hour];
    int mins = (int)[components minute];
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    dateFormatter.dateFormat=@"EEEE";
    NSString * dayString = [[dateFormatter stringFromDate:dateFromString] capitalizedString];
    
    NSString *strFormattedDate;
    if (hour >= 12)
    {
        if(mins>=10)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", dayString, monthString, day];
        }
        else
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", dayString, monthString, day];
        }
    }
    else
    {
        if(mins>=10)
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", dayString, monthString, day];
        }
        else
        {
            strFormattedDate = [NSString stringWithFormat:@"%@ %@ %d", dayString, monthString, day];
        }
    }
    
    return strFormattedDate;
}

-(NSString *)changeDateFormatForUpcoming:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEEE"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
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
        strFormattedDate = [NSString stringWithFormat:@"%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
    }
    
    return strFormattedDate;
}

- (void)addSegmentedView
{
    if (![CommonFunctions isIphone]) {
        if IS_IOS7_OR_LATER
            viewSegmentControl.frame = CGRectMake(0, self.view.frame.size.height-viewSegmentControl.frame.size.height, self.view.frame.size.width, viewSegmentControl.frame.size.height);
        else
            viewSegmentControl.frame = CGRectMake(0, self.view.frame.size.height-viewSegmentControl.frame.size.height-35, self.view.frame.size.width, viewSegmentControl.frame.size.height);
        [self.view addSubview:viewSegmentControl];
    }
    else{
        
        if IS_IOS7_OR_LATER
            viewSegmentControl.frame = CGRectMake(0, self.view.frame.size.height-viewSegmentControl.frame.size.height + ([CommonFunctions isIphone]?5:0), self.view.frame.size.width, viewSegmentControl.frame.size.height);
        else
            viewSegmentControl.frame = CGRectMake(0, self.view.frame.size.height-viewSegmentControl.frame.size.height-35, self.view.frame.size.width, viewSegmentControl.frame.size.height);
        if(![CommonFunctions isIphone5])
            viewSegmentControl.frame = CGRectMake(0, self.view.frame.size.height-viewSegmentControl.frame.size.height-80, self.view.frame.size.width, viewSegmentControl.frame.size.height);
    }
}

- (void)setSegmentedControlAppreance
{
    if (![CommonFunctions isIphone]) {
        [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentBackgroundImageNameiPad] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    else
        [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self setSegmentControlUI];
    
    UIFont *Boldfont = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:15.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentedControl setTitleTextAttributes:selectionAttributes
                                    forState:UIControlStateSelected];
}

#pragma mark - Set Segment Control UI
-(void) setSegmentControlUI
{
    [segmentedControl setFrame:CGRectMake(segmentedControl.frame.origin.x, segmentedControl.frame.origin.y, segmentedControl.frame.size.width, kSegmentControlHeight)];
    
    CGRect frame = kOriginalRectForSegmentControl;
    //Set segment control height.
    if ([CommonFunctions isIphone])
        frame = kOriginalRectForSegmentControl;
    
    if(!IS_IOS7_OR_LATER && [CommonFunctions isIphone5])
        [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y+20, frame.size.width, kSegmentControlHeight)];
    else if(IS_IOS7_OR_LATER && [CommonFunctions isIphone5])
    {
        [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y-5, frame.size.width, kSegmentControlHeightForiphone)];
    }
    else if(iPhone4WithIOS6)
    {
        [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y-20, frame.size.width, kSegmentControlHeightForiphone)];
        CGRect rect = kOriginalRectForLiveNowTable;
        rect.origin.y -= 97;
        rect.size.height += 20;
        [tblLiveNow setFrame:rect];
        rect = imgLiveNow.frame;
        rect.size.height += 15;
        [self.view bringSubviewToFront:imgLiveNow];
        [self.view bringSubviewToFront:lblLiveNowText];
        [imgLiveNow setFrame:rect];
        
        rect = kOriginalRectForWebView;
        rect.origin.y -= 90;
        rect.size.height -= 25;
        [_imgLiveChannelMovieThumb setFrame:rect];
        rect = self.lblNoVideoFoundBannerView.frame;
        rect.origin.y-= 70;
        [self.lblNoVideoFoundBannerView setFrame:rect];
        rect = lblNoVideoFoundCollectionView.frame;
        rect.origin.y -= 130;
        [lblNoVideoFoundCollectionView setFrame:rect];
    }
    else if(iPhone4WithIOS7)
    {
        [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y-10, frame.size.width, kSegmentControlHeightForiphone)];
        CGRect rect = kOriginalRectForScrollViewBanner;
        rect.origin.y += 5;
        [scrollViewBanner setFrame:rect];
        rect = pageControl.frame;
        rect.origin.y += 2;
        [pageControl setFrame:rect];
        rect = tblLiveNow.frame;
        rect.size.height -= 10;
        [tblLiveNow setFrame:rect];
    }
}

#pragma mark - IBAction Methods

- (void)btnPlayAction:(id)sender
{
    LiveNowFeaturedVideo *objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [self.arrLiveFeaturedVideos objectAtIndex:[sender tag]];
    [self playVideo:objLiveNowFeaturedVideo.videoUrl];
}

- (void)playVideo:(NSString*)strVideoUrl
{
    self.bIsOpenMediaPlayer = YES;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
    {
        [self showLoginView];
    }
    else{
        @try
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
            
            mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strVideoUrl]];
            [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
            [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
            
            [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                         name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                       object:nil];
            
            
            //Add Casting button
            objCustomControls = [CustomControls new];
            objCustomControls.strVideoUrl = strVideoUrl;
            objCustomControls.strVideoName = lblMovieName.text;
            objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
            [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:mpMoviePlayerViewController.view moviePlayerViewController:mpMoviePlayerViewController]];
            
            [objCustomControls hideCastButton];  //Hide cast button initially
            self.isCastingButtonHide = YES;
            singleTapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
            singleTapGestureRecognizer.numberOfTapsRequired = 1;
            [singleTapGestureRecognizer setDelegate:self];
            [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
            
            [self presentMoviePlayerViewControllerAnimated:mpMoviePlayerViewController];
                        
            [[NSNotificationCenter defaultCenter] removeObserver:mpMoviePlayerViewController
                                                            name:UIApplicationDidEnterBackgroundNotification
                                                          object:nil];
        }
        @catch (NSException *exception) {
            // throws exception
        }
    }
}

- (void)playVideoOnListView:(NSString*)videoUrl
{
    [btnListView setImage:[UIImage imageNamed:@"list_view_inactive"] forState:UIControlStateNormal];
    [popOverListView dismissPopoverAnimated:YES];
    
    //Play Video
    self.strChannelUrl = [NSString stringWithFormat:@"%@", videoUrl];
    [self playVideo:videoUrl];
}

- (IBAction)btnListViewPressed:(id)sender
{
    if ([self.arrLiveChannelVideos count] != 0) {
        UIButton *btnList = (UIButton*)sender;
        [btnList setImage:[UIImage imageNamed:@"list_view_active"] forState:UIControlStateNormal];
        
        LiveFeaturedListViewController *objVODFeaturedViewController = [[LiveFeaturedListViewController alloc] initWithNibName:@"LiveFeaturedListViewController" bundle:nil];
        objVODFeaturedViewController.delegate = self;
        objVODFeaturedViewController._arrayLiveVideos = self.arrLiveChannelVideos;
        
        popOverListView = [[UIPopoverController alloc] initWithContentViewController:objVODFeaturedViewController];
        popOverListView.popoverBackgroundViewClass = [popoverBackgroundView class];
        
        [popOverListView setDelegate:self];
        
        CGRect rect;
        rect.origin.x = -20;
        rect.origin.y = -365;
        rect.size.width = 440;
        rect.size.height = 379;
        
        [popOverListView presentPopoverFromRect:rect inView:btnList permittedArrowDirections:0 animated:YES];
    }
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrLiveChannelVideos count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveNowFeaturedCollectionCell *cell = [collectionVwGrid dequeueReusableCellWithReuseIdentifier:@"livenowfeaturecell" forIndexPath:indexPath];
    
    [cell setCellValues:[self.arrLiveChannelVideos objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveNowFeaturedVideo *objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [self.arrLiveChannelVideos objectAtIndex:indexPath.row];
    self.strChannelUrl = [NSString stringWithFormat:@"%@", objLiveNowFeaturedVideo.videoUrl];
    [self playVideo:objLiveNowFeaturedVideo.videoUrl];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollViewBanner.frame.size.width;
    int pageNumber = floor((scrollViewBanner.contentOffset.x - viewWidth/50) / viewWidth) +1;
    
    pageControl.currentPage = pageNumber;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollViewBanner.frame.size.width;
    int pageNumber = floor((scrollViewBanner.contentOffset.x - viewWidth/50) / viewWidth) +1;
    LiveNowFeaturedVideo *objLiveNowFeaturedVideo;
    if ([self.arrLiveFeaturedVideos count] != 0) {
        if ([self.arrLiveFeaturedVideos count]>=2 && pageNumber!=0) {
            objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [self.arrLiveFeaturedVideos objectAtIndex:pageNumber-1];
            [imgVwPrev sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:[UIImage imageNamed:@"abc.png"]];
            
            if (pageNumber+1<[self.arrLiveFeaturedVideos count]) {
                objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*) [self.arrLiveFeaturedVideos objectAtIndex:pageNumber+1];
                [imgVwNext sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.videoThumbnailUrl_en] placeholderImage:[UIImage imageNamed:@"abc.png"]];
            }
        }
    }

}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [popOverListView dismissPopoverAnimated:YES];
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
    self.searchBar.delegate = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    objSearchVideoViewController.delegate = self;
    [objSearchVideoViewController handleSearchText:searchBar.text searchCat:(int)segmentedControl.selectedSegmentIndex];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark - Channel view methods
- (void)showChannelSearchPopOver
{
    objSearchVideoViewController = [[SearchVideoViewController alloc] initWithNibName:@"SearchVideoViewController" bundle:nil];
    
    objSearchVideoViewController.iSectionType = 1;
    popOverListView = [[UIPopoverController alloc] initWithContentViewController:objSearchVideoViewController];
    popOverListView.popoverBackgroundViewClass = [popoverBackgroundView class];
    [popOverListView setDelegate:self];
    popOverListView.passthroughViews = [NSArray arrayWithObject:self.searchBar];
    
    CGRect rect;
    rect.origin.x = self.searchBar.frame.size.width;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        rect.origin.y = 40;
    else
        rect.origin.y = 210;
    
    rect.size.width = 450;
    rect.size.height = 666;
    
    [popOverListView presentPopoverFromRect:rect inView:self.searchBar permittedArrowDirections:0 animated:YES];
}

- (void)playSelectedChannelProgram:(NSString *)channelName channelLogo:(NSString*)channelLogo
{
    [self.searchBar resignFirstResponder];
    [popOverListView dismissPopoverAnimated:YES];
    [objChannelDetailView fetchChannelDetailsPlayFromSearch:channelName];
}

- (void)playSelectedLiveNowMovie:(NSString*)videoUrl
{
    [popOverListView dismissPopoverAnimated:YES];
    [self playVideo:videoUrl];
}

- (void)playSelectedUpcomingChannel:(SearchLiveNowVideo*)objSearchLiveNowVideo
{
    [self.searchBar resignFirstResponder];
    [popOverListView dismissPopoverAnimated:YES];
    segmentedControl.selectedSegmentIndex = 1;
    [objChannelDetailView removeFromSuperview];
    
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-41, 1, 82, 72)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
    
    strChannelLogoUrl = [NSString stringWithFormat:@"%@", objSearchLiveNowVideo.upcomingVideoChannelLogoUrl];

    [self.popOverListView dismissPopoverAnimated:YES];
    [btnListView setImage:[UIImage imageNamed:@"list_view_inactive"] forState:UIControlStateNormal];
    
    isChannelDetailOpen = YES;
    objChannelDetailView = [ChannelDetailView customView];
    objChannelDetailView.delegate = self;
    [objChannelDetailView setFrame:CGRectMake(0, 92, 768, self.view.frame.size.height-segmentedControl.frame.size.height-78-20-15-60)];
    [self.view addSubview:objChannelDetailView];
    
    [objChannelDetailView setUIAppearance];
    [objChannelDetailView fetchChannelDetailsAfterSearch:objSearchLiveNowVideo];    //Call method to fetch channel details
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
}

#pragma mark - UIPageControl Method

- (IBAction)changePage:(id)sender
{
    int page = (int)pageControl.currentPage;
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollViewBanner.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollViewBanner scrollRectToVisible:frame animated:YES];
}

#pragma mark - Setting Tableview Default frames
-(void) setTableViewFrameDefaultFrames
{
    if(iPhone4WithIOS6)
    {
        CGRect rect = kOriginalRectForLiveNowTable;
        rect.origin.y -= 139;
        rect.size.height -= 27;
        [tblLiveNow setFrame:rect];
    }
    else if(iPhone4WithIOS7)
    {
        CGRect rect = kOriginalRectForLiveNowTable;
        rect.origin.y -= 47;
        rect.size.height -= 45;
        [tblLiveNow setFrame:rect];
    }
    else if(iPhone5WithIOS7)
    {
        [tblLiveNow setFrame:kOriginalRectForLiveNowTable];
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(segmentedControl.selectedSegmentIndex == 2){
        if (upComingSelected && !searchDetail)
            return [daysForSearch count];
    }
    else if (selectedChannel == YES)
    {
        if ([days count] > 0) {
           return [days count];
        }
        return 0;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(segmentedControl.selectedSegmentIndex == 2)
    {
        if (upComingSelected && !searchDetail)
        {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, 25)];
            header.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0];
            
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
            [header addSubview:headerLabel];
            headerLabel.textColor = [UIColor whiteColor];
            headerLabel.textAlignment = NSTextAlignmentCenter;
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.font = [UIFont fontWithName:kProximaNova_Bold size:14.0];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss EEEE";
            NSString *strDate = [formatter stringFromDate:[daysForSearch objectAtIndex:section]];
            
            [headerLabel setText:[self changeDateFormatForSearch:strDate]];
            
            return header;
        }
    }
    if(segmentedControl.selectedSegmentIndex == 1)
    {
        if(selectedChannel == YES)
        {
            if ([days count] > 0) {
                BOOL y = [self compareDates:[days objectAtIndex:section]];
                if (y == YES) {
                    return nil;
                }
                else
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss EEEE";
                    NSString *strDate = [formatter stringFromDate:[days objectAtIndex:section]];
                    return [self returnViewForHeader:[self changeDateFormatForUpcoming:strDate] UITableView:tblLiveNow];
                }
            }
        }
    }
    return nil;
}

- (UIView *) returnViewForHeader:(NSString *)str UITableView:(UITableView *)tblVw
{
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(tblVw.frame.origin.x, 0, tblVw.frame.size.width, 20)];
    [vw setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(tblVw.frame.origin.x+20, 3, size.width, 14)];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];//change by bharti
    [lbl setBackgroundColor:vw.backgroundColor];
    [lbl setText:str];
    [vw addSubview:lbl];
    return vw;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if((!(segmentedControl.selectedSegmentIndex == 0) && selectedChannel) || (segmentedControl.selectedSegmentIndex == 2))
    {
        if(upComingSelected)
        {
            if ([days count] > 0) {
                BOOL y = [self compareDates:[days objectAtIndex:section]];
                if (y) {
                    return 0;
                }
            }
            return 19;
        }
    }
    if(segmentedControl.selectedSegmentIndex == 1)
    {
        if(selectedChannel)
        {
            if ([days count] > 0) {
                BOOL y = [self compareDates:[days objectAtIndex:section]];
                if (y) {
                    return 0;
                }
            }
            return 19;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(segmentedControl.selectedSegmentIndex == 3)
    {
        return 0;
    }
    if((segmentedControl.selectedSegmentIndex == 1) && !selectedChannel)
    {
        return [arrChannels count];
    }
    else if(segmentedControl.selectedSegmentIndex == 2)
    {
        if(!searchDetail)
        {
            if(!upComingSelected)
                return [arrsearchLiveNowVideos count];
            else
            {
                if([arrsearchLiveNowVideos count] ==0)
                    return 0;
                return [[groupedEventsSearch objectForKey:[daysForSearch objectAtIndex:section]] count];
            }
        }
        else
            return [arrChannelVideos count];
    }
    else if(selectedChannel)
    {
        if ([days count] > 0) {
            return [[groupedEvents objectForKey:[days objectAtIndex:section]] count];
        }
        else
            return 0;
    }
    return [self.arrLiveChannelVideos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((segmentedControl.selectedSegmentIndex == 0) || selectedChannel || (segmentedControl.selectedSegmentIndex == 2))
    {
        if (selectedChannel) {
            return 40;
        }
        return 55;
    }
    else if (segmentedControl.selectedSegmentIndex == 1)
        return 82;
    else
    {
        return 49;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if((segmentedControl.selectedSegmentIndex == 0))
    {
        static NSString *cellIdentifier = @"cell";
        LiveNowCustomCell *cell = [tblLiveNow dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveNowCustomCell" owner:self options:Nil] firstObject];
        }
        
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = [self.arrLiveChannelVideos objectAtIndex:indexPath.row];
        NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objLiveNowFeaturedVideo.videoTime_en];
        cell.lblTime.text = [convertedTime uppercaseString];
        cell.lblChannelName.text = objLiveNowFeaturedVideo.videoName_en;
        CGSize timeLblSize = [cell.lblTime.text sizeWithFont:cell.lblTime.font constrainedToSize:CGSizeMake(120, CGRectGetHeight(cell.lblTime.frame))];
        
        cell.lblTime.frame = CGRectMake(CGRectGetMinX(cell.lblTime.frame), CGRectGetMinY(cell.lblTime.frame), timeLblSize.width, CGRectGetHeight(cell.lblTime.frame));
        cell.lblChannelName.frame = CGRectMake(CGRectGetMaxX(cell.lblTime.frame)+5, CGRectGetMinY(cell.lblChannelName.frame), 150, CGRectGetHeight(cell.lblChannelName.frame));
        
        [cell.imgLiveNowChannel sd_setImageWithURL:[NSURL URLWithString:objLiveNowFeaturedVideo.channelLogoUrl] placeholderImage:[UIImage imageNamed:@""]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if(segmentedControl.selectedSegmentIndex == 1)
    {
        if(selectedChannel)
        {
            static NSString *cellIdentifier = @"cell";
            MelodyHitsCustomCell *cell = [tblLiveNow dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell == nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"MelodyHitsCustomCell" owner:self options:Nil] firstObject];
            }
            
            if ([days count] > 0) {
                
                UpcomingVideo *objUpcomingVideo = [[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                [cell setBackgroundColor:color_Background];
                
                NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideo.upcomingDay];
                
                cell.lblTime.text = [convertedTime uppercaseString];
                
                if ([CommonFunctions isEnglish])
                    cell.lblChannelName.text = objUpcomingVideo.upcomingVideoName_en;
                
                else
                    cell.lblChannelName.text = objUpcomingVideo.upcomingVideoName_ar;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            static NSString *cellIdentifier = @"cell";
            ChannelCustomCell *cell = [tblLiveNow dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell == Nil)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"ChannelCustomCell" owner:self options:Nil] firstObject];
            }
            [cell setBackgroundColor:color_Background];
            Channel *objChannel = [arrChannels objectAtIndex:indexPath.row];
            [cell.imgLogo sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:[UIImage imageNamed:@""]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    if((segmentedControl.selectedSegmentIndex == 2))
    {
        static NSString *cellIdentifier = @"cell";
        LiveNowCustomCell *cell = [tblLiveNow dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == Nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LiveNowCustomCell" owner:self options:Nil] firstObject];
        }
        
        SearchLiveNowVideo *objSearchLiveNowVideo;
        
        if(upComingSelected)
        {
            objSearchLiveNowVideo = [[groupedEventsSearch objectForKey:[daysForSearch objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        }
        else
        {
            objSearchLiveNowVideo = [arrsearchLiveNowVideos objectAtIndex:indexPath.row];
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
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(((segmentedControl.selectedSegmentIndex==0) || (segmentedControl.selectedSegmentIndex==2)) && (!searchDetail))
    {
        if(segmentedControl.selectedSegmentIndex==2)
        {
            searchDetail = true;
            SearchLiveNowVideo *objSearchLiveNowVideo;
            
            if(upComingSelected)
            {
                objSearchLiveNowVideo = [[groupedEventsSearch objectForKey:[daysForSearch objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            }
            else
            {
                objSearchLiveNowVideo = [arrsearchLiveNowVideos objectAtIndex:indexPath.row];
            }
            imgLiveNow.image = nil;
            [imgVwChannelLogo removeFromSuperview];
            imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 55, 48)];
            imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
            [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];

            [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
            
            lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil];

            CGSize size = [lblLiveNowText.text sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:13.0]];
            CGRect rect = channelImage.frame;
            rect.origin.x = (320-size.width + 30)/2 - 30;
            [channelImage setFrame:rect];
            rect = lblLiveNowText.frame;
            rect.origin.x = (320-size.width+5)/2;
            [lblLiveNowText setFrame:rect];
            lblLiveNowText.textAlignment = NSTextAlignmentLeft;
            
            channelURL = objSearchLiveNowVideo.channelURL;
            self.strChannelUrl = objSearchLiveNowVideo.channelURL;
            [channelImage setHidden:YES];
            [channelImage sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.videoThumb] placeholderImage:[UIImage imageNamed:@""]];
            
            UpcomingVideos *objUpcommingVideos = [[UpcomingVideos alloc] init];
            [objUpcommingVideos fetchChannelUpcomingVideos:self selector:@selector(ReponseForChannelVideos:) channelName:objSearchLiveNowVideo.channelName];
            self.navigationItem.leftBarButtonItem  = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemActioniPhone)];
            return;
        }
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = [self.arrLiveChannelVideos objectAtIndex:indexPath.row];
        [self playVideo:objLiveNowFeaturedVideo.videoUrl];
    }
    else
    {
        if(!selectedChannel)
        {
            [imgVwChannelLogo removeFromSuperview];
            imgChannelLiveBg.hidden = NO;

            Channel *objChannel = [arrChannels objectAtIndex:indexPath.row];
            lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil];

            CGSize size = [lblLiveNowText.text sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:13.0]];
            CGRect rect = channelImage.frame;
            rect.origin.x = (320-size.width + 30)/2 - 30;
            [channelImage setFrame:rect];
            rect = lblLiveNowText.frame;
            rect.origin.x = (320-size.width+5)/2;
            [lblLiveNowText setFrame:rect];
            
            lblLiveNowText.textAlignment = NSTextAlignmentLeft;
            channelURL = objChannel.channelLiveNowVideoUrl;
            [channelImage setHidden:YES];
            [channelImage sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:[UIImage imageNamed:@""]];
            strChannelLogoUrl = [NSString stringWithFormat:@"%@", objChannel.channelLogoUrl];
            
            imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 55, 48)];
            imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
            [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:strChannelLogoUrl] placeholderImage:nil];
            [self.navigationController.navigationBar addSubview:imgVwChannelLogo];

            isChannelDetailOpen = YES;

            self.strChannelUrl = [NSString stringWithFormat:@"%@", objChannel.channelLiveNowVideoUrl];
            UpcomingVideos *objUpcommingVideos = [[UpcomingVideos alloc] init];
            [objUpcommingVideos fetchChannelUpcomingVideos:self selector:@selector(ReponseForChannelVideos:) channelName:objChannel.channelName_en];
            self.navigationItem.leftBarButtonItem  = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemActioniPhone)];
        }
    }
}

#pragma mark - MPMoviePlayerViewController Delegate

- (void)FetchMediaPlayerCurrentPlayBackTimeWhileCasting
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.videoStartTime = mpMoviePlayerViewController.moviePlayer.currentPlaybackTime;
}

- (void)PlayCurrentPlayBackTimeOnPlayer
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [mpMoviePlayerViewController.moviePlayer setCurrentPlaybackTime:appDelegate.videoStartTime];
    appDelegate.videoStartTime = mpMoviePlayerViewController.moviePlayer.currentPlaybackTime;
}

- (void)stopVideoWhileCasting
{
    [mpMoviePlayerViewController.moviePlayer pause];
    
    //Add Casting Play/Pause button
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls adddOverlayOnMPMoviplayerWhileCasting:mpMoviePlayerViewController]];
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];

    self.bIsLoad = YES;
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if ([objCustomControls castingDevicesCount]>0) {
        [objCustomControls unHideCastButton];
    }
    
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    { //playing
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    { //stopped
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    { //paused
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
    {
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
    }
    //playableDuration
    //playbackState
    appDelegate.videoStartTime = mpMoviePlayerViewController.moviePlayer.currentPlaybackTime;
    objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    self.bIsLoad = NO;
    [objCustomControls removeNotifications];
    objCustomControls = nil;
    
    [mpMoviePlayerViewController.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:mpMoviePlayerViewController];
    [self dismissMoviePlayerViewControllerAnimated];
    mpMoviePlayerViewController = nil;
}

- (void)hideCastingButtonSyncWithPlayer
{
    self.isCastingButtonHide = NO;
    [objCustomControls hideCastButton];
}

#pragma mark - Youtube player delegate methods
- (void)handleClickOnMediaViewToHideCastButton
{
    if (self.bIsLoad) {
        
        [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];

        if (self.isCastingButtonHide)
        {
            [objCustomControls hideCastButton];
            self.isCastingButtonHide = !self.isCastingButtonHide;
        }
        else
        {
            if ([objCustomControls castingDevicesCount]>0) {
                [objCustomControls unHideCastButton];
                self.isCastingButtonHide = !self.isCastingButtonHide;
            }
        }
    }
}

#pragma mark - Live now Upcoming Button click
-(IBAction)liveNowButton_Clicked:(id)sender
{
    switch ([sender tag])
    {
        case 1:
            upComingSelected = false;
            [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_live_upcoming_btn_active.png"] forState:UIControlStateNormal];
            [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_grey_btn.png"] forState:UIControlStateNormal];
            break;
            
        case 2:
            upComingSelected = true;
            [btnLiveNow setBackgroundImage:[UIImage imageNamed:@"search_grey_btn.png"] forState:UIControlStateNormal];
            [btnUpcoming setBackgroundImage:[UIImage imageNamed:@"search_live_upcoming_btn_active.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    if(![[CommonFunctions shared] isInValidString:txtSearch StringToMatch:kEmptyString])
        [self searchLiveNowVideos];
}

-(NSString *)changeDateFormatForSearch:(NSString *)strDate
{
    NSString *dateString = strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEEE"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:dateFromString];
    
    int day = (int)[components day];
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
        strFormattedDate = [NSString stringWithFormat:@"%d %@ %@", day, [CommonFunctions changeLanguageForMonths:dayString], [CommonFunctions changeLanguageForDays:monthString]];
    }
    
    return strFormattedDate;
}

#pragma mark - UITextField delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    txt = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txt resignFirstResponder];
    
    return YES;
}

#pragma mark - show or hide controls
-(void) showOrHideControls
{
    tblLiveNow.hidden= NO;
    if(!selectedChannel)
    {
        if ([self.arrLiveFeaturedVideos count] == 0) {
            self.lblNoVideoFoundBannerView.hidden = NO;
            lblNoVideoFoundCollectionView.hidden = NO;
            if([CommonFunctions isIphone])
                [tblLiveNow setHidden:YES];
        }
    }
    else
    {
        if ([arrChannelVideos count] == 0)
        {
            if([CommonFunctions isIphone])
                [tblLiveNow setHidden:YES];
        }
    }
}

#pragma mark - Search Action Event


-(IBAction)searchClicked:(id)sender
{
    if(sender != nil)
    {
        if([[CommonFunctions shared] isInValidString:txtSearch StringToMatch:kEmptyString])
        {
            [CommonFunctions showAlertView:kSearchErrorMessage TITLE:kEmptyString Delegate:self];
            [txtSearch becomeFirstResponder];
            return;
        }
    }
    firstSearch = YES;
    [self searchLiveNowVideos];
}

#pragma mark - SearchVideos
-(void) searchLiveNowVideos
{
    if(![[CommonFunctions shared] isInValidString:txtSearch StringToMatch:kEmptyString])
    {
        [txt resignFirstResponder];
        SearchLiveNowVideos *objSearchLiveNowVideos = [[SearchLiveNowVideos alloc] init];
        if(!upComingSelected)
            [objSearchLiveNowVideos searchChannelsLiveNow:self selector:@selector(searchVideosServerResponse:) channelName:txtSearch.text isArb:@"false"];
        else
            [objSearchLiveNowVideos searchChannelsUpcoming:self selector:@selector(searchVideosServerResponse:) channelName:txtSearch.text isArb:@"false"];
    }
}

#pragma mark - UITextField delegate method
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txt resignFirstResponder];
}

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [self.searchBar resignFirstResponder];
    [btnListView setImage:[UIImage imageNamed:@"list_view_inactive"] forState:UIControlStateNormal];
    return YES;
}

#pragma mark - Login View
- (void)showLoginView
{
    [self.searchBar resignFirstResponder];
    LoginViewController *objLoginsViewController = [[LoginViewController alloc] init];
    objLoginsViewController.delegateUpdateMovie = self;
    [self presentViewController:objLoginsViewController animated:YES completion:nil];
}

#pragma mark - Settings Delegate

- (void)popToLiveNowAfterLogout
{
    [imgVwChannelLogo removeFromSuperview];
//    [self.navigationController popViewControllerAnimated:NO];
}

- (void)userSucessfullyLogout
{
    [imgVwChannelLogo removeFromSuperview];
    [popOverListView dismissPopoverAnimated:YES];
}

- (void)changeLanguage
{
    [popOverListView dismissPopoverAnimated:YES];
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    objLanguageViewController.delegate = self;
    [self presentViewController:objLanguageViewController animated:YES completion:nil];
}

- (void)loginUser
{
    [popOverListView dismissPopoverAnimated:YES];
    [self showLoginView];
}

- (void)changeLanguageMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];
    
    [self setLocalizedText];
    if (isChannelDetailOpen) {
        [objChannelDetailView changeLanguageChannelView];
    }
    if (isCompnayInfoOpen) {
        lblNoVideoFoundCollectionView.hidden = YES;
        [objCompanyInfoViewController changeLanguageFromLiveNow];
    }
    if (isFAQOpen) {
        [objFAQViewController reloadFAQTblVw];
    }
    else
    {
        [collectionVwGrid reloadData];
        [self setBannerView:NO];
    }
}

- (void)companyInfoSelected:(int)infoType
{
    [imgVwChannelLogo removeFromSuperview];
    isCompnayInfoOpen = YES;

    [popOverListView dismissPopoverAnimated:YES];
    
    [objCompanyInfoViewController.view removeFromSuperview];
    objCompanyInfoViewController = [[CompanyInfoViewController alloc] initWithNibName:@"CompanyInfoViewController" bundle:nil];
    objCompanyInfoViewController.iInfoType = infoType;
    objCompanyInfoViewController.view.frame = CGRectMake(0, 0, 768, self.view.frame.size.height-segmentedControl.frame.size.height-20);
    [self.view addSubview:objCompanyInfoViewController.view];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
}

- (void)sendFeedback
{
    [imgVwChannelLogo removeFromSuperview];

    [popOverListView dismissPopoverAnimated:YES];
    [objFeedbackViewController.view removeFromSuperview];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
    }
    else{
        objFeedbackViewController = [[FeedbackViewController alloc] init];
        objFeedbackViewController.view.frame = CGRectMake(0, 0, 768, self.view.frame.size.height-segmentedControl.frame.size.height-20);
        objFeedbackViewController.delegate = self;
        [self.view addSubview:objFeedbackViewController.view];
        
        self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    }
}

- (void)cancelSendingFeedback
{
    self.navigationItem.leftBarButtonItem = nil;
    [objFeedbackViewController.view removeFromSuperview];
}

- (void)FAQCallBackMethod
{
    [imgVwChannelLogo removeFromSuperview];
    isFAQOpen = YES;
    [popOverListView dismissPopoverAnimated:YES];
    [objFAQViewController.view removeFromSuperview];
    
    objFAQViewController = [[FAQViewController alloc] init];
    objFAQViewController.view.frame = CGRectMake(0, 0, 768, 960);
    if IS_IOS7_OR_LATER
        objFAQViewController.view.frame = CGRectMake(0, 90, 768, 960);
    
    [self.view addSubview:objFAQViewController.view];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
}

#pragma mark - UIWebview Delegate method
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [wbVwVideo setHidden:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(segmentedControl.selectedSegmentIndex!=0)
    {
        [wbVwVideo setHidden:NO];
        if(![CommonFunctions userLoggedIn])
        {
            [userLoggedInButton setHidden:NO];
        }
        else
        {
            [userLoggedInButton setHidden:NO];
        }
    }
}

#pragma mark - Action for playing Video
-(IBAction) PlayVideo_Clicked:(id)sender
{
    if(![CommonFunctions userLoggedIn])
    {
        [self showLoginViewForPlayingVideo];
    }
    else
    {
        if (lblMovieName.hidden == NO) {
            MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
            objMoviePlayerViewController.strVideoUrl = self.strChannelUrl;
            
            [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - Hide playing button
-(void) hidePlayingButton
{
    [userLoggedInButton setHidden:NO];
}

#pragma mark - Login View
- (void)showLoginViewForPlayingVideo
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegate = self;
    objLoginViewController.selector = @selector(hidePlayingButton);
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

+ (void)popFromVodSection
{
    
}

#pragma mark - Login Delegate Method

- (void)updateMovieDetailViewAfterLogin
{
    [self playVideo:self.strChannelUrl];
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
    if (![CommonFunctions isIphone]) {
        [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 122]];
    }
    else
    {
        [self.view addSubview:[CommonFunctions addAdmobBanner:self.view.frame.size.height - 50]];
    }
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Memory Management Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"PopToLiveNowAfterLogout"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end