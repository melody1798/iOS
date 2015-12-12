//
//  MovieDetailViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "VideoDetail.h"
#import "CustomControls.h"
#import "DetailArtist.h"
#import "Constant.h"
#import "MoviePlayerViewController.h"
#import "WatchListMovies.h"
#import "NSIUtility.h"
#import "AppDelegate.h"
#import "WatchListViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CommonFunctions.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "UIImageView+WebCache.h"
#import "SeriesDetail.h"
#import "FAQViewController.h"
#import "VODSearchController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "EpisodeDetailViewController.h"
#import "CustomControls.h"

@interface MovieDetailViewController () <UITableViewDataSource, UITableViewDelegate, UpdateMovieDetailOnLoginDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, UIActionSheetDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList, UpdateMovieDetailOnLoginDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView*           tblVwCastAndCrew;
    IBOutlet UILabel*               lblMovieName;
    IBOutlet UIButton*              btnAddToWatchList;
    IBOutlet UIButton*              btnShare;
    IBOutlet UIButton*              btnPlayVideo;
    IBOutlet UILabel*               lblSingerName;
    IBOutlet UILabel*               lblMusicVideoDuration;
    IBOutlet UIImageView*           imgVwVideoThumbnail;
    LoginViewController*            objLoginViewController;
    UIPopoverController*            popOverSearch;
    SearchVideoViewController*      objSearchVideoViewController;
    SettingViewController*          objSettingViewController;
    IBOutlet UIView*                vwMovieDetailHeader;
    IBOutlet UIView*                vwActionSheetView;
    IBOutlet UIImageView*           imgVwActionSheetBg;
    MPMoviePlayerViewController*    mpMoviePlayerViewController;
    CustomControls*                 objCustomControls;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
}

@property (strong, nonatomic) UISearchBar*      searchBarVOD;
@property (strong, nonatomic) NSMutableString*  strSingerName;
@property (assign, nonatomic) BOOL              isForWatchlist;
@property (strong, nonatomic) NSString*         strThumbnailUrl;
@property (strong, nonatomic) NSString*         strMovieDuration;
@property (assign, nonatomic) BOOL              isCastingButtonHide;
@property (assign, nonatomic) BOOL              bIsLoad;
@property (retain, nonatomic) NSString*         strMovieNameFacebookShare;
@property (retain, nonatomic) NSString*         strSeriesNameFacebookShare;


- (IBAction)btnAddToWatchListAction:(id)sender;
- (IBAction)btnPreviewAction:(id)sender;
- (IBAction)btnShareListAction:(id)sender;
- (IBAction)playBtnAction:(id)sender;
- (IBAction)btnActionSheetHide:(id)sender;
- (IBAction)btnFacebookShare:(id)sender;
- (IBAction)btnTwitterShare:(id)sender;
- (IBAction)btnWhatsappShare:(id)sender;
- (IBAction)btnEmailShare:(id)sender;
@end

@implementation MovieDetailViewController

@synthesize strMovieId;
@synthesize isMusicVideo;
@synthesize isEpisode;

@synthesize arrCastAndCrew;
@synthesize arrProducers;
@synthesize strVideoUrl;
@synthesize strVideoDesc;
@synthesize strVideoTitle;
@synthesize strSeriesImageUrl;
@synthesize strEpisodeId;
@synthesize strGenreName;
@synthesize isEpisodeInWatchList;
@synthesize strEpisodeNum;
@synthesize strEpisodeDuration;

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



    lblMovieName.text = self.strVideoTitle; //Set video title

    [self setlocalizedText]; //localized text
    //Update watchlist counter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];
    //Pop to root VOD home when tapped on melody logo navigatin bar.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewToRootViewController) name:@"PopViewToRootViewController" object:nil];
    
    [self setUI]; //Set UI
    self.navigationItem.hidesBackButton = YES; //Hide back button
    [self setNavigationBarButtons];
    
    if (self.isSeries == NO) {
        if ([self checkUserAccessToken]) {
        }
    }
}

- (void)setUI
{
    [lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:22.0]];
    [btnAddToWatchList.titleLabel setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [btnShare.titleLabel setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [lblSingerName setFont:[UIFont fontWithName:kProximaNova_Bold size:13.0]];
    [lblMusicVideoDuration setFont:[UIFont fontWithName:kProximaNova_Bold size:11.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //Add iAd
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    
    imgVwVideoThumbnail.image = nil;
    if (IS_IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    if (self.isSeries == YES) {
        
        if (self.isEpisodeInWatchList == YES) {
            btnAddToWatchList.enabled = NO;
            [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
        }
        else
        {
            btnAddToWatchList.enabled = YES;
            [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_inactive"] forState:UIControlStateNormal];
        }
        SeriesDetail *objSeriesDetail = [SeriesDetail new];
        [objSeriesDetail fetchSeriesDetail:self selector:@selector(seriesDetailServerResponse:) parameter:strMovieId];
    }
    else
    {
        //Fetch movie detail
        VideoDetail *objVideoDetail = [VideoDetail new];
        [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:strMovieId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    }

    [self setlocalizedText];
    [tblVwCastAndCrew reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)popViewToRootViewController
{
    tblVwCastAndCrew.dataSource = nil;
    tblVwCastAndCrew.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)movieDetailFromWatchListPop:(NSString*)movieId
{
    strMovieId = movieId;
}

#pragma mark - UI update methods

- (void)setlocalizedText
{
    [btnAddToWatchList setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"add to watchlist" value:@"" table:nil] forState:UIControlStateNormal];
    [btnShare setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] uppercaseString] forState:UIControlStateNormal];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
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


#pragma mark - Settings Delegate
- (void)userSucessfullyLogout
{
    [popOverSearch dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
}

- (void)changeLanguage
{
    [popOverSearch dismissPopoverAnimated:YES];
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    objLanguageViewController.delegate = self;
    [self presentViewController:objLanguageViewController animated:YES completion:nil];
}

- (void)changeLanguageMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    VideoDetail *objVideoDetail = [VideoDetail new];
    [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:strMovieId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    
    [self setlocalizedText];
    [tblVwCastAndCrew reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginScreen];
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
    VODSearchController *objVODSearchController = [[VODSearchController alloc] init];
    [self.navigationController pushViewController:objVODSearchController animated:NO];
}

- (void)watchListItemAction
{
    self.isForWatchlist = YES;
    if (![self checkUserAccessToken]) {
        
        [self showLoginScreen];
    }
    else{
        
        BOOL toPush = YES;
        NSArray *viewControllers = [self.navigationController viewControllers];
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[WatchListViewController class]]) {
                toPush = NO;
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        if (toPush) {
            WatchListViewController *objWatchListViewController = [[WatchListViewController alloc] initWithNibName:@"WatchListViewController" bundle:nil];
            objWatchListViewController.delegate = self;
            //Fetch and pass current view cgcontext for background display
            UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
            objWatchListViewController._imgViewBg = viewImage;
            [self.navigationController pushViewController:objWatchListViewController animated:YES];
        }
    }
}

- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

- (void)showLoginScreen
{
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegateUpdateMovie = self;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

#pragma mark - Settings Delegate
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
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    [popOverSearch dismissPopoverAnimated:YES];
    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQViewController animated:YES];
}

#pragma mark - IBAction

- (IBAction)playBtnAction:(id)sender
{
    if (![self checkUserAccessToken]) {
        
        [self showLoginScreen];
    }
    else{
        
        NSString *movieID = strMovieId;
        if (self.isSeries) {
            movieID = strEpisodeId;
        }
        
        //Play in media player
        if ([self.strVideoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self performSelector:@selector(convertBCoveUrl:) withObject:self.strVideoUrl afterDelay:0.1];
        }
        else if ([self.strVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSRange range = [self.strVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [self.strVideoUrl length])];
            NSString *youtubeVideoId = [self.strVideoUrl substringFromIndex:range.location+1];
            [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:self.strVideoUrl];
            
            [self saveToLastViewed];
        }
        else //Play in Movieplayer viewcontroller
        {
            MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
            objMoviePlayerViewController.strVideoUrl = self.strVideoUrl;
            objMoviePlayerViewController.strVideoId = movieID;
            [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
        }
    }
}

- (void)convertBCoveUrl:(id)object
{
    //Convert bcove url in mp4
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
}

- (void)saveToLastViewed
{
    if ([self checkUserAccessToken] && self.strVideoUrl!=nil) {
        
        //Save to last viewed
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strVideoUrl, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

#pragma mark - Youtube player
- (void)playYoutubeVideoPlayer:(NSString*)youtubeVideoId videoUrl:(NSString*)videoUrl
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //Notifications to handle casting values.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopYoutubeVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchYoutubeMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayYoutubeCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
    
    youtubeMoviePlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:youtubeVideoId];
    [youtubeMoviePlayer.moviePlayer prepareToPlay];
    youtubeMoviePlayer.moviePlayer.shouldAutoplay = YES;
    youtubeMoviePlayer.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    //Add Casting button
    objCustomControls = [CustomControls new];
    objCustomControls.strVideoUrl = videoUrl;
    objCustomControls.strYoutubeVideoUrl = videoUrl;
    objCustomControls.startingTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
    
    [youtubeMoviePlayer.moviePlayer.view addSubview:[objCustomControls castingIconButton:youtubeMoviePlayer.view moviePlayerViewController:youtubeMoviePlayer]];
    
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:youtubeMoviePlayer.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stateChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:youtubeMoviePlayer.moviePlayer];
    //hode cast button intially (unhide after loading youtube player)
    [objCustomControls hideCastButton];
    self.isCastingButtonHide = YES;
    //Add tap gesture to hide/unhide cast button.
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [youtubeMoviePlayer.view addGestureRecognizer:singleTapGestureRecognizer];
    
    [self presentMoviePlayerViewControllerAnimated:youtubeMoviePlayer];
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

- (void)videoFinished:(NSNotification *)notification
{
    self.bIsLoad = NO;
    objCustomControls = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:youtubeMoviePlayer.moviePlayer];
    youtubeMoviePlayer = nil;
}

- (void)FetchYoutubeMediaPlayerCurrentPlayBackTimeWhileCasting
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.videoStartTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
}

- (void)PlayYoutubeCurrentPlayBackTimeOnPlayer
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [youtubeMoviePlayer.moviePlayer setCurrentPlaybackTime:appDelegate.videoStartTime];
    appDelegate.videoStartTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
}

- (void)stopYoutubeVideoWhileCasting
{
    [youtubeMoviePlayer.moviePlayer pause];
    
    //Add Casting Play/Pause button
    [youtubeMoviePlayer.moviePlayer.view addSubview:[objCustomControls adddOverlayOnMPMoviplayerWhileCasting:youtubeMoviePlayer]];
}

- (void)hideCastingButtonSyncWithPlayer
{
    self.isCastingButtonHide = NO;
    [objCustomControls hideCastButton];
}

- (void)stateChange:(NSNotification*)notification
{
    if ([objCustomControls castingDevicesCount]>0) { //Check if there is any casting device available.
        
        [objCustomControls unHideCastButton];
    }
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime]; //Hide cast icon after 5 seconds

    self.bIsLoad = YES;

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.videoStartTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
    
    if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    { //playing
    }
    if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    { //stopped
    }
    if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    {
    }
    if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
    {
    }
    if (youtubeMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
    }
    //Add Casting button
    objCustomControls.strVideoUrl = [NSString stringWithFormat:@"%@", youtubeMoviePlayer.moviePlayer.contentURL];
    objCustomControls.strVideoName = lblMovieName.text;
    objCustomControls.totalVideoDuration = youtubeMoviePlayer.moviePlayer.duration;
}


#pragma mark - Play movie in Media player
- (void)playInMediaPlayer:(NSString*)strMP4VideoUrl
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
    mpMoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    //Add Casting button
    objCustomControls = [CustomControls new];
    objCustomControls.strVideoUrl = strMP4VideoUrl;
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
    
    [self saveToLastViewed];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mpMoviePlayerViewController
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
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
        
        self.isCastingButtonHide = !self.isCastingButtonHide;
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
    //    }
}

#pragma mark - IBAction Methods
- (IBAction)btnPreviewAction:(id)sender
{
    [NSIUtility showAlertView:nil message:kUnderConstructionErrorMessage];
}

- (IBAction)btnShareListAction:(id)sender
{
    if ([strVideoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
    }
    else
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            imgVwActionSheetBg.layer.cornerRadius = 12.0;
            imgVwActionSheetBg.layer.masksToBounds = YES;
            [self.view addSubview:vwActionSheetView];
        }
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share with" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"" otherButtonTitles:@"", @"", @"", nil];
            
            [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
            
            [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"twitter_icon"] forState:UIControlStateNormal];
            
            [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImage imageNamed:@"whatsapp"] forState:UIControlStateNormal];
            
            [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:3] setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
            
            [actionSheet showInView:self.view];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {   //facebook share
            [self shareOnFacebook];
            break;
        }
        case 1:
        {
            //Twitter Share
            [self shareOnTwitter];
            break;
        }
        case 2:
        {
            //Whatsapp
            [self shareOnWhatsapp];
            break;
        }
        case 3:
        {
            //Email
            [self showMailComposer];
            break;
        }
        default:
            break;
    }
}

- (void)showMailComposer
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;

        NSString *strUrlToShare = [NSString stringWithFormat:@"%@", self.strMovieNameFacebookShare];
        [mail setSubject:[NSString stringWithFormat:@"%@", self.strMovieNameFacebookShare]];
        [mail setMessageBody:[NSString stringWithFormat:@"%@<p><font size=\"2\" face=\"Helvetica\"><a href=%@>%@</a></font></p>%@", strUrlToShare, strVideoUrl, strVideoUrl, [CommonFunctions showPostedMessageDownload]] isHTML:YES];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        DLog(@"This device cannot send email");
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView* view in [actionSheet subviews]) {
        
        if ([view isKindOfClass:NSClassFromString(@"UIAlertButton")]) {
        }
    }
}

- (void)shareOnFacebook
{
    /*
    // If the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *par = [[FBShareDialogParams alloc] init];
    par.link = [NSURL URLWithString:self.strVideoUrl];
    par.picture = [NSURL URLWithString:self.strThumbnailUrl];
    
    par.name = [NSString stringWithFormat:@"%@\n%@", self.strMovieNameFacebookShare, self.strVideoUrl];
    par.caption = self.strVideoUrl;
    //  par.description = strCaptionToShare;

    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   par.name, @"name",
                                   @" ", @"caption",
                                   [self showPostedMessageFacebook], @"description",
                                   strVideoUrl, @"link",
                                   self.strThumbnailUrl, @"picture",
                                   nil];*/
    // If the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *par = [[FBShareDialogParams alloc] init];
    par.link = [NSURL URLWithString:strVideoUrl];
    par.picture = [NSURL URLWithString:self.strThumbnailUrl];
    
    par.name = [NSString stringWithFormat:@"%@\n%@", self.strMovieNameFacebookShare, self.strVideoUrl];
    par.caption = self.strVideoUrl;
    //  par.description = strCaptionToShare;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   par.name, @"name",
                                   @" ", @"caption",
                                   [self showPostedMessageFacebook], @"description",
                                   strVideoUrl, @"link",
                                   self.strThumbnailUrl, @"picture",
                                   nil];
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User cancelled.
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User cancelled.
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"posted successfully" value:@"" table:nil]];
                                                          }
                                                      }
                                                  }
                                              }];
}

- (NSString*)showPostedMessageFacebook
{
    return @"For more movies, series and music videos, download Melody Now app from Apple App Store or Google Play Store";
}

#pragma mark - A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)shareOnTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString *strUrlToShare = [NSString stringWithFormat:@"%@\n%@\n%@", self.strMovieNameFacebookShare, self.strVideoUrl, [CommonFunctions showPostedMessageTwitter]];
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:strUrlToShare];
      //  [tweetSheet addURL:[NSURL URLWithString:self.strVideoUrl]];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    break;
                    
                case SLComposeViewControllerResultDone:
                    [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"posted successfully" value:@"" table:nil]];
                    break;
                    
                default:
                    break;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else{
        [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Please check twitter settings" value:@"" table:nil]];
    }
}

- (IBAction)btnAddToWatchListAction:(id)sender
{
    self.isForWatchlist = YES;

    if (![self checkUserAccessToken]) {
        
        [self showLoginScreen];
    }
    else{
        
        NSString *movieId = strMovieId;
        if (self.isSeries) {
            movieId = strEpisodeId;
        }
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToWatchList:self selector:@selector(saveWatchListServerResponse:) parameter:dict];
    }
}

- (IBAction)btnActionSheetHide:(id)sender
{
    [vwActionSheetView removeFromSuperview];
}

- (IBAction)btnFacebookShare:(id)sender
{
    [vwActionSheetView removeFromSuperview];
    [self shareOnFacebook];
}

- (IBAction)btnTwitterShare:(id)sender
{
    [vwActionSheetView removeFromSuperview];
    [self shareOnTwitter];
}


- (IBAction)btnWhatsappShare:(id)sender
{
    [vwActionSheetView removeFromSuperview];
    [self shareOnWhatsapp];
}

- (IBAction)btnEmailShare:(id)sender
{
    [vwActionSheetView removeFromSuperview];
    [self showMailComposer];
}

- (void)shareOnWhatsapp
{
    // strMovieUrl = @"http://youtu.be/OiTiKOy59o4";
    
    NSString *strUrlToShare = strVideoUrl;
    
    if ([strUrlToShare rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSMutableString *strUrl = [[NSMutableString alloc] init];
        [strUrl appendString:@"http://youtu.be"];
        [strUrl appendString:@"/"];
        
        NSArray* dividedText = [strUrlToShare componentsSeparatedByString:@"v="];
        
        if ([dividedText count] > 1) {
            [strUrl appendString:[dividedText objectAtIndex:1]];
        }
        
        strUrlToShare = strUrl;
    }
    
    NSString *strCaptionToShare = [NSString stringWithFormat:@"%@", self.strMovieNameFacebookShare];

    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@\n%@\n%@", strCaptionToShare, strUrlToShare, [CommonFunctions showPostedMessageDownload]];
    urlWhats = [urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Server Response
- (void)videoDetailServerResponse:(VideoDetail*)objVideoDetail
{
    self.strMovieNameFacebookShare = [NSString stringWithFormat:@"%@", objVideoDetail.movieTitle_en];

    self.strThumbnailUrl = [NSString stringWithFormat:@"%@", objVideoDetail.movieThumbnail];
    [imgVwVideoThumbnail sd_setImageWithURL:[NSURL URLWithString:objVideoDetail.movieThumbnail]];
    
    self.arrCastAndCrew = [[NSArray alloc] initWithArray:objVideoDetail.arrCastAndCrew];
    self.arrProducers = [[NSArray alloc] initWithArray:objVideoDetail.arrProducers];
    self.strVideoUrl = [NSString stringWithFormat:@"%@", objVideoDetail.movieUrl];
    
    if ([self.strVideoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound) {
       btnShare.enabled = NO;
    }
    
    if ([objVideoDetail.videoType isEqualToString:@"2"]) {
        isMusicVideo = YES;
    }
    if (isMusicVideo) {
        
        self.strSingerName = [[NSMutableString alloc] init];
        int numberOfSingers = 0;
        for (int i = 0; i < [self.arrCastAndCrew count]; i++) {
            
            DetailArtist *objDetailArtist = [self.arrCastAndCrew objectAtIndex:i];
            if ([objDetailArtist.artistRoleId isEqualToString:@"4"]) {
                
                numberOfSingers++;
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                {
                    [self.strSingerName appendString:objDetailArtist.artistName_en];
                }
                else
                {
                    [self.strSingerName appendString:objDetailArtist.artistName_ar];
                }
                
                if (i != [self.arrCastAndCrew count]-1) {
                    [self.strSingerName appendString:@", "];
                }
            }
        }
        
        if (numberOfSingers == 1) {
            
            [self.strSingerName replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.strSingerName length])];
        }
    }
    
    if ([objVideoDetail.movieDuration length] != 0) {
        
       // lblMusicVideoDuration.text = [NSString stringWithFormat:@"%@ %@", objVideoDetail.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
    }

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if (isMusicVideo) {
            
            self.strVideoDesc = [NSString stringWithFormat:@"%@\n%@ %@\n\n%@", self.strSingerName, objVideoDetail.movieDuration, [objVideoDetail.movieDuration length]==0?@"": [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDesc_en];
        }
        else
            self.strVideoDesc = [NSString stringWithFormat:@"%@\n\n%@ : %@ %@", objVideoDetail.movieDesc_en, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objVideoDetail.movieDuration, [objVideoDetail.movieDuration length]==0?@"": [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        
        self.strVideoTitle = [NSString stringWithFormat:@"%@", objVideoDetail.movieTitle_en];
    }
    else
    {
        self.strMovieDuration = [NSString stringWithFormat:@"%@", objVideoDetail.movieDuration];
        
//        self.strVideoDesc = [NSString stringWithFormat:@"%@\n\n%@ : %@ %@", objVideoDetail.movieDesc_ar, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [objVideoDetail.movieDuration length]==0?@"": [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDuration];
        
        self.strVideoDesc = [NSString stringWithFormat:@"%@\n\n", objVideoDetail.movieDesc_ar];
        
        self.strVideoTitle = [NSString stringWithFormat:@"%@", objVideoDetail.movieTitle_ar];
    }
    
    if (objVideoDetail.existsInWatchlist == YES) {
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
    }
    else
    {
        btnAddToWatchList.enabled = YES;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_inactive"] forState:UIControlStateNormal];
    }
    [self setupUIInfo];
}

- (void)seriesDetailServerResponse:(SeriesDetail*)objSeriesDetail
{
    self.strMovieNameFacebookShare = [NSString stringWithFormat:@"%@ - Ep %@", objSeriesDetail.seriesName_en, strEpisodeNum];
    
    lblMovieName.text = [NSString stringWithFormat:@"%@ - %@ %@", objSeriesDetail.seriesName, strEpisodeNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil]];
    
    self.strThumbnailUrl = [NSString stringWithFormat:@"%@", strSeriesImageUrl];

    [imgVwVideoThumbnail sd_setImageWithURL:[NSURL URLWithString:strSeriesImageUrl]];
    
    self.strVideoDesc = [NSString stringWithFormat:@"%@\n\n", objSeriesDetail.seriesDesc];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        self.strVideoDesc = [NSString stringWithFormat:@"%@\n\n%@ : %@ %@", objSeriesDetail.seriesDesc, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], self.strEpisodeDuration, [self.strEpisodeDuration length]==0?@"": [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
    else
        self.strMovieDuration = [NSString stringWithFormat:@"%@", self.strEpisodeDuration];

    self.arrCastAndCrew = [[NSArray alloc] initWithArray:objSeriesDetail.arrSeriesCastAndCrew];
    self.arrProducers = [[NSArray alloc] initWithArray:objSeriesDetail.arrSeriesProducers];
    [tblVwCastAndCrew reloadData];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)saveWatchListServerResponse:(NSDictionary*)dictResponse
{
    if ([[dictResponse objectForKey:@"Error"] intValue] == 0) {
        
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];

        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.iWatchListCounter++;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWatchListMovieCounter" object:nil];
        if (self.isSeries == YES) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EpisodeInWatchListFromSeriesDetail" object:nil];
        }
    }
}

#pragma mark - NavigationBar Button Action
- (void)backBarButtonItemAction
{
    NSInteger count = [self.navigationController.viewControllers count]-3;
    UIViewController * groupViewController = [self.navigationController.viewControllers objectAtIndex:count];
    [self.navigationController popToViewController:groupViewController animated:YES];
    return;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup UI
- (void)setupUIInfo
{
    lblMovieName.text = self.strVideoTitle;
    [lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:22.0]];
    [btnAddToWatchList.titleLabel setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [btnShare.titleLabel setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [btnShare addTarget:self action:@selector(btnShareListAction:) forControlEvents:UIControlEventTouchUpInside];
    [tblVwCastAndCrew reloadData];
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

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int totalSections = 3;
    
    if (isMusicVideo) {
        totalSections = 1;
    }
    return totalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalRows;
    switch (section) {
        case 0:
        {
            if ([self.strVideoDesc length] != 0)
                totalRows = 1;
            else
                totalRows = 0;
            break;
        }
        case 1:
        {
            totalRows = [self.arrCastAndCrew count];
            break;
        }
        case 2:
        {
            totalRows = [self.arrProducers count];
            break;
        }
        default:
            totalRows = 1;
            break;
    }
    return totalRows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectZero];
    [lblText setFont:[UIFont fontWithName:kProximaNova_Regular size:18.0]];
    lblText.backgroundColor = [UIColor clearColor];
    lblText.textColor = [UIColor whiteColor];
    
    switch (indexPath.section) {
        case 0:
        {
            lblText.frame = CGRectMake(20, 0, 700, 40);
            float lblHeight = [self getTextHeight:self.strVideoDesc AndFrame:lblText.frame];
            lblText.lineBreakMode = NSLineBreakByWordWrapping;
            [lblText setFrame:CGRectMake(20, 10, 700, lblHeight)];
            lblText.numberOfLines = lblHeight/18.0;

//            if ([self.strMovieDuration length]!=0) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {

                NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];
                NSMutableAttributedString *lbltextRuntime = [[NSMutableAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil]];
                
                NSString *lbltext = [NSString stringWithFormat:@" : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], self.strMovieDuration];
                
                NSAttributedString *strDesc = [[NSAttributedString alloc] initWithString:strVideoDesc];
                [lbltextMu appendAttributedString:strDesc];
                [lbltextMu appendAttributedString:lbltextRuntime];

                [lbltextMu appendAttributedString:[CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular]];

                lblText.attributedText = lbltextMu;
            }
            else
                lblText.text = self.strVideoDesc;

            break;
        }
       
        case 1:
        {
            [lblText setFrame:CGRectMake(20, 5, 350, 30)];
            [lblText setBackgroundColor:[UIColor clearColor]];
            
            UILabel *lblRole = [[UILabel alloc] initWithFrame:CGRectMake(400, 5, 340, 30)];
            [lblRole setFont:[UIFont fontWithName:kProximaNova_Regular size:18.0]];
            lblRole.backgroundColor = [UIColor clearColor];
            lblRole.textColor = [UIColor grayColor];
            [cell.contentView addSubview:lblRole];
            
            DetailArtist *objDetailArtist = (DetailArtist*) [self.arrCastAndCrew objectAtIndex:indexPath.row];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            {
                lblText.text = objDetailArtist.artistName_en;
                lblRole.text = objDetailArtist.artistRole_en;
            }
            else{
                lblText.text = objDetailArtist.artistName_ar;
                lblRole.text = objDetailArtist.artistRole_ar;
            }
            break;
        }
        case 2:
        {
            [lblText setFrame:CGRectMake(20, 5, 160, 30)];
            UILabel *lblRole = [[UILabel alloc] initWithFrame:CGRectMake(400, 5, 160, 30)];
            [lblRole setFont:[UIFont fontWithName:kProximaNova_Regular size:18.0]];
            lblRole.backgroundColor = [UIColor clearColor];
            lblRole.textColor = [UIColor grayColor];
            [cell.contentView addSubview:lblRole];
            
            DetailArtist *objDetailArtist = (DetailArtist*) [self.arrProducers objectAtIndex:indexPath.row];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            {
                lblText.text = objDetailArtist.artistName_en;
                lblRole.text = objDetailArtist.artistRole_en;
            }
            else
            {
                lblText.text = objDetailArtist.artistName_ar;
                lblRole.text = objDetailArtist.artistRole_ar;
            }
            break;
        }
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lblText];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (float) getTextHeight:(NSString*)str AndFrame:(CGRect)frame
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:18.0];
    CGFloat heightLbl;
    if (IS_IOS7_OR_LATER) {

        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)
                                                      options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
        
        frame.size.height = ceilf(CGRectGetHeight(rect));
        heightLbl = ceilf(frame.size.height) + 30;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
            heightLbl = ceilf(frame.size.height) + 95;
    } else {
        CGSize size = [self.strVideoDesc sizeWithFont:font constrainedToSize:CGSizeMake(748, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        heightLbl = ceilf(size.height) + 54;
    }
    return MAX(heightLbl, 54.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:18.0];
    float heightLbl;
    if (indexPath.section == 0) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            if (IS_IOS7_OR_LATER) {
                heightLbl = [self getTextHeight:self.strVideoDesc AndFrame:CGRectMake(20, 5, 700, 40)];
            }
            else
            {
                CGSize size = [self.strVideoDesc sizeWithFont:font constrainedToSize:CGSizeMake(748, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                heightLbl = ceilf(size.height) + 54.0;
            }
            return MAX(heightLbl, 54.0);
        }
        else
        {
            if (IS_IOS7_OR_LATER) {
                heightLbl = [self getTextHeight:self.strVideoDesc AndFrame:CGRectMake(20, 5, 700, 40)];
            }
            else
            {
                CGSize size = [self.strVideoDesc sizeWithFont:font constrainedToSize:CGSizeMake(748, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                heightLbl = ceilf(size.height) + 95.0;
            }
            return MAX(heightLbl, 60.0);
        }
    }
    
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc] init];
    
    [viewHeader setFrame:CGRectMake(0, 0, 768, 30)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 700, 20)];
    [lblHeaderTitle setBackgroundColor:[UIColor clearColor]];
    [lblHeaderTitle setTextColor:[UIColor grayColor]];

    [lblHeaderTitle setFont:[UIFont fontWithName:kProximaNova_SemiBold size:18.0]];
    if (section == 1 && [self.arrCastAndCrew count]!=0) {
        [lblHeaderTitle setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cast and crew" value:@"" table:nil]];
    }
    else if (section == 2 && [self.arrProducers count] != 0) {
        [lblHeaderTitle setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"producers" value:@"" table:nil]];
    }
    
    switch (section) {
        case 0:
        {
            [viewHeader setFrame:CGRectMake(0, 0, 768, 0)];
            break;
        }
        case 1:
        {
            if ([self.arrCastAndCrew count]!= 0) {
                [viewHeader addSubview:lblHeaderTitle];
            }
            break;
        }
        case 2:
        {
            if ([self.arrProducers count]!= 0) {
                [viewHeader addSubview:lblHeaderTitle];
            }
            break;
        }
        default:
            break;
    }
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        case 1:
        {
            if ([self.arrCastAndCrew count] != 0)
                return 60;
            break;
        }
        case 2:
        {
            if ([self.arrProducers count] != 0)
                return 60;
            break;
        }
        default:
            break;
    }
    
    return 0;
}

#pragma mark - Channel Play Delegate Method
- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self.searchBarVOD resignFirstResponder];
    
    [self.searchBarVOD removeFromSuperview];
    if (isSeries == NO) {

        self.strMovieId = videoId;
        //Fetch movie detail
        VideoDetail *objVideoDetail = [VideoDetail new];
        [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:strMovieId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    }
    else{
        SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
        objSeriesEpisodesViewController.strSeriesId = videoId;
        objSeriesEpisodesViewController.seriesUrl = @"";
        
        objSeriesEpisodesViewController.seriesName_en = seriesName;
        objSeriesEpisodesViewController.seriesName_ar = seriesName;
        objSeriesEpisodesViewController.seriesUrl = seriesThumb;
        
        [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
    }
}

#pragma mark - Update Detail Movie after login

- (void)updateMovieDetailViewAfterLogin
{
    VideoDetail *objVideoDetail = [VideoDetail new];
    [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:strMovieId UserID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    
    if (self.isForWatchlist == NO) {
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = self.strVideoUrl;
        objMoviePlayerViewController.strVideoId = strMovieId;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
        {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"posted successfully" value:@"" table:nil]];
            break;
        }
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultCancelled:
        {

            break;
        }
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController
{
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
    
    return YES;
}

- (NSMutableAttributedString*)changeMinTextFont:(NSString*)lblText fontName:(NSString*)textFontName
{
    //Format bullets
    NSMutableAttributedString *bulletStr = [[NSMutableAttributedString alloc] initWithString:@"د"];
    [bulletStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:textFontName size:28] range:NSMakeRange(0, [bulletStr length])];
    NSString *patternBold1 = [NSString stringWithFormat:@"(د)"];
    
    NSRegularExpression *expressionBold1 = [NSRegularExpression regularExpressionWithPattern:patternBold1 options:0 error:nil];
    
    //  enumerate matches
    NSRange rangeBold1 = NSMakeRange(0,[lblText length]);
    NSMutableAttributedString *txtViewDesc = [[NSMutableAttributedString alloc] initWithString:lblText];
    
    NSString *str2 = lblText;
    
    [expressionBold1 enumerateMatchesInString:str2 options:0 range:rangeBold1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange bulletTextRange = [result rangeAtIndex:1];
        
        [txtViewDesc replaceCharactersInRange:bulletTextRange withAttributedString:bulletStr];
    }];
    
    return txtViewDesc;
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

#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //Ad Admob
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70]];
}

#pragma mark - Memory Management
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:@"PopViewToRootViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end