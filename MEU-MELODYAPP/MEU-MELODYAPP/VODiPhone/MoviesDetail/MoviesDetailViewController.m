//
//  MoviesDetailViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviesDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "CustomControls.h"
#import "CommonFunctions.h"
#import "VideoDetail.h"
#import "MoviesViewController.h"
#import "CommonFunctions.h"
#import "MusicViewController.h"
#import "CollectionsViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "WatchListMovies.h"
#import "VODSearchViewController.h"
#import "VODHomeViewController.h"
#import "VODWatchListViewController.h"
#import "CastAndCrewDescriptionCell.h"
#import "CastAndCrewDescriptionCellForArtists.h"
#import "DetailArtist.h"
#import "SeriesViewController.h"
#import "SettingViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MoviePlayerViewController.h"
#import "SeriesDetail.h"
#import <Social/Social.h>
#import "NSIUtility.h"
#import "Episode.h"
#import "Episodes.h"
#import "RelatedSingerViewController.h"
#import "RelatedTableViewCell.h"
#import "RelatedEpisodeDetailViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface MoviesDetailViewController () <UIActionSheetDelegate, MovieDetailFromRelatedSingers, UIGestureRecognizerDelegate>
{
    IBOutlet UIView*            vWActionSheetView;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
    CustomControls*                         objCustomControls;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
}

@property (strong, nonatomic) NSMutableArray*       arrAllEpisodes;
@property (strong, nonatomic) NSString*             strThumnailUrl;
@property (assign, nonatomic) BOOL                  isCastingButtonHide;
@property (assign, nonatomic) BOOL                  bIsLoad;
@property (strong, nonatomic) CustomControls*       objCustomControls;
@property (strong, nonatomic) NSString*             strMovieNameToShareOnFacebook;
@property (strong, nonatomic) NSString*             strSeriesNameToShareOnFacebook;

- (IBAction)btnRelated:(id)sender;
- (IBAction)btnFacebookShare:(id)sender;
- (IBAction)btnTwitterShare:(id)sender;
- (IBAction)btnCloseActionSheet:(id)sender;

@end

@implementation MoviesDetailViewController

@synthesize _episodeDesc, strEpisodeDuration, strEpisodeId;
@synthesize strMovieUrl;
@synthesize isMusic;
@synthesize _arrEpisodes, selectedEpisodeIndex;
@synthesize relatedCheckFromWatchList;
@synthesize strSeasonNum;
@synthesize videoType;
@synthesize isFromCollection, isFromSearch;
@synthesize strSeriesName;
@synthesize objCustomControls;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [segmentControl setSelectedSegmentIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"info" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"related" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] forSegmentAtIndex:2];
    
    _wbVwMovie.scrollView.bounces = NO;
    _wbVwMovie.scrollView.scrollEnabled = NO;
    [self setUI];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingsBarButtonItemAction)];
    [self setSegmentedControlAppreance];
    [self setFonts];
    
    loginCheck = 0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.imgMovieName.image = nil;
    [self removeMelodyButton];

    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    if (videoType == 1)
    {
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"info" value:@"" table:nil] forSegmentAtIndex:0];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] forSegmentAtIndex:1];
        
        btnRelated.hidden = YES;
    }
    else
    {
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"info" value:@"" table:nil] forSegmentAtIndex:0];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"related" value:@"" table:nil] forSegmentAtIndex:1];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] forSegmentAtIndex:2];
    }
    
    
    if(_typeOfDetail == (int) series || videoType == 3)
    {
        [[[Episodes alloc] init] fetchSeriesSeasonalEpisodes:self selector:@selector(fetchSeriesEpisodesResponse:) parameter:_movieId seasonId:strSeasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    
    numberOfSections = 1;
    if(_typeOfDetail == (int) music)
        [lblMovie setText:@"MUSIC"];
    else if(_typeOfDetail == (int) collection)
        [lblMovie setText:@"COLLECTION"];
    else if(_typeOfDetail == (int) series)
        [lblMovie setText:@"SERIES"];
    else
        [lblMovie setText:@"MOVIES"];
    
    if (_typeOfDetail == (int) series || _isSeries) {
        //btnPlay.hidden = YES;
        
        VideoDetail *objVideoDetail = [[VideoDetail alloc] init];
        [objVideoDetail fetchVideoDetail:self selector:@selector(episodeDetailServerResponse:) parameter:strEpisodeId UserID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    else
    {
        VideoDetail *objVideoDetail = [[VideoDetail alloc] init];
        [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:_movieId UserID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    
    tblCastAndCrew.dataSource = self;
    tblCastAndCrew.delegate = self;
    
    segmentControl.selectedSegmentIndex = 0;
    
    if (objCustomControls) {
        
        [objCustomControls removeNotifications];
        objCustomControls = nil;
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    if (loginCheck == 1 && [CommonFunctions userLoggedIn])
    {
        loginCheck = 0;
        [self playVideo];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self removeMelodyButton];
    tblCastAndCrew.dataSource = nil;
    tblCastAndCrew.delegate = nil;
}

#pragma mark - Set UI

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

-(void) setUI
{
    if (videoType == 1) {
        btnRelated.hidden = YES;
        [segmentControl removeSegmentAtIndex:1 animated:NO];
    }
    
    if(iPhone5WithIOS6)
    {
        CGRect rect = headerView.frame;
        rect.origin.y -= 70;
        rect.size.height += 50;
        
        [headerView setFrame:rect];
        rect = _imgMovieName.frame;
        rect.origin.y -= 50;
        [_imgMovieName setFrame:rect];
        rect.origin.y += 5;
        rect.size.height -= 3;
        [_wbVwMovie setFrame:rect];
        rect = previewView.frame;
        rect.origin.y -= 45;
        rect.size.height += 100;
        [previewView setFrame:rect];
    }
    else if(iPhone4WithIOS6)
    {
        CGRect segmentFrame = segmentControl.frame;
        segmentFrame.origin.y = segmentFrame.origin.y - 7;
        segmentFrame.size.width = 300;
        segmentControl.frame = segmentFrame;
        
        CGRect rect = headerView.frame;
        rect.origin.y -= 70;
        rect.size.height += 50;
        
        [headerView setFrame:rect];
        
        rect = _imgMovieName.frame;
        rect.origin.y -= 50;
        [_imgMovieName setFrame:rect];
        rect.origin.y += 5;
        rect.size.height -= 3;
        [_wbVwMovie setFrame:rect];
        rect = previewView.frame;
        rect.origin.y -= 45;
        rect.size.height += 100;
        [previewView setFrame:rect];
    }
    else if (iPhone4WithIOS7)
    {
        CGRect segmentFrame = segmentControl.frame;
        segmentFrame.origin.y = segmentFrame.origin.y - 5;
        segmentControl.frame = segmentFrame;
        
        CGRect rect = headerView.frame;
        rect.origin.y += 10;
        rect.size.height += 50;
        [headerView setFrame:rect];
        rect = _wbVwMovie.frame;
        rect.origin.y += 18;
        rect.size.height -= 16;
        [_wbVwMovie setFrame:rect];
        
        rect = previewView.frame;
        rect.size.height += 100;
        [previewView setFrame:rect];
        rect = btnAddtoWatchList.frame;
        rect.size.width = 38;
        rect.size.height = 38;
        btnAddtoWatchList.frame = rect;
        
        rect = previewSubView.frame;
        rect.origin.y -= 15;
        [previewSubView setFrame:rect];
        rect = tblCastAndCrew.frame;
        rect.size.height -= 75;
        [tblCastAndCrew setFrame:rect];
    }
}

#pragma mark - Response for Video Detail Service
-(void) videoDetailServerResponse:(VideoDetail *) objVideoDetail
{
    [self setUI:objVideoDetail];
    self.strMovieUrl = [NSString stringWithFormat:@"%@", objVideoDetail.movieUrl];
    self.movieName = [NSString stringWithFormat:@"%@", objVideoDetail.movieTitle_en];
    self.strMovieNameToShareOnFacebook = [NSString stringWithFormat:@"%@", objVideoDetail.movieTitle_eniPhone];
}

- (void)episodeDetailServerResponse:(VideoDetail*)objVideoDetail
{
    if ([objVideoDetail.seriesSeasonCount isEqualToString:@"1"])
    {
        NSString *episodeName = [CommonFunctions isEnglish]?objVideoDetail.movieTitle_en:objVideoDetail.movieTitle_ar;
        self.strMovieNameToShareOnFacebook = objVideoDetail.movieTitle_en;
        
        if ([episodeName length]!=0) {
            self.movieName = [NSString stringWithFormat:@"%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVideoDetail.episodeNum, [CommonFunctions isEnglish]?objVideoDetail.movieTitle_en:objVideoDetail.movieTitle_ar];
            
            self.strMovieNameToShareOnFacebook = [NSString stringWithFormat:@"Ep %@ - %@", objVideoDetail.episodeNum, objVideoDetail.movieTitle_en];
        }
        else
        {
            self.movieName = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVideoDetail.episodeNum];
            self.strMovieNameToShareOnFacebook = [NSString stringWithFormat:@"Ep %@", objVideoDetail.episodeNum];
        }
    }
    else
    {
        self.movieName = [NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objVideoDetail.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objVideoDetail.episodeNum, [CommonFunctions isEnglish]?objVideoDetail.movieTitle_en:objVideoDetail.movieTitle_ar];
        self.strMovieNameToShareOnFacebook = [NSString stringWithFormat:@"Sn %@ - Ep %@ - %@", objVideoDetail.seasonNum, objVideoDetail.episodeNum, objVideoDetail.movieTitle_en];
    }
    
    if (self.strEpisodeDuration == nil) {
        self.strEpisodeDuration = objVideoDetail.movieDuration;
    }
    self.strMovieUrl = objVideoDetail.movieUrl;
    if(objVideoDetail.existsInWatchlist)
        [btnAddtoWatchList setEnabled:NO];
    else
        [btnAddtoWatchList setEnabled:YES];
    
    SeriesDetail *objSeriesDetail = [SeriesDetail new];
    [objSeriesDetail fetchSeriesDetail:self selector:@selector(seriesDetailServerResponse:) parameter:_movieId];
}

- (void)seriesDetailServerResponse:(SeriesDetail*)objSeriesDetail
{
   // description = [NSString stringWithFormat:@"%@", _episodeDesc];
    self.strThumnailUrl = [NSString stringWithFormat:@"%@", _movieThumbnail];
    [_imgMovieName sd_setImageWithURL:[NSURL URLWithString:_movieThumbnail]];
    lblMovieName.text = objSeriesDetail.seriesName;
    self.strSeriesNameToShareOnFacebook = objSeriesDetail.seriesName_en;
    
    lblMovieDuration.text = self.movieName;
    
    if ([self.strEpisodeDuration length] == 0) {
        CGRect lblMovieDurationRightFrame = lblMovieDurationRight.frame;
        lblMovieDurationRightFrame.origin.y = 27;
        lblMovieDurationRight.frame = lblMovieDurationRightFrame;
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
        {
          /*  NSString *lbltext  = [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], self.strEpisodeDuration];
            NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
            
            lblMovieDurationRight.attributedText = strAtt;  */
            
            NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];
            NSMutableAttributedString *lbltextRuntime = [[NSMutableAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil]];

            NSString *lbltext = [NSString stringWithFormat:@" : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], self.strEpisodeDuration];
            
            [lbltextMu appendAttributedString:lbltextRuntime];
            [lbltextMu appendAttributedString:[CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular]];
            
            lblMovieDurationRight.attributedText = lbltextMu;
        }
        else
            lblMovieDurationRight.text = [self.strEpisodeDuration length] > 0?[NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], self.strEpisodeDuration,  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
    }
        
   // if ([_episodeDesc length] == 0 || [description length] == 0) {
        description = objSeriesDetail.seriesDesc;
   // }
    arrCastAndCrew = [objSeriesDetail.arrSeriesCastAndCrew mutableCopy];
    arrProducers = [objSeriesDetail.arrSeriesProducers mutableCopy];
    
    if([CommonFunctions userLoggedIn])
    {
       // [self saveToLastViewed];
    }
    else
    {
    }
    
    if([arrCastAndCrew count] > 0)
        numberOfSections += 1;
    
    if([arrProducers count] >0)
        numberOfSections += 1;

    
    [tblCastAndCrew reloadData];
    
    // [self setupUIInfo];
}

- (void)fetchSeriesEpisodesResponse:(NSArray*)arrResponse
{
    _arrEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    self.arrAllEpisodes = [[NSMutableArray alloc] initWithArray:_arrEpisodes];
    
    //  if (selectedEpisodeIndex == 0) {
    
    for (int i = 0; i < [_arrEpisodes count]; i++) {
        Episode *objEpisode = (Episode*) [_arrEpisodes objectAtIndex:i];
        if ([objEpisode.episodeId isEqualToString:strEpisodeId]) {
            selectedEpisodeIndex = i;
            return;
        }
    }
    //}
}

- (void)saveWatchListServerResponse:(NSDictionary*)dictResponse
{
    [btnAddtoWatchList setEnabled:NO];
}

-(void)saveLastViewedServerResponse:(NSMutableArray *) arr
{
    
}

#pragma mark - Set text
-(void) setUI:(VideoDetail *) objVideoDetail
{
    if (videoType == 1)
    {
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"info" value:@"" table:nil] forSegmentAtIndex:0];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] forSegmentAtIndex:1];
    
        btnRelated.hidden = YES;
    }
    else
    {
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"info" value:@"" table:nil] forSegmentAtIndex:0];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"related" value:@"" table:nil] forSegmentAtIndex:1];
        [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"share" value:@"" table:nil] forSegmentAtIndex:2];
    }

    arrCastAndCrew = [objVideoDetail.arrCastAndCrew mutableCopy];
    arrProducers = [objVideoDetail.arrProducers mutableCopy];
    
    if (isMusic) {
        for (int i = 0; i < [arrCastAndCrew count]; i++) {
            DetailArtist *objDetailArtist = [arrCastAndCrew objectAtIndex:i];
            if ([objDetailArtist.artistRoleId isEqualToString:@"4"]) {
                
                self.strSingerId = objDetailArtist.artistId;
                lblMovieDuration.text = objDetailArtist.artistName_en;
                break;
            }
        }
    }
    
    self.strThumnailUrl = [NSString stringWithFormat:@"%@", [_movieThumbnail length]>0?_movieThumbnail:objVideoDetail.movieThumbnail];

    [_imgMovieName sd_setImageWithURL:[NSURL URLWithString:[_movieThumbnail length]>0?_movieThumbnail:objVideoDetail.movieThumbnail] placeholderImage:[UIImage imageNamed:@""]];
    
    if(_typeOfDetail==(int)series || videoType == 3)
    {
        lblMovieDurationRight.text = [objVideoDetail.movieDuration length] > 0?
        [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objVideoDetail.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
        
        if (![CommonFunctions isEnglish])
        {
            NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lblMovieDurationRight.text fontName:kProximaNova_Regular];
            lblMovieDurationRight.attributedText = strAtt;
        }
        
        if ([lblMovieDuration.text length] == 0) {
            CGRect lblMovieDurationRightFrame = lblMovieDurationRight.frame;
            lblMovieDurationRightFrame.origin.y = 30;
            lblMovieDurationRight.frame = lblMovieDurationRightFrame;
        }
        
        lblMovieDuration.hidden = NO;
        lblMovieDuration.text = [NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objVideoDetail.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objVideoDetail.episodeNum, objVideoDetail.movieTitle_en];
    }
    else
    {
        NSString *lbltext;
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
        {
//            lbltext = [objVideoDetail.movieDuration length] > 0?
//            [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDuration]:@"";
            
            if ([objVideoDetail.movieDuration length] > 0) {
                
                NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];
                NSMutableAttributedString *lbltextRuntime = [[NSMutableAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil]];
                
                NSString *lbltext = [NSString stringWithFormat:@" : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDuration];
                
                [lbltextMu appendAttributedString:lbltextRuntime];
                [lbltextMu appendAttributedString:[CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular]];
                
                lblMovieDuration.attributedText = lbltextMu;
            }
        }
        else
        {    lbltext = [objVideoDetail.movieDuration length] > 0?
            [NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objVideoDetail.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
            
            NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
            lblMovieDuration.attributedText = strAtt;
        }
        
        lblMovieName.text = objVideoDetail.movieTitle_en;
    }

    description = objVideoDetail.movieDesc_en;
    if(objVideoDetail.existsInWatchlist)
        [btnAddtoWatchList setEnabled:NO];
    else
        [btnAddtoWatchList setEnabled:YES];
    
    [_wbVwMovie loadHTMLString:[CommonFunctions getYouTubeEmbed:objVideoDetail.movieUrl embedRect:_wbVwMovie.frame] baseURL:Nil];
    if([CommonFunctions userLoggedIn])
    {
       // [btnPlay setHidden:YES];
       // [self saveToLastViewed];
    }
    else
    {
       // [btnPlay setHidden:NO];
    }
    
    if (isMusic == NO) {
        if([arrCastAndCrew count] > 0)
            numberOfSections += 1;
        
        if([arrProducers count] >0)
            numberOfSections += 1;
    }

    [tblCastAndCrew reloadData];
    
    if (_typeOfDetail == (int)series || videoType == 3) {
       // lblMovieName.text = strSeriesName;
    }
}

#pragma mark - Navigation bar button items

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
}

-(void) backBarButtonItemAction
{
    segmentControl.selectedSegmentIndex = 0;
    MoviesViewController *objMoviesViewController = [[MoviesViewController alloc] init];
    MusicViewController *objMusicViewController = [[MusicViewController alloc] init];
    CollectionsViewController *objCollectionsViewController = [[CollectionsViewController alloc] init];
    VODSearchViewController *objVODSearchViewController = [[VODSearchViewController alloc] init];
    VODHomeViewController *objVODHomeViewController = [[VODHomeViewController alloc] init];
    SeriesViewController *objSeriesViewController = [[SeriesViewController alloc] init];
    VODWatchListViewController *objVODWatchListViewController = [[VODWatchListViewController alloc] init];
    if(_typeOfDetail == (int) movie)
        [CommonFunctions pushViewController:self.navigationController ViewController:objMoviesViewController];
    else if(_typeOfDetail == (int) music)
        [CommonFunctions pushViewController:self.navigationController ViewController:objMusicViewController];
    else if(_typeOfDetail == (int) collection)
        [CommonFunctions pushViewController:self.navigationController ViewController:objCollectionsViewController];
    else if(_typeOfDetail == (int) search)
        [CommonFunctions pushViewController:self.navigationController ViewController:objVODSearchViewController];
    else if(_typeOfDetail == (int) home)
        [CommonFunctions pushViewController:self.navigationController ViewController:objVODHomeViewController];
    else if( _typeOfDetail == (int) watchlist)
        [CommonFunctions pushViewController:self.navigationController ViewController:objVODWatchListViewController];
    else if(_typeOfDetail == (int) series){
        
        if (isFromCollection)
            [CommonFunctions pushViewController:self.navigationController ViewController:objCollectionsViewController];
        else if (isFromSearch)
            [CommonFunctions pushViewController:self.navigationController ViewController:objVODSearchViewController];
        else
            [CommonFunctions pushViewController:self.navigationController ViewController:objSeriesViewController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) settingsBarButtonItemAction
{
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}


#pragma mark - User Defined Methods
- (void)setSegmentedControlAppreance
{
    [segmentControl setBackgroundImage:[UIImage imageNamed:kSegmentBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //Set segment control height.
    CGRect frame = segmentControl.frame;
    [segmentControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kSegmentControlHeight)];
    
    UIFont *fontBold = [UIFont fontWithName:kProximaNova_Bold size:12.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:fontBold,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentControl setTitleTextAttributes:attributes
                                  forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:fontBold,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentControl setTitleTextAttributes:selectionAttributes
                                  forState:UIControlStateSelected];
}


#pragma mark - setFonts
-(void) setFonts
{
    [lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:16.0]];
    [lblMovieDuration setFont:[UIFont fontWithName:kProximaNova_Regular size:12.0]];
    [lblMovieDurationMiddle setFont:[UIFont fontWithName:kProximaNova_Regular size:12.0]];
    [lblMovieDurationRight setFont:[UIFont fontWithName:kProximaNova_Regular size:12.0]];
    [lblMovie setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
}

#pragma mark - Segment index changed

- (IBAction)segmentIndexChanged:(id)sender
{
    if (videoType == 1)
    {
        btnRelated.hidden = YES;
        switch (segmentControl.selectedSegmentIndex)
        {
            case 0:
            {
                break;
            }
            case 1:
            {
                if ([strMovieUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                    segmentControl.selectedSegmentIndex = 0;
                }
                else
                {
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                        
                        [self openActionSheetView];
                    }
                    else{
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share with" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"" otherButtonTitles:@"", @"", @"", nil];
                        
                        [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
                        
                        [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"twitter_icon"] forState:UIControlStateNormal];
                        
                        [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImage imageNamed:@"whatsapp"] forState:UIControlStateNormal];
                        
                        [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:3] setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
                        
                        [actionSheet showInView:self.view];
                    }
                }
                break;
            }
            default:
                break;

        }
    }
    else
    {
        switch (segmentControl.selectedSegmentIndex)
        {
            case 0:
            {
                [tblCastAndCrew reloadData];
                break;
            }
            case 1:
            {
                [tblCastAndCrew reloadData];
                break;
            }
            case 2:
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    
                    [self openActionSheetView];
                }
                else{
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share with" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"" otherButtonTitles:@"", @"", @"", nil];
                    
                    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
                    
                    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"twitter_icon"] forState:UIControlStateNormal];
                    
                    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImage imageNamed:@"whatsapp"] forState:UIControlStateNormal];
                    
                    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:3] setImage:[UIImage imageNamed:@"email"] forState:UIControlStateNormal];
                    
                    [actionSheet showInView:self.view];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

- (IBAction)btnRelated:(id)sender
{
    segmentControl.selectedSegmentIndex = 1;
    
    if (videoType == 2) {
        
        if (_strSingerId == nil) {
            
            [NSIUtility showAlertView:nil message:@"No singer available for this video"];
            
            return;
        }
        RelatedSingerViewController *objRelatedSingerViewController = [[RelatedSingerViewController alloc] init];
        objRelatedSingerViewController.delegate = self;
        objRelatedSingerViewController.singerId = _strSingerId;
        [self.navigationController pushViewController:objRelatedSingerViewController animated:YES];
    }
    else if (_typeOfDetail == (int)series  || relatedCheckFromWatchList || videoType == 3)
    {
        if (segmentControl.selectedSegmentIndex==1) {
            [self setRelatedData];
        }
    }
}

- (void)setRelatedData
{
  //  selectedEpisodeIndex++;
    _arrEpisodes = [[NSArray alloc] initWithArray:self.arrAllEpisodes];
    if (selectedEpisodeIndex > [_arrEpisodes count]-1) {
//        [NSIUtility showAlertView:nil message:@"No related episode"];
//        return;
    }
    
    NSMutableArray *arrEpisodes1 = [[NSMutableArray alloc] init];
    if (selectedEpisodeIndex==0 && [_arrEpisodes count]>=1) {
        
        if ([_arrEpisodes count]==1 && segmentControl.selectedSegmentIndex==1) {
        }
        if ([_arrEpisodes count]==1) {
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No related episode" value:@"" table:nil]];
            return;
        }
        else
            [arrEpisodes1 addObject:[_arrEpisodes objectAtIndex:selectedEpisodeIndex
                                +1]];
    }
    else if (selectedEpisodeIndex!=0 && [_arrEpisodes count]>selectedEpisodeIndex+1)
    {
        [arrEpisodes1 addObject:[_arrEpisodes objectAtIndex:selectedEpisodeIndex-1]];
        [arrEpisodes1 addObject:[_arrEpisodes objectAtIndex:selectedEpisodeIndex+1]];
    }
    else if (selectedEpisodeIndex==[_arrEpisodes count]-1)
    {
        [arrEpisodes1 addObject:[_arrEpisodes objectAtIndex:selectedEpisodeIndex-1]];
    }
    
    if ([arrEpisodes1 count]!=0) {
        _arrEpisodes = [[NSArray alloc] initWithArray:arrEpisodes1];
        [tblCastAndCrew reloadData];
    }
}

- (void)setRelatedDataOnRelatedAction:(int)indexPathRow
{
    Episode *objEpisode = (Episode*) [_arrEpisodes objectAtIndex:indexPathRow];
    
    _movieId = objEpisode.seriesID;
    self.strEpisodeId = objEpisode.episodeId;
    
    [lblMovieDurationRight setText:objEpisode.episodeDuration];
    strMovieUrl = objEpisode.episodeUrl;
    
    self.strThumnailUrl = [NSString stringWithFormat:@"%@", objEpisode.episodeThumb];

    [_imgMovieName sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:[UIImage imageNamed:@""]];
    
    CGRect lblMovieDurationRightFrame = lblMovieDurationRight.frame;
    lblMovieDurationRightFrame.origin.y = 30;
    lblMovieDurationRight.frame = lblMovieDurationRightFrame;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
    {
        NSString *lblText = [objEpisode.episodeDuration length]>0?[NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objEpisode.episodeDuration]:@"";
        NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lblText fontName:kProximaNova_Regular];
        
        lblMovieDurationRight.attributedText = strAtt;
    }
    else
        lblMovieDurationRight.text = [objEpisode.episodeDuration length]>0?[NSString stringWithFormat:@"%@ : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objEpisode.episodeDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
    
    //lblMovieDurationRight.text = [objEpisode.episodeDuration length]>0?[NSString stringWithFormat:@"%@ %@", objEpisode.episodeDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:@"";
    
    if ([objEpisode.episodeDesc_en length] != 0) {
        description = objEpisode.episodeDesc_en;
    }
    
    lblMovieDuration.text = [NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objEpisode.episodeNum,[CommonFunctions isEnglish]? objEpisode.episodeName_en: objEpisode.episodeName_ar];
    
    if([CommonFunctions userLoggedIn])
    {
        // [self saveToLastViewed];
    }
    
    [tblCastAndCrew reloadData];
}

- (void)fetchMovieDetailFromRelatedSinger:(NSString*)movieId
{
    _movieId = movieId;
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

#pragma mark - Add to watchlist Action
-(IBAction)addToWatchList_Clicked:(id)sender
{
    if(![self checkUserAccessToken])
        [self showLoginScreen];
    else
    {
        NSDictionary *dict;
        if (_typeOfDetail == (int)series)
            
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], strEpisodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        else
        {
            if (videoType == 3)
                dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], strEpisodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
            else
                dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], _movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToWatchList:self selector:@selector(saveWatchListServerResponse:) parameter:dict];
    }
}

#pragma Add to Watchlist
-(void) addToWatchlist
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], _movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    [objWatchListMovies saveMovieToWatchList:self selector:@selector(saveWatchListServerResponse:) parameter:dict];
}

- (void)showLoginScreen
{
    if (objLoginViewController.view.superview)
    {
        return;
    }
    
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

#pragma mark - save to last viewed
-(void) saveToLastViewed
{
    if([CommonFunctions userLoggedIn])
    {
        //Save to last viewed
        NSDictionary *dict;
        @try
        {
            NSString *movieIDForLastViewed = _movieId;
            if (_typeOfDetail == (int) series || _isSeries)
                movieIDForLastViewed = strEpisodeId;
            
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], movieIDForLastViewed, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        @catch (NSException *exception)
        {
        }
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
}

- (void)saveEpisodeToLastViewed
{
    if([CommonFunctions userLoggedIn])
    {
        //Save to last viewed
        NSDictionary *dict;
        @try
        {
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], strEpisodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        @catch (NSException *exception)
        {
        }
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
        // btnPlay.hidden = YES;
    }
}

#pragma mark - To check if user is logged in
- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

#pragma mark - Play clicked

-(IBAction)playClicked:(id)sender
{
//    _discoveryManager.devicePicker.delegate = self;
//    [_discoveryManager.devicePicker showPicker:sender];

    
    if(![CommonFunctions userLoggedIn])
    {
        loginCheck = 1;
        [self showLoginScreen];
    }
    else
    {
        [self playVideo];
    }
}

- (void)playVideo
{
    if ([self.strMovieUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(convertBCoveUrl:) withObject:self.strMovieUrl afterDelay:0.1];
    }
    else if ([self.strMovieUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSRange range = [self.strMovieUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [self.strMovieUrl length])];
        NSString *youtubeVideoId = [self.strMovieUrl substringFromIndex:range.location+1];
        [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:self.strMovieUrl];
        
        //Save to last viewed
        [self saveToLastViewed];
    }
    else
    {
        MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
        objMoviePlayerViewController.strVideoUrl = self.strMovieUrl;
        if (_typeOfDetail == (int) series || _isSeries)
            objMoviePlayerViewController.strVideoId = strEpisodeId;
        else
            objMoviePlayerViewController.strVideoId = _movieId;
        
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
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
    //Notifications to handle casting values.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    [youtubeMoviePlayer.moviePlayer stop];
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
    objCustomControls.strVideoName = lblMovieName.text;
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
    objCustomControls = [[CustomControls alloc] init];
    objCustomControls.strVideoUrl = strMP4VideoUrl;
    objCustomControls.strVideoName = lblMovieName.text;
    objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:mpMoviePlayerViewController.view moviePlayerViewController:mpMoviePlayerViewController]];
    
    [objCustomControls hideCastButton];
    self.isCastingButtonHide = YES;
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
    

    [self presentMoviePlayerViewControllerAnimated:mpMoviePlayerViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mpMoviePlayerViewController
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [self saveToLastViewed];
}

#pragma mark - MPMoviePlayerViewController Delegate

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];

    self.bIsLoad = YES;
    if ([objCustomControls castingDevicesCount]>0) {
        [objCustomControls unHideCastButton];
    }
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        //playing
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    {
        //stopped
    }
    
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    {
        //paused
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted)
    {
        //interrupted
    }
    
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
    {
        //seeking forward
    }
    if (mpMoviePlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
        //seeking backward
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
    [self dismissMoviePlayerViewControllerAnimated];
    mpMoviePlayerViewController = nil;
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

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (segmentControl.selectedSegmentIndex == 0) {
        return numberOfSections;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentControl.selectedSegmentIndex == 0) {
        
        UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
        float heightLbl;
        
        switch (indexPath.section)
        {
            case 0:
            {
                if (IS_IOS7_OR_LATER) {
                    
                    if ([description length] > 0)
                        heightLbl = [self getTextHeight:description AndFrame:CGRectMake(0, 0, 300, 40)];
                    else
                        return 0;
                }
                else
                {
                    CGSize size = [description sizeWithFont:font constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                    heightLbl = ceilf(size.height) + 40.0;
                }
                return MAX(heightLbl, 50.0);
            }
        }
        return 30;
    }
    else
        return 115;
}

- (void)btnPrevRelatedAction:(id)sender
{
    if (segmentControl.selectedSegmentIndex == 1) {
        
        Episode *objEpisode;
        for (int i = 0; i < [_arrEpisodes count]; i++) {
            objEpisode = (Episode*) [_arrEpisodes objectAtIndex:i];
            if ([objEpisode.episodeId isEqualToString:[NSString stringWithFormat:@"%d", (int)[sender tag]]]) {
                selectedEpisodeIndex = i;
                break;
            }
        }
        
        [self redirectToMovieDetailPage:[NSString stringWithFormat:@"%d", (int)[sender tag]] movieThumbnail:objEpisode.episodeThumb videoType:3 seriesId:objEpisode.seriesID seasonNumber:objEpisode.seasonNum];
    }
}

- (void)btnNextRelatedAction:(id)sender
{
    if (segmentControl.selectedSegmentIndex == 1) {
        Episode *objEpisode;
        for (int i = 0; i < [_arrEpisodes count]; i++) {
            objEpisode = (Episode*) [_arrEpisodes objectAtIndex:i];
            if ([objEpisode.episodeId isEqualToString:[NSString stringWithFormat:@"%d", (int)[sender tag]]]) {
                selectedEpisodeIndex = i;
                break;
            }
        }
        
        [self redirectToMovieDetailPage:[NSString stringWithFormat:@"%d", (int)[sender tag]] movieThumbnail:objEpisode.episodeThumb videoType:3 seriesId:objEpisode.seriesID seasonNumber:objEpisode.seasonNum];
    }
}

-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail videoType:(NSInteger)videoTypeId seriesId:(NSString*)seriesId seasonNumber:(NSString*)seasonNum
{   
    MoviesDetailViewController *objMoviesDetailViewController = [[MoviesDetailViewController alloc] init];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:100];
    [objMoviesDetailViewController setVideoType:(int)videoTypeId];
    if (videoTypeId == 3) {
        [objMoviesDetailViewController setMovieId:seriesId];
        objMoviesDetailViewController.isSeries = YES;
        objMoviesDetailViewController.strSeasonNum = seasonNum;
    }
    objMoviesDetailViewController.strEpisodeId = movieId;
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}


#pragma mark - UITableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (segmentControl.selectedSegmentIndex == 1 && videoType != 1) {
     
        cellIdentifier = @"relatedcell";
        RelatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell== nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RelatedTableViewCell" owner:self options:nil] firstObject];

        Episode *objEpisode = [_arrEpisodes objectAtIndex:indexPath.row];
        cell.btnPrev.tag = [objEpisode.episodeId integerValue];
        [cell setRelatedEpisodesPrev:objEpisode];

        if (indexPath.row<[_arrEpisodes count]-1) {
            Episode *objEpisode = [_arrEpisodes objectAtIndex:indexPath.row+1];
            cell.btnNext.tag = [objEpisode.episodeId integerValue];
            [cell setRelatedEpisodesNext:objEpisode];
        }
        
        
        [cell.btnPrev addTarget:self action:@selector(btnPrevRelatedAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnNext addTarget:self action:@selector(btnNextRelatedAction:) forControlEvents:UIControlEventTouchUpInside];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        if(indexPath.section == 0)
        {
            cellIdentifier = @"CastAndCrewDescriptionCellReuse";
            CastAndCrewDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil)
                cell = (CastAndCrewDescriptionCell *)[[[NSBundle mainBundle] loadNibNamed:@"CastAndCrewDescriptionCell" owner:self options:nil] firstObject];
            
            cell.lblDescription.frame = CGRectMake(0, 0, 300, 40);
            float lblHeight = 0.0;
            if ([description length] > 0) {
                lblHeight = [self getTextHeight:description AndFrame:cell.lblDescription.frame];
            }
            cell.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.lblDescription setFrame:CGRectMake(0, 0, 300, lblHeight)];
            cell.lblDescription.numberOfLines = lblHeight/15.0;
            [cell.lblDescription setFont:[UIFont fontWithName:kProximaNova_Regular size:15.0]];
            cell.lblDescription.text = description;
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
        }
        else
        {
            NSString *name;
            NSString *role;
            cellIdentifier = @"CastAndCrewDescriptionCellForArtistReuse";
            CastAndCrewDescriptionCellForArtists *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(cell == nil)
                cell = (CastAndCrewDescriptionCellForArtists *)[[[NSBundle mainBundle] loadNibNamed:@"CastAndCrewDescriptionCellForArtists" owner:self options:nil] firstObject];
            
            DetailArtist *objDetailArtist;
            objDetailArtist = (indexPath.section == 1)?([arrCastAndCrew count]>0?[arrCastAndCrew objectAtIndex:indexPath.row]:nil):([arrProducers count]>0?[arrProducers objectAtIndex:indexPath.row]:nil);
            name = [CommonFunctions isEnglish]?objDetailArtist.artistName_en:objDetailArtist.artistName_ar;
            role = [CommonFunctions isEnglish]?objDetailArtist.artistRole_en:objDetailArtist.artistRole_ar;
            cell.lblName.text = name;
            cell.lblRole.text = role;
            
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (float) getTextHeight:(NSString*)str AndFrame:(CGRect)frame
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    CGFloat heightLbl;
    if (IS_IOS7_OR_LATER) {
        
        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)
                                        options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
        
        frame.size.height = ceilf(CGRectGetHeight(rect));
        heightLbl = ceilf(frame.size.height+20);
        
    } else {
        CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        heightLbl = ceilf(size.height) + 50;
    }
    return MAX(heightLbl, 50.0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 0) {
        
        switch (section)
        {
            case 0:
                if ([description length]!=0)
                    return 1;
                break;
                
            case 1:
                return [arrCastAndCrew count];
                break;
                
            case 2:
                return [arrProducers count];
                break;
        }
    }
    return [_arrEpisodes count]>0?1:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 0) {
        
        NSString *titleheader;
        UIView *vw;
        UILabel *lbl;
        switch (section)
        {
            case 0:
            {
                vw = [[UIView alloc] initWithFrame:CGRectMake(tblCastAndCrew.frame.origin.x, 0, tblCastAndCrew.frame.size.width, 0)];
                return vw;
            }
            case 1:
                if([arrCastAndCrew count] == 0)
                    goto CASE2;
                titleheader = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"cast and crewiPhone" value:@"" table:nil];
                goto DEFAULTCASE;
            CASE2:
            case 2:
                titleheader = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"producers" value:@"" table:nil];
                goto DEFAULTCASE;
                
            DEFAULTCASE:
            default:
                vw = [[UIView alloc] initWithFrame:CGRectMake(tblCastAndCrew.frame.origin.x, 0, tblCastAndCrew.frame.size.width, 35)];
                CGSize size = [titleheader sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:18.0]];
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, size.width, 30)];
                [lbl setTextColor:[UIColor whiteColor]];
                [lbl setTextAlignment:NSTextAlignmentLeft];
                [lbl setFont:[UIFont fontWithName:kProximaNova_Bold size:18.0]];
                [lbl setBackgroundColor:[UIColor clearColor]];
                [lbl setText:titleheader];
                [vw addSubview:lbl];
                return vw;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 0) {
        
        switch (section)
        {
            case 0:
            {
                return 0.001f;
            }
            case 1:
                return 35;
            case 2:
                return 35;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - MFMailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"posted successfully" value:@"" table:nil]];
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIAlertSheet Delegate

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
    
    segmentControl.selectedSegmentIndex = 0;
}

- (IBAction)btnFacebookShare:(id)sender
{
    [self closeActionSheetView];
    [self shareOnFacebook];
}

- (IBAction)btnTwitterShare:(id)sender
{
    [self closeActionSheetView];
    [self shareOnTwitter];
}

- (IBAction)btnCloseActionSheet:(id)sender
{
    [self closeActionSheetView];
}

- (IBAction) btnWhatsappActionSheet
{
    [self closeActionSheetView];
    [self shareOnWhatsapp];
}

- (IBAction) btnmailActionSheet:(id)sender
{
    [self closeActionSheetView];
    [self showMailComposer];
}

- (void)closeActionSheetView
{
    [UIView animateWithDuration:0.5 animations:^{
        [vWActionSheetView setFrame:CGRectMake(0, self.view.frame.size.height, vWActionSheetView.frame.size.width, vWActionSheetView.frame.size.height)];
    } completion:^(BOOL finished) {
        [vWActionSheetView removeFromSuperview];
        [segmentControl setSelectedSegmentIndex:0];
    }];
}

- (void)openActionSheetView
{
    [vWActionSheetView setFrame:CGRectMake(0, self.view.frame.size.height, vWActionSheetView.frame.size.width, vWActionSheetView.frame.size.height)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:vWActionSheetView];
    
    [UIView animateWithDuration:0.5f animations:^{
        [vWActionSheetView setFrame:CGRectMake(0, self.view.frame.size.height - vWActionSheetView.frame.size.height, vWActionSheetView.frame.size.width, vWActionSheetView.frame.size.height)];
        
    } completion:nil];
}

- (NSString*)showPostedMessageFacebook
{
    return @"For more movies, series and music videos, download Melody Now app from Apple App Store or Google Play Store";
}

- (void)shareOnFacebook
{
    // If the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *par = [[FBShareDialogParams alloc] init];
    par.link = [NSURL URLWithString:strMovieUrl];
    par.picture = [NSURL URLWithString:self.strThumnailUrl];

    par.name = [NSString stringWithFormat:@"%@\n%@", self.strMovieNameToShareOnFacebook, self.strMovieUrl];
    if (videoType == 3) {
        par.name = [NSString stringWithFormat:@"\n%@ - %@\n%@", self.strSeriesNameToShareOnFacebook, self.strMovieNameToShareOnFacebook, self.strMovieUrl];
    }
    par.caption = self.strMovieUrl;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   par.name, @"name",
                                   @" ", @"caption",
                                   [self showPostedMessageFacebook], @"description",
                                   strMovieUrl, @"link",
                                   self.strThumnailUrl, @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
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
    //  }
}

- (void)shareOnTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString *strUrlToShare;
        strUrlToShare = [NSString stringWithFormat:@"%@\n%@\n%@", self.strMovieNameToShareOnFacebook, self.strMovieUrl, [CommonFunctions showPostedMessageTwitter]];
        if (videoType == 3) {
            strUrlToShare = [NSString stringWithFormat:@"%@ - %@\n%@\n%@", self.strSeriesNameToShareOnFacebook, self.strMovieNameToShareOnFacebook, self.strMovieUrl, [CommonFunctions showPostedMessageTwitter]];
        }
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:strUrlToShare];
        //   [tweetSheet addURL:[NSURL URLWithString:self.strMovieUrl]];
        
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

- (void)shareOnWhatsapp
{    
   // strMovieUrl = @"http://youtu.be/OiTiKOy59o4";
    
    NSString *strUrlToShare = self.strMovieUrl;
    
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
    
    NSString *strCaptionToShare = [NSString stringWithFormat:@"%@", self.strMovieNameToShareOnFacebook];
    if (videoType == 3) {
        strCaptionToShare = [NSString stringWithFormat:@"%@ - %@", self.strSeriesNameToShareOnFacebook, self.strMovieNameToShareOnFacebook];
    }

    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@\n\n%@\n%@", strCaptionToShare, strUrlToShare, [CommonFunctions showPostedMessageDownload]];
    urlWhats = [urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showMailComposer
{
     if ([MFMailComposeViewController canSendMail])
     {
         NSString *strUrlToShare = [NSString stringWithFormat:@"%@", self.strMovieNameToShareOnFacebook];
         if (videoType == 3) {
             strUrlToShare = [NSString stringWithFormat:@"%@ - %@", self.strSeriesNameToShareOnFacebook, self.strMovieNameToShareOnFacebook];
         }
        
         MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
         mail.mailComposeDelegate = self;
         [mail setSubject:[NSString stringWithFormat:@"%@", strUrlToShare]];
         
         [mail setMessageBody:[NSString stringWithFormat:@"%@<p><font size=\"2\" face=\"Helvetica\"><a href=%@>%@</a></font></p>%@", strUrlToShare, self.strMovieUrl, self.strMovieUrl, [CommonFunctions showPostedMessageDownload]] isHTML:YES];
         
         [self presentViewController:mail animated:YES completion:^{
         }];
     }
     else
     {
     }
}


#pragma mark - iAd Banner Delegate Methods
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

#pragma mark - Memory Management Method

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end