//
//  CollectionsViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 21/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CollectionsViewController.h"
#import "MoviesCollections.h"
#import "MoviesCollection.h"
#import "MoviesInCollection.h"
#import "MovieInCollection.h"
#import "FeaturedTableViewCustomCell.h"
#import "CollectionsDetailCustomCell.h"
#import "UIImageView+WebCache.h"
#import "MoviesDetailViewController.h"
#import "CustomControls.h"
#import "VODCategoryViewController.h"
#import "CommonFunctions.h"
#import "SettingViewController.h"
#import "SeriesSeasonsEpisodesViewController.h"
#import "LoginViewController.h"
#import "MoviePlayerViewController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

@interface CollectionsViewController () <UIGestureRecognizerDelegate>
{
    BOOL                            loginCheck;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
    CustomControls*                         objCustomControls;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
}

@property (nonatomic, strong) NSString *collNameEng, *collNameAr;
@property (nonatomic, strong) NSString *strMovieID, *strMovieUrl;
@property (assign, nonatomic) BOOL                      isCastingButtonHide;
@property (assign, nonatomic) BOOL                      bIsLoad;
@property (strong, nonatomic) NSString*                 strMovieNameOnCastingDevice;

@end

@implementation CollectionsViewController

@synthesize collNameAr, collNameEng;

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
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];

    [self initUI];
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingsBarButtonItemAction)];

    [self setupUI];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    if (loginCheck == 1 && [CommonFunctions userLoggedIn])
    {
        loginCheck = 0;
        [self redirectToPlayer:self.strMovieUrl videoId:self.strMovieID];
    }
}

- (void)setupUI
{
    if (iPhone4WithIOS7) {
        CGRect collVwFrame = collVw.frame;
        collVwFrame.size.height = collVw.frame.size.height-80;
        collVw.frame = collVwFrame;
    }
}

#pragma mark - Navigation Bar back button clicked


-(void) backBarButtonItemAction
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    VODCategoryViewController *objVODCategoryViewController = [[VODCategoryViewController alloc] init];
    if(collectionDetailVisible)
    {
        [lblNoVideoFound setHidden:YES];
        [tblCollections setHidden:NO];
        collectionDetailVisible = NO;
        [lblHeader setTextColor:[UIColor whiteColor]];
        [lblHeader setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"collectionSmall" value:@"" table:nil]];
    }
    else
        [CommonFunctions pushViewController:self.navigationController ViewController:objVODCategoryViewController];
}

-(void) settingsBarButtonItemAction
{
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Series"];
    
    [lblHeader setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"collectionSmall" value:@"" table:nil]];
    [lblNoVideoFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];

    if (![kCommonFunction checkNetworkConnectivity])
    {
        [lblNoVideoFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoVideoFound];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        MoviesCollections *objMoviesCollections = [[MoviesCollections alloc] init];
        [objMoviesCollections fetchVODCollections:self selector:@selector(responseForMoviesCollection:)];
    }
    if (collectionDetailVisible)
    {
        lblHeader.text = [CommonFunctions isEnglish]?self.collNameEng:self.collNameAr;
        [collVw reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self removeMelodyButton];
}

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
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

#pragma Response from web service
-(void) responseForMoviesCollection:(NSMutableArray *)arrMoviesCollectionsLocal
{
    arrMoviesCollections = [arrMoviesCollectionsLocal mutableCopy];
    if([arrMoviesCollections count] == 0)
    {
        [self.view bringSubviewToFront:lblNoVideoFound];
        [lblNoVideoFound setHidden:NO];
    }
    [tblCollections reloadData];
}

-(void)responseForDetailMovieCollection:(NSMutableArray *) arrMoviesInCollectionLocal
{
    arrMoviesInCollection = [arrMoviesInCollectionLocal mutableCopy];
    
    if([arrMoviesInCollection count] == 0)
    {
        [self.view bringSubviewToFront:lblNoVideoFound];
        [lblNoVideoFound setHidden:NO];
    }
    [tblCollections setHidden:YES];
    collectionDetailVisible = YES;
    [collVw reloadData];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    
}

#pragma mark - init UI
-(void) initUI
{
    [self setFont];
    arrMoviesCollections = [[NSMutableArray alloc] init];
    arrMoviesInCollection = [[NSMutableArray alloc] init];
    [self setFont];
    [collVw registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:Nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReUse"];
    
    
    if(iPhone4WithIOS7)
    {
        CGRect rect = tblCollections.frame;
        rect.size.height -=90;
        [tblCollections setFrame:rect];
    }
    
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
}

#pragma  mark - Set fonts
-(void) setFont
{
    [lblNoVideoFound setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [lblHeader setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrMoviesCollections count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    FeaturedTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell== nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
    [cell setBackgroundColor:[UIColor clearColor]];
    MoviesCollection *objMoviesCollection = [arrMoviesCollections objectAtIndex:indexPath.row];;
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objMoviesCollection.collectionThumb] placeholderImage:[UIImage imageNamed:@""]];
    CGRect rect = cell.frame;
    rect.size.width = CGRectGetWidth(tableView.frame);
    cell.frame = rect;
    
    cell.imgMovie.frame = CGRectMake(CGRectGetMinX(cell.imgMovie.frame), CGRectGetMinY(cell.imgMovie.frame), CGRectGetWidth(cell.frame), CGRectGetHeight(cell.imgMovie.frame));
    
    cell.lblMovieName.text =  [CommonFunctions isEnglish]?objMoviesCollection.collectionName_en:objMoviesCollection.collectionName_ar;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.lblMovieName sizeToFit];
    
    rect = cell.lblMovieName.frame;
    CGRect rect1 = cell.lblSeperator.frame;
    [cell.lblSeperator setFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect1.origin.y, rect1.size.width, rect1.size.height)];
    rect1 = cell.lblSeperator.frame;
    
    rect = cell.lblEpisodeName.frame;
    rect.origin.x = rect1.origin.x + rect1.size.width + 2;
    [cell.lblEpisodeName setFrame:rect];
    [cell.lblEpisodeName sizeToFit];
    
    if([cell.lblEpisodeName.text isEqualToString:@""])
    {
        [cell.lblSeperator setHidden:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    MoviesCollection *objMovieCollection =[arrMoviesCollections objectAtIndex:indexPath.row];
    NSDictionary *dictParameter = [NSDictionary dictionaryWithObject:objMovieCollection.collectionId forKey:@"collectionId"];
    lblHeader.text = [CommonFunctions isEnglish]?objMovieCollection.collectionName_en:objMovieCollection.collectionName_ar;
    
    self.collNameEng = objMovieCollection.collectionName_en;
    self.collNameAr = objMovieCollection.collectionName_ar;
    
    MoviesInCollection *objMoviesInCollection = [[MoviesInCollection alloc] init];
    [lblHeader setTextColor:[UIColor colorWithRed:223.0/255.0 green:160.0/255.0 blue:42.0/255.0 alpha:1.0]];
    [objMoviesInCollection fetchCollectionMovies:self selector:@selector(responseForDetailMovieCollection:) parameters:dictParameter];
}


#pragma mark - Collection View delagate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrMoviesInCollection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"CollectionsDetailCustomCellReUse";
    CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
    
    MovieInCollection *objMovieCollection = [arrMoviesInCollection objectAtIndex:indexPath.row];
    [cell setBackgroundColor:color_Background];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objMovieCollection.thumbUrl] placeholderImage:[UIImage imageNamed:@""]];
    cell.lblName.text = [CommonFunctions isEnglish]?objMovieCollection.movieName_en:objMovieCollection.movieName_ar;
    
    if (objMovieCollection.movieType == 2) {
        
        cell.lblEpisodeTitle.hidden = NO;
        [cell.lblEpisodeTitle setFrame:CGRectMake(cell.lblEpisodeTitle.frame.origin.x, cell.lblEpisodeTitle.frame.origin.y+15, cell.lblName.frame.size.width,  cell.lblEpisodeTitle.frame.size.height)];
        cell.lblEpisodeTitle.hidden = NO;
        cell.lblEpisodeTitle.textColor = [UIColor whiteColor];
        cell.lblEpisodeTitle.text = [CommonFunctions isEnglish]?objMovieCollection.singerName_en:objMovieCollection.singerName_ar;
    }
    
    else
    {
        cell.lblEpisodeTitle.hidden = YES;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *movieId = kEmptyString;
    NSString *movieThumbnail = kEmptyString;
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    MovieInCollection *objMovieCollection = [arrMoviesInCollection objectAtIndex:indexPath.row];
    movieId = objMovieCollection.movieID;
    movieThumbnail = objMovieCollection.thumbUrl;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
        self.strMovieNameOnCastingDevice = objMovieCollection.movieName_en;
    }
    else
        self.strMovieNameOnCastingDevice = objMovieCollection.movieName_ar;
    
    if (objMovieCollection.isSeries) {
       
        SeriesSeasonsEpisodesViewController *objSeriesSeasonsEpisodesViewController = [[SeriesSeasonsEpisodesViewController alloc] init];
        
        objSeriesSeasonsEpisodesViewController.strSeriesId = objMovieCollection.movieID;
        objSeriesSeasonsEpisodesViewController.seriesUrl = objMovieCollection.thumbUrl;
        objSeriesSeasonsEpisodesViewController.seriesName_en = objMovieCollection.movieName_en;
        objSeriesSeasonsEpisodesViewController.seriesName_ar = objMovieCollection.movieName_ar;
        [self.navigationController pushViewController:objSeriesSeasonsEpisodesViewController animated:YES];
    }
    else if (objMovieCollection.movieType == 2)
    {
        self.strMovieID = [NSString stringWithFormat:@"%@", objMovieCollection.movieID];
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            self.strMovieUrl = objMovieCollection.movieUrl;
            [self showLoginScreen];
        }
        else
            [self redirectToPlayer:objMovieCollection.movieUrl videoId:objMovieCollection.movieID];
    }
    else
        [self redirectToMovieDetailPage:movieId movieThumbnail:movieThumbnail isSeries:objMovieCollection.isSeries videoType:objMovieCollection.movieType];
}

#pragma mark - Show Login Screen

- (void)showLoginScreen
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginCheck = 1;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}


#pragma mark - redirect to movie detail page
-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail isSeries:(BOOL)isSeries videoType:(NSInteger)videoType
{
    MoviesDetailViewController *objMoviesDetailViewController = [[MoviesDetailViewController alloc] initWithNibName:@"MoviesDetailViewController~iphone" bundle:nil];
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[MoviesDetailViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    [objMoviesDetailViewController setIsSeries:isSeries];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int) collection];
    [objMoviesDetailViewController setVideoType:videoType];
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}

- (void) redirectToPlayer:(NSString *)url videoId:(NSString*)videoId
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
        
        //Save to last viewed
        // [self saveToLastViewed];
    }
    else
    {
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = url;
        objMoviePlayerViewController.strVideoId = videoId;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
    if (videoId != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], videoId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
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
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

@end