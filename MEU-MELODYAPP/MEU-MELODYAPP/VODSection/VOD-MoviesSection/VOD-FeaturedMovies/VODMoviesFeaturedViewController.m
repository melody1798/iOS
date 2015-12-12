 //
//  VODMoviesFeaturedViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMoviesFeaturedViewController.h"
#import "Constant.h"
#import "VODMoviesFeaturedCollectionCell.h"
#import "VODMovieAtoZView.h"
#import "VODMoviesCollections.h"
#import "FeaturedMovies.h"
#import "AtoZMovies.h"
#import "MBProgressHUD.h"
#import "GenresViewController.h"
#import "popoverBackgroundView.h"
#import "MoviesCollections.h"
#import "GenresView.h"
#import "CollectionMoviesViewController.h"
#import "MoviePlayerViewController.h"
#import "CustomControls.h"
#import "MovieDetailViewController.h"
#import "WatchListViewController.h"
#import "NSIUtility.h"
#import "CommonFunctions.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SearchVideoViewController.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "Genres.h"
#import "EpisodeDetailViewController.h"
#import "VODSearchController.h"
#import "AtoZMovie.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface VODMoviesFeaturedViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate, genreSelectedDelegate, collectionDidSelect, AtoZMovieSeleted, genreMovieSelectedDelegate, UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList>
{
    IBOutlet UISegmentedControl*     segmentedControl;
    IBOutlet UICollectionView*       collectionVw;
    VODMovieAtoZView*                objVODMovieAtoZView;
    VODMoviesCollections*            objVODMoviesCollections;
    UIPopoverController*             popOverGenres;
    GenresView*                      objGenreView;
    LoginViewController*             objLoginViewController;
    UIPopoverController*             popOverSearch;
    SearchVideoViewController*       objSearchVideoViewController;
    IBOutlet UIImageView*            imgVwSubMenuBg;
    SettingViewController*           objSettingViewController;
}

@property (weak, nonatomic) IBOutlet UILabel*   lblNoVideoFoundText;
@property (strong, nonatomic) NSArray*          arrFeaturedMovies;
@property (strong, nonatomic) NSMutableArray*   arrAtoZMovies;
@property (strong, nonatomic) NSMutableArray*   arrAlphabets;
@property (strong, nonatomic) NSArray*          arrMoviesCollections;
@property (strong, nonatomic) UISearchBar*      searchBarVOD;
@property (strong, nonatomic) NSMutableArray*   arrArabicAlphabets;
@property (strong, nonatomic) NSString*         strGenreId;
@property (strong, nonatomic) NSString*         strPreviousLanguage;

- (IBAction)btnGenreAction:(id)sender;

@end

@implementation VODMoviesFeaturedViewController

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
    
    self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];



    [self setLocalizedText];
    imgVwSubMenuBg.hidden = YES;

    self.arrAlphabets = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];

    self.lblNoVideoFoundText.hidden = YES;
    
    self.lblNoVideoFoundText.font = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 13.0:22.0];
    
    [self setNavigationBarButtons];
    [self registerCollectionViewCell];
    [self setSegmentedControlAppreance];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        self.lblNoVideoFoundText.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        //Fetch VOD featured movies.
        FeaturedMovies *objFeaturedMovies = [FeaturedMovies new];
        [objFeaturedMovies fetchFeaturedMovies:self selector:@selector(fetchFeaturedMovieServerResponse:)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Watchlist"];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    [self setLocalizedText];
    [collectionVw reloadData];
    [objGenreView reloadGenresTableViewData];
    
    if (![self.strPreviousLanguage isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey]]) {
        
        if (objVODMovieAtoZView!=nil) {
            self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];
            AtoZMovies *objAtoZMovies = [AtoZMovies new];
            [objAtoZMovies fetchAtoZMovies:self selector:@selector(AtoZMoviesServerResponse:)];
        }
    }
    
    [objVODMoviesCollections reloadCollectionView:self.arrMoviesCollections];
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
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

- (void)setLocalizedText
{
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"atoz" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    
    if (objGenreView==nil) {
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            if ([objGenreView.strGenreName length] >= 16)
                [segmentedControl setTitle:[objGenreView.strGenreName substringToIndex:16] forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:objGenreView.strGenreName forSegmentAtIndex:2];
        }
        else{
            if ([objGenreView.strGenreName_ar length] >= 16)
                [segmentedControl setTitle:[objGenreView.strGenreName_ar substringToIndex:16] forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:objGenreView.strGenreName_ar forSegmentAtIndex:2];
        }
    }
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"packs" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];

    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
}

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

#pragma mark - Navigationbar buttons actions

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
    VODSearchController *objVODSearchController = [[VODSearchController alloc] init];
    [self.navigationController pushViewController:objVODSearchController animated:NO];
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

    [self setLocalizedText];
    [collectionVw reloadData];
    [objGenreView reloadGenresTableViewData];
//    [objVODMovieAtoZView reloadTableView:self.arrAtoZMovies arrAlphabets:self.arrAlphabets];
    [objVODMoviesCollections reloadCollectionView:self.arrMoviesCollections];
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    if (objGenreView!=nil) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            
            [segmentedControl setTitle:objGenreView.strGenreName forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:objGenreView.strGenreName_ar forSegmentAtIndex:2];
        
        [objGenreView fetchAllGenres:self.strGenreId genreName_en:objGenreView.strGenreName genreName_ar:objGenreView.strGenreName_ar genreType:@"movies"];
    }
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

#pragma mark - Server Response
- (void)fetchFeaturedMovieServerResponse:(NSArray*)arrResponse
{
    self.arrFeaturedMovies = [[NSArray alloc] initWithArray:arrResponse];
    
    if ([arrResponse count]!=0) {
        [collectionVw reloadData];
    }
    else{
        self.lblNoVideoFoundText.hidden = NO;
    }
}

- (void)AtoZMoviesServerResponse:(NSArray*)arrResponse
{
    objVODMovieAtoZView.i = -1;
    self.arrAtoZMovies = [arrResponse mutableCopy];
    
    if ([self.arrAtoZMovies count] == 0) {
        objVODMovieAtoZView.i = 0;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        
        self.arrAlphabets = [CommonFunctions createArabicAlphabetsArray:self.arrAtoZMovies];
        self.arrAtoZMovies = [CommonFunctions returnArrayOfRecordForParticularAlphabetArabic:self.arrAtoZMovies arrayOfAphabetsToDisplay:self.arrAlphabets];
    }
    else
        self.arrAtoZMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabet:self.arrAtoZMovies arrayOfAphabetsToDisplay:self.arrAlphabets] mutableCopy];

    [objVODMovieAtoZView reloadTableView:self.arrAtoZMovies arrAlphabets:self.arrAlphabets];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)moviesCollectionsServerResponse:(NSArray*)arrResponse
{
    objVODMoviesCollections.i = -1;

    self.arrMoviesCollections = [NSArray arrayWithArray:arrResponse];
    if ([self.arrMoviesCollections count] == 0) {
        objVODMoviesCollections.i = 0;
    }
    //Call Method to register collection view cells
    [objVODMoviesCollections registerCollectionVwCell];
    [objVODMoviesCollections reloadCollectionView:arrResponse];
}

#pragma mark - Register CollectionView Cell
- (void)registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"VODMoviesFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"vodmoviefeaturecell"];
}

#pragma mark - Set Segmentedbar apperance
- (void)setSegmentedControlAppreance
{
    [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentMoviesBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //Set segment control height.
    CGRect frame = segmentedControl.frame;
    [segmentedControl setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kSegmentControlHeight)];
    
    UIFont *Boldfont = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentedControl setTitleTextAttributes:selectionAttributes
                                    forState:UIControlStateSelected];
}

#pragma mark - SegmentedControl index change
- (IBAction)segmentedControlIndexChanged
{
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    
    imgVwSubMenuBg.hidden = YES;
    self.lblNoVideoFoundText.hidden = YES;

    if (segmentedControl.selectedSegmentIndex != 2) {
        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    }
    [objGenreView removeFromSuperview];
    objGenreView = nil;

    [objVODMovieAtoZView removeFromSuperview];
    objVODMovieAtoZView = nil;
    
    [objVODMoviesCollections removeFromSuperview];
    objVODMoviesCollections = nil;
    
    if (segmentedControl.selectedSegmentIndex!= 1 && segmentedControl.selectedSegmentIndex!= 2) {
        [objVODMovieAtoZView removeFromSuperview];
        objVODMovieAtoZView = nil;
    }
    if (segmentedControl.selectedSegmentIndex!= 3  && segmentedControl.selectedSegmentIndex!= 2) {
        [objVODMoviesCollections removeFromSuperview];
        objVODMoviesCollections = nil;
    }
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            if ([self.arrFeaturedMovies count] == 0) {
                //Fetch VOD featured movies.
                FeaturedMovies *objFeaturedMovies = [FeaturedMovies new];
                [objFeaturedMovies fetchFeaturedMovies:self selector:@selector(fetchFeaturedMovieServerResponse:)];
            }
            break;
        }
        case 1:
        {
            if (![kCommonFunction checkNetworkConnectivity])
            {
                self.lblNoVideoFoundText.hidden = NO;
                [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
            }
            else
            {
                objVODMovieAtoZView = [VODMovieAtoZView customView];
                objVODMovieAtoZView.i = -1;
                if IS_IOS7_OR_LATER
                    [objVODMovieAtoZView setFrame:CGRectMake(0, 140, 768, 767)];
                else
                    [objVODMovieAtoZView setFrame:CGRectMake(0, 50, 768, 770)];
                [self.view addSubview:objVODMovieAtoZView];
                
                objVODMovieAtoZView.delegate = self;
                [objVODMovieAtoZView reloadTableView:self.arrAtoZMovies arrAlphabets:self.arrAlphabets];
                
                if ([self.arrAtoZMovies count] == 0) {
                    AtoZMovies *objAtoZMovies = [AtoZMovies new];
                    [objAtoZMovies fetchAtoZMovies:self selector:@selector(AtoZMoviesServerResponse:)];
                }
            }
            break;
        }
        case 2:
        {
        }
        case 3:
        {
            if (![kCommonFunction checkNetworkConnectivity])
            {
                self.lblNoVideoFoundText.hidden = NO;
                [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
            }
            else
            {
                //Collections
                [objVODMoviesCollections removeFromSuperview];
                objVODMoviesCollections = nil;
                
                objVODMoviesCollections = [VODMoviesCollections customView];
                objVODMoviesCollections.i = -1;
                
                if IS_IOS7_OR_LATER
                    [objVODMoviesCollections setFrame:CGRectMake(0, 140, 768, 768)];
                else
                    [objVODMoviesCollections setFrame:CGRectMake(0, 50, 768, 778)];
                objVODMoviesCollections.delegate = self;
                [self.view addSubview:objVODMoviesCollections];
                
                [objVODMoviesCollections registerCollectionVwCell];
                [objVODMoviesCollections reloadCollectionView:self.arrMoviesCollections];
                
                if ([self.arrMoviesCollections count] == 0) {
                    MoviesCollections *objMoviesCollections = [MoviesCollections new];
                    [objMoviesCollections fetchMoviesCollections:self selector:@selector(moviesCollectionsServerResponse:)];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)btnGenreAction:(id)sender
{
    segmentedControl.selectedSegmentIndex = 2;
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        self.lblNoVideoFoundText.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        Genres *objGenres = [Genres new];
        [objGenres fetchGenres:self selector:@selector(fetchGenresServerResponse:) methodName:@"movies"];
    }
}

#pragma mark - Server Response Method
- (void)fetchGenresServerResponse:(NSArray*)arrResponse
{
    
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    if ([arrResponse count] > 0) {
        //Genres
        GenresViewController *objGenresViewController = [[GenresViewController alloc] initWithNibName:@"GenresViewController" bundle:nil];
       // objGenresViewController.strSectionType = @"movies";
        objGenresViewController.arrGenresList = arrResponse;
        objGenresViewController.delegate = self;
        
        popOverGenres = [[UIPopoverController alloc] initWithContentViewController:objGenresViewController];
        popOverGenres.popoverBackgroundViewClass = [popoverBackgroundView class];
        [popOverGenres setDelegate:self];
        CGRect rect1 = objGenresViewController.view.frame;
        
        CGRect rect;
        rect.origin.x = 200;
        rect.origin.y = -75;
        rect.size.width = 220;
        rect.size.height = 87;
        
        [popOverGenres setPopoverContentSize:CGSizeMake(rect1.size.width, (arrResponse.count + 1) * 40)];
        [popOverGenres presentPopoverFromRect:rect inView:segmentedControl permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
}

#pragma mark - UICollectionView Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrFeaturedMovies count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VODMoviesFeaturedCollectionCell *cell = [collectionVw dequeueReusableCellWithReuseIdentifier:@"vodmoviefeaturecell" forIndexPath:indexPath];
    [cell setCellValues:[self.arrFeaturedMovies objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeaturedMovie *objFeaturedMovie = (FeaturedMovie*)[self.arrFeaturedMovies objectAtIndex:indexPath.row];
    [self playMoviewWithUrl:objFeaturedMovie.movieID];
}

#pragma mark - AtoZ selected delegate

- (void)playSelectedMovie:(NSString *)movieID
{
    [self playMoviewWithUrl:movieID];
}

#pragma mark - Genre Selected Delegate

- (void)genreIDSelected:(NSString *)genreID genreName_en:(NSString *)genreName_en genreName_ar:(NSString *)genreName_ar
{
    self.strGenreId = [NSString stringWithFormat:@"%@", genreID];
    [objGenreView removeFromSuperview];
    objGenreView = nil;
    
    [popOverGenres dismissPopoverAnimated:YES];
    objGenreView = [GenresView customView];
    
    if IS_IOS7_OR_LATER
        [objGenreView setFrame:CGRectMake(0, 140, 768, 770)];
    else
        [objGenreView setFrame:CGRectMake(0, 40, 768, 780)];
    
    objGenreView.strGenreName = genreName_en;
    objGenreView.strGenreName_ar = genreName_ar;
    
    [self.view addSubview:objGenreView];
    objGenreView.delegate = self;
    //Call websrevice to fetch genres detail
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        [objGenreView fetchAllGenres:genreID genreName_en:genreName_en genreName_ar:genreName_ar genreType:@"movies"];
        if ([genreName_en length] >= 16)
            [segmentedControl setTitle:[genreName_en substringToIndex:16] forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:genreName_en forSegmentAtIndex:2];
    }
    else
    {
        if ([genreName_ar length] >= 16)
            [segmentedControl setTitle:[genreName_ar substringToIndex:16] forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:genreName_ar forSegmentAtIndex:2];
        
        [objGenreView fetchAllGenres:genreID genreName_en:genreName_en genreName_ar:genreName_ar genreType:@"movies"];
    }
}

- (void)playGenreSelectedMovie:(NSString *)movieID
{
    [self playMoviewWithUrl:movieID];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    popOverGenres = nil;
}

#pragma mark - MPMoViewPlayer Controller Play movie

- (void)playMoviewWithUrl:(NSString*)movieUrl
{
    EpisodeDetailViewController *objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] init];
    objEpisodeDetailViewController.episodeId = movieUrl;
    UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
    objEpisodeDetailViewController._imgViewBg = viewImage;
    objEpisodeDetailViewController.isFromVODMovies = YES;
    [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
}

#pragma mark - CollectionView Did Select Item

- (void)collectionVwSelectedItem:(MoviesCollection *)objMoviesCollection
{
    CollectionMoviesViewController *objCollectionMoviesViewController = [[CollectionMoviesViewController alloc] initWithNibName:@"CollectionMoviesViewController" bundle:nil];
    objCollectionMoviesViewController.objMoviesCollection = objMoviesCollection;
    [self.navigationController pushViewController:objCollectionMoviesViewController animated:YES];
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

#pragma mark - Memory Management Method
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end