//
//  ChannelDetailViewViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "ChannelDetailViewViewController.h"
#import "LoginViewController.h"
#import "CommonFunctions.h"
#import "UIImageView+WebCache.h"
#import "UpcomingVideos.h"
#import "UpcomingVideo.h"
#import "AppDelegate.h"
#import "MelodyHitsCustomCell.h"
#import "MoviePlayerViewController.h"
#import "CustomControls.h"
#import "SettingViewController.h"
#import "Channels.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ChannelDetailViewViewController () <UpdateMovieDetailOnLoginDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView*       tblVwUpcoming;
    IBOutlet UILabel*           lblLiveNowTitle;
    IBOutlet UILabel*           lblChannelName;
    UIImageView*                imgVwChannelLogo;
    NSArray*                    arrUpcomingVideos;
    NSArray*                    arrTodayUpcomingVideos;
    IBOutlet UIWebView*         webVwChannel;
    IBOutlet UILabel*           lblNoUpcomings;
    LoginViewController*        objLoginViewController;
    IBOutlet UIButton*          btnPlayVideo;
    NSMutableArray*             days;
    NSMutableDictionary*        groupedEvents;
    IBOutlet UIImageView*       imgVwMovieLogo;
    IBOutlet UILabel*           lblMovieName;
    IBOutlet UILabel*           lblMovieTime;
    IBOutlet UILabel*           lblUpcoming;
    IBOutlet UIImageView*       imgLiveProgramBg;
    IBOutlet UIImageView*       imgLivePlayIcon;
    
    MPMoviePlayerViewController* mpMoviePlayerViewController;
    CustomControls*             objCustomControls;
    UITapGestureRecognizer*     singleTapGestureRecognizer;
}

@property (strong, nonatomic) NSString* strChannelName_en;
@property (strong, nonatomic) NSString* strChannelName_ar;
@property (strong, nonatomic) NSString* strLiveMovie_en;
@property (strong, nonatomic) NSString* strLiveMovie_ar;
@property (strong, nonatomic) NSString* strChannelUrl;
@property (strong, nonatomic) NSString* strChannelLogoUrl;
@property (assign, nonatomic) BOOL      bLiveVideoPlaying;
@property (assign, nonatomic) BOOL      isCastingButtonHide;
@property (assign, nonatomic) BOOL      bIsLoad;

@end

@implementation ChannelDetailViewViewController

@synthesize strChannelName;

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
    
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];

    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //Add 	
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];

    //Set google analytics.
    [CommonFunctions addGoogleAnalyticsForView:@"Channel"];

    [self addChannelLogoOnNavBar]; //Add melody logo on navigation bar.
    
    [lblLiveNowTitle setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil]];
    lblUpcoming.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
    lblNoUpcomings.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    //Fetch channel detail server resposne.
    if (appDelegate.isFromSearch)
        [self fetchChannelDetailsPlayFromSearch:appDelegate.channelName];
    else
        [self fetchChannelDetails];
}

- (void)addChannelLogoOnNavBar
{
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 50, 47)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:self.strChannelLogoUrl] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

#pragma mark - UINavigationBar Action
- (void)settingsBarButtonItemAction
{
    [imgVwChannelLogo removeFromSuperview];

    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.navigationController ViewController:objSettingViewController];
}

- (void)backBarButtonItemAction
{
    [imgVwChannelLogo removeFromSuperview];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.isFromSearch = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Set UI
- (void)setUI
{
    lblMovieName.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 13.0:18.0)];
    lblMovieTime.font = [UIFont fontWithName:kProximaNova_SemiBold size:([CommonFunctions isIphone]? 12.0:18.0)];
    lblNoUpcomings.font = [UIFont fontWithName:kProximaNova_Bold size:12.0];

    lblMovieName.textColor = YELLOW_COLOR;
    lblMovieTime.textColor = [UIColor whiteColor];
    
    lblLiveNowTitle.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    lblUpcoming.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if (iPhone4WithIOS7) {
        CGRect lblMovieFrame = lblMovieName.frame;
        lblMovieFrame.origin.y = lblMovieName.frame.origin.y + 40;
        lblMovieName.frame = lblMovieFrame;
        
        CGRect lblTimeFrame = lblMovieTime.frame;
        lblTimeFrame.origin.y = lblMovieTime.frame.origin.y + 40;
        lblMovieTime.frame = lblTimeFrame;
    }
}

- (void)fetchChannelDetails
{
    //Fetch upcoming data from server.
    UpcomingVideos *objUpcomingVideos = [UpcomingVideos new];
    [objUpcomingVideos fetchChannelUpcomingVideos:self selector:@selector(upcomingVideosResponse:) channelName:self.strChannelName];
}

#pragma mark - Play Channel from Selected search
- (void)fetchChannelDetailsPlayFromSearch:(NSString*)channelName
{
    UpcomingVideos *objUpcomingVideos = [UpcomingVideos new];
    [objUpcomingVideos fetchChannelUpcomingVideos:self selector:@selector(upcomingVideosResponse:) channelName:channelName];
}

#pragma mark - Upcoming video server response
- (void)upcomingVideosResponse:(UpcomingVideos*)objUpcomingVideos
{
    //Set response to UI
    //Set logo on navigation bar.
    [imgVwChannelLogo removeFromSuperview];
    imgVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 1, 50, 47)];
    imgVwChannelLogo.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:40.0/255.0 alpha:1.0];
    [imgVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:objUpcomingVideos.channelLogoUrl] placeholderImage:nil];
    [self.navigationController.navigationBar addSubview:imgVwChannelLogo];
    
    self.strChannelLogoUrl = [NSString stringWithFormat:@"%@", objUpcomingVideos.channelLogoUrl];
    
    lblNoUpcomings.hidden = YES;
    [self GroupUpcomingData:objUpcomingVideos.arrUpcomingVideos];
    
    if ([arrUpcomingVideos count] == 0) {
        lblNoUpcomings.hidden = NO;
    }
    
    if (objUpcomingVideos.liveVideoName_en != nil) {
        
        self.strChannelUrl = objUpcomingVideos.liveChannelUrl;
        self.bLiveVideoPlaying = YES;
        lblMovieName.hidden = NO;
        lblMovieTime.hidden = NO;
        imgLiveProgramBg.hidden = NO;
        imgLivePlayIcon.hidden = NO;
        lblMovieTime.textAlignment = NSTextAlignmentLeft;

        self.strLiveMovie_en = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_en];
        self.strLiveMovie_ar = [NSString stringWithFormat:@"%@", objUpcomingVideos.liveVideoName_ar];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            lblMovieName.text = objUpcomingVideos.liveVideoName_en;
        }
        else
        {
            lblMovieName.text = objUpcomingVideos.liveVideoName_ar;
        }
        
        if (objUpcomingVideos.liveVideoStartTime!=nil) {
            
            NSString *convertedTime = [CommonFunctions convertGMTDateFromLocalDate:objUpcomingVideos.liveVideoStartTime];
            lblMovieTime.text = [convertedTime uppercaseString];
        }
        else
            lblMovieTime.hidden = YES;
        
        [imgVwMovieLogo setHidden:NO];
        [imgVwMovieLogo sd_setImageWithURL:[NSURL URLWithString:objUpcomingVideos.liveVideoThumbnail]];
    }
    else
    {
        self.bLiveVideoPlaying = NO;

        lblMovieName.hidden = YES;
        lblMovieTime.hidden = NO;
        [imgVwMovieLogo sd_setImageWithURL:[NSURL URLWithString:@""]];
        [imgVwMovieLogo setHidden:YES];
        imgLivePlayIcon.hidden = YES;
        lblMovieTime.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No live show found for this channel." value:@"" table:nil];
        lblMovieTime.textAlignment = NSTextAlignmentCenter;
    }
    [tblVwUpcoming reloadData];
}

#pragma mark - Group upcoming data according to date
- (void)GroupUpcomingData:(NSArray*)arrUpcomingData
{
    arrUpcomingVideos = [[NSArray alloc] initWithArray:arrUpcomingData];
    arrTodayUpcomingVideos = [[NSArray alloc] initWithArray:arrUpcomingData];
    
    [self sortDataByDate:arrUpcomingData];
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
    
    [tblVwUpcoming reloadData];
}

- (IBAction)playBtnAction:(id)sender
{
    if (self.bLiveVideoPlaying == YES) {
        if (![self checkUserAccessToken]) {
            
            [self showLoginScreen];
        }
        else{
            [self playVideo];
        }
    }
}

- (void)showLoginScreen
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    objLoginViewController.delegateUpdateMovie = self;
    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    [objLoginViewController.view setFrame:CGRectMake(0, windowHeight, self.view.frame.size.width, windowHeight)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:objLoginViewController.view];
    [UIView animateWithDuration:0.5f animations:^{
        [objLoginViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, windowHeight)];
    } completion:nil];
}

- (void)playVideo
{
    @try
    {
        mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:self.strChannelUrl]];
        [mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
        [mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
        
        [mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
        // Register to receive a notification when the movie has finished playing.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        //Add Casting button
        objCustomControls = [CustomControls new];
        objCustomControls.strVideoUrl = self.strChannelUrl;
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
        mpMoviePlayerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    }
    @catch (NSException *exception) {
        // throws exception
    }
}

- (void)hideCastingButtonSyncWithPlayer
{
    self.isCastingButtonHide = NO;
    [objCustomControls hideCastButton];
}

#pragma mark - Youtube player delegate methods
- (void)handleClickOnMediaViewToHideCastButton
{
    //Check if movie player loads then show casting button on user tap.
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

- (void)willEnterFullscreen:(NSNotification*)notification {
}

- (void)enteredFullscreen:(NSNotification*)notification {
}

- (void)willExitFullscreen:(NSNotification*)notification {
}

- (void)exitedFullscreen:(NSNotification*)notification {
}

- (void)updateMovieDetailViewAfterLogin
{
    [self playVideo];
}

- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

#pragma mark - Change language
- (void)changeLanguageChannelView
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        lblMovieName.text = self.strLiveMovie_en;
    else
        lblMovieName.text = self.strLiveMovie_ar;
    
    NSString *strTime = lblMovieTime.text;
    lblMovieTime.text = [CommonFunctions convertTimeUnitLanguage:strTime]; //Convert time unit according to language.
    [tblVwUpcoming reloadData];
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [days count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //  return [arrUpcomingVideos count];
    return [[groupedEvents objectForKey:[days objectAtIndex:section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"channelcell";
    MelodyHitsCustomCell *cell = (MelodyHitsCustomCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (MelodyHitsCustomCell*) [[[NSBundle mainBundle] loadNibNamed:@"MelodyHitsCustomCell" owner:self options:nil] objectAtIndex:0];
    }
    
    [cell setChannelSetValue:[[groupedEvents objectForKey:[days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *vwHeaderUpcoming = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    
    UIImageView *imgVwHeaderBack = [[UIImageView alloc] initWithFrame:vwHeaderUpcoming.frame];
    imgVwHeaderBack.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1.0];
    
    UILabel *lblUpcomingPrograms = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    lblUpcomingPrograms.textAlignment = NSTextAlignmentCenter;
    
    //Compare if data is today's date and group in first section.
    BOOL y = [self compareDates:[days objectAtIndex:section]];
    if (y) {
        lblUpcomingPrograms.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"upcoming" value:@"" table:nil] uppercaseString];
        return nil;
    }
    else
    {
        [lblUpcomingPrograms setFrame:CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        [lblUpcomingPrograms setTextAlignment:NSTextAlignmentLeft];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss EEEE";
        NSString *strDate = [formatter stringFromDate:[days objectAtIndex:section]];
        [lblUpcomingPrograms setText:[self changeDateFormat:strDate]];
    }
    
    lblUpcomingPrograms.font = [UIFont fontWithName:kProximaNova_Bold size:14.0];
    lblUpcomingPrograms.textColor = [UIColor whiteColor];
    lblUpcomingPrograms.backgroundColor = [UIColor clearColor];
    
    [vwHeaderUpcoming addSubview:imgVwHeaderBack];
    [vwHeaderUpcoming addSubview:lblUpcomingPrograms];
    
    return vwHeaderUpcoming;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BOOL y = [self compareDates:[days objectAtIndex:section]];
    if (y) {
        return 0;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (BOOL)compareDates:(NSDate*)date
{
    //Compare server date with device date.
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

-(NSString *)changeDateFormat:(NSString *)strDate
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
    //Add Admob is iads fails.
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