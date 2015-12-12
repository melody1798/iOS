//
//  VODWatchListViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODWatchListViewController.h"
#import "GenreDetailCustomCell.h"
#import "DetailGenres.h"
#import "DetailGenre.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"
#import "CustomControls.h"
#import "LastViewedMovie.h"
#import "WatchListMovies.h"
#import "WatchListMovie.h"
#import "MoviesDetailViewController.h"
#import "MoviePlayerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface VODWatchListViewController () <UIGestureRecognizerDelegate>
{
    BOOL            relatedCheckFromWatchList;
    BOOL            isMusic;
    NSString        *seasonNum;
    NSString        *episodeId;
    BOOL            isSeries;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
    CustomControls*                         objCustomControls;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
}

@property (assign, nonatomic) BOOL          isCastingButtonHide;
@property (assign, nonatomic) BOOL          bIsLoad;
@property (strong, nonatomic) NSString*     strMovieNameOnCastingDevice;

@end

@implementation VODWatchListViewController
static int kheaderHeight = 19;

#define OriginalRectForWatchListLabel CGRectMake(67,161,227,101)
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

    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    [self setFonts];
    [self initVars];
}

-(void)viewWillAppear:(BOOL)animated
{
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Watchlist"];
    lblWatchlist.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"empty watchlist" value:@"" table:nil];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    [lblWatchListHeader setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil]];

    if([CommonFunctions userLoggedIn])
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"] forKey:@"userId"];
        numberOfSections = 0;
        
        if (![kCommonFunction checkNetworkConnectivity])
        {
            lblWatchlist.hidden = NO;
            [tblWatchlist setBounces:NO];
            [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
        }
        else
        {
            //Fetch last viewed
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            LastViewedMovie *objLastViewedMovie = [LastViewedMovie new];
            [objLastViewedMovie fetchLastviewed:self selector:@selector(lastViewedServerResponse:) parameter:dict];
            [lblWatchlist setFrame:OriginalRectForWatchListLabel];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //Fetch watchlist
            WatchListMovies *objWatchListMovies = [WatchListMovies new];
            [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
        }
    }
}

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - Response

-(void) lastViewedServerResponse:(LastViewedMovie *) objLastViewedMovie
{
    [arrLastViewedMovies removeAllObjects];
    if(objLastViewedMovie)
    {
        arrLastViewedMovies = [[NSMutableArray alloc] init];
        [arrLastViewedMovies addObject:objLastViewedMovie];
        numberOfSections += 1;
        [tblWatchlist reloadData];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)watchListServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];

    [arrWatchList removeAllObjects];
    arrWatchList = [arrResponse mutableCopy];
    if([arrWatchList count]>0)
    {
        numberOfSections += 1;
        lblWatchlist.hidden = YES;
        [tblWatchlist setBounces:YES];
    }
    else
    {
        lblWatchlist.hidden = NO;
        [tblWatchlist setBounces:NO];
    }
    
    [tblWatchlist reloadData];
    
    if(numberOfSections == 0)
    {
//        CGRect rect = [lblWatchlist frame];
//        rect.origin.y -= 100;
//        [lblWatchlist setFrame:rect];
    }
}

-(void)watchListDeleteItemServerResponse:(NSMutableDictionary *) dct
{
    [self viewWillAppear:YES];
}

#pragma mark - Initialize variables
-(void) initVars
{
    arrWatchList = [[NSMutableArray alloc] init];
    
    tblWatchlist.allowsMultipleSelectionDuringEditing = NO;
    
    
    if(iPhone4WithIOS7)
    {
        CGRect rect = tblWatchlist.frame;
        rect.size.height -= 85;
        [tblWatchlist setFrame:rect];
    }
}

#pragma mark - Set Fonts
-(void) setFonts
{
    [lblWatchListHeader setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil]];
    [lblWatchlist setFont:[UIFont fontWithName:kProximaNova_Regular size:12.0]];
    [lblWatchListHeader setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
}

#pragma mark - Delete WatchList Delegate Method

- (void)deleteWatchListItem:(NSString *)movieId
{
    //WatchList/Delete
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    
    [objWatchListMovies deleteWatchListItem:self selector:@selector(watchListDeleteItemServerResponse:) parameter:dict];
}



#pragma mark - UITableView delegates

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    if(([arrLastViewedMovies count]>0) && (indexPath.section== 0) && (indexPath.row == 0))
        return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //add code here for when you hit delete
        
        WatchListMovie *objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
        [self deleteWatchListItem:objWatchListMovie.movieId];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if([arrLastViewedMovies count] >0)
                return [CommonFunctions returnViewForHeader:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"last viewed" value:@"" table:nil] UITableView:tblWatchlist];
            else if([arrWatchList count] > 0)
                return [CommonFunctions returnViewForHeader:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil]UITableView:tblWatchlist];
            return Nil;
            break;
            
        default:
            if([arrWatchList count] > 0)
                return [CommonFunctions returnViewForHeader:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil] UITableView:tblWatchlist];
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if([arrLastViewedMovies count] > 0)
                return 1;
            else if([arrWatchList count] > 0)
                return [arrWatchList count];
            break;
            
        default:
            if([arrWatchList count] > 0)
                return [arrWatchList count];
            break;
    }
    return  0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if([arrLastViewedMovies count] > 0 || ([arrWatchList count] > 0))
                return kheaderHeight;
            break;
            
        default:
            if([arrWatchList count] > 0)
                return kheaderHeight;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *movieName = kEmptyString;
    NSString *movieThumb = kEmptyString;
    NSString *movieTime = kEmptyString;
    NSString *movieEpisode = kEmptyString;
    
    static NSString *cellIdentifier = @"cell";
    GenreDetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell== nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GenreDetailCustomCell" owner:self options:nil] firstObject];
    
    if(indexPath.section == 0)
    {
        if([arrLastViewedMovies count]>0)
        {
            LastViewedMovie *objLastViewedMovie = [arrLastViewedMovies objectAtIndex:indexPath.row];
            movieName = objLastViewedMovie.movieName_en;
            movieThumb = objLastViewedMovie.movieThumb;
            movieTime = objLastViewedMovie.episodeDuration;
            if (objLastViewedMovie.videoType == 3)
            {
                movieName = objLastViewedMovie.seriesName_en;
                movieEpisode = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objLastViewedMovie.episodeNum];
            }
            else if (objLastViewedMovie.videoType == 2)
            {
                cell.lblAbbr.textColor = [UIColor whiteColor];
                movieEpisode = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish] ? objLastViewedMovie.singerName_en:objLastViewedMovie.singerName_ar;
            }
        }
        else if([arrWatchList count] > 0)
        {
            WatchListMovie *objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
            movieName = objWatchListMovie.movieName_en;
            movieThumb = objWatchListMovie.movieThumb;
            movieTime = objWatchListMovie.episodeDuration;
            if (objWatchListMovie.videoType == 3)
            {
                movieName = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objWatchListMovie.seriesName_en:objWatchListMovie.seriesName_ar;
                movieEpisode = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objWatchListMovie.episodeNum];
            }
        }
    }
    else
    {
        WatchListMovie *objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
        movieName = objWatchListMovie.movieName_en;
        movieThumb = objWatchListMovie.movieThumb;
        movieTime = objWatchListMovie.episodeDuration;
        if (objWatchListMovie.videoType == 3)
        {
            movieName = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objWatchListMovie.seriesName_en:objWatchListMovie.seriesName_ar;
            movieEpisode = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objWatchListMovie.episodeNum];
        }
    }
   // cell.lblTime.text = [movieTime length]>0?[NSString stringWithFormat:@"%@ %@", movieTime, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
    {
        NSString *lbltext  = [NSString stringWithFormat:@"%@ %@",  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], movieTime];
        NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
        cell.lblTime.attributedText = strAtt;
    }
    else
        cell.lblTime.text = [NSString stringWithFormat:@"%@ %@", movieTime, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
    
    
    cell.lblName.text = movieName;
    /*Dummy Code*/
  //  cell.lblAbbr.te xt = @"-";
    CGSize size = [@"-" sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    /*End of Dummy Code*/
    size.height += 4;
    size.width += 4;
    CGRect rect = cell.imgBackground.frame;
    rect.size.width += 25;
    [cell.imgBackground setFrame:rect];

    
    CGRect frameSingerLbl =  cell.lblName.frame;
    frameSingerLbl.origin.y = 26;
    cell.lblName.frame = frameSingerLbl;
    
    cell.lblAbbr.text = movieEpisode;
    cell.lblAbbr.hidden = (cell.lblAbbr.text.length>0?NO:YES);
    cell.lblAbbr.textAlignment = NSTextAlignmentLeft;
    [cell.imgMovies sd_setImageWithURL:[NSURL URLWithString:movieThumb] placeholderImage:[UIImage imageNamed:@""]];
    [cell setBackgroundColor:[UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WatchListMovie *objWatchListMovie;
    switch (indexPath.section)
    {
        case 0:
        {
            if([arrLastViewedMovies count] > 0)
            {
                LastViewedMovie *objLastViewedMovie = [arrLastViewedMovies objectAtIndex:indexPath.row];
                if ([objLastViewedMovie.seriesID length]!=0) {
                    relatedCheckFromWatchList = YES;
                    seasonNum = objLastViewedMovie.seasonNum;
                    episodeId = objLastViewedMovie.movieId;
                    isSeries = YES;
                    
                    [self redirectToMovieDetailPage:objLastViewedMovie.seriesID movieThumbnail:kEmptyString videoType:objLastViewedMovie.videoType];
                }
                else
                {
                    relatedCheckFromWatchList = NO;
                    isSeries = NO;
                    if (objLastViewedMovie.videoType == 2) {
                        
                        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
                            self.strMovieNameOnCastingDevice = objLastViewedMovie.movieName_en;
                        }
                        else
                            self.strMovieNameOnCastingDevice = objLastViewedMovie.movieName_ar;
                        
                        isMusic = YES;
                        [self redirectToPlayer:objLastViewedMovie.movieUrl];
                    }
                    
                    else
                        [self redirectToMovieDetailPage:objLastViewedMovie.movieId movieThumbnail:kEmptyString videoType:objLastViewedMovie.videoType];
                }
            }
            else
            {
                objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
                if ([objWatchListMovie.seriesID length]!=0) {
                    relatedCheckFromWatchList = YES;
                    seasonNum = objWatchListMovie.seasonNum;
                    episodeId = objWatchListMovie.movieId;
                    isSeries = YES;
                    [self redirectToMovieDetailPage:objWatchListMovie.seriesID movieThumbnail:kEmptyString videoType:0];
                }
                else
                {
                    relatedCheckFromWatchList = NO;
                    if (objWatchListMovie.videoType == 2) {
                        
                        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
                            self.strMovieNameOnCastingDevice = objWatchListMovie.movieName_en;
                        }
                        else
                            self.strMovieNameOnCastingDevice = objWatchListMovie.movieName_ar;
                        
                        isMusic = YES;
                        [self redirectToPlayer:objWatchListMovie.movieUrl];
                    }
                    
                    else
                    {
                        isSeries = NO;
                        [self redirectToMovieDetailPage:objWatchListMovie.movieId movieThumbnail:kEmptyString videoType:objWatchListMovie.videoType];
                    }
                }
                break;
            }
            break;
        }
        case 1:
        {
            objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
            if ([objWatchListMovie.seriesID length]!=0) {
                relatedCheckFromWatchList = YES;
                seasonNum = objWatchListMovie.seasonNum;
                episodeId = objWatchListMovie.movieId;
                isSeries = YES;
                
                [self redirectToMovieDetailPage:objWatchListMovie.seriesID movieThumbnail:kEmptyString videoType:objWatchListMovie.videoType];
            }
            else
            {
                relatedCheckFromWatchList = NO;
                if (objWatchListMovie.videoType == 2) {
                    isMusic = YES;
                    [self redirectToPlayer:objWatchListMovie.movieUrl];
                }
                
                else
                {
                    isSeries = NO;
                    [self redirectToMovieDetailPage:objWatchListMovie.movieId movieThumbnail:kEmptyString videoType:objWatchListMovie.videoType];
                }
            }
            
            break;
        }
            
        default:
        {
            objWatchListMovie = [arrWatchList objectAtIndex:indexPath.row];
            if ([objWatchListMovie.seriesID length]!=0) {
                relatedCheckFromWatchList = YES;
                seasonNum = objWatchListMovie.seasonNum;
                episodeId = objWatchListMovie.movieId;
                isSeries = YES;
                [self redirectToMovieDetailPage:objWatchListMovie.seriesID movieThumbnail:kEmptyString videoType:0];
            }
            else
            {
                relatedCheckFromWatchList = NO;
                if (objWatchListMovie.videoType == 2) {
                    isMusic = YES;
                    [self redirectToPlayer:objWatchListMovie.movieUrl];
                }
                
                else
                {
                    isSeries = NO;
                    [self redirectToMovieDetailPage:objWatchListMovie.movieId movieThumbnail:kEmptyString videoType:objWatchListMovie.videoType];
                }
            }
            break;
        }
    }
}

- (void)convertBCoveUrl:(id)object
{
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

#pragma mark - redirect to movie detail page

- (void) redirectToPlayer:(NSString *)url
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

#pragma mark - Redirect movie controller
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
    [objMoviesDetailViewController setRelatedCheckFromWatchList:relatedCheckFromWatchList];
    [objMoviesDetailViewController setTypeOfDetail:(int) watchlist];
    [objMoviesDetailViewController setIsMusic:isMusic];
    [objMoviesDetailViewController setStrSeasonNum:seasonNum];
    [objMoviesDetailViewController setVideoType:videoType];
    [objMoviesDetailViewController setStrEpisodeId:episodeId];
    [objMoviesDetailViewController setIsSeries:isSeries];
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

@end