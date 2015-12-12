//
//  MusicSingersVideosViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 04/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MusicSingersVideosViewController.h"
#import "SingerVideos.h"
#import "CustomControls.h"
#import "VODFeaturedCollectionCell.h"
#import "SingerVideo.h"
#import "MovieDetailViewController.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"
#import "popoverBackgroundView.h"
#import "SearchVideoViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "MoviePlayerViewController.h"

@interface MusicSingersVideosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList>
{
    IBOutlet UICollectionView*      collectionVw;
    UIPopoverController*            popOverSearch;
    SearchVideoViewController*      objSearchVideoViewController;
    LoginViewController*            objLoginViewController;
    SettingViewController*          objSettingViewController;
    IBOutlet UILabel*               lblSingerName;
}

@property (weak, nonatomic) IBOutlet UILabel*       lblNoVideoFoundText;
@property (strong, nonatomic) NSArray*              arrSingerVideos;
@property (strong, nonatomic) UISearchBar*          searchBarVOD;

@end

@implementation MusicSingersVideosViewController

@synthesize singerID;
@synthesize singerName_en, singerName_ar;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewToRootViewController) name:@"PopViewToRootViewController" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];

    [self setNavigationBarButtons];
    [self registerCollectionViewCell];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblSingerName.text = singerName_en;
    else
        lblSingerName.text = singerName_ar;

    [lblSingerName setFont:[UIFont fontWithName:kProximaNova_Bold size:18.0]];
    
    SingerVideos *objSingerVideos = [SingerVideos new];
    NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:singerID forKey:@"singerId" ];
    [objSingerVideos fetchSingerVideos:self selector:@selector(singerVideosServerResponse:) parameters:dictParameters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [collectionVw reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
//    CGRect rect1 = collectionVw.frame;
//    rect1.size.height += 100;
//    [collectionVw setFrame:rect1];
}

- (void)popViewToRootViewController
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)setNavigationBarButtons
{
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

#pragma mark - Navigationbar buttons actions

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
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
    if (self.searchBarVOD == nil) {
        self.searchBarVOD = [[UISearchBar alloc] initWithFrame:CGRectMake(510, 15, 230, 42)];
        self.searchBarVOD.delegate = self;
        self.searchBarVOD.tintColor = [UIColor clearColor];
        self.searchBarVOD.tintColor = [UIColor darkGrayColor];
        [self.navigationController.navigationBar addSubview:self.searchBarVOD];
        [self.searchBarVOD becomeFirstResponder];
        
        if(![CommonFunctions isIphone])
            [self showSearchPopOver];
    }
}

- (void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)watchListItemAction
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey]) {
        
        [self showLoginView];
    }
    else{
        WatchListViewController *objWatchListViewController = [[WatchListViewController alloc] initWithNibName:@"WatchListViewController" bundle:nil];
        objWatchListViewController.delegate =  self;
        //Fetch and pass current view cgcontext for background display
        UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
        objWatchListViewController._imgViewBg = viewImage;
        [self.navigationController pushViewController:objWatchListViewController animated:YES];
    }
}

- (void)showLoginView
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

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        
        lblSingerName.text = singerName_en;
    else
        lblSingerName.text = singerName_ar;
    
    [collectionVw reloadData];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:@"back_btn" Target:self selector:@selector(backBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)loginUser
{
    [popOverSearch dismissPopoverAnimated:YES];
    [self showLoginView];
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

#pragma mark - Server Response
- (void)singerVideosServerResponse:(NSArray*)arrResponse
{
    self.arrSingerVideos = [[NSArray alloc] initWithArray:arrResponse];
    
    self.lblNoVideoFoundText.hidden = YES;
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    if ([arrResponse count] == 0) {
        self.lblNoVideoFoundText.hidden = NO;
    }
    [collectionVw reloadData];
}

- (void)registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"VODFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"vodfeaturecell"];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrSingerVideos count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VODFeaturedCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"vodfeaturecell" forIndexPath:indexPath];
    
    [cell setCellValuesForSingersVideos:[self.arrSingerVideos objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SingerVideo *objSingerVideo = (SingerVideo*)[self.arrSingerVideos objectAtIndex:indexPath.row];
    /*MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
    objMovieDetailViewController.strMovieId = objSingerVideo.movieID;
    objMovieDetailViewController.isMusicVideo = YES;
    [self.navigationController pushViewController:objMovieDetailViewController animated:YES];
    */
    
    MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
    objMoviePlayerViewController.strVideoUrl = objSingerVideo.movieUrl;
    [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
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

- (void)playSelectedVODProgram:(NSString*)videoId isSeries:(BOOL)isSeries seriesThumb:(NSString*)seriesThumb seriesName:(NSString*)seriesName movieType:(NSInteger)movietype
{
    [popOverSearch dismissPopoverAnimated:YES];
    
    if (isSeries == NO) {
        MovieDetailViewController *objMovieDetailViewController = [[MovieDetailViewController alloc] init];
        objMovieDetailViewController.strMovieId = videoId;
        objMovieDetailViewController.isMusicVideo = YES;
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

#pragma mark - UIPopOver Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController*)popoverController
{
    [self.searchBarVOD resignFirstResponder];
    [self.searchBarVOD removeFromSuperview];
    self.searchBarVOD = nil;
    self.searchBarVOD.delegate = nil;
    
    return YES;
}

#pragma mark - Memory Management
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end