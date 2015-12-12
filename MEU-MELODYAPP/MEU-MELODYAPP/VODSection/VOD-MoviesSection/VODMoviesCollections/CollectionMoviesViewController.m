//
//  CollectionMoviesViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CollectionMoviesViewController.h"
#import "VODMoviesCollections.h"
#import "VODFeaturedCollectionCell.h"
#import "MoviesInCollection.h"
#import "CustomControls.h"
#import "constant.h"
#import "MovieDetailViewController.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "EpisodesCollectionCell.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "MoviePlayerViewController.h"
#import "EpisodeDetailViewController.h"
#import "VODSearchController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

@interface CollectionMoviesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, ChannelProgramPlay,SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList, UIPopoverControllerDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UICollectionView*      collectionVw;
    MoviesInCollection*             objMoviesInCollection;
    LoginViewController*            objLoginViewController;
    UIPopoverController*            popOverSearch;
    SearchVideoViewController*      objSearchVideoViewController;
    SettingViewController*          objSettingViewController;
    MPMoviePlayerViewController*    mpMoviePlayerViewController;
    CustomControls*                 objCustomControls;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
}

@property (weak, nonatomic) IBOutlet UIButton*      btnCollectionName;
@property (weak, nonatomic) IBOutlet UILabel*       lblNoVideoFoundText;
@property (strong, nonatomic) UISearchBar*          searchBarVOD;
@property (strong, nonatomic) NSString*             strVideoIdForLastViewed;
@property (assign, nonatomic) BOOL                  isCastingButtonHide;
@property (assign, nonatomic) BOOL                  bIsLoad;
@property (strong, nonatomic) NSString*             strMovieNameOnCastingDevice;

- (IBAction)btnCollectionNameAction:(id)sender;

@end

@implementation CollectionMoviesViewController

@synthesize objMoviesCollection;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewToRootViewController) name:@"PopViewToRootViewController" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];

    [self setNavigationBarButtons];
    [self registerCollectionViewCell];
    [self setLocalizedText];
    
    [self.btnCollectionName.titleLabel setFont:[UIFont fontWithName:kProximaNova_Regular size:36.0]];
    self.btnCollectionName.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (objMoviesInCollection == nil) {
        
        if (![kCommonFunction checkNetworkConnectivity])
        {
            self.lblNoVideoFoundText.hidden = NO;
            [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
        }
        else
        {
            objMoviesInCollection = [MoviesInCollection new];
            NSDictionary *dictParameter = [NSDictionary dictionaryWithObject:objMoviesCollection.collectionId forKey:@"collectionId"];
            [objMoviesInCollection fetchCollectionMovies:self selector:@selector(fetchMoviesInCollectionServerResponse:) parameters:dictParameter];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [collectionVw reloadData];
    [self setLocalizedText];
    
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];

    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)popViewToRootViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)setLocalizedText
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        [self.btnCollectionName setTitle:objMoviesCollection.collectionName_en forState:UIControlStateNormal];
    else
        [self.btnCollectionName setTitle:objMoviesCollection.collectionName_ar forState:UIControlStateNormal];

    self.lblNoVideoFoundText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)setNavigationBarButtons
{
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

#pragma mark - UINavigationBar Button Action

- (IBAction)btnCollectionNameAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
}

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)watchListItemAction
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
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
   /* if (self.searchBarVOD == nil) {
        self.searchBarVOD = [[UISearchBar alloc] initWithFrame:CGRectMake(510, 15, 230, 42)];
        self.searchBarVOD.delegate = self;
        self.searchBarVOD.tintColor = [UIColor clearColor];
        self.searchBarVOD.tintColor = [UIColor darkGrayColor];
        [self.navigationController.navigationBar addSubview:self.searchBarVOD];
        [self.searchBarVOD becomeFirstResponder];
        
        if(![CommonFunctions isIphone])
            [self showSearchPopOver];
    } */
}

#pragma mark - Settings Delegate

- (void)userSucessfullyLogout
{
    [popOverSearch dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
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

    [collectionVw reloadData];
    [self setLocalizedText];
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginView];
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
- (void)fetchMoviesInCollectionServerResponse:(NSArray*)arrResponse
{
    self.lblNoVideoFoundText.hidden = YES;
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
    [collectionVw reloadData];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    
}

#pragma mark - Register UICollectionView Cell

- (void)registerCollectionViewCell
{
    //Register for all series episodes
    [collectionVw registerNib:[UINib nibWithNibName:@"EpisodeCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"episodes"];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [objMoviesInCollection.arrCollectionMovies count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EpisodesCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"episodes" forIndexPath:indexPath];
    
    [cell setCellValuesForCollectionMovies:[objMoviesInCollection.arrCollectionMovies objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MovieInCollection *objMovieInCollection = (MovieInCollection*)[objMoviesInCollection.arrCollectionMovies objectAtIndex:indexPath.row];
    if (objMovieInCollection.isSeries) {
        SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
        objSeriesEpisodesViewController.strSeriesId = objMovieInCollection.movieID;
        objSeriesEpisodesViewController.seriesUrl = @"";
        
        objSeriesEpisodesViewController.seriesName_en = objMovieInCollection.movieName_en;
        objSeriesEpisodesViewController.seriesName_ar = objMovieInCollection.movieName_ar;
        objSeriesEpisodesViewController.seriesUrl = objMovieInCollection.thumbUrl;
        
        [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
    }
    else
    {
        if (objMovieInCollection.movieType == 2) {
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
                self.strMovieNameOnCastingDevice = objMovieInCollection.movieName_en;
            }
            else
                self.strMovieNameOnCastingDevice = objMovieInCollection.movieName_ar;
            
            self.strVideoIdForLastViewed = [NSString stringWithFormat:@"%@", objMovieInCollection.movieID];
            //For brightcove video
            if ([objMovieInCollection.movieUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self performSelector:@selector(convertBCoveUrl:) withObject:objMovieInCollection.movieUrl afterDelay:0.1];
            }
            else if ([objMovieInCollection.movieUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSRange range = [objMovieInCollection.movieUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [objMovieInCollection.movieUrl length])];
                NSString *youtubeVideoId = [objMovieInCollection.movieUrl substringFromIndex:range.location+1];
                [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:objMovieInCollection.movieUrl];
                [self saveToLastViewed];
            }
            else
            {
                MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
                objMoviePlayerViewController.strVideoUrl = objMovieInCollection.movieUrl;
                objMoviePlayerViewController.strVideoId = objMovieInCollection.movieID;
                [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
            }
        }
        else
        {
            EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
            objEpisodeDetailViewController.episodeId = objMovieInCollection.movieID;
            UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
            objEpisodeDetailViewController._imgViewBg = viewImage;
            objEpisodeDetailViewController.isFromVODMovies = YES;
            [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
        }
    }
}

- (void)saveToLastViewed
{
    if (self.strVideoIdForLastViewed != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strVideoIdForLastViewed, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

- (void)convertBCoveUrl:(id)object
{
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
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

- (void)playVideoOnPlayer:(NSString*)videoUrl
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
    }
    else{
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = videoUrl;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    
    if (isSeries == NO) {
        
        if (movietype == 2) {
            
            [self playVideoOnPlayer:@""];
        }
        else{
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

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController
{
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
    
    return YES;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end