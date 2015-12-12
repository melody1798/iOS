//
//  VODSearchViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODSearchViewController.h"
#import "GenreDetailCustomCell.h"
#import "CommonFunctions.h"
#import "UIImageView+WebCache.h"
#import "SearchLiveNowVideos.h"
#import "SearchLiveNowVideo.h"
#import "MoviesDetailViewController.h"
#import "CustomControls.h"
#import "SettingViewController.h"
#import "SeriesSeasonsEpisodesViewController.h"
#import "MoviePlayerViewController.h"
#import "LoginViewController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface VODSearchViewController () <UIGestureRecognizerDelegate>
{
    int loginCheck;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
    CustomControls*                         objCustomControls;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
}

- (IBAction)btnCancelAction:(id)sender;

@property (nonatomic ,strong) NSString*  strMovieUrl;//music video url to play directly
@property (nonatomic ,strong) NSString*  strMovieID;//music video id to play directly
@property (assign, nonatomic) BOOL       isCastingButtonHide;
@property (assign, nonatomic) BOOL       bIsLoad;
@property (strong, nonatomic) NSString*  strMovieNameOnCastingDevice;

@end

@implementation VODSearchViewController

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
    [super viewDidLoad];

    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];

    [lblHeaderSearch setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil]];
    
    arrSearch = [[NSMutableArray alloc] init];
    [self setFonts];
    [self setUI];
    [txtSearch becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"VOD Search"];
    
    if ([txtSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightGrayColor];
        //Search Melody
        txtSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Search Melody" value:@"" table:nil] attributes:@{NSForegroundColorAttributeName: color}];
    } else {
    }
    
    [lblCancel setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cancel" value:@"" table:nil]];
    
    [self.navigationController.navigationBar setHidden:YES];

    lblNoVideoFound.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"nil" table:nil];

    if ([txtSearch.text length]!=0) {
        [self searchLiveNowVideos];
    }

    [tblSearch reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self.navigationController.navigationBar setHidden:NO];
    [txtSearch resignFirstResponder];
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

- (void)setUI
{
    if(iPhone5WithIOS7)
    {
//        CGRect rect = tblSearch.frame;
//        rect.origin.y -= 70;
//        rect.size.height += 120;
//        [tblSearch setFrame:rect];
    }
    if(iPhone4WithIOS7)
    {
        CGRect rect = headerView.frame;
        rect.origin.y += 10;
        [headerView setFrame:rect];
    }
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingBarButtonItemAction)];
}


#pragma mark - Settings Button Action
-(void)settingBarButtonItemAction
{
    [txt resignFirstResponder];
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}

#pragma mark - response for featured Videos
-(void)searchVideosServerResponse:(NSMutableArray *) arrResponse
{
    arrSearch = [arrResponse mutableCopy];
    
    if([arrSearch count] > 0)
    {
        [tblSearch setHidden:NO];
    lblNoVideoFound.hidden = YES;
    }
    else
        lblNoVideoFound.hidden = NO;
    [tblSearch reloadData];
}

#pragma mark - Set fonts
-(void) setFonts
{
    lblNoVideoFound.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 12.0:22.0];
    [lblHeaderSearch setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [txtSearch setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
}

#pragma mark - UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [arrSearch count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    GenreDetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell== nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GenreDetailCustomCell" owner:self options:nil] firstObject];
    
    SearchLiveNowVideo *objSearchLiveNowVideo = [arrSearch objectAtIndex:indexPath.row];
  //  cell.lblTime.text =  [objSearchLiveNowVideo.videoDuration length] > 0?[NSString stringWithFormat:@"%@ %@", objSearchLiveNowVideo.videoDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
    if (objSearchLiveNowVideo.isSeries)
    {
        cell.lblTime.text = [CommonFunctions isEnglish]?[NSString stringWithFormat:@"%@ %@", objSearchLiveNowVideo.videoDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil]]:[NSString stringWithFormat:@"%@ %@",[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objSearchLiveNowVideo.videoDuration];
    }
    
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
        {
            NSString *lbltext  = [NSString stringWithFormat:@"%@ %@",  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objSearchLiveNowVideo.videoDuration];
            NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
            cell.lblTime.attributedText = strAtt;
        }
        else
            cell.lblTime.text = [NSString stringWithFormat:@"%@ %@", objSearchLiveNowVideo.videoDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
    }
    cell.lblName.text = objSearchLiveNowVideo.videoName_en;
    /*Dummy Code*/
    cell.lblAbbr.text = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objSearchLiveNowVideo.artistName_en:objSearchLiveNowVideo.artistName_ar;
    
    cell.lblAbbr.hidden = NO;
    CGSize size = [@"-" sizeWithFont:[UIFont fontWithName:kProximaNova_Regular size:14.0]];
    /*End of Dummy Code*/
    size.height += 4;
    size.width += 4;
    
    CGRect rect = cell.imgBackground.frame;
    rect.size.width += 30;
    [cell.imgBackground setFrame:rect];
    
    cell.lblAbbr.textColor = [UIColor whiteColor];
    cell.lblAbbr.textAlignment = NSTextAlignmentLeft;
//    [[cell lblAbbr] setFrame:CGRectMake(cell.lblAbbr.frame.origin.x, cell.lblAbbr.frame.origin.y, size.width, size.height)];
//    [cell.lblAbbr setBackgroundColor:[UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0]];
    [cell.imgMovies sd_setImageWithURL:[NSURL URLWithString:objSearchLiveNowVideo.videoThumb] placeholderImage:[UIImage imageNamed:@""]];
    
//    if (objSearchLiveNowVideo.isSeries)
//        cell.lblTime.text = @"isseries";
//    
//    else
//        cell.lblTime.hidden = NO;
    
//    cell.lblAbbr.frame = CGRectMake(CGRectGetMinX(cell.lblAbbr.frame), CGRectGetMaxY(cell.lblName.frame)-1, CGRectGetWidth(cell.lblAbbr.frame), CGRectGetHeight(cell.lblAbbr.frame));
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchLiveNowVideo *objSearchLiveNowVideo = [arrSearch objectAtIndex:indexPath.row];
    if (objSearchLiveNowVideo.isSeries == YES) {
        SeriesSeasonsEpisodesViewController *objSeriesSeasonsEpisodesViewController = [[SeriesSeasonsEpisodesViewController alloc] init];
        
        objSeriesSeasonsEpisodesViewController.strSeriesId = objSearchLiveNowVideo.videoId;
        objSeriesSeasonsEpisodesViewController.seriesUrl = objSearchLiveNowVideo.videoThumb;
        
        objSeriesSeasonsEpisodesViewController.seriesName_en = objSearchLiveNowVideo.videoName_en;
        objSeriesSeasonsEpisodesViewController.isFromSearch = YES;
        
        [self.navigationController pushViewController:objSeriesSeasonsEpisodesViewController animated:YES];
    }
    
    else if (objSearchLiveNowVideo.videoType == 2)
    {
        self.strMovieID = [NSString stringWithFormat:@"%@", objSearchLiveNowVideo.videoId];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objSearchLiveNowVideo.videoName_en;
        }
        else
            self.strMovieNameOnCastingDevice = objSearchLiveNowVideo.videoName_ar;
        
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            self.strMovieUrl = objSearchLiveNowVideo.videoUrl;
            [self showLoginScreen];
        }
        
        else
            [self redirectToPlayer:objSearchLiveNowVideo.videoUrl videoId:objSearchLiveNowVideo.videoId];
    }
    
    else
        [self redirectToMovieDetailPage:objSearchLiveNowVideo.videoId movieThumbnail:kEmptyString videoType:objSearchLiveNowVideo.videoType];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    
}

#pragma mark - Show Login Screen

- (void)showLoginScreen
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginCheck = 1;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}


#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    txt = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([[CommonFunctions shared] isInValidString:txtSearch StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kVideoSearchErrorMessage TITLE:kEmptyString Delegate:self];
        [txtSearch becomeFirstResponder];
        return YES;
    }
    
    [self searchLiveNowVideos];
    return YES;
}

#pragma mark - Search Action Event
-(IBAction)searchClicked:(id)sender
{
    if([[CommonFunctions shared] isInValidString:txtSearch StringToMatch:kEmptyString])
    {
        [CommonFunctions showAlertView:kVideoSearchErrorMessage TITLE:kEmptyString Delegate:self];
        [txtSearch becomeFirstResponder];
        return;
    }
    
    [self searchLiveNowVideos];
}

- (IBAction)btnCancelAction:(id)sender
{
    txtSearch.text = @"";
    [txtSearch resignFirstResponder];
}

#pragma mark - SearchVideos
-(void) searchLiveNowVideos
{
    [txt resignFirstResponder];
    SearchLiveNowVideos *objSearchLiveNowVideos = [[SearchLiveNowVideos alloc] init];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
   
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:txtSearch.text isArb:@"false"];
    else
        [objSearchLiveNowVideos searchVOD:self selector:@selector(searchVideosServerResponse:) movieName:txtSearch.text isArb:@"true"];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txt resignFirstResponder];
}

#pragma mark - redirect to movie detail page

- (void)convertBCoveUrl:(id)object
{
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

- (void) redirectToPlayer: (NSString *)url videoId:(NSString*)videoId
{
    self.strMovieID = [NSString stringWithFormat:@"%@", videoId];
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
        objMoviePlayerViewController.strVideoId = videoId;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
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
    
    if (self.strMovieID != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strMovieID, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];
    
    mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    
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
    
    if (self.strMovieID != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strMovieID, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
    
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


#pragma mark - Redirect movie

-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail videoType:(NSInteger)videoType
{
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[MoviesDetailViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    MoviesDetailViewController *objMoviesDetailViewController = [[MoviesDetailViewController alloc] initWithNibName:@"MoviesDetailViewController~iphone" bundle:nil];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int) search];
    [objMoviesDetailViewController setVideoType:videoType];
    if (videoType == 2) {
        [objMoviesDetailViewController setIsMusic:YES];
    }
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
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