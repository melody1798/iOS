//
//  SeriesEpisodesViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesEpisodesViewController.h"
#import "Episodes.h"
#import "EpisodesCollectionCell.h"
#import "CustomControls.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "SearchVideoViewController.h"
#import "popoverBackgroundView.h"
#import "CommonFunctions.h"
#import "UIImageView+WebCache.h"
#import "EpisodeDetailViewController.h"
#import "MovieDetailViewController.h"
#import "SeasonsViewController.h"
#import "CommonFunctions.h"
#import "SeriesSeasons.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesSeason.h"
#import "CustomNavBar.h"
#import "FAQViewController.h"
#import "MoviePlayerViewController.h"
#import "VODSearchController.h"

@interface SeriesEpisodesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate, ChannelProgramPlay, SelectedSeasonDelegate, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList>
{
    IBOutlet UICollectionView*      collectionVw;
    LoginViewController*            objLoginViewController;
    SearchVideoViewController*      objSearchVideoViewController;
    UIPopoverController*            popOverSearch;
    IBOutlet UILabel*               lblNoEpisodeFound;
    IBOutlet UIImageView*           imgVwSeriesThumb;
    IBOutlet UILabel*               lblSeriesName;
    IBOutlet UILabel*               lblSeasonName;
    IBOutlet UIButton*              btnSelectSeason;
    EpisodeDetailViewController*    objEpisodeDetailViewController;
    UIPopoverController*            popOverSeasons;
    NSString*                       strSeason;
    SettingViewController*          objSettingViewController;
}

@property (strong, nonatomic) NSArray*          arrEpisodes;
@property (strong, nonatomic) NSArray*          arrSeasons;
@property (strong, nonatomic) UISearchBar*      searchBarVOD;

- (IBAction)btnSelectSeasonAction:(id)sender;

@end

@implementation SeriesEpisodesViewController

@synthesize strSeriesId;
@synthesize seriesUrl;
@synthesize seriesName_en, seriesName_ar;

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
    


    [self registerCollectionViewCell];
    [self setNavigationBarButtons];
    [self setLocalizeText];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewToRootViewController) name:@"PopViewToRootViewController" object:nil];

    lblNoEpisodeFound.font = [UIFont fontWithName:kProximaNova_Bold size:22.0];
    lblSeriesName.font = [UIFont fontWithName:kProximaNova_Bold size:24.0];
    lblSeasonName.font = [UIFont fontWithName:kProximaNova_Bold size:18.0];
    
    [imgVwSeriesThumb sd_setImageWithURL:[NSURL URLWithString:seriesUrl] placeholderImage:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];
    
    SeriesSeasons *objSeriesSeasons = [SeriesSeasons new];
    [objSeriesSeasons fetchSeriesSeasons:self selector:@selector(seriesSeasonServerResponse:) parameter:strSeriesId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    [collectionVw reloadData];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)popViewToRootViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)callVideo
{
    
}


#pragma mark - Register Colletion view cell
- (void)registerCollectionViewCell
{
    //Register for all series episodes
    [collectionVw registerNib:[UINib nibWithNibName:@"EpisodeCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"episodes"];
}

- (void)setLocalizeText
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblSeriesName.text = seriesName_en;
    else
        lblSeriesName.text = seriesName_ar;

    [lblSeasonName setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"select season" value:@"" table:nil]];
    [lblNoEpisodeFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];
}

- (void)setNavigationBarButtons
{
    //[self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

#pragma mark - Navigationbar buttons actions

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
}

- (void)backBarButtonItemAction
{
    collectionVw.delegate = nil;
    collectionVw.dataSource = nil;
    self.searchBarVOD.delegate = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)watchListItemAction
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginScreen];
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
    VODSearchController *objVODSearchController = [[VODSearchController alloc] initWithNibName:@"VODSearchController" bundle:nil];
    [self.navigationController pushViewController:objVODSearchController animated:NO];
}

#pragma mark - IBAction

- (IBAction)btnSelectSeasonAction:(id)sender
{
    if ([self.arrSeasons count] > 1)
        [self showSeasonPopOver:self.arrSeasons];
    else if ([self.arrSeasons count] == 0)
        [NSIUtility showAlertView:nil message:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"no season found" value:@"" table:nil]];
}

- (void)showSeasonPopOver:(NSArray*)arrSeasons
{
    //Season
    SeasonsViewController *objSeasonsViewController = [[SeasonsViewController alloc] initWithNibName:@"SeasonsViewController" bundle:nil];
    objSeasonsViewController.delegate = self;
    objSeasonsViewController.strSeriesId = strSeriesId;
    objSeasonsViewController.arrSeasons = arrSeasons;
    popOverSeasons = nil;
    popOverSeasons = [[UIPopoverController alloc] initWithContentViewController:objSeasonsViewController];
    popOverSeasons.popoverBackgroundViewClass = [popoverBackgroundView class];
    
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = 196;
    rect.size.height = [self setPopOverHeight:[arrSeasons count]];
    if ([arrSeasons count] == 1)
        rect.origin.y = rect.size.height+10;
    else if ([arrSeasons count] == 2)
        rect.origin.y = rect.size.height - [arrSeasons count]*10;
    else if ([arrSeasons count] >= 3)
        rect.origin.y = rect.size.height - [arrSeasons count]*15;

    [popOverSeasons presentPopoverFromRect:rect inView:btnSelectSeason permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
}

- (float)setPopOverHeight:(NSInteger)totalSeasons
{
    float controllerHeight = 0;
    for (int i = 0; i < totalSeasons; i++) {
        
        controllerHeight += 25;
    }
    if (controllerHeight>160) {
        controllerHeight = 160;
    }
    
    return controllerHeight;
}

- (void)showLoginScreen
{
    if (objLoginViewController.view.superview) {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

#pragma mark - Settings Delegate

- (void)userSucessfullyLogout
{
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

    [self setLocalizeText];
    [collectionVw reloadData];
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginScreen];
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

#pragma mark - Selected Series Delegate Method

- (void)seriesSeasonServerResponse:(NSArray*)arrResponse
{
    self.arrSeasons = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrSeasons count] > 0){
        
        SeriesSeason *objSeriesSeason = [arrResponse objectAtIndex:0];
        [lblSeasonName setText:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], objSeriesSeason.seasonNum]];
        
        if ([self.arrSeasons count] == 1) {
            btnSelectSeason.hidden = YES;
            lblSeasonName.hidden = YES;
        }
        else
        {
            btnSelectSeason.hidden = NO;
            lblSeasonName.hidden = NO;
        }
        Episodes *objEpisodes = [Episodes new];
        [objEpisodes fetchSeriesSeasonalEpisodes:self selector:@selector(seriesEpisodesServerResponse:) parameter:strSeriesId seasonId:objSeriesSeason.seasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    else
    {
        lblNoEpisodeFound.hidden = NO;
        btnSelectSeason.hidden = YES;
        lblSeasonName.hidden = YES;
    }
}

- (void)fetchEpisodesForSelectedSeason:(NSString *)seasonId
{
    [popOverSeasons dismissPopoverAnimated:YES];
    strSeason = [NSString stringWithFormat:@"%@", seasonId];
    lblSeasonName.text = [[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], seasonId] uppercaseString];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblSeriesName.text = [NSString stringWithFormat:@"%@", seriesName_en];
    else
        lblSeriesName.text = [NSString stringWithFormat:@"%@", seriesName_ar];

    Episodes *objEpisodes = [Episodes new];
    [objEpisodes fetchSeriesSeasonalEpisodes:self selector:@selector(seriesEpisodesServerResponse:) parameter:strSeriesId seasonId:seasonId userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
}

#pragma mark - Server Response

- (void)seriesEpisodesServerResponse:(NSArray*)arrResponse
{
    lblNoEpisodeFound.hidden = YES;

    self.arrEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrEpisodes count] == 0) {
        lblNoEpisodeFound.hidden = NO;
    }
    [collectionVw reloadData];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrEpisodes count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EpisodesCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"episodes" forIndexPath:indexPath];
    [cell setCellValuesSeriesEpisodes:[self.arrEpisodes objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (objEpisodeDetailViewController.view.superview) {
        return;
    }
    objEpisodeDetailViewController = nil;
    objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] initWithNibName:@"EpisodeDetailViewController" bundle:nil];
    
    Episode *objEpisode = (Episode*) [self.arrEpisodes objectAtIndex:indexPath.row];
    NSString *episodeName;
    NSString *episodeDesc;
    NSString *seriesName;
    NSString *seriesDesc;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        episodeName = objEpisode.episodeName_en;
        episodeDesc = objEpisode.episodeDesc_en;
        seriesName = objEpisode.seriesName_en;
        seriesDesc = objEpisode.seriesDesc_en;
    }
    else
    {
        episodeName = objEpisode.episodeName_ar;
        episodeDesc = objEpisode.episodeDesc_ar;
        seriesName = objEpisode.seriesName_ar;
        seriesDesc = objEpisode.seriesDesc_ar;
    }
    
    if ([seriesDesc length] == 0) {
        seriesDesc = @"";
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:objEpisode.episodeUrl, episodeName, episodeDesc, objEpisode.seasonNum, objEpisode.episodeNum,[NSString stringWithFormat:@"%d", objEpisode.bIsExistsInWatchList], objEpisode.episodeId, strSeriesId, objEpisode.episodeDuration, seriesName, seriesDesc, objEpisode.episodeThumb, [NSString stringWithFormat:@"%ld", (long)objEpisode.seriesSeasonsCount], nil] forKeys:[NSArray arrayWithObjects:@"url", @"episodeName", @"episodeDesc", @"seasonNum", @"episodeNum", @"isExistsInWatchList", @"episodeId", @"seriesId", @"duration", @"seriesName", @"seriesDesc", @"episodethumb", @"seriesSeasonCount", nil]];
    objEpisodeDetailViewController.dictEpisodeData = dict;
    
    //Fetch and pass current view cgcontext for background display
    UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
    objEpisodeDetailViewController._imgViewBg = viewImage;
   
    objEpisodeDetailViewController.arrCastCrew = objEpisode.arrCastAndCrew;
    objEpisodeDetailViewController.arrProducers = objEpisode.arrProducers;
   
    [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
    
//    Episode *objEpisode = (Episode*) [self.arrEpisodes objectAtIndex:indexPath.row];
//
//    MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
//    objMoviePlayerViewController.strVideoUrl = objEpisode.episodeUrl;
//    [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
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

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];

    if (isSeries == NO) {
        MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
        objMovieDetailViewController.strMovieId = videoId;
        [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
    }
    else{
        self.strSeriesId = videoId;
        self.seriesName_en = seriesName;
        self.seriesName_ar = seriesName;
        self.seriesUrl = seriesThumb;
        
        [self setLocalizeText];
        
        Episodes *objEpisodes = [Episodes new];
        [objEpisodes fetchSeriesEpisodes:self selector:@selector(seriesEpisodesServerResponse:) parameter:strSeriesId userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
}

#pragma mark - UISearchBar Delegate

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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [objSearchVideoViewController handleSearchText:self.searchBarVOD.text searchCat:2];
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

#pragma mark - Memory Management Methods

- (void)dealloc
{
    self.searchBarVOD.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"PopViewToRootViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"updateWatchListMovieCounter"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"GotoVODHomeNoti"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end