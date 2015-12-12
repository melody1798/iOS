//
//  WatchListViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "WatchListViewController.h"
#import "WatchListMovies.h"
#import "WatchListCollectionViewCell.h"
#import "CustomControls.h"
#import "WatchListMovie.h"
#import "UIImageView+WebCache.h"
#import "LastViewedMovie.h"
#import "MovieDetailViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "SearchVideoViewController.h"
#import "NSIUtility.h"
#import "popoverBackgroundView.h"
#import "CommonFunctions.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "EpisodeDetailViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "MBProgressHUD.h"
#import "VODSearchController.h"
#import "MoviePlayerViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

@interface WatchListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DeleteWatchListDelegate, ChannelProgramPlay, UIPopoverControllerDelegate, UISearchBarDelegate, SettingsDelegate, LanguageSelectedDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UICollectionView*      collectionVwWatchList;
    IBOutlet UIView*                vWLastViewed;
    IBOutlet UIView*                vWWatchList;
    IBOutlet UILabel*               lblWatchListTitle;
    IBOutlet UILabel*               lblLastViewedText;
    IBOutlet UIImageView*           imgVwLastViewedThumb;
    IBOutlet UILabel*               lblLastViewedVideoTitle;
    IBOutlet UILabel*               lblLastViewedSingerTitle;
    IBOutlet UIImageView*           imgVwBackground;
    IBOutlet UILabel*               lblWatchListEmpty;
    BOOL                            isWatchListEditing;
    UIPopoverController*            popOverSearch;
    SearchVideoViewController*      objSearchVideoViewController;
    SettingViewController*          objSettingViewController;
    MPMoviePlayerViewController*    mpMoviePlayerViewController;
    XCDYouTubeVideoPlayerViewController *youtubeMoviePlayer;
    UITapGestureRecognizer*         singleTapGestureRecognizer;
    CustomControls*                 objCustomControls;
}

@property (strong, nonatomic) NSArray*      arrWatchList; //save watchlist data
@property (strong, nonatomic) NSString*     strLastViewedVideoId;   //to add video in lastviewed
@property (strong, nonatomic) NSString*     strLastViewedVideoUrl;  //to add video in lastviewed
@property (assign, nonatomic) NSInteger     strLastViewedVideoType; //to add video in lastviewed
@property (strong, nonatomic) UISearchBar*  searchBarVOD;
@property (strong, nonatomic) NSDictionary* dictLastResponse;       //Last viewed server response.
@property (assign, nonatomic) BOOL          isCastingButtonHide;    //flag to hide/show casting button.
@property (assign, nonatomic) BOOL          bIsLoad;
@property (strong, nonatomic) NSString*     strMovieNameOnCastingDevice; //send video name to casting device.

- (IBAction)playLastViewedVideo:(id)sender;

@end

@implementation WatchListViewController

@synthesize _imgViewBg;
@synthesize isFromHome;

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

    //Add iAd
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];

    [self setLocalizedText];    //Set localized data
    
    [imgVwBackground setImage:_imgViewBg];
    
    //Add obsrever to updatewtahclist button counter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];
    //Add obsrever to pop to VOD home from watchlist
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopViewToRootViewControllerFromWatchList) name:@"PopViewToRootViewControllerWatchListController" object:nil];

    [self setNavigationBarButton];

    lblWatchListTitle.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblLastViewedText.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblWatchListEmpty.font = [UIFont fontWithName:kProximaNova_Bold size:20.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)PopViewToRootViewControllerFromWatchList
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Watchlist"];
    
    [self registerCollectionViewCell];

    isWatchListEditing = NO;
    [collectionVwWatchList reloadData];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        lblWatchListEmpty.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"] forKey:@"userId"];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //Fetch watchlist
        [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
        //Fetch lastviewed
        LastViewedMovie *objLastViewedMovie = [LastViewedMovie new];
        [objLastViewedMovie fetchLastviewed:self selector:@selector(lastViewedServerResponse:) parameter:dict];
    }
}

- (void)setLocalizedText
{
    lblWatchListTitle.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil] uppercaseString];
    lblLastViewedText.text = [[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"last viewed" value:@"" table:nil] uppercaseString];
}

#pragma mark  - Navigation Bar buttons
- (void)setNavigationBarButton
{
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListEditNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
    if (isFromHome == YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigationbar buttons actions
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

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)watchListItemAction
{
    isWatchListEditing = !isWatchListEditing; //Flag to show/hide edit watchlist button

    self.navigationItem.leftBarButtonItems = nil;
    if (isWatchListEditing)
        self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListDoneNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];

    else
        self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListEditNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
    
    [collectionVwWatchList reloadData];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
}

#pragma mark - Settings Delegate

- (void)userSucessfullyLogout
{
    //After logout pop to live tv class.
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    [self setLocalizedText];
    [collectionVwWatchList reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListEditNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginScreen];
}


- (void)showLoginScreen
{
    
}

- (void)companyInfoSelected:(int)infoType
{
    //If terms and condition selected.
    [popOverSearch dismissPopoverAnimated:YES];
    CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] initWithNibName:@"CompanyInfoViewController" bundle:nil];
    objCompanyInfoViewController.iInfoType = infoType;
    [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
}

- (void)sendFeedback
{
    //If feedback selected.
    [popOverSearch dismissPopoverAnimated:YES];
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    //If FAQ selected.
    [popOverSearch dismissPopoverAnimated:YES];
    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQViewController animated:YES];
}

#pragma mark - Delete WatchList Delegate Method

- (void)deleteWatchListItem:(int)tag
{
    //WatchList/Delete
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], [NSString stringWithFormat:@"%d", tag], nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
    
    [objWatchListMovies deleteWatchListItem:self selector:@selector(watchListDeleteItemServerResponse:) parameter:dict];
    
    if ([[dict objectForKey:@"movieid"] isEqualToString:_strLastViewedVideoId]) {
        
        LastViewedMovie *objLastViewedMovie = [LastViewedMovie new];
        [objLastViewedMovie fetchLastviewed:self selector:@selector(lastViewedServerResponse:) parameter:dict];
    }
}

- (IBAction)playLastViewedVideo:(id)sender
{
    if ([[self.dictLastResponse objectForKey:@"seriesId"] length] != 0) {
        //Show episode view

        EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
        
        objEpisodeDetailViewController.dictEpisodeData = self.dictLastResponse;
        
        //Fetch and pass current view cgcontext for background display
        UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
        objEpisodeDetailViewController._imgViewBg = viewImage;
        
        [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
    }
    else{
        if (self.strLastViewedVideoType == 2) { //If video type is music
            
            self.strMovieNameOnCastingDevice = lblLastViewedVideoTitle.text;
            
            //Play in media player
            if ([self.strLastViewedVideoUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //Convert bcove url to mp4.
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self performSelector:@selector(convertBCoveUrl:) withObject:self.strLastViewedVideoUrl afterDelay:0.1];
            }
            else if ([self.strLastViewedVideoUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //fetch youtube video id
                NSRange range = [self.strLastViewedVideoUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [self.strLastViewedVideoUrl length])];
                NSString *youtubeVideoId = [self.strLastViewedVideoUrl substringFromIndex:range.location+1];
                [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:self.strLastViewedVideoUrl];
            }
            else //Play in Movieplayer viewcontroller
            {
                MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
                objMoviePlayerViewController.strVideoId = self.strLastViewedVideoId;
                objMoviePlayerViewController.strVideoUrl = self.strLastViewedVideoUrl;
                [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
            }
        }
        else
        {
            //Show episode overlay screen.
            EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
            objEpisodeDetailViewController.episodeId = self.strLastViewedVideoId;
            UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
            objEpisodeDetailViewController._imgViewBg = viewImage;
            objEpisodeDetailViewController.isFromVOD = YES;
            [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
        }
    }
}

#pragma mark - Server Response
- (void)lastViewedServerResponse:(LastViewedMovie*)objLastViewedMovie
{
    self.dictLastResponse = nil;
    
    lblLastViewedVideoTitle.textColor = YELLOW_COLOR;
    lblLastViewedVideoTitle.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblLastViewedText.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    lblLastViewedSingerTitle.font = [UIFont fontWithName:kProximaNova_Regular size:12.0];
    lblLastViewedSingerTitle.textColor = [UIColor whiteColor];

    if (objLastViewedMovie != nil) {
        if ([objLastViewedMovie.seriesID length] != 0) {
            
            NSString *seriesName;
            NSString *seriesDesc;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            {
                seriesName = objLastViewedMovie.seriesName_en;
                seriesDesc = objLastViewedMovie.seriesDesc_en;
            }
            else{
                seriesName = objLastViewedMovie.seriesDesc_en;
                seriesDesc = objLastViewedMovie.seriesDesc_ar;
            }
            self.dictLastResponse = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:objLastViewedMovie.movieUrl, objLastViewedMovie.movieName_en, @"", objLastViewedMovie.seasonNum, objLastViewedMovie.episodeNum, objLastViewedMovie.isExistsInWatchList, objLastViewedMovie.movieId, objLastViewedMovie.seriesID, objLastViewedMovie.episodeDuration, seriesName, seriesDesc, objLastViewedMovie.movieThumb, nil] forKeys:[NSArray arrayWithObjects:@"url", @"episodeName", @"episodeDesc", @"seasonNum", @"episodeNum", @"isExistsInWatchList", @"episodeId", @"seriesId", @"duration", @"seriesName", @"seriesDesc", @"episodethumb", nil]];
        }

        self.strLastViewedVideoId = [NSString stringWithFormat:@"%@", objLastViewedMovie.movieId];
        self.strLastViewedVideoUrl = [NSString stringWithFormat:@"%@", objLastViewedMovie.movieUrl];
        self.strLastViewedVideoType = objLastViewedMovie.videoType;
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.fImageWidth = imgVwLastViewedThumb.frame.size.width;
        appDelegate.fImageHeight = imgVwLastViewedThumb.frame.size.height;
        
        [imgVwLastViewedThumb sd_setImageWithURL:[NSURL URLWithString:objLastViewedMovie.movieThumb] placeholderImage:nil];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            lblLastViewedVideoTitle.text = objLastViewedMovie.movieName_en;
        }
        else        {
            lblLastViewedVideoTitle.text = objLastViewedMovie.movieName_ar;
        }

        if (objLastViewedMovie.videoType == 2) { //If music
            
            NSString *movieName = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objLastViewedMovie.movieName_en:objLastViewedMovie.movieName_ar;
            
            lblLastViewedVideoTitle.text = [NSString stringWithFormat:@"%@", movieName];
            
            BOOL isSinger;
            if ([objLastViewedMovie.singerName_en length]!=0 && [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
                
                isSinger = YES;
                lblLastViewedSingerTitle.text = objLastViewedMovie.singerName_en;
            }
            else            {
                isSinger = YES;
                lblLastViewedSingerTitle.text = objLastViewedMovie.singerName_ar;
            }
            
            if (isSinger) {
                lblLastViewedSingerTitle.hidden = NO;
                lblLastViewedVideoTitle.numberOfLines = 1;
            }
        }
        if (objLastViewedMovie.videoType == 3) { // if episode

            NSString *seriesEpiName = [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objLastViewedMovie.seriesName_en:objLastViewedMovie.seriesName_ar;
            
            lblLastViewedVideoTitle.text = [NSString stringWithFormat:@"%@", [seriesEpiName length]>22?[seriesEpiName substringToIndex:21]:seriesEpiName];
            lblLastViewedSingerTitle.hidden = NO;
            lblLastViewedSingerTitle.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objLastViewedMovie.episodeNum];
        }

        [self setLastViewedFrame]; //Set lastviewed view frame.
    }
    else{
        
        [vWLastViewed removeFromSuperview];
    }
}

- (void)setLastViewedFrame
{
    if IS_IOS7_OR_LATER
        [vWLastViewed setFrame:CGRectMake(0, 100, vWLastViewed.frame.size.width, vWLastViewed.frame.size.height)];
    else
        [vWLastViewed setFrame:CGRectMake(0, 20, vWLastViewed.frame.size.width, vWLastViewed.frame.size.height)];
    [self.view addSubview:vWLastViewed];
    
    CGRect vWWatchListFrame = vWWatchList.frame;
    vWWatchListFrame.origin.x = 200;
    vWWatchListFrame.size.width = 583;
    vWWatchList.frame = vWWatchListFrame;
    
    CGRect collectionVwWatchListFrame = collectionVwWatchList.frame;
    collectionVwWatchListFrame.origin.x = 0;
    collectionVwWatchListFrame.size.width = 583;
    collectionVwWatchList.frame = collectionVwWatchListFrame;
    
    [collectionVwWatchList reloadData];

}

- (void)watchListServerResponse:(NSArray*)arrResponse
{
    self.navigationItem.leftBarButtonItems = nil;
    [self setNavigationBarButton];
    
    lblWatchListEmpty.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist is empty" value:@"" table:nil];
    
    if ([arrResponse count] > 0) {
        vWWatchList.hidden = NO;
        lblWatchListEmpty.hidden = YES;
        
        self.arrWatchList = [NSArray arrayWithArray:arrResponse];
        
        //Reset Watchlist counter.
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.iWatchListCounter = (int)[arrResponse count];
        
        //Update Left bar button for watchlist
        self.navigationItem.leftBarButtonItems = nil;
        
        if (isWatchListEditing)
            self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListDoneNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
        else
            self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListEditNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWatchListMovieCounter" object:nil];
        
        //Reload watchlist data collection view.
        [collectionVwWatchList reloadData];
    }
    else{
        
        //Reset Watchlist counter.
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.iWatchListCounter = (int)[arrResponse count];
        
        //Update Left bar button for watchlist
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchListEditNavigationBarButton:@"watch_list_edit" Target:self selector:@selector(watchListItemAction)]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateWatchListMovieCounter" object:nil];
        
        vWWatchList.hidden = YES;
        lblWatchListEmpty.hidden = NO;
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark - Watchlist server resposne.
- (void)watchListDeleteItemServerResponse:(NSArray*)arrResponse
{
    WatchListMovies *objWatchListMovies = [WatchListMovies new];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"] forKey:@"userId"];
    
    [objWatchListMovies fetchWatchList:self selector:@selector(watchListServerResponse:) parameter:dict];
}

#pragma mark - Register CollectionView Cell
- (void)registerCollectionViewCell
{
    [collectionVwWatchList registerNib:[UINib nibWithNibName:@"WatchListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"watchListCell"];
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrWatchList count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WatchListCollectionViewCell *cell = [collectionVwWatchList dequeueReusableCellWithReuseIdentifier:@"watchListCell" forIndexPath:indexPath];
    if (isWatchListEditing) {
        cell.btnDelete.hidden = NO;
    }
    else
        cell.btnDelete.hidden = YES;

    cell.delegate = self;
    [cell setCellValues:[self.arrWatchList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WatchListMovie *objWatchListMovie = (WatchListMovie*)[self.arrWatchList objectAtIndex:indexPath.row];
    
    if ([objWatchListMovie.seriesID length] != 0) {
        //Show episode view
        
        NSString *episodeName =  [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objWatchListMovie.movieName_en:objWatchListMovie.movieName_ar;
        
        NSString *seriesName =  [[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]?objWatchListMovie.seriesName_en:objWatchListMovie.seriesName_ar;

        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:objWatchListMovie.movieUrl, episodeName, @"", objWatchListMovie.seasonNum, objWatchListMovie.episodeNum,@"yes", objWatchListMovie.movieId, objWatchListMovie.seriesID, objWatchListMovie.episodeDuration, seriesName, objWatchListMovie.movieThumb, nil] forKeys:[NSArray arrayWithObjects:@"url", @"episodeName", @"episodeDesc", @"seasonNum", @"episodeNum", @"isExistsInWatchList", @"episodeId", @"seriesId", @"duration", @"seriesName", @"episodethumb", nil]];
        EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
        objEpisodeDetailViewController.dictEpisodeData = dict; //Pass required data to next controller.
        
        //Fetch and pass current view cgcontext for background display
        UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
        objEpisodeDetailViewController._imgViewBg = viewImage;
        
        [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
    }
    else{
        
        if (objWatchListMovie.videoType == 2) { //if music
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]){
                self.strMovieNameOnCastingDevice = objWatchListMovie.movieName_en;
            }
            else
                self.strMovieNameOnCastingDevice = objWatchListMovie.movieName_ar;
            //Play in media player
            if ([objWatchListMovie.movieUrl rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self performSelector:@selector(convertBCoveUrl:) withObject:objWatchListMovie.movieUrl afterDelay:0.1];
            }
            else if ([objWatchListMovie.movieUrl rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                NSRange range = [objWatchListMovie.movieUrl rangeOfString:@"=" options:NSBackwardsSearch range:NSMakeRange(0, [objWatchListMovie.movieUrl length])];
                NSString *youtubeVideoId = [objWatchListMovie.movieUrl substringFromIndex:range.location+1];
                [self playYoutubeVideoPlayer:youtubeVideoId videoUrl:objWatchListMovie.movieUrl];
            }
            else //Play in Movieplayer viewcontroller
            {
                MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
                objMoviePlayerViewController.strVideoUrl = objWatchListMovie.movieUrl;
                objMoviePlayerViewController.strVideoId = objWatchListMovie.movieId;
                [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
            }
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], objWatchListMovie.movieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
            //Fetch last viewed.
            LastViewedMovie *objLastViewedMovie = [LastViewedMovie new];
            [objLastViewedMovie fetchLastviewed:self selector:@selector(lastViewedServerResponse:) parameter:dict];
        }
        else
        {
            //Show overlay
            EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
            objEpisodeDetailViewController.episodeId = objWatchListMovie.movieId;
            UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
            objEpisodeDetailViewController._imgViewBg = viewImage;
            objEpisodeDetailViewController.isFromVOD = YES;
            [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
        }
    }
}

- (void)convertBCoveUrl:(id)object
{
    //Convert bcove url in mp4.
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
    [self dismissMoviePlayerViewControllerAnimated];
    mpMoviePlayerViewController = nil;
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

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController
{
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
    
    return YES;
}

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    //Play VOD movie
    [popOverSearch dismissPopoverAnimated:YES];
    
    if (isSeries == NO) {
        MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
        objMovieDetailViewController.strMovieId = videoId;
        [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
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

#pragma mark - UIGestureRecognizer delegate methods
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
    //If iad fails, load Admob
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 70]];
}

#pragma mark - Memory Management
-(void)dealloc {
    
    collectionVwWatchList.dataSource = nil;
    collectionVwWatchList.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:@"PopViewToRootViewControllerWatchListController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end