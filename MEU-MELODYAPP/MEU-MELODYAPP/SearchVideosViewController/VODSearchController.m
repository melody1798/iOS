//
//  VODSearchController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/01/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "VODSearchController.h"
#import "SearchLiveNowVideos.h"
#import "VODSearchTableViewCell.h"
#import "CustomControls.h"
#import "CommonFunctions.h"
#import "MovieDetailViewController.h"
#import "LoginViewController.h"
#import "MoviePlayerViewController.h"
#import "SeriesEpisodesViewController.h"
#import "CustomTabbar.h"
#import "EpisodeDetailViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "WatchListMovies.h"
#import "CustomControls.h"

@interface VODSearchController () <UITableViewDataSource, UITableViewDelegate, CellSelection, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView*       tblSearchResult;
    IBOutlet UILabel*           lblNoResult;
    MPMoviePlayerViewController *mpMoviePlayerViewController;
    CustomControls*             objCustomControls;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
}

@property (strong, nonatomic) NSMutableArray*       arrVODSearch;
@property (strong, nonatomic) NSString*             strVideoId;
@property (assign, nonatomic) BOOL                  isCastingButtonHide;
@property (assign, nonatomic) BOOL                  bIsLoad;
@property (strong, nonatomic) NSString*             strMovieNameOnCastingDevice;

@end

@implementation VODSearchController

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


    tblSearchResult.hidden = YES;
    tblSearchResult.delegate = self;
    tblSearchResult.dataSource = self;
    //Remove seperators according to data in tableview.
    tblSearchResult.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    lblNoResult.font = [UIFont fontWithName:kProximaNova_Bold size:20.0];
    lblNoResult.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"nil" table:nil];
    lblNoResult.hidden = YES;
    
    //Add observer to pop to VOD home screen after tapping on melody logo.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewToRootViewController) name:@"PopViewToRootViewController" object:nil];

    //Add back button.
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70 delegate:self]];
    //Set melody icon in navigation bar.
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    //Remove observer.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PopViewToRootViewController"
                                                  object:nil];
    [self removeMelodyButton]; //Remove melody logo button.
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

- (void)btnMelodyIconAction
{
    //Set VOD home tab segment.
    [self.tabBarController setSelectedViewController:[[self.tabBarController viewControllers] objectAtIndex:0]];
    [[(CustomTabBar *)self.tabBarController segmentProperty] setSelectedSegmentIndex:0];
    
    UINavigationController *indexNavController = (UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:self.tabBarController.selectedIndex];
    [indexNavController popToRootViewControllerAnimated:NO];
}

- (void)popViewToRootViewController
{
    tblSearchResult.dataSource = nil;
    tblSearchResult.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchInVOD:(NSString*)searchString
{
    //Call service to fetch search response.
    SearchLiveNowVideos *objSearchLiveNowVideos = [SearchLiveNowVideos new];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:searchString isArb:@"false"];
    else
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:searchString isArb:@"true"];
}

#pragma mark - Server Response
- (void)searchVideosServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    self.arrVODSearch = [[NSMutableArray alloc] initWithArray:arrResponse];
    [tblSearchResult reloadData];
    
    if ([arrResponse count] == 0) {
        
        lblNoResult.hidden = NO;
        tblSearchResult.hidden = YES;
        [tblSearchResult reloadData];
    }
    else
    {
        lblNoResult.hidden = YES;
        tblSearchResult.hidden = NO;
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrVODSearch count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString *cellIdentifier = @"VODSearch";
    VODSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VODSearchTableViewCell" owner:self options:Nil] firstObject];
    }
    
    [cell setVODSearchValue:[self.arrVODSearch objectAtIndex:indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    cell.delegate = self;
    cell.btnTap.tag = indexPath.row;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 30)];
    [viewHeader setBackgroundColor:[UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:41.0/255.0 alpha:1.0]];
    
    UILabel *lblHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 700, 20)];
    [lblHeaderTitle setBackgroundColor:[UIColor clearColor]];
    [lblHeaderTitle setTextColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [lblHeaderTitle setFont:[UIFont fontWithName:kProximaNova_SemiBold size:15.0]];
    
    [lblHeaderTitle setText:[NSString stringWithFormat:@"%lu Results found", (unsigned long)[self.arrVODSearch count]]];
    [viewHeader addSubview:lblHeaderTitle];
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - Handle search result action
- (void)searchCellSelected:(NSInteger)row
{
    SearchLiveNowVideo *objSearchLiveNowVideo = (SearchLiveNowVideo*)[self.arrVODSearch objectAtIndex:row];
    if (objSearchLiveNowVideo.videoType == 2) {
        
        self.strVideoId = objSearchLiveNowVideo.videoId;
        if (![self checkUserAccessToken]) {
            
            [self showLoginScreen];
        }
        else{
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
                self.strMovieNameOnCastingDevice = objSearchLiveNowVideo.videoName_en;
            }
            else
                self.strMovieNameOnCastingDevice = objSearchLiveNowVideo.videoName_ar;
            
            
            //For brightcove video
            if ([objSearchLiveNowVideo.videoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self performSelector:@selector(convertBCoveUrl:) withObject:objSearchLiveNowVideo.videoUrl afterDelay:0.1];
            }
            else if ([objSearchLiveNowVideo.videoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSRange range = [objSearchLiveNowVideo.videoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [objSearchLiveNowVideo.videoUrl length])];
                NSString *youtubeVideoId = [objSearchLiveNowVideo.videoUrl substringFromIndex:range.location+1];
                [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:objSearchLiveNowVideo.videoUrl];
                [self saveToLastViewed];
            }
            else
            {
                MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
                objMoviePlayerViewController.strVideoUrl = objSearchLiveNowVideo.videoUrl;
                [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
            }
        }
    }
    else if (objSearchLiveNowVideo.videoType == 0 && objSearchLiveNowVideo.isSeries == YES) {
        
        SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
        objSeriesEpisodesViewController.strSeriesId = objSearchLiveNowVideo.videoId;
        objSeriesEpisodesViewController.seriesUrl = @"";
        objSeriesEpisodesViewController.seriesName_en = objSearchLiveNowVideo.videoName_en;
        objSeriesEpisodesViewController.seriesName_ar = objSearchLiveNowVideo.videoName_ar;
        objSeriesEpisodesViewController.seriesUrl = objSearchLiveNowVideo.videoThumb;
        
        [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
        
        return;
    }
    else
    {
        [self showMovieOverlay:objSearchLiveNowVideo.videoId];
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
    //Remove all observers.
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
    //Add tap gesture to show /hide casting button
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
    
    [self presentMoviePlayerViewControllerAnimated:mpMoviePlayerViewController];
    
    [self saveToLastViewed];        //Save to last viewed.
    
    //To force media player to display if app enters in background.
    //otherwise media player dismiss automatically.
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
    if ([objCustomControls castingDevicesCount]>0) {
        [objCustomControls unHideCastButton];
        self.isCastingButtonHide = !self.isCastingButtonHide;
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
    
    //Set video start time
    appDelegate.videoStartTime = mpMoviePlayerViewController.moviePlayer.currentPlaybackTime;
    
    //Set total duration of video.
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

#pragma mark - Last Viewed
- (void)saveToLastViewed
{
    //Save to last viewed
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strVideoId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
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
- (void)showLoginScreen
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] init];
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchInVOD:searchBar.text];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)dealloc
{
    tblSearchResult.dataSource = nil;
    tblSearchResult.delegate = nil;
    tblSearchResult = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PopViewToRootViewController"
                                                  object:nil];
}

#pragma mark - UIGestureRecognizer delegates
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

#pragma mark - Memory management methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end