//
//  VODHomeViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODHomeViewController.h"
#import "VODHomeCustomCell.h"
#import "VODFeaturedVideo.h"
#import "VODFeaturedVideos.h"
#import "UIImageView+WebCache.h"
#import "MoviesDetailViewController.h"
#import "CommonFunctions.h"
#import "MoviePlayerViewController.h"
#import "LoginViewController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"
#import <AVFoundation/AVFoundation.h>
#import "GAIDictionaryBuilder.h"

@interface VODHomeViewController () <UIGestureRecognizerDelegate>
{
    int loginCheck;
    XCDYouTubeVideoPlayerViewController*        youtubeMoviePlayer;
    UITapGestureRecognizer*                     singleTapGestureRecognizer;
    CustomControls*                             objCustomControls;
    MPMoviePlayerViewController*                mpMoviePlayerViewController;
}

@property (nonatomic ,strong) NSString*         strMovieUrl;//music video url to play directly
@property (nonatomic ,strong) NSString*         strMovieId;//music id url to play directly
@property (assign, nonatomic) BOOL              isCastingButtonHide;
@property (assign, nonatomic) BOOL              bIsLoad;
@property (strong, nonatomic) NSString*         strMovieNameOnCastingDevice;

@end

@implementation VODHomeViewController

@synthesize strMovieUrl;

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
    
    intStateChanged = 0;
    [super viewDidLoad];
    
//    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];

    [self initUI];
    
    arrRecords = [[NSMutableArray alloc] init];

    if (IS_IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //Method to enable sound play even if phone is on silent mode.
    [self enableSoundIfPhoneOnSilent];
    
    [self loaddata];
}

- (void)enableSoundIfPhoneOnSilent
{
    //Enable sound play even if phone is on silent mode.
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
}

#pragma mark - set UI
-(void) initUI
{
    lblNoVideoFound.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    
    if(iPhone4WithIOS6)
    {
        CGRect rect = tblVideos.frame;
        rect.origin.y -= 97;
        rect.size.height += 125;
        [tblVideos setFrame:rect];
    }
    
    if(iPhone5WithIOS7)
    {
        CGRect rect = lblNoVideoFound.frame;
        rect.origin.y -= 20;
        [lblNoVideoFound setFrame:rect];
    }
    
    if(iPhone4WithIOS7)
    {
        CGRect rect = tblVideos.frame;
        rect.origin.y += 15;
        rect.size.height -= 40;
        [tblVideos setFrame:rect];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    //if (intStateChanged == 0)
    {
        [super viewWillAppear:YES];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"country"] length] == 0) {
            [self fetchCurrentCountry];
        }
        else
            [self fetchVODData];
        
        //Get real time data to google analytics
        [CommonFunctions addGoogleAnalyticsForView:@"Home"];
        [lblNoVideoFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];

        
        intStateChanged = 1;
        
    }
}

- (void)fetchVODData
{
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [lblNoVideoFound setHidden:NO];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        VODFeaturedVideos *objVODFeaturedVideos = [[VODFeaturedVideos alloc] init];
        [objVODFeaturedVideos fetchVODFeaturedVideos:self selector:@selector(reponseForFeaturedMovies:)];
    }
}

- (void)fetchCurrentCountry
{
    NSMutableURLRequest *requestHTTP = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://freegeoip.net/json/"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
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
            [self fetchVODData];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            [self fetchVODData];
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    UIView* view = [CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self];
    [self.view addSubview:view];
    
    if (loginCheck == 1 && [CommonFunctions userLoggedIn])
    {
        loginCheck = 0;
        [self redirectToPlayer:self.strMovieUrl movieId:self.strMovieId];
    }
}

#pragma mark - Response from web service
-(void)reponseForFeaturedMovies:(NSMutableArray *) arrResponse
{
    arrRecords = [arrResponse mutableCopy];
    if([arrRecords count] > 0)
    {
        [lblNoVideoFound setHidden:YES];
        [tblVideos setHidden:NO];
    }
    else
    {
        [lblNoVideoFound setHidden:NO];
        [tblVideos setHidden:YES];
    }

    [tblVideos reloadData];
}

#pragma mark - Show Login Screen

- (void)showLoginScreen
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginCheck = 1;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

#pragma mark - UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [arrRecords count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        return 200;
    }
    return 190;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    VODHomeCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell== nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VODHomeCustomCell" owner:self options:nil] firstObject];
    [cell setBackgroundColor:[UIColor clearColor]];
    VODFeaturedVideo *objVODFeaturedVideo = [arrRecords objectAtIndex:indexPath.row];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objVODFeaturedVideo.movieThumbnail] placeholderImage:[UIImage imageNamed:@""]];
    cell.lblMovieName.text =  objVODFeaturedVideo.movieTitle_en;
    
    if ([objVODFeaturedVideo.videoType isEqualToString:@"2"]) {
        cell.lblSeasonName.text =  [CommonFunctions isEnglish]?objVODFeaturedVideo.artistName_en:objVODFeaturedVideo.artistName_ar;
    }
    else if ([objVODFeaturedVideo.videoType isEqualToString:@"3"])
    {
        cell.lblMovieName.text = [CommonFunctions isEnglish]?objVODFeaturedVideo.seriesName_en:objVODFeaturedVideo.seriesName_ar;
        if (objVODFeaturedVideo.numberOfSeasons>1) {
            cell.lblSeasonName.text = [NSString stringWithFormat:@"%@ %@ - %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objVODFeaturedVideo.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVODFeaturedVideo.episodeNum];
        }
        else
        {
            cell.lblSeasonName.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVODFeaturedVideo.episodeNum];
        }
    }
    //[cell.lblMovieName setBackgroundColor:[UIColor lightGrayColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.lblMovieName sizeToFit];
    CGRect rect = cell.lblSeperator.frame;
    rect.origin.x = cell.lblMovieName.frame.origin.x + cell.lblMovieName.frame.size.width + 2;
    [cell.lblSeperator setFrame:rect];
    rect = cell.lblSeasonName.frame;
    rect.origin.x = cell.lblSeperator.frame.origin.x + cell.lblSeperator.frame.size.width + 2;
    
    [cell.lblSeasonName setFrame:rect];
    [cell.lblSeasonName sizeToFit];
    
    if([cell.lblSeasonName.text isEqualToString:@""])
    {
        [cell.lblSeperator setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VODFeaturedVideo *objVODFeaturedVideo = [arrRecords objectAtIndex:indexPath.row];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        self.strMovieNameOnCastingDevice = objVODFeaturedVideo.movieTitle_en;
    }
    else
        self.strMovieNameOnCastingDevice = objVODFeaturedVideo.movieTitle_ar;
    
    
    if ([objVODFeaturedVideo.videoType isEqualToString:@"2"])
    {
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            self.strMovieUrl = objVODFeaturedVideo.movieUrl;
            self.strMovieId = objVODFeaturedVideo.movieID;
            [self showLoginScreen];
        }
        else
        {
            [self redirectToPlayer:objVODFeaturedVideo.movieUrl movieId:objVODFeaturedVideo.movieID];
        }
    }
    else
        [self redirectToMovieDetailPage:objVODFeaturedVideo.movieID movieThumbnail:objVODFeaturedVideo.movieThumbnail videoType:[objVODFeaturedVideo.videoType integerValue] seriesId:objVODFeaturedVideo.seriesId seasonNumber:objVODFeaturedVideo.seasonNum];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    
}

- (void)convertBCoveUrl:(id)object
{

    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playMovie:) userInfo:strMP4VideoUrl repeats:NO];
}
-(void)playMovie:(NSTimer *)sender
{
    NSString *userInfo = sender.userInfo;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [self playInMediaPlayer:userInfo];
    
}

#pragma mark - redirect to movie detail page

- (void) redirectToPlayer: (NSString *)url movieId:(NSString*)movieId
{
    if ([url rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(convertBCoveUrl:) withObject:url afterDelay:0.1];
    }
    else if ([url rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSRange range = [url rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [url length])];
        NSString *youtubeVideoId = [url substringFromIndex:range.location+1];
        [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:url];
    }
    else
    {
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = url;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
    
    if (movieId != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail videoType:(NSInteger)videoType seriesId:(NSString*)seriesId seasonNumber:(NSString*)seasonNum
{
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[MoviesDetailViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    MoviesDetailViewController *objMoviesDetailViewController = [[MoviesDetailViewController alloc] init];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int) home];
    [objMoviesDetailViewController setVideoType:videoType];
    if (videoType == 3) {
        [objMoviesDetailViewController setMovieId:seriesId];
        objMoviesDetailViewController.isSeries = YES;
        objMoviesDetailViewController.strSeasonNum = seasonNum;
    }
    objMoviesDetailViewController.strEpisodeId = movieId;
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
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
    
    //self.isCastingButtonHide = !self.isCastingButtonHide;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
    
    mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    mpMoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
    
    // Register to receive a notification when the movie has finished playing.
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
    
    ///
    [objCustomControls hideCastButton];
    self.isCastingButtonHide = YES;
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
    
    ///
    
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:mpMoviePlayerViewController.view moviePlayerViewController:mpMoviePlayerViewController]];
    [self presentMoviePlayerViewControllerAnimated:mpMoviePlayerViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mpMoviePlayerViewController
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - MPMoviePlayerViewController Delegate

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    
    
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];

    self.bIsLoad = YES;
    self.isCastingButtonHide = !self.isCastingButtonHide;
    
    if ([objCustomControls castingDevicesCount]>0) {
        [objCustomControls unHideCastButton];
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    { //playing
        NSLog(@"Playing");
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    { //stopped
        NSLog(@"stopped");
        
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    { //paused
        NSLog(@"paused");
        
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted)
    { //interrupted
        NSLog(@"interrupted");
        
    }if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
    {
        NSLog(@"forward");
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
        NSLog(@"backward");
        
    }

    
    appDelegate.videoStartTime = mpMoviePlayerViewController.moviePlayer.currentPlaybackTime;
    
    objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
}

-(void)loaddata
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"country"] length] == 0) {
        [self fetchCurrentCountry];
    }
    else
        [self fetchVODData];
    
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Home"];
    [lblNoVideoFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];
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
    
    //[self loaddata];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//        intStateChanged = 0;
//        [self loaddata];
//
//        
//    }];
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
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

#pragma mark - Memory Management methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end