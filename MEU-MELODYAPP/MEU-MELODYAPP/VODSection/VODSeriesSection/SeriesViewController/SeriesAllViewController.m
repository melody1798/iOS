//
//  SeriesAllViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesAllViewController.h"
#import "VODFeaturedCollectionCell.h"
#import "VODMoviesFeaturedCollectionCell.h"
#import "GenresViewController.h"
#import "popoverBackgroundView.h"
#import "Series.h"
#import "Episodes.h"
#import "SeriesEpisodesViewController.h"
#import "Serie.h"
#import "CustomControls.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "WatchListViewController.h"
#import "CommonFunctions.h"
#import "NSIUtility.h"
#import "popoverBackgroundView.h"
#import "SearchVideoViewController.h"
#import "MovieDetailViewController.h"
#import "EpisodeDetailViewController.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CompanyInfoViewController.h"
#import "FeedbackViewController.h"
#import "SeriesEpisodesViewController.h"
#import "FAQViewController.h"
#import "DetailGenres.h"
#import "Genres.h"
#import "MoviePlayerViewController.h"
#import "VODSearchController.h"

@interface SeriesAllViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPopoverControllerDelegate, genreSelectedDelegate, UISearchBarDelegate, ChannelProgramPlay, SettingsDelegate, LanguageSelectedDelegate, FetchMovieDetailFromWatchList>
{
    IBOutlet UISegmentedControl*     segmentedControl;
    IBOutlet UICollectionView*       collectionVwSeries;
    UIPopoverController*             popOverGenre;
    IBOutlet UILabel*                lblNoResultFound;
    LoginViewController*             objLoginViewController;
    UIPopoverController*             popOverSearch;
    UIPopoverController*             popOverSettings;
    SearchVideoViewController*       objSearchVideoViewController;
    EpisodeDetailViewController*     objEpisodeDetailViewController;
    int                              iPreviousSegmentindex;
    SettingViewController*           objSettingViewController;
}

@property (strong, nonatomic) UISearchBar*  searchBarVOD;
@property (strong, nonatomic) NSArray*      arrSeries;
@property (strong, nonatomic) NSArray*      arrEpisodes;
@property (strong, nonatomic) NSArray*      arrGenreSeries;
@property (strong, nonatomic) NSString*     strSelectedGenre_en;
@property (strong, nonatomic) NSString*     strSelectedGenre_ar;

- (IBAction)segmentControlIndexChanged;

@end

@implementation SeriesAllViewController

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



    iPreviousSegmentindex = 0;
    CGRect collectionVwFrame = collectionVwSeries.frame;
    collectionVwFrame.origin.x = 10;
    collectionVwFrame.size.width = 748;
    collectionVwSeries.frame = collectionVwFrame;
    [collectionVwSeries reloadData];
    
    lblNoResultFound.font = [UIFont fontWithName:kProximaNova_Bold size:22.0];

    [self setLocalizedText];
    [self setNavigationBarButtons];
    [self registerCollectionViewCell];
    [self setSegmentedControlAppreance];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        lblNoResultFound.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        Series *objSeries = [Series new];
        [objSeries fetchAllSeries:self selector:@selector(seriesResponse:) isArb:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]?@"true":@"false"];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
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
    
    [collectionVwSeries reloadData];
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];

}

- (void)updateWatchListCounter:(NSNotification *)notification
{
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
}

- (void)setLocalizedText
{
    [lblNoResultFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No video found" value:@"" table:nil]];

    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"all series" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured episodes" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    if (iPreviousSegmentindex!=2) {

        [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            [segmentedControl setTitle:self.strSelectedGenre_en forSegmentAtIndex:2];
        }
        else
        {
            if ([self.strSelectedGenre_ar length] >= 16)
                [segmentedControl setTitle:[self.strSelectedGenre_ar substringToIndex:16] forSegmentAtIndex:2];
            else
                [segmentedControl setTitle:self.strSelectedGenre_ar forSegmentAtIndex:2];
        }
    }
}

#pragma mark - Navigation bar buttons
- (void)setNavigationBarButtons
{
  //  [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)], [CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)]];
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

#pragma mark - UINavigationBar Button Action

- (void)btnMelodyIconAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoVODHomeNoti" object:nil userInfo:nil];
}

- (void)backBarButtonItemAction
{
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
    [popOverGenre dismissPopoverAnimated:YES];
    
    objSettingViewController = [[SettingViewController alloc] init];
    objSettingViewController.delegate = self;
    popOverSettings = [[UIPopoverController alloc] initWithContentViewController:objSettingViewController];
    popOverSettings.popoverBackgroundViewClass = [popoverBackgroundView class];
    
    [popOverSettings setDelegate:self];
    
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
    
    [popOverSettings presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
}

- (void)searchBarButtonItemAction
{
   /* if (self.searchBarVOD == nil) {
        self.searchBarVOD = [[UISearchBar alloc] initWithFrame:CGRectMake(510, 15, 230, 42)];
        self.searchBarVOD.delegate = self;
        self.searchBarVOD.tintColor = [UIColor clearColor];
        self.searchBarVOD.tintColor = [UIColor darkGrayColor];
        [self.navigationController.navigationBar addSubview:self.searchBarVOD];
        [self.searchBarVOD becomeFirstResponder];
        
        [self showSearchPopOver];
    } */
    VODSearchController *objVODSearchController = [[VODSearchController alloc] init];
    [self.navigationController pushViewController:objVODSearchController animated:NO];
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
    [popOverSettings dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopToLiveNowAfterLogout" object:nil];
}

- (void)changeLanguage
{
    [popOverSettings dismissPopoverAnimated:YES];
    LanguageViewController *objLanguageViewController = [[LanguageViewController alloc] init];
    objLanguageViewController.delegate = self;
    [self presentViewController:objLanguageViewController animated:YES completion:nil];
}

- (void)changeLanguageMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLiveNowSegmentedControl" object:self];

    [self setLocalizedText];
    if (iPreviousSegmentindex == 0 || iPreviousSegmentindex == 1) {
        [collectionVwSeries reloadData];
    }
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    if (iPreviousSegmentindex==2) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
            
            [segmentedControl setTitle:self.strSelectedGenre_en forSegmentAtIndex:2];
        else
            [segmentedControl setTitle:self.strSelectedGenre_ar forSegmentAtIndex:2];
    }
}

- (void)loginUser
{
    [popOverSettings dismissPopoverAnimated:YES];
    [self showLoginScreen];
}

- (void)companyInfoSelected:(int)infoType
{
    [popOverSettings dismissPopoverAnimated:YES];
    
    CompanyInfoViewController *objCompanyInfoViewController = [[CompanyInfoViewController alloc] initWithNibName:@"CompanyInfoViewController" bundle:nil];
    objCompanyInfoViewController.iInfoType = infoType;
    [self.navigationController pushViewController:objCompanyInfoViewController animated:YES];
}

- (void)sendFeedback
{
    [popOverSettings dismissPopoverAnimated:YES];
    FeedbackViewController *objFeedbackViewController = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:objFeedbackViewController animated:YES];
}

- (void)FAQCallBackMethod
{
    [popOverSettings dismissPopoverAnimated:YES];
    FAQViewController *objFAQViewController = [[FAQViewController alloc] init];
    [self.navigationController pushViewController:objFAQViewController animated:YES];
}

#pragma mark - Server Response

- (void)seriesResponse:(NSArray*)arrResponse
{
    lblNoResultFound.hidden = YES;
    self.arrSeries = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrSeries count] == 0 && segmentedControl.selectedSegmentIndex == 0) {
        lblNoResultFound.hidden = NO;
    }
    [collectionVwSeries reloadData];
}

- (void)episodeServerResponse:(NSArray*)arrResponse
{
    lblNoResultFound.hidden = YES;
    self.arrEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrEpisodes count] == 0) {
        lblNoResultFound.hidden = NO;
    }
    [collectionVwSeries reloadData];
}

- (void)genresServerResponse:(NSArray*)arrResponse
{
    CGRect collectionVwFrame = collectionVwSeries.frame;
    collectionVwFrame.origin.x = 10;
    collectionVwFrame.size.width = 748;
    collectionVwSeries.frame = collectionVwFrame;
    [collectionVwSeries reloadData];
    
    lblNoResultFound.hidden = YES;
    if ([arrResponse count] == 0) {
        lblNoResultFound.hidden = NO;
    }
    
    self.arrGenreSeries = [[NSMutableArray alloc] initWithArray:arrResponse];
    [collectionVwSeries reloadData];
}

#pragma mark - Register Colletion view cell
- (void)registerCollectionViewCell
{
    //Register for all series
    [collectionVwSeries registerNib:[UINib nibWithNibName:@"VODFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"vodfeaturecell"];
    [collectionVwSeries registerNib:[UINib nibWithNibName:@"VODMoviesFeaturedCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"fetauredSeries"];
}

#pragma mark - UISegmentedControl Methods
- (IBAction)segmentControlIndexChanged
{
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];

    iPreviousSegmentindex = (int)segmentedControl.selectedSegmentIndex;
    
    lblNoResultFound.hidden = YES;

    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            if ([self.arrSeries count] == 0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    lblNoResultFound.hidden = NO;
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    Series *objSeries = [Series new];
                    [objSeries fetchAllSeries:self selector:@selector(seriesResponse:) isArb:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]?@"true":@"false"];
                }
            }
            else
            {
                lblNoResultFound.hidden = YES;
            }
            
            CGRect collectionVwFrame = collectionVwSeries.frame;
            collectionVwFrame.origin.x = 10;
            collectionVwFrame.size.width = 748;
            collectionVwSeries.frame = collectionVwFrame;
            [collectionVwSeries reloadData];
            break;
        }
        case 1:
        {
            if (![kCommonFunction checkNetworkConnectivity])
            {
                lblNoResultFound.hidden = NO;
                [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
            }
            else
            {
                if ([self.arrEpisodes count]==0) {
                    
                    Episodes *objEpisodes = [Episodes new];
                    [objEpisodes fetchFeaturedEpisodes:self selector:@selector(episodeServerResponse:) userId:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
                }
                else
                    lblNoResultFound.hidden = YES;
            }
            CGRect collectionVwFrame = collectionVwSeries.frame;
            collectionVwFrame.origin.x = 0;
            collectionVwFrame.size.width = 768;
            collectionVwSeries.frame = collectionVwFrame;
            [collectionVwSeries reloadData];
            break;
        }
        case 3:
        {
        }
        default:
        {
            [popOverGenre dismissPopoverAnimated:YES];
            [self showGenreView];
            break;
        }
    }
}

- (IBAction)btnGenreAction:(id)sender;
{
    segmentedControl.selectedSegmentIndex = 2;    
    [popOverGenre dismissPopoverAnimated:YES];
    [self showGenreView];
}

- (void)setSegmentedControlAppreance
{
    [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentMusicBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
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

- (void)showGenreView
{
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
    Genres *objGenres = [Genres new];
    [objGenres fetchGenres:self selector:@selector(fetchGenresServerResponse:) methodName:@"series"];
}

- (void)fetchGenresServerResponse:(NSArray*)arrResponse
{
    //Genres
    if ([arrResponse count] > 0) {
        
        GenresViewController *objGenresViewController = [[GenresViewController alloc] initWithNibName:@"GenresViewController" bundle:nil];
        objGenresViewController.arrGenresList = arrResponse;
        objGenresViewController.delegate = self;
        
        popOverGenre = [[UIPopoverController alloc] initWithContentViewController:objGenresViewController];
        popOverGenre.popoverBackgroundViewClass = [popoverBackgroundView class];
        [popOverGenre setDelegate:self];
        
        CGRect rect;
        rect.origin.x = 350;
        rect.origin.y = 5;
        rect.size.width = 0;
        rect.size.height = 0;
        CGRect rect1 = objGenresViewController.view.frame;
        [popOverGenre setPopoverContentSize:CGSizeMake(rect1.size.width, (arrResponse.count + 1) * 40)];
        [popOverGenre presentPopoverFromRect:rect inView:segmentedControl permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
}

#pragma mark - Genre Selected Delegate

- (void)genreIDSelected:(NSString *)genreID genreName_en:(NSString *)genreName_en genreName_ar:(NSString *)genreName_ar
{
    iPreviousSegmentindex = 2;
    [popOverGenre dismissPopoverAnimated:YES];
    NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:genreID forKey:@"GenereId" ];
    
    self.strSelectedGenre_en = [NSString stringWithFormat:@"%@", genreName_en];
    self.strSelectedGenre_ar = [NSString stringWithFormat:@"%@", genreName_ar];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        [segmentedControl setTitle:self.strSelectedGenre_en forSegmentAtIndex:2];
    else
        [segmentedControl setTitle:self.strSelectedGenre_ar forSegmentAtIndex:2];

    DetailGenres *objDetailGenres = [DetailGenres new];
    [objDetailGenres fetchGenreDetails:self selector:@selector(genresServerResponse:) parameters:dictParameters genreType:@"series"];
}

- (void)fetchEpisodesGenreSelectedSeries:(NSString*)seriesID seriesThumb:(NSString*)seriesThumb seriesName_en:(NSString *)seriesName_en seriesName_ar:(NSString *)seriesName_ar
{
    //Open series episodes view
    SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
    objSeriesEpisodesViewController.strSeriesId = seriesID;
    objSeriesEpisodesViewController.seriesUrl = seriesThumb;
    objSeriesEpisodesViewController.seriesName_en = seriesName_en;
    objSeriesEpisodesViewController.seriesName_ar = seriesName_ar;

    [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
}

- (void)playGenreSelectedMovie:(NSString*)seriesId
{
    //Open series episodes view
    SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
    objSeriesEpisodesViewController.strSeriesId = seriesId;
    [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger totalRows = 0;
    if (iPreviousSegmentindex == 0)
        totalRows = [self.arrSeries count];
    else if (iPreviousSegmentindex == 1)
        totalRows = [self.arrEpisodes count];
    else if (iPreviousSegmentindex == 2)
        totalRows = [self.arrGenreSeries count];
    
    return totalRows;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (iPreviousSegmentindex) {
        case 0:
        {
            VODFeaturedCollectionCell *cell = [collectionVwSeries dequeueReusableCellWithReuseIdentifier:@"vodfeaturecell" forIndexPath:indexPath];
            [cell setCellValuesForAllSeries:[self.arrSeries objectAtIndex:indexPath.row]];
            return cell;
        }
        case 1:
        {
            VODMoviesFeaturedCollectionCell *cell = [collectionVwSeries dequeueReusableCellWithReuseIdentifier:@"fetauredSeries" forIndexPath:indexPath];
            [cell setCellValuesSeriesEpisodes:[self.arrEpisodes objectAtIndex:indexPath.row]];
            return cell;
        }
        case 2:
        {
            VODFeaturedCollectionCell *cell = [collectionVwSeries dequeueReusableCellWithReuseIdentifier:@"vodfeaturecell" forIndexPath:indexPath];
            [cell setCellValuesForAllSeries:[self.arrGenreSeries objectAtIndex:indexPath.row]];
            return cell;
        }
        default:
            return nil;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (iPreviousSegmentindex) {
        case 0:
        {
            //Open series episodes view
            SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
            Serie *objSerie = (Serie*) [self.arrSeries objectAtIndex:indexPath.row];
            objSeriesEpisodesViewController.strSeriesId = objSerie.serieId;
            objSeriesEpisodesViewController.seriesUrl = objSerie.serieThumb;
            objSeriesEpisodesViewController.seriesName_en = objSerie.serieName_en;
            objSeriesEpisodesViewController.seriesName_ar = objSerie.serieName_ar;

            [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
            
            break;
        }
        case 1:
        {
          /*  MoviePlayerViewController *objMoviePlayerViewController = [[MoviePlayerViewController alloc] init];
            Episode *objEpisode = (Episode*) [self.arrEpisodes objectAtIndex:indexPath.row];
            objMoviePlayerViewController.strVideoUrl = objEpisode.episodeUrl;
            [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil]; */
            
            [self showEpisodeDetailView:indexPath.row];
            break;
        }
            
        case 2:
        {
            //Open series episodes view
            SeriesEpisodesViewController *objSeriesEpisodesViewController = [[SeriesEpisodesViewController alloc] initWithNibName:@"SeriesEpisodesViewController" bundle:nil];
            Serie *objSerie = (Serie*) [self.arrGenreSeries objectAtIndex:indexPath.row];
            objSeriesEpisodesViewController.strSeriesId = objSerie.serieId;
            objSeriesEpisodesViewController.seriesUrl = objSerie.serieThumb;
            objSeriesEpisodesViewController.seriesName_en = objSerie.serieName_en;
            objSeriesEpisodesViewController.seriesName_ar = objSerie.serieName_ar;
            
            [self.navigationController pushViewController:objSeriesEpisodesViewController animated:YES];
            
            break;
        }
        default:
            break;
    }
}

- (void)showEpisodeDetailView:(NSInteger)indexPathRow
{
    if (objEpisodeDetailViewController.view.superview) {
        return;
    }
    objEpisodeDetailViewController = nil;
    objEpisodeDetailViewController = [[EpisodeDetailViewController alloc] initWithNibName:@"EpisodeDetailViewController" bundle:nil];
    
    Episode *objEpisode = (Episode*) [self.arrEpisodes objectAtIndex:indexPathRow];
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
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:objEpisode.episodeUrl, episodeName, episodeDesc, objEpisode.seasonNum, objEpisode.episodeNum,[NSString stringWithFormat:@"%d", objEpisode.bIsExistsInWatchList], objEpisode.episodeId, objEpisode.seriesID, objEpisode.episodeDuration, seriesName, seriesDesc, objEpisode.episodeThumb,  [NSString stringWithFormat:@"%d",(int)objEpisode.seriesSeasonsCount], nil] forKeys:[NSArray arrayWithObjects:@"url", @"episodeName", @"episodeDesc", @"seasonNum", @"episodeNum", @"isExistsInWatchList", @"episodeId", @"seriesId", @"duration", @"seriesName", @"seriesDesc", @"episodethumb", @"seriesSeasonCount", nil]];
    
    objEpisodeDetailViewController.dictEpisodeData = dict;
    
    //Fetch and pass current view cgcontext for background display
    UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
    objEpisodeDetailViewController._imgViewBg = viewImage;
    
    objEpisodeDetailViewController.arrCastCrew = objEpisode.arrCastAndCrew;
    objEpisodeDetailViewController.arrProducers = objEpisode.arrProducers;

    [self.navigationController pushViewController:objEpisodeDetailViewController animated:NO];
}

#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize mElementSize;
    switch (iPreviousSegmentindex) {
        case 0:
        {
            mElementSize = CGSizeMake(366, 208);
            break;
        }
        case 1:
        {
            mElementSize = CGSizeMake(768, 319);
            break;
        }
        case 2:
        {
            mElementSize = CGSizeMake(366, 208);
            //[self showGenreView];
            break;
        }
        default:
            break;
    }
    
    return mElementSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            return 0;
    }
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (iPreviousSegmentindex == 0 || iPreviousSegmentindex == 2) {
        return 20;
    }
    return 0.0;
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
    if (popoverController == popOverSearch) {
        [self.searchBarVOD resignFirstResponder];
        [self.searchBarVOD removeFromSuperview];
        self.searchBarVOD = nil;
        self.searchBarVOD.delegate = nil;
    }

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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.searchBarVOD.delegate = nil;
}

@end