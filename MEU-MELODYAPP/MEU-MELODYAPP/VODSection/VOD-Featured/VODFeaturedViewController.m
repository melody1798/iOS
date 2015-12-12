//
//  VODFeaturedViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODFeaturedViewController.h"
#import "Constant.h"
#import "VODFeaturedCollectionCell.h"
#import "LiveNowFeaturedViewController.h"
#import "CustomControls.h"
#import "VODFeaturedVideos.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "MovieDetailViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "CommonFunctions.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "FlickrPhoto.h"
#import <InfiniteScroll/INFNetworkImageScrollViewTile.h>
#import <InfiniteScroll/INFRandomLayout.h>
#import <InfiniteScroll/INFUniformSizeLayout.h>
#import "FAQViewController.h"
#import "EpisodeDetailViewController.h"
#import "WatchListMovies.h"
#import "MoviePlayerViewController.h"
#import "VODSearchController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomControls.h"
#import <CoreMotion/CoreMotion.h>

#define SEARCH_BAR_ANIMATION_DURATION       .2
#define INITIAL_FLICKR_SEARCH_TERM          @"nature"
#define TILE_SELECTION_ANIMATION_DURATION   .5
#define kUpdateInterval (10.0f/100.0f)


@interface VODFeaturedViewController () <UISearchBarDelegate, UIPopoverControllerDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList, UIScrollViewDelegate, UIAccelerometerDelegate, ImageConsumer, UIGestureRecognizerDelegate, UpdateMovieDetailOnLoginDelegate>
{
    LoginViewController*            objLoginViewController;
    UIPopoverController*            popOverSearch;
    SearchVideoViewController*      objSearchVideoViewController;
    SettingViewController*          objSettingViewController;
    
    float x;
    
    CGFloat ballXVelocity;
	CGFloat ballYVelocity;
    CMMotionManager *accelerometer;
    float   timerDuration;
    BOOL    isPositive;
    BOOL    isDefined;
    NSTimer *timerAnimation;
    BOOL        isDone;
    int     iContentOffsetIncrement;
    EpisodeDetailViewController*            imageViewController;
    UINavigationController*                 imageNavController;
    VODSearchController*                    objVODSearchController;
    UIImage*                                viewImage;
    int                                     previousIndex;
    CustomControls*                         objCustomControls;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
}

@property (strong, nonatomic) UIImage*              viewImage;
@property (strong, nonatomic) NSArray*              arrFeaturedVideos;
@property (strong, nonatomic) UISearchBar*          searchBarVOD;
@property (strong, nonatomic) UILabel*              lblNoVideoFoundText;
@property (strong, nonatomic)  MPMoviePlayerController* moviePlayer1;
////
@property (nonatomic, strong) INFScrollViewTile *selectedTile;
@property (nonatomic, readwrite, assign) CGRect selectedTileOriginalFrame;
@property (nonatomic, readwrite, strong) NSArray *images;
@property (nonatomic, readwrite, strong) NSArray *layouts;
@property (nonatomic, readwrite, strong) id<INFLayout> currentLayout;
@property (assign, nonatomic) BOOL              isForWatchlist;
@property (strong, nonatomic) NSString*         strVideoIdForLastViewed;
@property (assign, nonatomic) BOOL              isCastingButtonHide;
@property (assign, nonatomic) BOOL              bIsLoad;
@property (strong, nonatomic) NSString*         strMovieNameOnCastingDevice;

- (NSAttributedString*)changeSingerNameFont:(NSString*)singerName;

@end

@implementation VODFeaturedViewController

@synthesize viewImage;

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
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollDragging:) name:@"StartAccelerate" object:nil];
    
    
    isDone = YES;
    
    iContentOffsetIncrement = 3;
    previousIndex = 0;  //intialize 0 for image pickup.
    ballXVelocity = 0.0f;
    ballYVelocity = 0.0f;
    timerDuration = 0.1;
    
    self.layouts = @[[[INFUniformSizeLayout alloc] initWithTileSize:CGSizeMake(310, 174)], [INFRandomLayout layout]];
    self.currentLayout = self.layouts[0];
    [self.infiniteScrollView setScrollEnabled:self.images.count];
    
    UILabel *lbl = [[UILabel  alloc] initWithFrame:CGRectMake(10, 250, 200, 40)];
    lbl.backgroundColor = [UIColor redColor];
    [self.infiniteScrollView addSubview:lbl];
    
    self.infiniteScrollView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];
    
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.hidesBackButton = YES;
     
    [self setNavigationBarButtons];

    if (![kCommonFunction checkNetworkConnectivity])
    {
        self.lblNoVideoFoundText = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 768, 40)];
        self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:22.0];
        self.lblNoVideoFoundText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"no video found" value:@"" table:nil];
        self.lblNoVideoFoundText.textAlignment = NSTextAlignmentCenter;
        self.lblNoVideoFoundText.backgroundColor = [UIColor clearColor];
        self.lblNoVideoFoundText.textColor = [UIColor whiteColor];
        [self.view addSubview:self.lblNoVideoFoundText];
        
       // [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        VODFeaturedVideos *objVODFeaturedVideos = [VODFeaturedVideos new];
        [objVODFeaturedVideos fetchVODFeaturedVideos:self selector:@selector(fetchVODFeaturedVideoResponse:)];
    }
    //Method to enable sound play even if phone is on silent mode.
    [self enableSoundIfPhoneOnSilent];
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
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Watchlist"];
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70 delegate:self]];
//        [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70]];
    if (![kCommonFunction checkNetworkConnectivity])
    {
    }
    else
    {
        NSMutableArray *photos = [NSMutableArray array];
        for (VODFeaturedVideo *objVODFeaturedVideo in _arrFeaturedVideos) {
            
            [photos addObject:[[FlickrPhoto alloc] initWithFlickrID:objVODFeaturedVideo.movieID secret:objVODFeaturedVideo.movieThumbnail farm:objVODFeaturedVideo.movieTitle_en server:@""]];
        }
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self reloadInfiniteScrollViewWithData:photos];
                       });
    }
    
    [self fetchCurrentCountry];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [timerAnimation invalidate];
    timerAnimation = nil;
}

- (void)enableSoundIfPhoneOnSilent
{
    //Enable sound play even if phone is on silent mode.
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)btnMelodyIconAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNavigationBarButtons
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(btnMelodyIconAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(self.view.frame.size.width/2-40, 0, 80, 72)];
    [self.navigationController.navigationBar  addSubview:btn];
    
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

#pragma mark - Server Response Method

- (void)fetchVODFeaturedVideoResponse:(NSArray*)arrResponse
{
    self.lblNoVideoFoundText.hidden = YES;

    _arrFeaturedVideos = [[NSArray alloc] initWithArray:arrResponse];
    if ([_arrFeaturedVideos count] == 0) {
        self.lblNoVideoFoundText = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 768, 40)];
        self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:22.0];
        self.lblNoVideoFoundText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"no video found" value:@"" table:nil];
        self.lblNoVideoFoundText.textAlignment = NSTextAlignmentCenter;
        self.lblNoVideoFoundText.backgroundColor = [UIColor clearColor];
        self.lblNoVideoFoundText.textColor = [UIColor whiteColor];
        [self.view addSubview:self.lblNoVideoFoundText];
    }
    
    self.infiniteScrollView.hidden = NO;

    NSMutableArray *photos = [NSMutableArray array];
    for (VODFeaturedVideo *objVODFeaturedVideo in _arrFeaturedVideos) {
        
        [photos addObject:[[FlickrPhoto alloc] initWithFlickrID:objVODFeaturedVideo.movieID secret:objVODFeaturedVideo.movieThumbnail farm:objVODFeaturedVideo.movieTitle_en server:@""]];
    }
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self reloadInfiniteScrollViewWithData:photos];
                   });
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]) {
        
        if (![CommonFunctions isIphone]) {
            WatchListMovies *objWatchListMovies = [WatchListMovies new];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"] forKey:@"userId"];
            
            [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
        }
    }
}

- (void)watchListServerResponse:(NSArray*)arrResponse
{
    //Reset Watchlist counter.
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.iWatchListCounter = (int)[arrResponse count];
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark - Navigationbar buttons actions
- (void)settingsBarButtonItemAction
{
    self.isForWatchlist = YES;
    
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

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginView];
}

- (void)changeLanguageMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)showLoginView
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegateUpdateMovie = self;
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
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
    }
    else{
        FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
        [self.navigationController pushViewController:objFeedbackViewController animated:YES];
    }
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

- (void)watchListItemAction
{
    self.isForWatchlist = YES;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
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
            objWatchListViewController._imgViewBg = viewImage;
            objWatchListViewController.isFromHome = YES;
            [self.navigationController pushViewController:objWatchListViewController animated:YES];
        }
    }
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

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    
    if (isSeries == NO) {
        
        if (movietype == 2) {
            [self playVideoOnPlayer:@"" videoId:@"" videoName:self.strMovieNameOnCastingDevice];
        }
        else
        {
            MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
            objMovieDetailViewController.strMovieId = videoId;
            [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
        }
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

#pragma mark - INFScrollViewDelegate

- (id<INFLayout>)layoutForInfiniteScrollView:(INFScrollView *)infiniteScrollView
{
    NSAssert(self.currentLayout != nil, @"Some layout must be selected.");
    return self.currentLayout;
}

- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView willUseInfiniteScrollViewTitle:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash
{
    if (self.images.count == 0)
        return;
    
     NSUInteger photoIndex = previousIndex;
//    if (photoIndex == previousIndex) {
//        photoIndex = rand() % [self.images count];
//    }
//    previousIndex = photoIndex;
    
    
    VODFeaturedVideo *objVODFeaturedVideo = (VODFeaturedVideo*) [_arrFeaturedVideos objectAtIndex:photoIndex];
    
    NSAttributedString *title;
    title = [[NSAttributedString alloc] initWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objVODFeaturedVideo.movieTitle_en:objVODFeaturedVideo.movieTitle_ar];
    
    if ([objVODFeaturedVideo.videoType isEqualToString:@"3"]) {
        if (objVODFeaturedVideo.numberOfSeasons > 1)
        {
            NSString *episodeTitle = [NSString stringWithFormat:@"%@ - %@ %@ - %@ %@", [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objVODFeaturedVideo.seriesName_en:objVODFeaturedVideo.seriesName_ar, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objVODFeaturedVideo.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVODFeaturedVideo.episodeNum];
            
            title = [[NSAttributedString alloc] initWithString:episodeTitle];
        }
        else
        {
            NSString *episodeTitle = [NSString stringWithFormat:@"%@ - %@ %@", [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objVODFeaturedVideo.seriesName_en:objVODFeaturedVideo.seriesName_ar, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVODFeaturedVideo.episodeNum];
            title = [[NSAttributedString alloc] initWithString:episodeTitle];
        }
    }
    if ([objVODFeaturedVideo.videoType isEqualToString:@"2"]) {
        
        NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];

        NSAttributedString *strDesc = [[NSAttributedString alloc] initWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objVODFeaturedVideo.movieTitle_en:objVODFeaturedVideo.movieTitle_ar];
        
        [lbltextMu appendAttributedString:strDesc];
        [lbltextMu appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
        [lbltextMu appendAttributedString:[self changeSingerNameFont:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objVODFeaturedVideo.artistName_en:objVODFeaturedVideo.artistName_ar]];
        
        title = [[NSAttributedString alloc] initWithAttributedString:lbltextMu];
        
    }
    
    [(INFNetworkImageScrollViewTile *)tile fillTileWithNetworkImage:[self.images objectAtIndex:photoIndex] tag:[objVODFeaturedVideo.movieID integerValue] title:title];

    
    [(INFNetworkImageScrollViewTile *)tile setTag:[objVODFeaturedVideo.movieID intValue]];
    [(INFNetworkImageScrollViewTile *)tile setSenderTag:[objVODFeaturedVideo.movieID intValue]];
    
    [(INFNetworkImageScrollViewTile *)tile setDelegate:self];
    
    //Select random number for image pick up.
    if (previousIndex == self.images.count-1)
        previousIndex = 0;
    else
        previousIndex++;
}

- (NSAttributedString*)changeSingerNameFont:(NSString*)singerName
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:16.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:singerName attributes:attrsDictionary];
    
    return attrString;
}

- (void)selectedImage:(int)sender
{
    [accelerometer stopAccelerometerUpdates];

    if (![kCommonFunction checkNetworkConnectivity])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] delegate:nil cancelButtonTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"ok" value:@"" table:nil] otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        for (VODFeaturedVideo *objVODFeaturedVideo in self.arrFeaturedVideos) {
            
            NSString *movieId = [NSString stringWithFormat:@"%ld", (long) sender];
            
            if (([movieId isEqualToString:objVODFeaturedVideo.movieID]) && ([objVODFeaturedVideo.videoType isEqualToString:@"3"])) {
                
                EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
                objEpisodeDetailViewController.episodeId = [NSString stringWithFormat:@"%ld", (long) sender];
                objEpisodeDetailViewController.isFromVOD = NO;
                objEpisodeDetailViewController.seriesIdFromVOD = objVODFeaturedVideo.seriesId;
                
                UIImage *viewImage1 = [CommonFunctions fetchCGContext:self.view];
                objEpisodeDetailViewController._imgViewBg = viewImage1;
                
                [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
                
                return;
            }
            else if (([movieId isEqualToString:objVODFeaturedVideo.movieID]) && ([objVODFeaturedVideo.videoType isEqualToString:@"2"])) {
                [self playVideoOnPlayer:objVODFeaturedVideo.movieUrl videoId:objVODFeaturedVideo.movieID videoName:objVODFeaturedVideo.movieTitle_en];
                return;
            }
        }
        
        [self showMovieOverlay:[NSString stringWithFormat:@"%ld", (long) sender]];
    }
}

- (INFScrollViewTile *)infiniteScrollViewTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView
{
    return [[INFNetworkImageScrollViewTile alloc] init];
}

- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView isDoneUsingTile:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash
{
    NSAttributedString *atr = [[NSAttributedString alloc] initWithString:@""];
    [(INFNetworkImageScrollViewTile *)tile fillTileWithNetworkImage:nil tag:0 title:atr];
}

- (void)didTapInfiniteScrollViewTile:(INFScrollViewTile *)tile
{
    [accelerometer stopAccelerometerUpdates];
    if (![kCommonFunction checkNetworkConnectivity])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] delegate:nil cancelButtonTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"ok" value:@"" table:nil] otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        for (int subVwCount = 0; subVwCount < [tile.subviews count]; subVwCount++) {
            
            if ([[tile.subviews objectAtIndex:subVwCount] isKindOfClass:[UIImageView class]]) {
                
                UIImageView *img = (UIImageView*) [tile.subviews objectAtIndex:subVwCount];
                UITapGestureRecognizer *recognizer = [img.gestureRecognizers objectAtIndex:0];
                
                for (VODFeaturedVideo *objVODFeaturedVideo in self.arrFeaturedVideos) {
                    
                    NSString *movieId = [NSString stringWithFormat:@"%ld", (long)recognizer.view.tag];
                    
                    if (([movieId isEqualToString:objVODFeaturedVideo.movieID]) && ([objVODFeaturedVideo.videoType isEqualToString:@"3"])) {
                        
                        EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
                        objEpisodeDetailViewController.episodeId = [NSString stringWithFormat:@"%ld", (long)recognizer.view.tag];
                        objEpisodeDetailViewController.isFromVOD = NO;
                        objEpisodeDetailViewController.seriesIdFromVOD = objVODFeaturedVideo.seriesId;
                        UIImage *viewImage1 = [CommonFunctions fetchCGContext:self.view];
                        objEpisodeDetailViewController._imgViewBg = viewImage1;
                        
                        imageNavController = [[UINavigationController alloc] initWithRootViewController:objEpisodeDetailViewController];
                        
                        [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
                        
                        return;
                    }
                    else if (([objVODFeaturedVideo.movieID isEqualToString:movieId]) && ([objVODFeaturedVideo.videoType isEqualToString:@"2"])) {
                        [self playVideoOnPlayer:objVODFeaturedVideo.movieUrl videoId:objVODFeaturedVideo.movieID videoName:objVODFeaturedVideo.movieTitle_en];
                        return;
                    }
                    else if (([objVODFeaturedVideo.movieID isEqualToString:movieId]) && ([objVODFeaturedVideo.videoType isEqualToString:@"1"])) {
                        
                        [self showMovieOverlay:[NSString stringWithFormat:@"%ld", (long)recognizer.view.tag]];
                        return;
                    }
                    else
                    {
                        
                    }
                }
            }
        }
    }
}

- (void)showMovieOverlay:(NSString*)movieId
{
    EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
    objEpisodeDetailViewController.episodeId = movieId;
    UIImage *viewImage1 = [CommonFunctions fetchCGContext:self.view];
    objEpisodeDetailViewController._imgViewBg = viewImage1;
    objEpisodeDetailViewController.isFromVOD = YES;
    [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
}

- (void)playVideoOnPlayer:(NSString*)videoUrl videoId:(NSString*)videoId videoName:(NSString*)videoName
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        self.strMovieNameOnCastingDevice = videoName;
    }
    else
        self.strMovieNameOnCastingDevice = videoName;
    
    self.strVideoIdForLastViewed = [NSString stringWithFormat:@"%@", videoId];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
    }
    else{
        
        //For brightcove video
        if ([videoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self performSelector:@selector(convertBCoveUrl:) withObject:videoUrl afterDelay:0.0];
        }
        else if ([videoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSRange range = [videoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [videoUrl length])];
            NSString *youtubeVideoId = [videoUrl substringFromIndex:range.location+1];
            [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:videoUrl];
            
            [self saveToLastViewed:self.strVideoIdForLastViewed];
        }
        else
        {
            MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
            objMoviePlayerViewController.strVideoUrl = videoUrl;
            objMoviePlayerViewController.strVideoId = videoId;
            [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
        }
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
    //hide cast button intially (unhide after loading youtube player)
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
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];
    
    self.bIsLoad = YES;
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.videoStartTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
    
    if ([objCustomControls castingDevicesCount]>0) {
        [objCustomControls unHideCastButton];
    }
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
    objCustomControls.strVideoName = self.strMovieNameOnCastingDevice;
    objCustomControls.totalVideoDuration = youtubeMoviePlayer.moviePlayer.duration;
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerViewController *moviePlayerViewController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerViewController];
    
    if ([moviePlayerViewController
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [self dismissMoviePlayerViewControllerAnimated];
        moviePlayerViewController = nil;
    }
}

- (void)convertBCoveUrl:(id)object
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
}

#pragma mark -Loginviewcontroller delegate
- (void)updateMovieDetailViewAfterLogin
{
    if (self.isForWatchlist == NO) {
        
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = @"";
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

- (void)saveToLastViewed:(NSString*)movieId
{
    if (movieId != nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

- (void)imageSelected:(int)tag
{
    
}

- (void)dismissSelectedTile
{
}

- (void)didCancelTileSelection:(UITapGestureRecognizer *)tapRecognizer
{
}


#pragma mark - Infinite scroll methods

- (void) scrollDragging: (NSNotification *)notif
{
    if ([[notif object] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [timerAnimation invalidate];
        timerAnimation = nil;
    }
    
    else
    {
        timerAnimation = [NSTimer scheduledTimerWithTimeInterval:timerDuration target:self selector:@selector(animateScrollview) userInfo:nil repeats:YES];
    }
}

#pragma mark - Data Reload

- (void)reloadInfiniteScrollViewWithData:(NSArray *)images
{
    self.images = images;
    [self.infiniteScrollView setScrollEnabled:images.count];
    [self.infiniteScrollView reloadData:NO];
    
    timerAnimation = [NSTimer scheduledTimerWithTimeInterval:timerDuration target:self selector:@selector(animateScrollview) userInfo:nil repeats:YES];
    
    accelerometer = [[CMMotionManager alloc] init];
    [self startMyMotionDetect];
    viewImage = [CommonFunctions fetchCGContext:self.view];
}


- (void)startMyMotionDetect
{
    [accelerometer
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if (data.acceleration.x > 0.25) {
                                
                                isPositive = YES;
                                iContentOffsetIncrement = iContentOffsetIncrement + 2;
                                if (iContentOffsetIncrement >= 15) {
                                    iContentOffsetIncrement = 15;
                                }
                            }
                            else if (data.acceleration.x < -0.25) {  // tilting the device downwards
                                
                                isPositive = NO;
                                iContentOffsetIncrement = iContentOffsetIncrement + 2;
                                if (iContentOffsetIncrement >= 15) {
                                    iContentOffsetIncrement = 15;
                                }
                            }
                            else if(data.acceleration.y < -0.25) {  // tilting the device to the right
                                
                                iContentOffsetIncrement = 3;
                            }
                            
                            else if (data.acceleration.y > 0.25) {  // tilting the device to the left
                                
                                iContentOffsetIncrement = 3;
                            }
                            else
                            {
                                iContentOffsetIncrement = 3;
                            }
                        }
                        );
     }
     ];
}

- (void)animateScrollview
{
    if (isPositive) {
        [self.infiniteScrollView setContentOffset:CGPointMake(self.infiniteScrollView.contentOffset.x-12*iContentOffsetIncrement, self.infiniteScrollView.contentOffset.y-12) animated:YES];
    }
    else{
        [self.infiniteScrollView setContentOffset:CGPointMake(self.infiniteScrollView.contentOffset.x+12*iContentOffsetIncrement, self.infiniteScrollView.contentOffset.y+12) animated:YES];
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    static NSDate *lastDrawTime;
    
    if(lastDrawTime != nil){
        NSTimeInterval secondsSinceLastDraw = -([lastDrawTime timeIntervalSinceNow]);
        ballXVelocity = ballXVelocity - acceleration.x * secondsSinceLastDraw;
        
        if (acceleration.x > 0.25) {
            
            isPositive = YES;
            iContentOffsetIncrement = iContentOffsetIncrement + 2;
            if (iContentOffsetIncrement >= 15) {
                iContentOffsetIncrement = 15;
            }
        }
        else if (acceleration.x < -0.25) {  // tilting the device downwards
            
            isPositive = NO;
            iContentOffsetIncrement = iContentOffsetIncrement + 2;
            if (iContentOffsetIncrement >= 15) {
                iContentOffsetIncrement = 15;
            }
        }
        else if(acceleration.y < -0.25) {  // tilting the device to the right
            
            iContentOffsetIncrement = 3;
        }
        
        else if (acceleration.y > 0.25) {  // tilting the device to the left
            
            iContentOffsetIncrement = 3;
        }
        else
        {
            iContentOffsetIncrement = 3;
            //  isPositive = YES;
        }
    }
    lastDrawTime = [[NSDate alloc] init];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    
    if([[touch valueForKey:@"view"] isKindOfClass:[UIView class]])
    {        //for further differences can user viewSelected.tag
    }
}

- (void)movieDetailFromWatchListPop:(NSString*)movieId
{
    
}

#pragma mark - Play movie in Media player
- (void)playInMediaPlayer:(NSString*)strMP4VideoUrl
{
    mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
    mpMoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
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
    objCustomControls.strVideoName = self.strMovieNameOnCastingDevice;
    objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
    
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:mpMoviePlayerViewController.view moviePlayerViewController:mpMoviePlayerViewController]];
    [self presentMoviePlayerViewControllerAnimated:mpMoviePlayerViewController];
    
    [self saveToLastViewed:self.strVideoIdForLastViewed];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mpMoviePlayerViewController
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - MPMoviePlayerViewController Delegate

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];
    
    self.bIsLoad = YES;
    if ([objCustomControls castingDevicesCount]>0) {
        self.isCastingButtonHide = !self.isCastingButtonHide;
        [objCustomControls unHideCastButton];
    }
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
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

- (void)willEnterFullscreen:(NSNotification*)notification {
}

- (void)enteredFullscreen:(NSNotification*)notification {
}

- (void)willExitFullscreen:(NSNotification*)notification {
}

- (void)exitedFullscreen:(NSNotification*)notification {
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
    
    //    if ([moviePlayerViewController
    //         respondsToSelector:@selector(setFullscreen:animated:)])
    //    {
    [self dismissMoviePlayerViewControllerAnimated];
    mpMoviePlayerViewController = nil;
    //    }
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
    [banner removeFromSuperview];
    
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70]];
}

#pragma mark - Memory Management

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [accelerometer stopAccelerometerUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end