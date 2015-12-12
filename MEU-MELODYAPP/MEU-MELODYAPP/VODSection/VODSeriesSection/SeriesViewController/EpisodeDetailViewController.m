//
//  EpisodeDetailViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "EpisodeDetailViewController.h"
#import "LoginViewController.h"
#import "WatchListMovies.h"
#import "AppDelegate.h"
#import "Episodes.h"
#import "Episode.h"
#import "CommonFunctions.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerViewController.h"
#import "MovieDetailViewController.h"
#import "SeriesDetail.h"
#import "VideoDetail.h"
#import <QuartzCore/QuartzCore.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface EpisodeDetailViewController () <UpdateMovieDetailOnLoginDelegate, UIGestureRecognizerDelegate>
{
    BOOL                    isMoreSelected;
    IBOutlet UILabel*       lblEpisodeName;
    IBOutlet UILabel*       lblSeriesName;
    IBOutlet UITextView*    txtVwDesc;
    IBOutlet UILabel*       lblDuration;
    IBOutlet UILabel*       lblSeason;
    IBOutlet UIButton*      btnMoreInfo;
    IBOutlet UIButton*      btnAddToWatchList;
    IBOutlet UIImageView*   imgVwBackground;
    IBOutlet UIView*        vWEpisodeDetail;
    IBOutlet UIButton*      btnPlay;
    IBOutlet UIImageView*   imgVwEpisodeThumb;
    LoginViewController*    objLoginViewController;
    BOOL                    isMoreInfo;
    BOOL                    isExistInWatchList;
    CustomControls*         objCustomControls;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*     singleTapGestureRecognizer;
}

@property (strong, nonatomic) NSString*         strSeriesId;
@property (strong, nonatomic) NSDictionary*     dictMoreInfo;
@property (strong, nonatomic) NSString*         strVideoUrl;
@property (strong, nonatomic) NSString*         strEpisodeDuration;
@property (strong, nonatomic) NSString*         movieIdForPlayer;
@property (assign, nonatomic) BOOL              isForWatchlist;
@property (assign, nonatomic) BOOL              isCastingButtonHide;
@property (assign, nonatomic) BOOL              bIsLoad;

- (IBAction)btnCloseAction:(id)sender;
- (IBAction)btnAddToWatchList:(id)sender;
- (IBAction)btnMoreInfo:(id)sender;
- (IBAction)btnPlayAction:(id)sender;

@end

@implementation EpisodeDetailViewController

@synthesize dictEpisodeData;
@synthesize _imgViewBg;
@synthesize arrCastCrew, arrProducers;
@synthesize isFromVOD, episodeId;
@synthesize seriesIdFromVOD;
@synthesize isFromVODMovies;
@synthesize mpMoviePlayerViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    self.movieIdForPlayer = [[NSString alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WatchListButtonUpdateOnSeriesDetail:) name:@"EpisodeInWatchListFromSeriesDetail" object:nil];
    
    if (isFromVODMovies == YES) {
        self.movieIdForPlayer = episodeId;
        VideoDetail *objVideoDetail = [VideoDetail new];
        [objVideoDetail fetchVideoDetail:self selector:@selector(movieDetailResponse:) parameter:episodeId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    }
    else if (isFromVOD == YES) {
        
        self.movieIdForPlayer = episodeId;
        [self setUI];
        VideoDetail *objVideoDetail = [VideoDetail new];
        [objVideoDetail fetchVideoDetail:self selector:@selector(movieDetailResponse:) parameter:episodeId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    }
    else
    {
        [self setUI];
        if (self.seriesIdFromVOD != nil)
        {
            self.movieIdForPlayer = episodeId;
            VideoDetail *objVideoDetail = [VideoDetail new];
            [objVideoDetail fetchVideoDetail:self selector:@selector(videoDetailServerResponse:) parameter:episodeId UserID:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
        }
        else{
            if ([[dictEpisodeData objectForKey:@"isExistsInWatchList"] boolValue] == 1) {
                btnAddToWatchList.enabled = NO;
            }
            self.movieIdForPlayer = [dictEpisodeData objectForKey:@"episodeId"];
            SeriesDetail *objSeriesDetail = [SeriesDetail new];
            [objSeriesDetail fetchSeriesDetail:self selector:@selector(seriesDetailServerResponse:) parameter:[dictEpisodeData objectForKey:@"seriesId"]];
        }
    }
    [self setLocalizeText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//        [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 15]];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-15 delegate:self]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabbarNoti" object:nil];
    
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)showEpisodeControllerAnimated:(UIView*)objEpisodeDetailView
{
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnhideTabbarNoti" object:nil];
    
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)WatchListButtonUpdateOnSeriesDetail:(NSNotification*)notif
{
    btnAddToWatchList.enabled = NO;
    [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
}

#pragma mark - Server Response

- (void)movieDetailResponse:(VideoDetail*)objVideoDetail
{
    self.strVideoUrl = [NSString stringWithFormat:@"%@", objVideoDetail.movieUrl];
    CGRect txtVwFrame = txtVwDesc.frame;
    txtVwFrame.origin.y = txtVwDesc.frame.origin.y-40;
    txtVwFrame.size.height = txtVwDesc.frame.size.height+40;
    txtVwDesc.frame = txtVwFrame;
    
    [imgVwEpisodeThumb sd_setImageWithURL:[NSURL URLWithString:objVideoDetail.movieThumbnail]];
    if (objVideoDetail.existsInWatchlist == 1)
    {
        isExistInWatchList = YES;
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
    }
    [imgVwBackground setImage:_imgViewBg];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblSeriesName.text = [objVideoDetail.movieTitle_en length]>0?[objVideoDetail.movieTitle_en uppercaseString]:@"";
    else
        lblSeriesName.text = [objVideoDetail.movieTitle_ar length]>0?[objVideoDetail.movieTitle_ar uppercaseString]:@"";

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        txtVwDesc.text = objVideoDetail.movieDesc_en;
    else
        txtVwDesc.text = objVideoDetail.movieDesc_ar;

    lblSeason.textColor = YELLOW_COLOR;
    
    if ([objVideoDetail.movieDuration length] > 0)
    {
        self.strEpisodeDuration = [NSString stringWithFormat:@"%@", objVideoDetail.movieDuration];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            
            lblDuration.text = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objVideoDetail.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        else
        {
           // NSString *lbltext = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDuration];
            
            NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];
            NSMutableAttributedString *lbltextRuntime = [[NSMutableAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil]];
            
            NSString *lbltext = [NSString stringWithFormat:@" : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.movieDuration];
            
            [lbltextMu appendAttributedString:lbltextRuntime];
            [lbltextMu appendAttributedString:[CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular]];
            lblDuration.attributedText = lbltextMu;
            
//            lblDuration.attributedText = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
        }
    }
    else
        lblDuration.text = @"";
}

- (void)videoDetailServerResponse:(VideoDetail*)objVideoDetail
{
    [imgVwEpisodeThumb sd_setImageWithURL:[NSURL URLWithString:objVideoDetail.movieThumbnail]];
    if (objVideoDetail.existsInWatchlist == 1)
    {
        isExistInWatchList = YES;
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
    }
    [imgVwBackground setImage:_imgViewBg];
    
   /* btnMoreInfo.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    btnAddToWatchList.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblSeriesName.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblSeason.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    txtVwDesc.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    lblDuration.font = [UIFont fontWithName:kProximaNova_Regular size:14.0];
    lblEpisodeName.font = [UIFont fontWithName:kProximaNova_Regular size:14.0]; */
    
    lblSeriesName.text = [objVideoDetail.seriesName length]>0?[objVideoDetail.seriesName uppercaseString]:@"";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblEpisodeName.text = objVideoDetail.movieTitle_en;
    else
        lblEpisodeName.text = objVideoDetail.movieTitle_ar;
    
    if ([objVideoDetail.movieDesc_en length] == 0)
    {
        txtVwDesc.text = [dictEpisodeData objectForKey:@"seriesDesc"];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            txtVwDesc.text = objVideoDetail.movieDesc_en;
        else
            txtVwDesc.text = objVideoDetail.movieDesc_ar;
    }
    
    if ([[dictEpisodeData objectForKey:@"seriesSeasonCount"] integerValue] > 1)
        
        lblSeason.text = [NSString stringWithFormat:@"%@ %@ | %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objVideoDetail.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [objVideoDetail.episodeNum length]>0?objVideoDetail.episodeNum:@""];
    else
        
        lblSeason.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [objVideoDetail.episodeNum length]>0?objVideoDetail.episodeNum:@""];
    
    lblSeason.textColor = YELLOW_COLOR;
    
    if ([objVideoDetail.duration length] > 0)
    {
        self.strEpisodeDuration = [NSString stringWithFormat:@"%@", objVideoDetail.movieDuration];

        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            
            lblDuration.text = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], objVideoDetail.duration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        else
        {
//            NSString *lbltext = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.duration];
//            
//            lblDuration.attributedText = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
            NSMutableAttributedString *lbltextMu = [[NSMutableAttributedString alloc] init];
            NSMutableAttributedString *lbltextRuntime = [[NSMutableAttributedString alloc] initWithString:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil]];
            
            NSString *lbltext = [NSString stringWithFormat:@" : %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objVideoDetail.duration];
            
            [lbltextMu appendAttributedString:lbltextRuntime];
            [lbltextMu appendAttributedString:[CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular]];
            
            lblDuration.attributedText = lbltextMu;
        }
    }
    else
        lblDuration.text = @"";
    
    //Call series detail webservice.
    if (seriesIdFromVOD != nil)
    {
        SeriesDetail *objSeriesDetail = [SeriesDetail new];
        [objSeriesDetail fetchSeriesDetail:self selector:@selector(seriesDetailServerResponse:) parameter:seriesIdFromVOD];
        
        //For more info
        NSString *episodeName;
        NSString *episodeDesc;
        NSString *seriesName;
        NSString *seriesDesc;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            episodeName = objVideoDetail.movieTitle_en;
            episodeDesc = objVideoDetail.movieDesc_en;
            seriesName = objVideoDetail.seriesName;
            seriesDesc = objVideoDetail.seriesDesc;
        }
        else
        {
            episodeName = objVideoDetail.movieTitle_ar;
            episodeDesc = objVideoDetail.movieDesc_ar;
            seriesName = objVideoDetail.seriesName;
            seriesDesc = objVideoDetail.seriesDesc;
        }
        if ([seriesDesc length] == 0) {
            seriesDesc = @"";
        }
        if ([episodeName length] == 0) {
            episodeName = @"";
        }
        if ([seriesName length] == 0) {
            seriesName = @"";
        }
        if ([episodeDesc length] == 0) {
            episodeDesc = @"";
        }
        
        self.dictMoreInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[objVideoDetail.movieUrl length]>0?objVideoDetail.movieUrl:@"", episodeName, episodeDesc, objVideoDetail.seasonNum, objVideoDetail.episodeNum,[NSString stringWithFormat:@"%d", objVideoDetail.existsInWatchlist], episodeId, self.seriesIdFromVOD, objVideoDetail.duration, seriesName, seriesDesc, objVideoDetail.movieThumbnail,  [NSString stringWithFormat:@"%@", objVideoDetail.seriesSeasonCount], nil] forKeys:[NSArray arrayWithObjects:@"url", @"episodeName", @"episodeDesc", @"seasonNum", @"episodeNum", @"isExistsInWatchList", @"episodeId", @"seriesId", @"duration", @"seriesName", @"seriesDesc", @"episodethumb", @"seriesSeasonCount", nil]];
    }
}

- (void)seriesDetailServerResponse:(SeriesDetail*)objSeriesDetail
{
    self.strSeriesId = objSeriesDetail.seriesId;
    if ([[dictEpisodeData objectForKey:@"episodeDesc"] length]==0)
        txtVwDesc.text = objSeriesDetail.seriesDesc;
}

- (void)setLocalizeText
{
    [btnMoreInfo setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"more info" value:@"" table:nil] forState:UIControlStateNormal];
    [btnAddToWatchList setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"add to watchlist" value:@"" table:nil] forState:UIControlStateNormal];
}

- (void)setUI
{    
    [imgVwEpisodeThumb sd_setImageWithURL:[NSURL URLWithString:[dictEpisodeData objectForKey:@"episodethumb"]]];
    if ([[dictEpisodeData objectForKey:@"isExistsInWatchList"] boolValue] == 1)
    {
        isExistInWatchList = YES;
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
    }
    [imgVwBackground setImage:_imgViewBg];

    btnMoreInfo.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    btnAddToWatchList.titleLabel.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblSeriesName.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblSeason.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    txtVwDesc.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    lblDuration.font = [UIFont fontWithName:kProximaNova_Regular size:14.0];
    lblEpisodeName.font = [UIFont fontWithName:kProximaNova_Regular size:14.0];

    lblSeriesName.text = [dictEpisodeData objectForKey:@"seriesName"]>0?[[dictEpisodeData objectForKey:@"seriesName"] uppercaseString]:@"";
    lblEpisodeName.text = [dictEpisodeData objectForKey:@"episodeName"];

    if ([[dictEpisodeData objectForKey:@"episodeDesc"] length]==0)
        txtVwDesc.text = [dictEpisodeData objectForKey:@"seriesDesc"];
    else
        txtVwDesc.text = [dictEpisodeData objectForKey:@"episodeDesc"];
    
    if ([[dictEpisodeData objectForKey:@"seriesSeasonCount"] integerValue] > 1)
    {
        if ([[[dictEpisodeData objectForKey:@"episodeNum"] stringValue] length]>0)
            
            lblSeason.text = [NSString stringWithFormat:@"%@ %@ | %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], [dictEpisodeData objectForKey:@"seasonNum"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [[[dictEpisodeData objectForKey:@"episodeNum"] stringValue] length]>0?[dictEpisodeData objectForKey:@"episodeNum"]:@""];
    }
    else
    {
        if ([[[dictEpisodeData objectForKey:@"episodeNum"] stringValue] length]>0)

            lblSeason.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [[[dictEpisodeData objectForKey:@"episodeNum"] stringValue] length]>0?[dictEpisodeData objectForKey:@"episodeNum"]:@""];
    }
    
    lblSeason.textColor = YELLOW_COLOR;
    
    if ([[dictEpisodeData objectForKey:@"duration"] length] > 0)
    {
        self.strEpisodeDuration = [NSString stringWithFormat:@"%@", [dictEpisodeData objectForKey:@"duration"]];

        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

            lblDuration.text = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [dictEpisodeData objectForKey:@"duration"],  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
        else
        {
            NSString *lbltext = [NSString stringWithFormat:@"%@: %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"runtime" value:@"" table:nil], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], [dictEpisodeData objectForKey:@"duration"]];
        
            lblDuration.attributedText = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
        }
    }
    else
        lblDuration.text = @"";
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark - IBAction Methods

- (IBAction)btnAddToWatchList:(id)sender
{
    self.isForWatchlist = YES;
    if (![self checkUserAccessToken]) {
        
        [self showLoginScreen];
    }
    else{
        
        NSDictionary *dict;
        if (isFromVOD == YES) {
            
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], self.movieIdForPlayer, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        else if (isFromVODMovies == YES) {
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], self.movieIdForPlayer, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        else
        {
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:kUserIDKey], self.movieIdForPlayer, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        }
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToWatchList:self selector:@selector(saveWatchListServerResponse:) parameter:dict];
    }
}

- (IBAction)btnMoreInfo:(id)sender
{
    MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
    
    if (isFromVOD == YES) {
        
        if (self.seriesIdFromVOD != nil) {
            if ([[dictEpisodeData objectForKey:@"seriesSeasonCount"] integerValue] > 1)
                
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - Sn %@ - %@ %@", [self.dictMoreInfo objectForKey:@"seriesName"], [self.dictMoreInfo objectForKey:@"seasonNum"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [self.dictMoreInfo objectForKey:@"episodeNum"]];
            else
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - %@ %@", [self.dictMoreInfo objectForKey:@"seriesName"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [self.dictMoreInfo  objectForKey:@"episodeNum"]];
            
            objMovieDetailViewController.strVideoUrl = [self.dictMoreInfo  objectForKey:@"url"];
            objMovieDetailViewController.strSeriesImageUrl = [self.dictMoreInfo  objectForKey:@"episodethumb"];
            objMovieDetailViewController.isSeries = YES;
            
            objMovieDetailViewController.strMovieId = self.seriesIdFromVOD;
            objMovieDetailViewController.strEpisodeId = [self.dictMoreInfo  objectForKey:@"episodeId"];
            objMovieDetailViewController.isEpisodeInWatchList = isExistInWatchList;
            
            //
            objMovieDetailViewController.strEpisodeNum = [self.dictMoreInfo  objectForKey:@"episodeNum"];
            objMovieDetailViewController.strEpisodeDuration = self.strEpisodeDuration;
        }
        else
        {
            objMovieDetailViewController.strMovieId = self.episodeId;
        }
    }
    else if (isFromVODMovies == YES)
    {
        objMovieDetailViewController.strMovieId = self.episodeId;
    }
    else
    {
        if (self.seriesIdFromVOD != nil) {
            if ([[dictEpisodeData objectForKey:@"seriesSeasonCount"] integerValue] > 1)
                
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - Sn %@ - %@ %@", [self.dictMoreInfo objectForKey:@"seriesName"], [self.dictMoreInfo objectForKey:@"seasonNum"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [self.dictMoreInfo objectForKey:@"episodeNum"]];
            else
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - %@ %@", [self.dictMoreInfo objectForKey:@"seriesName"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [self.dictMoreInfo  objectForKey:@"episodeNum"]];
            
            objMovieDetailViewController.strVideoUrl = [self.dictMoreInfo  objectForKey:@"url"];
            objMovieDetailViewController.strSeriesImageUrl = [self.dictMoreInfo  objectForKey:@"episodethumb"];
            objMovieDetailViewController.isSeries = YES;
            
            objMovieDetailViewController.strMovieId = self.seriesIdFromVOD;
            objMovieDetailViewController.strEpisodeId = [self.dictMoreInfo  objectForKey:@"episodeId"];
            objMovieDetailViewController.isEpisodeInWatchList = isExistInWatchList;
            
            ///
            objMovieDetailViewController.strEpisodeNum = [self.dictMoreInfo  objectForKey:@"episodeNum"];
            objMovieDetailViewController.strEpisodeDuration = self.strEpisodeDuration;
        }
        
        else
        {
            if ([[dictEpisodeData objectForKey:@"seriesSeasonCount"] integerValue] > 1)
                
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - Sn %@ - %@ %@", [dictEpisodeData objectForKey:@"seriesName"], [dictEpisodeData objectForKey:@"seasonNum"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [dictEpisodeData objectForKey:@"episodeNum"]];
            else
                objMovieDetailViewController.strVideoTitle = [NSString stringWithFormat:@"%@ - %@ %@", [dictEpisodeData objectForKey:@"seriesName"], [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], [dictEpisodeData objectForKey:@"episodeNum"]];
            
            objMovieDetailViewController.strVideoUrl = [dictEpisodeData objectForKey:@"url"];
            objMovieDetailViewController.strSeriesImageUrl = [dictEpisodeData objectForKey:@"episodethumb"];
            objMovieDetailViewController.isSeries = YES;
            
            objMovieDetailViewController.strMovieId = self.strSeriesId;
            objMovieDetailViewController.strEpisodeId = [dictEpisodeData objectForKey:@"episodeId"];
            //objMovieDetailViewController.isEpisodeInWatchList = [[self.dictEpisodeData objectForKey:@"isExistsInWatchList"] boolValue];
            objMovieDetailViewController.isEpisodeInWatchList = isExistInWatchList;
            
            objMovieDetailViewController.strEpisodeNum = [dictEpisodeData objectForKey:@"episodeNum"];
            objMovieDetailViewController.strEpisodeDuration = self.strEpisodeDuration;
        }
    }
    [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
}

- (void)saveWatchListServerResponse:(NSDictionary*)dictResponse
{
    if ([[dictResponse objectForKey:@"Error"] intValue] == 0) {

        isExistInWatchList = YES;
        btnAddToWatchList.enabled = NO;
        [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];

        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.iWatchListCounter++;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWatchListMovieCounter" object:nil];
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
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

- (BOOL)checkUserAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey])
        return YES;
    else
        return NO;
}

- (void)saveEpisodeToLastViewed
{
    //Save to last viewed
    NSDictionary *dict;
    if (isFromVOD == YES) {
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], episodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    }
    else if (isFromVODMovies == YES)
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], episodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    else
    {
        if (self.seriesIdFromVOD != nil)
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], episodeId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        else
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], [dictEpisodeData objectForKey:@"episodeId"], nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    }
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
}

- (IBAction)btnPlayAction:(id)sender
{
    if (![self checkUserAccessToken]) {
        
        [self showLoginScreen];
    }
    else{
    
        [self playVideo];
    }
}

- (void)playVideo
{
    //Play in media player
    if ([self.strVideoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(convertBCoveUrl:) withObject:self.strVideoUrl afterDelay:0.1];
    }
    else if ([self.strVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSRange range = [self.strVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [self.strVideoUrl length])];
        NSString *youtubeVideoId = [self.strVideoUrl substringFromIndex:range.location+1];
        [self playYoutubeVideoPlayer:youtubeVideoId];
        //Save to last viewed
        [self saveEpisodeToLastViewed];
    }
    else //Play in Movieplayer viewcontroller
    {
        [self playVideoOnController];
        [self saveEpisodeToLastViewed];
    }
}

- (void)convertBCoveUrl:(id)object
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
}

- (void)playVideoOnController
{
    MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
    
    if (isFromVOD == YES) {
        objMoviePlayerViewController.strVideoUrl = self.strVideoUrl;
    }
    else if (isFromVODMovies == YES)
    {
        objMoviePlayerViewController.strVideoUrl = self.strVideoUrl;
    }
    else
        objMoviePlayerViewController.strVideoUrl = [dictEpisodeData objectForKey:@"url"];
    objMoviePlayerViewController.strVideoId = self.movieIdForPlayer;
    [self presentViewController:objMoviePlayerViewController animated:YES completion:nil];
}

#pragma mark - Youtube player
- (void)playYoutubeVideoPlayer:(NSString*)youtubeVideoId
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
    objCustomControls.strVideoUrl = self.strVideoUrl;
    objCustomControls.strYoutubeVideoUrl = self.strVideoUrl;
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
//    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
//    appDelegate.videoStartTime = youtubeMoviePlayer.moviePlayer.currentPlaybackTime;
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
    objCustomControls.strVideoName = lblSeriesName.text;
    objCustomControls.totalVideoDuration = youtubeMoviePlayer.moviePlayer.duration;
}

#pragma mark - Play movie in Media player
- (void)playInMediaPlayer:(NSString*)strMP4VideoUrl
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoWhileCasting) name:@"StopVideoWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchMediaPlayerCurrentPlayBackTimeWhileCasting) name:@"FetchMediaPlayerCurrentPlayBackTimeWhileCasting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlayCurrentPlayBackTimeOnPlayer) name:@"PlayCurrentPlayBackTimeOnPlayer" object:nil];

    self.mpMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:strMP4VideoUrl]];
    [self.mpMoviePlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [self.mpMoviePlayerViewController.moviePlayer setShouldAutoplay:YES];
    [self.mpMoviePlayerViewController.moviePlayer setFullscreen:YES animated:YES];
    self.mpMoviePlayerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;

    [self.mpMoviePlayerViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.mpMoviePlayerViewController.moviePlayer setScalingMode:MPMovieScalingModeNone];
    // Register to receive a notification when the movie has finished playing.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.mpMoviePlayerViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mpMoviePlayerViewController.moviePlayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    
    //Add Casting button
    objCustomControls = [CustomControls new];
    objCustomControls.strVideoUrl = strMP4VideoUrl;
    objCustomControls.strVideoName = lblSeriesName.text;
    objCustomControls.totalVideoDuration = self.mpMoviePlayerViewController.moviePlayer.duration;
    
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:self.mpMoviePlayerViewController.view moviePlayerViewController:self.mpMoviePlayerViewController]];
    
///
    [objCustomControls hideCastButton];
    self.isCastingButtonHide = YES;
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
    
    ///
    
    [self presentMoviePlayerViewControllerAnimated:self.mpMoviePlayerViewController];

    [self saveEpisodeToLastViewed];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.mpMoviePlayerViewController
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (void)playerLoadStateChanged:(NSNotification *)notification {
    
    [self performSelector:@selector(hideCastingButtonSyncWithPlayer) withObject:nil afterDelay:kAutoHideCastButtonTime];
    
    MPMovieLoadState loadState = self.mpMoviePlayerViewController.moviePlayer.loadState;
    
    if(loadState == MPMovieLoadStateUnknown)
    {
        [self.mpMoviePlayerViewController.moviePlayer play];
    }
}

- (void)hideCastingButtonSyncWithPlayer
{
    self.isCastingButtonHide = NO;
    [objCustomControls hideCastButton];
}

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

#pragma mark - Update Detail Movie after login

- (void)updateMovieDetailViewAfterLogin
{
    if (self.isForWatchlist == NO) {
        [self performSelector:@selector(playVideo) withObject:nil afterDelay:0.1];
    }

    Episodes *objEpisodes = [Episodes new];
    [objEpisodes fetchSeriesEpisodes:self selector:@selector(seriesEpisodesServerResponse:) parameter:[dictEpisodeData objectForKey:@"seriesId"] userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
}

- (void)seriesEpisodesServerResponse:(NSArray*)arrResponse
{
    for (int i=0; i < [arrResponse count]; i++) {
        Episode *objEpisode = (Episode*) [arrResponse objectAtIndex:i];
        
        if ([objEpisode.episodeId isEqualToString:[dictEpisodeData objectForKey:@"episodeId"]]) {
            
            isExistInWatchList = YES;
            btnAddToWatchList.enabled = NO;
            [btnAddToWatchList setBackgroundImage:[UIImage imageNamed:@"add_to_watchlist_disable"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)btnCloseAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UIGestureRecognizer Delegates
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
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 15]];
}

#pragma mark - Memory Management Methods
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end