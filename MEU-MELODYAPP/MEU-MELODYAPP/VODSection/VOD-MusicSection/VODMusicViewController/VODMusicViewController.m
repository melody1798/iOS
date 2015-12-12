//
//  VODMusicViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMusicViewController.h"
#import "constant.h"
#import "VODFeaturedCollectionCell.h"
#import "MusicSingerView.h"
#import "FeaturedMusics.h"
#import "GenresViewController.h"
#import "popoverBackgroundView.h"
#import "CustomControls.h"
#import "MusicSingersVideosViewController.h"
#import "MovieDetailViewController.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SearchVideoViewController.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "DetailGenres.h"
#import "Genres.h"
#import "GenresView.h"
#import "MoviePlayerViewController.h"
#import "VODSearchController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

@interface VODMusicViewController () <UICollectionViewDataSource, UICollectionViewDelegate, musicSingerSelectionDelegate, UIPopoverControllerDelegate, genreSelectedDelegate, UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList, genreMovieSelectedDelegate, UpdateMovieDetailOnLoginDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UISegmentedControl*     segmentedControl;
    IBOutlet UICollectionView*       collectionVw;
    MusicSingerView*                 objMusicSingerView;
    UIPopoverController*             popOverGenres;
    LoginViewController*             objLoginViewController;
    UIPopoverController*             popOverSearch;
    SearchVideoViewController*       objSearchVideoViewController;
    SettingViewController*           objSettingViewController;
    GenresView*                      objGenreView;
    MPMoviePlayerViewController*     mpMoviePlayerViewController;
    CustomControls*                  objCustomControls;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
}

@property (weak, nonatomic) IBOutlet UILabel*       lblNoVideoFoundText;
@property (strong, nonatomic) NSArray*              arrFeaturedMusicVideos;
@property (strong, nonatomic) NSArray*              arrGenreMusic;
@property (strong, nonatomic) NSString*             strGenreName_en;
@property (strong, nonatomic) NSString*             strGenreName_ar;
@property (strong, nonatomic) UISearchBar*          searchBarVOD;
@property (strong, nonatomic) NSString*             strGenreId;
@property (strong, nonatomic) NSString*             strPreviousLanguage;
@property (strong, nonatomic) NSString*             strMovieIdForLastViewed;
@property (assign, nonatomic) BOOL                  isCastingButtonHide;
@property (assign, nonatomic) BOOL                  bIsLoad;
@property (strong, nonatomic) NSString*             strMovieNameOnCastingDevice;
@property (strong, nonatomic) NSString*             strMusicVideoUrl;

- (IBAction)btnGenreAction:(id)sender;

@end

@implementation VODMusicViewController

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
    
    self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];



    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];

    [self setLocalizedText];
    [self setNavigationBarButtons];
    [self registerCollectionViewCell];
    [self setSegmentedControlAppreance];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        self.lblNoVideoFoundText.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        FeaturedMusics *objFeaturedMusics = [FeaturedMusics new];
        [objFeaturedMusics fetchFeaturedMusicVideos:self selector:@selector(featuredVideosServerResponse:)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Watchlist"];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70 delegate:self]];
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    [self setLocalizedText];
    
    if (![self.strPreviousLanguage isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey]]) {
        
        if (objMusicSingerView!=nil) {
            self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];
            [objMusicSingerView fetchMusicSingersAfterLanguageChange];
        }
    }
    
    [collectionVw reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
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

- (void)setLocalizedText
{
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"musicatoz" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    
    if (segmentedControl.selectedSegmentIndex!=2 || [self.strGenreName_en length] == 0 || [self.strGenreName_ar length] == 0) {
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            if ([self.strGenreName_en length] >= 16)
                [segmentedControl setTitle:[self.strGenreName_en substringToIndex:16] forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:self.strGenreName_en forSegmentAtIndex:2];
        }
        else{
            if ([self.strGenreName_ar length] >= 16)
                [segmentedControl setTitle:[self.strGenreName_ar substringToIndex:16] forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:self.strGenreName_ar forSegmentAtIndex:2];
        }
    }
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

#pragma mark - Navigationbar buttons actions

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
}

- (void)watchListItemAction
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginScreen];
    }
    else{
        WatchListViewController *objWatchListViewController = [[WatchListViewController alloc] initWithNibName:@"WatchListViewController" bundle:nil];
        objWatchListViewController.delegate = self;
        //Fetch and pass current view cgcontext for background display
        UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
        objWatchListViewController._imgViewBg = viewImage;
        [self.navigationController pushViewController:objWatchListViewController animated:YES];
    }
}

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

- (void)showLoginScreen
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegateUpdateMovie = self;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
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
    self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    [self setLocalizedText];
    [objGenreView reloadGenresTableViewData];
    
   // [objMusicSingerView reloadSingersTableView];
    [collectionVw reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    // [objMusicSingerView fetchMusicSingers];

    if (segmentedControl.selectedSegmentIndex == 2) {
        
        if ([self.strGenreName_en length] == 0 || [self.strGenreName_ar length] == 0) {
            [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
        }
        else
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
                
                [segmentedControl setTitle:self.strGenreName_en forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:self.strGenreName_ar forSegmentAtIndex:2];
        }
        [objGenreView fetchAllGenres:self.strGenreId genreName_en:self.strGenreName_en genreName_ar:self.strGenreName_ar genreType:@"music"];
    }
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginScreen];
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
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    [popOverSearch dismissPopoverAnimated:YES];
    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQViewController animated:YES];
}

#pragma mark - Server Response
- (void)featuredVideosServerResponse:(NSArray*)arrResponse
{
  //  arrResponse = [NSArray new];
    self.arrFeaturedMusicVideos = [[NSArray alloc] initWithArray:arrResponse];
    
    self.lblNoVideoFoundText.hidden = YES;
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
    
    [collectionVw reloadData];
}

#pragma mark - IBAction Methods
- (IBAction)segmentedControlIndexChanged
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70 delegate:self]];
    
    self.lblNoVideoFoundText.hidden = YES;

    [objGenreView removeFromSuperview];
    objGenreView = nil;
    
    self.strGenreName_en = @"";
    self.strGenreName_ar = @"";
    
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];

    [objMusicSingerView removeFromSuperview];
    if (segmentedControl.selectedSegmentIndex!= 2) {
        
        if (objMusicSingerView != nil) {
            [objMusicSingerView removeFromSuperview];
            objMusicSingerView = nil;
        }
    }

    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            if (![kCommonFunction checkNetworkConnectivity])
            {
                if ([self.arrFeaturedMusicVideos count]==0)
                    self.lblNoVideoFoundText.hidden = NO;

                [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
            }
            else
            {
                FeaturedMusics *objFeaturedMusics = [FeaturedMusics new];
                [objFeaturedMusics fetchFeaturedMusicVideos:self selector:@selector(featuredVideosServerResponse:)];
            }
            [collectionVw reloadData];
            break;
        }
        case 1:
        {
            
            if (objMusicSingerView == nil) {
                objMusicSingerView = [MusicSingerView customView];
                
                if IS_IOS7_OR_LATER
                    [objMusicSingerView setFrame:CGRectMake(0, 140, 768, 770)];
                else
                    [objMusicSingerView setFrame:CGRectMake(0, 55, 768, 780)];
                [self.view addSubview:objMusicSingerView];
                objMusicSingerView.delegate = self;
                
                //Call webservice to fetch singers
                [objMusicSingerView fetchMusicSingers];
            }
            break;
        }
        case 2:
        {
        }
    }
}

- (IBAction)btnGenreAction:(id)sender
{    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70 delegate:self]];
    segmentedControl.selectedSegmentIndex = 2;
    
    Genres *objGenres = [Genres new];
    [objGenres fetchGenres:self selector:@selector(fetchGenresServerResponse:) methodName:@"music"];
}

#pragma mark - Server Response

- (void)fetchGenresServerResponse:(NSArray*)arrResponse
{
    if ([arrResponse count] > 0) {
        
        //Genres
        GenresViewController *objGenresViewController = [[GenresViewController alloc] initWithNibName:@"GenresViewController" bundle:nil];
        objGenresViewController.arrGenresList = arrResponse;
        
        objGenresViewController.delegate = self;
        
        popOverGenres = [[UIPopoverController alloc] initWithContentViewController:objGenresViewController];
        popOverGenres.popoverBackgroundViewClass = [popoverBackgroundView class];
        [popOverGenres setDelegate:self];
        
        CGRect rect;
        rect.origin.x = 160;
        rect.origin.y = -75;
        rect.size.width = 220;
        rect.size.height = 87;
        
        CGRect rect1 = objGenresViewController.view.frame;
        [popOverGenres setPopoverContentSize:CGSizeMake(rect1.size.width, (arrResponse.count + 1) * 40)];
        [popOverGenres presentPopoverFromRect:rect inView:segmentedControl permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
}

- (void)musicSingerSelected:(NSString*)singerId singerName_en:(NSString*)singerName_en singerName_ar:(NSString*)singerName_ar
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        self.strMusicVideoUrl = [NSString stringWithFormat:@"%@", singerId];
        [self showLoginScreen];
    }
    else{
        [self playMusicVideo:singerId];
    }
}

- (void)playMusicVideo:(NSString*)singerId
{
    if ([singerId rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(convertBCoveUrl:) withObject:singerId afterDelay:0.1];
    }
    else if ([singerId rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSRange range = [singerId rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [singerId length])];
        NSString *youtubeVideoId = [singerId substringFromIndex:range.location+1];
        [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:singerId];
    }
    else
    {
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = singerId;
        objMoviePlayerViewController.strVideoId = @"";
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
   [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark - Genre Selected Delegate

- (void)genreIDSelected:(NSString *)genreID genreName_en:(NSString *)genreName_en genreName_ar:(NSString *)genreName_ar
{
    self.strGenreId = [NSString stringWithFormat:@"%@", genreID];
    
    [objMusicSingerView removeFromSuperview];
    [popOverGenres dismissPopoverAnimated:YES];
    
    self.strGenreName_en = [NSString stringWithFormat:@"%@", genreName_en];
    self.strGenreName_ar = [NSString stringWithFormat:@"%@", genreName_ar];
    
    [objGenreView removeFromSuperview];
    objGenreView = nil;
    objGenreView = [GenresView customView];
    
    if IS_IOS7_OR_LATER
        [objGenreView setFrame:CGRectMake(0, 140, 768, 770)];
    else
        [objGenreView setFrame:CGRectMake(0, 40, 768, 780)];
    
    [self.view addSubview:objGenreView];
    objGenreView.delegate = self;

    //Call websrevice to fetch genres detail
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        [objGenreView fetchAllGenres:genreID genreName_en:genreName_en genreName_ar:genreName_ar genreType:@"music"];
        if ([genreName_en length] >= 16)
            [segmentedControl setTitle:[genreName_en substringToIndex:16] forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:genreName_en forSegmentAtIndex:2];
    }
    else
    {
        if ([genreName_ar length] >= 16)
            [segmentedControl setTitle:[genreName_ar substringToIndex:16] forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:genreName_ar forSegmentAtIndex:2];
        
        [objGenreView fetchAllGenres:genreID genreName_en:genreName_en genreName_ar:genreName_ar genreType:@"music"];
    }
}

- (void)playGenreSelectedMovie:(NSString*)movieID
{
    [self playMovieWithUrl:movieID videoId:movieID];
}

- (void)playMovieWithUrl:(NSString*)movieUrl videoId:(NSString*)videoId
{
    self.strMovieIdForLastViewed = [NSString stringWithFormat:@"%@", videoId];
     
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        self.strMusicVideoUrl = [NSString stringWithFormat:@"%@", movieUrl];
        [self showLoginScreen];
    }
    else{
        
        if ([movieUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self performSelector:@selector(convertBCoveUrl:) withObject:movieUrl afterDelay:0.1];
        }
        else if ([movieUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSRange range = [movieUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [movieUrl length])];
            NSString *youtubeVideoId = [movieUrl substringFromIndex:range.location+1];
            [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:movieUrl];
            
            [self saveToLastViewed:self.strMovieIdForLastViewed];
        }
        else
        {
            MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
            objMoviePlayerViewController.strVideoUrl = movieUrl;
            objMoviePlayerViewController.strVideoId = videoId;
            [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
            
            [self saveToLastViewed:self.strMovieIdForLastViewed];
        }
    }
}

- (void)convertBCoveUrl:(id)object
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
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


#pragma mark - Play movie in Media player
- (void)playInMediaPlayer:(NSString*)strMP4VideoUrl
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    mpMoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
    
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
    objCustomControls.strVideoName = self.strMovieNameOnCastingDevice;
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
    
    [self saveToLastViewed:self.strMovieIdForLastViewed];
    
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

- (void)hideCastingButtonSyncWithPlayer
{
    self.isCastingButtonHide = NO;
    [objCustomControls hideCastButton];
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
    
    //    if ([moviePlayerViewController
    //         respondsToSelector:@selector(setFullscreen:animated:)])
    //    {
    [self dismissMoviePlayerViewControllerAnimated];
    mpMoviePlayerViewController = nil;
    //    }
}

#pragma mark - Last Viewed
- (void)saveToLastViewed:(NSString*)videoId
{
    if (videoId != nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], videoId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

#pragma mark -Loginviewcontroller delegate
- (void)updateMovieDetailViewAfterLogin
{
    [self playMusicVideo:self.strMusicVideoUrl];
}

#pragma mark - Register CollectionView Cell
- (void)registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"VODFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"vodfeaturecell"];
}

#pragma mark - Set Segmentedbar apperance
- (void)setSegmentedControlAppreance
{
    [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentMusicBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //Set segment control height.
    CGRect frame = segmentedControl.frame;
    [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kSegmentControlHeight)];
    
    UIFont *Boldfont = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentedControl setTitleTextAttributes:selectionAttributes
                                    forState:UIControlStateSelected];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (segmentedControl.selectedSegmentIndex == 0)
        return [self.arrFeaturedMusicVideos count];
    return [self.arrGenreMusic count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VODFeaturedCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"vodfeaturecell" forIndexPath:indexPath];
    
    if (segmentedControl.selectedSegmentIndex == 0)
        [cell setCellValuesForMusic:[self.arrFeaturedMusicVideos objectAtIndex:indexPath.row]];

    else
        [cell setCellValuesForMusicGenre:[self.arrGenreMusic objectAtIndex:indexPath.row]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        FeaturedMusic *objFeaturedMusic = (FeaturedMusic*)[self.arrFeaturedMusicVideos objectAtIndex:indexPath.row];
        
        [self playMovieWithUrl:objFeaturedMusic.musicUrl videoId:objFeaturedMusic.musicId];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objFeaturedMusic.musicTitle_en;
        }
        else
            self.strMovieNameOnCastingDevice = objFeaturedMusic.musicTitle_en;
    }
    else{
        DetailGenre *objDetailGenre = (DetailGenre*) [self.arrGenreMusic objectAtIndex:indexPath.row];
        [self playMovieWithUrl:objDetailGenre.movieUrl videoId:objDetailGenre.movieID];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_en;
        }
        else
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_ar;
    }
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

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    
    if (isSeries == NO) {
        
        [self playMovieWithUrl:videoId videoId:videoId];
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

- (void)movieDetailFromWatchListPop:(NSString*)movieId
{
    
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

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Memory Management
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end