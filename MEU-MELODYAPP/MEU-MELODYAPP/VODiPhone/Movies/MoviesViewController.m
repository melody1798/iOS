//
//  MoviesViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MoviesViewController.h"
#import "CustomControls.h"
#import "CommonFunctions.h"
#import "FeaturedTableViewCustomCell.h"
#import "MoviesDetailViewController.h"
#import "CategoriesCustomCell.h"
#import "GenreDetailCustomCell.h"
#import "CollectionsDetailCustomCell.h"
#import "FeaturedMovies.h"
#import "FeaturedMovie.h"
#import "AtoZMovie.h"
#import "AtoZMovies.h"
#import "FeaturedMovies.h"
#import "Genre.h"
#import "Genres.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "DetailGenres.h"
#import "DetailGenre.h"
#import "MoviesCollections.h"
#import "MoviesCollection.h"
#import "MoviesInCollection.h"
#import "MovieInCollection.h"
#import "AppDelegate.h"
#import "VODCategoryViewController.h"
#import "SettingViewController.h"
#import "VODSegmentControl.h"

static int offset = 0;
static int offsetIOS6 = 20;
static int offsetIOS6Height = 10;
static int offsetIOS6iPhone4 = 40;
@interface MoviesViewController ()

@property (strong, nonatomic) NSString*     strCollectionName;
@property (strong, nonatomic) NSString*     strCollectionNameAr;

@property (strong, nonatomic) NSString*     strGenreName;
@property (strong, nonatomic) NSString*     strGenreNameAr;
@property (strong, nonatomic) NSString*     strPreviousLanguage;
@property (strong, nonatomic) NSString*     strGenreId;


- (IBAction)btnGenreAction:(id)sender;

@end

@implementation MoviesViewController
@synthesize strCollectionNameAr, strCollectionName, strGenreName, strGenreNameAr;


#define rectForNoVideo CGRectMake(10,170,300,29)
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

    self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];
    
    [self initUI];
    [collView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Movies"];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    tblMovies.hidden = YES;
    tblCollections.hidden = YES;
    tblGenre.hidden = YES;
    tblGenreDetail.hidden = YES;
    
    lblMovies.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"a-z" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"packs" value:@"" table:nil] forSegmentAtIndex:3];
    
    [segmentControl setUserInteractionEnabled:YES];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [lblNoVideoFound setHidden:NO];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        if (![self.strPreviousLanguage isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey]]) {
            
            self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];
            
            AtoZMovies *objAtoZMovies = [[AtoZMovies alloc]init];
            [objAtoZMovies fetchAtoZMovies:self selector:@selector(responseForAtoZMoviesAfterLanguageChange:)];
            
            if (genreDetail)
            {
                NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:self.strGenreId forKey:@"GenereId"];
                DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
                [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"movies"];
            }
            else
            {
                Genres *objGenres = [[Genres alloc] init];
                [objGenres fetchGenres:self selector:@selector(responseForGenres:) methodName:@"movies"];
            }
        }
        
        if (arrFeaturedMovies.count == 0)
        {
            FeaturedMovies *objFeaturedMovies = [[FeaturedMovies alloc] init];
            [objFeaturedMovies fetchFeaturedMovies:self selector:@selector(responseForFeaturedMovies:)];
        }
    }
    if (segmentControl.selectedSegmentIndex == 0)
        [tblMovies reloadData];
    
    else if (segmentControl.selectedSegmentIndex == 1)
    {
        [tblGenreDetail reloadData];
        [tblAlphabets reloadData];
    }
    
    else if (segmentControl.selectedSegmentIndex == 2)//refresh code if language change for genre case
    {
        [tblGenre reloadData];
        [tblGenreDetail reloadData];
        [tblAlphabets reloadData];
        
        if (genreDetail)
            lblMovies.text = [CommonFunctions isEnglish]?self.strGenreName:self.strGenreNameAr;
    }
    
    else if (segmentControl.selectedSegmentIndex == 3)
    {
        [tblCollections reloadData];
        [collView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
}

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
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

#pragma mark - Response For Services
-(void)responseForFeaturedMovies:(NSMutableArray *)arrFeaturedMoviesLocal
{
    arrFeaturedMovies = [arrFeaturedMoviesLocal mutableCopy];
    if([arrFeaturedMovies count] == 0)
        [lblNoVideoFound setHidden:NO];
    [tblMovies reloadData];
    AtoZMovies *objAtoZMovies = [[AtoZMovies alloc]init];
    [objAtoZMovies fetchAtoZMovies:self selector:@selector(responseForAtoZMovies:)];
}

-(void)responseForAtoZMoviesAfterLanguageChange:(NSMutableArray *)arrAtoZMoviesLocal
{
    arrAtoZMovies = [arrAtoZMoviesLocal mutableCopy];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        
        arrAlphabets = [CommonFunctions createArabicAlphabetsArray:arrAtoZMovies];
        arrAtoZMovies = [CommonFunctions returnArrayOfRecordForParticularAlphabetArabic:arrAtoZMovies arrayOfAphabetsToDisplay:arrAlphabets];
    }
    
    else
        arrAtoZMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabet:arrAtoZMovies arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
    
    [tblAlphabets reloadData];
    [tblGenreDetail reloadData];
}

-(void)responseForAtoZMovies:(NSMutableArray *)arrAtoZMoviesLocal
{
    arrAtoZMovies = [arrAtoZMoviesLocal mutableCopy];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        
        arrAlphabets = [CommonFunctions createArabicAlphabetsArray:arrAtoZMovies];
        arrAtoZMovies = [CommonFunctions returnArrayOfRecordForParticularAlphabetArabic:arrAtoZMovies arrayOfAphabetsToDisplay:arrAlphabets];
    }
    
    else
        arrAtoZMovies = [[CommonFunctions returnArrayOfRecordForParticularAlphabet:arrAtoZMovies arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
    
    [tblAlphabets reloadData];
    [tblGenreDetail reloadData];
    Genres *objGenres = [[Genres alloc] init];
    [objGenres fetchGenres:self selector:@selector(responseForGenres:) methodName:@"movies"];
    [self showOrHideAlphabeticalTable];
}

-(void) responseForGenres:(NSMutableArray *) arrGenresLocal
{
    arrGenres = [arrGenresLocal mutableCopy];
    [tblGenre reloadData];
    MoviesCollections *objMoviesCollections = [[MoviesCollections alloc] init];
    [objMoviesCollections fetchMoviesCollections:self selector:@selector(responseForMoviesCollection:)];
}

-(void) reponseForGenresService:(NSMutableArray *) arrDetailGenreLocal
{
    arrDetailGenre = [arrDetailGenreLocal mutableCopy];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        
        arrAlphabetsForGenre = [CommonFunctions createArabicAlphabetsArrayArabic:arrDetailGenre];
        arrDetailGenre = [CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenreArabic:arrDetailGenre arrayOfAphabetsToDisplay:arrAlphabetsForGenre];
    }
    
    else
        arrDetailGenre = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenre:arrDetailGenre arrayOfAphabetsToDisplay:arrAlphabetsForGenre] mutableCopy];
    
    [tblGenreDetail reloadData];
    [tblAlphabets reloadData];
    [self showOrHideControls:vwAToZ];
    
    [self showOrHideAlphabeticalTable];
    
    if([arrDetailGenre count] == 0)
    {
        [lblNoVideoFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoVideoFound];
    }
    
    else
        [btnGenre setEnabled:YES];
    
    [segmentControl setUserInteractionEnabled:YES];
}

-(void) responseForMoviesCollection:(NSMutableArray *)arrMoviesCollectionsLocal
{
    arrMoviesCollections = [arrMoviesCollectionsLocal mutableCopy];
    [tblCollections reloadData];
}

-(void)responseForDetailMovieCollection:(NSMutableArray *) arrMoviesInCollectionLocal
{
    arrMoviesInCollection = [arrMoviesInCollectionLocal mutableCopy];
    if([arrMoviesInCollection count] == 0)
    {
        [lblNoVideoFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoVideoFound];
        CGRect rect = lblNoVideoFound.frame;
        rect.origin.y += 20;
        [lblNoVideoFound setFrame:rect];
    }

    [vwCollections bringSubviewToFront:collParentView];
    [tblCollections setHidden:YES];
    [collView setHidden:NO];
    [collView reloadData];
}

#pragma mark - init UI
-(void) initUI
{
    lastSelectedIndex = 0;
    
    lblMovies.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil];
    lblNoVideoFound.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil];
    
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"a-z" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"packs" value:@"" table:nil] forSegmentAtIndex:3];
    
    [segmentControl setSelectedSegmentIndex:0];
    [lblCollectionName setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [lblNoVideoFound setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [collView registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReUse"];
    
    arrAlphabets = [[NSMutableArray alloc] init];
    arrFeaturedMovies = [[NSMutableArray alloc] init];
    arrAtoZMovies = [[NSMutableArray alloc] init];
    arrGenres = [[NSMutableArray alloc] init];
    arrDetailGenre = [[NSMutableArray alloc] init];
    arrMoviesCollections = [[NSMutableArray alloc] init];
    arrMoviesInCollection = [[NSMutableArray alloc] init];
    arrAlphabets = [[NSMutableArray alloc] init];
    arrAlphabetsForGenre = [[NSMutableArray alloc] init];
    
    tblAlphabets.sectionIndexColor = [UIColor colorWithRed:141/255.0 green:149/255.0 blue:158/255.0 alpha:1.0];
    if (IS_IOS7_OR_LATER)
    {
        [tblAlphabets setSectionIndexBackgroundColor:[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:25.0/255.0 alpha:1.0]];
        tblAlphabets.sectionIndexTrackingBackgroundColor = [UIColor whiteColor];
    }
    else
        tblAlphabets.sectionIndexTrackingBackgroundColor = [UIColor whiteColor];
    [lblMovies setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingBarButtonItemAction)];
    [self setSegmentedControlAppreance];
    
    if(iPhone4WithIOS7)
    {
        CGRect rect = vwCollections.frame;
        rect.origin.y += offset+20;
//        rect.size.height-=offset;
        rect.size.height-=offset;
        [vwCollections setFrame:rect];

        rect.size.height-=offset+10;
        [vwFeatured setFrame:rect];

        rect.size.height-=offset+15;
        [vwGenre setFrame:rect];
        
        rect.origin.y += offset/2;
        rect.size.height-=offset+52;
        [vwAToZ setFrame:rect];
        
        rect = segmentControl.frame;
        rect.origin.y += offset;
        [segmentControl setFrame:rect];
        
        rect = tblAlphabets.frame;
        rect.size.height-=offset+0;
        [tblAlphabets setFrame:rect];
        rect = tblCollections.frame;
        rect.size.height-=offset;
        
        rect.origin.y += 27;
        rect.size.height -= 62;
        
        [tblCollections setFrame:rect];
        rect = tblGenre.frame;
       // rect.size.width+=10;
        rect.size.height-=offset;
        rect.origin.y += 7;
        rect.size.height -= 30;
        [tblGenre setFrame:rect];
        rect = tblGenreDetail.frame;
        rect.size.height-=offset;
        [tblGenreDetail setFrame:rect];
        rect = tblMovies.frame;
       // rect.size.width +=10;
       // rect.size.height-=offset;
        
        rect.origin.y+=7;
        rect.size.height-=0;
        [tblMovies setFrame:rect];
        
        rect = collView.frame;
        rect.size.height-=50;
        [collView setFrame:rect];
        rect = headerView.frame;
        [headerView setFrame:rect];
        
        rect = tblGenreDetail.frame;
        rect.origin.y -= 5;
        [tblGenreDetail setFrame:rect];
        rect = tblAlphabets.frame;
        rect.origin.x += 0;
        rect.size.height-=offset;
        [tblAlphabets setFrame:rect];
        
        rect = tblGenreDetail.frame;
        rect.size.height-=offset+0;
        [tblGenreDetail setFrame:rect];
    }
    else if(!IS_IOS7_OR_LATER && [CommonFunctions isIphone])
    {
        segmentControl.frame = CGRectMake(0, [CommonFunctions isIphone5]?30:20, 320, segmentControl.frame.size.height);
        CGRect rect = vwCollections.frame;
        rect.origin.y += [CommonFunctions isIphone5]?offsetIOS6:offsetIOS6iPhone4;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:offsetIOS6iPhone4;
        [vwCollections setFrame:rect];
        [vwFeatured setFrame:rect];
        [vwGenre setFrame:rect];
        rect.origin.y += offset/2;
        [vwAToZ setFrame:rect];
        rect = segmentControl.frame;
        rect.origin.y += [CommonFunctions isIphone5]?offsetIOS6:offsetIOS6iPhone4;
        [segmentControl setFrame:rect];
        rect = tblAlphabets.frame;
        rect.size.height-=[CommonFunctions isIphone5]?50 : 80;
        [tblAlphabets setFrame:rect];
        rect = tblCollections.frame;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:offsetIOS6iPhone4;
        [tblCollections setFrame:rect];
        rect = tblGenre.frame;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:offsetIOS6iPhone4;
        [tblGenre setFrame:rect];
        rect = tblGenreDetail.frame;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:offsetIOS6iPhone4;
        [tblGenreDetail setFrame:rect];
        rect = tblMovies.frame;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:offsetIOS6iPhone4;
        [tblMovies setFrame:rect];
        rect = collView.frame;
        rect.size.height+=[CommonFunctions isIphone5]?offsetIOS6Height:20;
        [collView setFrame:rect];
        rect = tblGenreDetail.frame;
        rect.origin.y -= 5;
        rect.size.height -= [CommonFunctions isIphone5]?25:110;
        [tblGenreDetail setFrame:rect];
        rect = tblMovies.frame;
        rect.size.height -= [CommonFunctions isIphone5]?20:100;
        [tblMovies setFrame:rect];
        rect = tblGenre.frame;
        rect.size.height -= [CommonFunctions isIphone5]?20:100;
        [tblGenre setFrame:rect];
        rect = tblCollections.frame;
        rect.size.height -= [CommonFunctions isIphone5]?20:100;
        [tblCollections setFrame:rect];
        if(![CommonFunctions isIphone5])
        {
            rect = lblNoVideoFound.frame;
            rect.origin.y -= 75;
            lblNoVideoFound.frame = rect;
            rect = segmentControl.frame;
            rect.origin.x += 10;
            rect.origin.y -= 15;
            rect.size.width -= 20;
            [segmentControl setFrame:rect];
            rect = tblGenre.frame;
            rect.size.width += 10;
            [tblGenre setFrame:rect];
            rect = tblAlphabets.frame;
            rect.origin.x += 10;
            [tblAlphabets setFrame:rect];
            rect = tblGenreDetail.frame;
            rect.size.width += 10;
            [tblGenreDetail setFrame:rect];
            
            rect = tblMovies.frame;
            rect.origin.y += 6;
            rect.size.height -= 6;
            [tblMovies setFrame:rect];
            
            rect = tblGenreDetail.frame;
            rect.origin.y += 3;
            rect.size.height -= 3;
            [tblGenreDetail setFrame:rect];
            
            rect = tblGenre.frame;
            rect.origin.y += 6;
            rect.size.height -= 6;
            [tblGenre setFrame:rect];
        }
    }
}

#pragma mark - navigation controller button action events


-(void)settingBarButtonItemAction
{
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}

-(void)backBarButtonItemAction
{
    if(collectionDetail || genreDetail)
    {
        [self segmentedIndexChanged];
        return;
    }
    VODCategoryViewController *objVODCategoryViewController = [[VODCategoryViewController alloc] init];
    [CommonFunctions pushViewController:self.navigationController ViewController:objVODCategoryViewController];
}

#pragma mark - Back button for genre UI
-(void) setUIWhenGenreBackButtonClicked
{
    genreDetail = false;
    [self showOrHideControls:vwGenre];
    [self showOrHideAlphabeticalTable];
    [tblGenre reloadData];
    lastSelectedIndex = 2;
    lblMovies.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil];
}

#pragma mark - Set Default UI
-(void) setDefaultUI
{
    collectionDetail = false;
    genreDetail = false;
    [lblNoVideoFound setHidden:YES];
    [tblCollections setHidden:NO];
    [vwCollections bringSubviewToFront:tblCollections];
    lblMovies.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil];
    
    [lblNoVideoFound setFrame:rectForNoVideo];
    
    if(iPhone4WithIOS6)
    {
        CGRect rect = lblNoVideoFound.frame;
        rect.origin.y -= 75;
        lblNoVideoFound.frame = rect;
    }   
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
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

#pragma mark - IBAction Methods

- (IBAction)btnGenreAction:(id)sender
{
    if(genreDetail)
    {
        [self segmentedIndexChanged];
        return;
    }
    else
    {
        [self showOrHideControls:vwGenre];
        [self showOrHideAlphabeticalTable];
        
        if([arrGenres count] == 0 && !genreDetail)
        {
            [lblNoVideoFound setHidden:NO];
            [self.view bringSubviewToFront:lblNoVideoFound];
        }
        else
        {
            if ([arrGenres count]!=0) {
                [tblGenre reloadData];
            }
        }
        lastSelectedIndex = 2;
        segmentControl.selectedSegmentIndex = 2;
        genreDetail = YES;
    }
}

#pragma mark - UITableView delegate methods

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
{
    if(tableView == tblAlphabets)
        if([segmentControl selectedSegmentIndex] == 1)
            return arrAlphabets;
        else
            return arrAlphabetsForGenre;
    return Nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:0 inSection:index];
    @try
    {
        [UIView animateWithDuration:0.2 animations:^{
            [tblGenreDetail scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } completion:^(BOOL finished){
            //Do something after scrollToRowAtIndexPath finished, e.g.:
            [segmentControl setUserInteractionEnabled:YES];
        }];
    }
    @catch (NSException *exception)
    {
        DLog(@"%@",exception.description);
    }
    return index;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView==tblGenreDetail)
    {
        if([segmentControl selectedSegmentIndex] == 1)
            return [CommonFunctions returnViewForHeader:[arrAlphabets objectAtIndex:section] UITableView:tblGenreDetail];
        else
            return [CommonFunctions returnViewForHeader:[arrAlphabetsForGenre objectAtIndex:section] UITableView:tblGenreDetail];
    }
    return Nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==tblGenreDetail)
    {
        if(segmentControl.selectedSegmentIndex == 1)
        {
            if(([arrAtoZMovies count] == 0))
            {
                DLog(@"%d",section);
                return 0;
            }
            
            if([[arrAtoZMovies objectAtIndex:section] count] == 0)
            {
                DLog(@"%d",section);
                return 0;
            }
        }
        else
        {
            if(([arrDetailGenre count] == 0))
            {
                DLog(@"%d",section);
                return 0;
            }
            
            if([[arrDetailGenre objectAtIndex:section] count] == 0)
            {
                DLog(@"%d",section);
                return 0;
            }
        }
        
        return 19;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView==tblGenreDetail)
    {
        if([segmentControl selectedSegmentIndex] == 1)
            return [arrAlphabets objectAtIndex:section];
        else
            return [arrAlphabetsForGenre objectAtIndex:section];
    }
    return kEmptyString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == tblGenreDetail)
    {
        if(segmentControl.selectedSegmentIndex == 1)
            return [arrAtoZMovies count];
        else
            return [arrDetailGenre count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tblMovies)
        return [arrFeaturedMovies count];
    
    if(tableView == tblGenreDetail)
    {
        if(segmentControl.selectedSegmentIndex == 2)
        {
            if([arrDetailGenre count] ==0)
                return 0;
            
            return  [[arrDetailGenre objectAtIndex:section] count];
        }
        
        if (segmentControl.selectedSegmentIndex == 1) {
            if([arrAtoZMovies count] ==0)
                return 0;
            return [[arrAtoZMovies objectAtIndex:section] count];
        }
    }
    
    if(tableView == tblCollections)
        return [arrMoviesCollections count];
    
    if (tableView == tblGenre)
        return [arrGenres count];
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblMovies)
        return 200;
    else if (tableView == tblCollections)
        return 200;
    if(tableView == tblGenreDetail)
        return (iPhone5WithIOS7?104:100);//change by bharti
    
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==tblMovies)
    {
        tblMovies.hidden = NO;
        static NSString *cellIdentifier = @"cell";
        FeaturedTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell== nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
        [cell setBackgroundColor:[UIColor clearColor]];
        FeaturedMovie *objFeaturedMovie = [arrFeaturedMovies objectAtIndex:indexPath.row];
        [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objFeaturedMovie.movieThumbnail] placeholderImage:[UIImage imageNamed:@""]];
        cell.lblMovieName.text =  [CommonFunctions isEnglish]?objFeaturedMovie.movieTitle_en: objFeaturedMovie.movieTitle_ar;
        
        [cell.lblMovieName sizeToFit];
        CGRect rect = cell.lblMovieName.frame;
        CGRect rect1 = cell.lblSeperator.frame;
        [cell.lblSeperator setFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect1.origin.y, rect1.size.width, rect1.size.height)];
        rect1 = cell.lblSeperator.frame;
        
        rect = cell.lblEpisodeName.frame;
        rect.origin.x = rect1.origin.x + rect1.size.width + 2;
        [cell.lblEpisodeName setFrame:rect];
        [cell.lblEpisodeName sizeToFit];
        if([cell.lblEpisodeName.text isEqualToString:@""])
        {
            [cell.lblSeperator setHidden:YES];
        }
//
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if(tableView==tblCollections)
    {
        tblCollections.hidden = NO;

        static NSString *cellIdentifier = @"cell";
        FeaturedTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell== nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
        [cell setBackgroundColor:[UIColor clearColor]];
        MoviesCollection *objMoviesCollection = [arrMoviesCollections objectAtIndex:indexPath.row];
        [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objMoviesCollection.collectionThumb] placeholderImage:[UIImage imageNamed:@""]];
        cell.lblMovieName.text =  [CommonFunctions isEnglish]?objMoviesCollection.collectionName_en:objMoviesCollection.collectionName_ar;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.lblMovieName sizeToFit];
        CGRect rect = cell.lblMovieName.frame;
        CGRect rect1 = cell.lblSeperator.frame;
        [cell.lblSeperator setFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect1.origin.y, rect1.size.width, rect1.size.height)];
        rect1 = cell.lblSeperator.frame;
        
        rect = cell.lblEpisodeName.frame;
        rect.origin.x = rect1.origin.x + rect1.size.width + 2;
        [cell.lblEpisodeName setFrame:rect];
        [cell.lblEpisodeName sizeToFit];
        if([cell.lblEpisodeName.text isEqualToString:@""])
        {
            [cell.lblSeperator setHidden:YES];
        }
        
        return cell;
    }
    else if(tableView == tblGenre)
    {
        tblGenre.hidden = NO;

        static NSString *cellIdentifier = @"cell";
        CategoriesCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell== nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoriesCustomCell" owner:self options:nil] firstObject];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        Genre *objGenre = [arrGenres objectAtIndex:indexPath.row];
        cell.lblCategories.text =  [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
        CGRect rect = cell.imgArrow.frame;
        rect.origin.x = rect.origin.x-15;
        [cell.imgArrow setFrame:rect];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(tableView == tblGenreDetail)
    {
        tblGenreDetail.hidden = NO;
        
        static NSString *cellIdentifier = @"cell";
        GenreDetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell== nil)
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GenreDetailCustomCell" owner:self options:nil] firstObject];
        if(segmentControl.selectedSegmentIndex == 2)
        {
            DetailGenre *objDetailGenre = (DetailGenre*)[[arrDetailGenre objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            cell.lblTime.text = [objDetailGenre.movieDuration length]>0?[CommonFunctions isEnglish]?[NSString stringWithFormat:@"%@ %@", objDetailGenre.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]]:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objDetailGenre.movieDuration]:@"";
            
            NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:cell.lblTime.text fontName:kProximaNova_Regular];
            cell.lblTime.attributedText = strAtt;
            
            cell.lblName.text = [CommonFunctions isEnglish]?objDetailGenre.movieTitle_en:objDetailGenre.movieTitle_ar;
            /*Dummy Code*/
           // cell.lblAbbr.text = @"-";
            CGSize size = [@"-" sizeWithFont:[UIFont fontWithName:kProximaNova_Regular size:14.0]];
            /*End of Dummy Code*/
            size.height += 4;
            size.width += 4;
            [[cell lblAbbr] setFrame:CGRectMake(cell.lblAbbr.frame.origin.x, cell.lblAbbr.frame.origin.y, size.width, size.height)];
            [cell.lblAbbr setBackgroundColor:[UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0]];
            [cell.imgMovies sd_setImageWithURL:[NSURL URLWithString:objDetailGenre.movieThumbnail] placeholderImage:[UIImage imageNamed:@""]];
            cell.backgroundColor = [UIColor clearColor];
        }
        else if (segmentControl.selectedSegmentIndex == 1)
        {
            AtoZMovie *objAtoZMovie = (AtoZMovie*)
            [[arrAtoZMovies objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            if ([objAtoZMovie.movieDuration length]!=0)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic])
                {
                    NSString *lbltext  = [NSString stringWithFormat:@"%@ %@",  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil], objAtoZMovie.movieDuration];
                    NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:lbltext fontName:kProximaNova_Regular];
                    cell.lblTime.attributedText = strAtt;
                }
                else
                    cell.lblTime.text = [NSString stringWithFormat:@"%@ %@", objAtoZMovie.movieDuration, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"min" value:@"" table:nil]];
            }
            
            cell.lblName.text = [CommonFunctions isEnglish]?objAtoZMovie.movieName_en:objAtoZMovie.movieName_ar;
            
            /*Dummy Code*/
           // cell.lblAbbr.text = @"-";
            CGSize size = [@"-" sizeWithFont:[UIFont fontWithName:kProximaNova_Regular size:14.0]];
            /*End of Dummy Code*/
            size.height += 4;
            size.width += 4;
            
            [[cell lblAbbr] setFrame:CGRectMake(cell.lblAbbr.frame.origin.x, cell.lblAbbr.frame.origin.y, size.width, size.height)];
            [cell.lblAbbr setBackgroundColor:[UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0]];
            [cell.imgMovies sd_setImageWithURL:[NSURL URLWithString:objAtoZMovie.movieThumbNail] placeholderImage:[UIImage imageNamed:@""]];
        }
        
        CGSize size = [cell.lblName.text sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
        if(size.width<[[cell lblName] frame].size.width)
        {
            [[cell lblAbbr] setFrame:CGRectMake(cell.lblAbbr.frame.origin.x, cell.lblAbbr.frame.origin.y-7,cell.lblAbbr.frame.size.width, cell.lblAbbr.frame.size.height)];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];

        return cell;
    }
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
//    [cell setBackgroundColor:[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0]];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    if((tableView == tblMovies) || (tableView == tblGenreDetail))
    {
        if(segmentControl.selectedSegmentIndex!=3)
        {
            NSString *movieId = kEmptyString;
            NSString *movieThumbnail = kEmptyString;
            if(tableView == tblMovies)
            {
                FeaturedMovie *objFeaturedMovie = [arrFeaturedMovies objectAtIndex:indexPath.row];
                movieId = objFeaturedMovie.movieID;
                movieThumbnail = objFeaturedMovie.movieThumbnail;
            }
            else if(tableView == tblGenreDetail)
            {
                if(segmentControl.selectedSegmentIndex==1)
                {
                    NSMutableArray *arrAtoZMoviesLocal = [arrAtoZMovies objectAtIndex:indexPath.section];
                    AtoZMovie *objAtoZMovie = [arrAtoZMoviesLocal objectAtIndex:indexPath.row];
                    movieThumbnail = objAtoZMovie.movieThumbNail;
                    movieId = objAtoZMovie.movieId;
                }
                else
                {
                    NSMutableArray *arrDetailGenreLocal = [arrDetailGenre objectAtIndex:indexPath.section];
                    DetailGenre *objDetailGenre = [arrDetailGenreLocal objectAtIndex:indexPath.row];
                    movieId = objDetailGenre.movieID;
                    movieThumbnail = objDetailGenre.movieThumbnail;
                }
            }
            [self redirectToMovieDetailPage:movieId movieThumbnail:movieThumbnail];
        }
    }
    if(tableView==tblCollections)
    {
        collectionDetail = true;
        [collView setHidden:YES];
        MoviesCollection *objMovieCollection =[arrMoviesCollections objectAtIndex:indexPath.row];
        NSDictionary *dictParameter = [NSDictionary dictionaryWithObject:objMovieCollection.collectionId forKey:@"collectionId"];
        
        lblCollectionName.text = @"";
        lblCollectionName.text = [CommonFunctions isEnglish]?objMovieCollection.collectionName_en:objMovieCollection.collectionName_ar;
        self.strCollectionName = [NSString stringWithFormat:@"%@", objMovieCollection.collectionName_en];
        self.strCollectionNameAr = [NSString stringWithFormat:@"%@", objMovieCollection.collectionName_ar];
        
        MoviesInCollection *objMoviesInCollection = [[MoviesInCollection alloc] init];
        nestedSelectedIndex = (int)indexPath.row;
        [objMoviesInCollection fetchCollectionMovies:self selector:@selector(responseForDetailMovieCollection:) parameters:dictParameter];
    }
    else if(tableView == tblGenre)
    {
        genreDetail = true;
        Genre *objGenre = [arrGenres objectAtIndex:indexPath.row];
        nestedSelectedIndex = (int)indexPath.row;
        self.strGenreName = objGenre.genreName_en;
        self.strGenreNameAr = objGenre.genreName_ar;
        
        lblMovies.text = [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
        self.strGenreId = objGenre.genreId;
        NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:objGenre.genreId forKey:@"GenereId"];
        DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
        [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"movies"];
    }
}

#pragma Enable Segment Control
-(void) enableSegmentControl
{
    [segmentControl setUserInteractionEnabled:YES];
}

#pragma UIScrollview Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == tblGenreDetail)
    {
        [segmentControl setUserInteractionEnabled:NO];
        btnGenre.enabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == tblGenreDetail)
    {
        [segmentControl setUserInteractionEnabled:YES];
        btnGenre.enabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(scrollView == tblGenreDetail)
    {
        [segmentControl setUserInteractionEnabled:YES];
        btnGenre.enabled = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == tblGenreDetail)
    {
        [segmentControl setUserInteractionEnabled:YES];
        btnGenre.enabled = YES;
    }
}

#pragma mark - segment Index changed
- (IBAction)segmentedIndexChanged
{
    [self setDefaultUI];
    switch (segmentControl.selectedSegmentIndex)
    {
        case 0:
            [tblMovies setContentOffset:CGPointZero];
            [self showOrHideControls:vwFeatured];
            if([arrFeaturedMovies count] == 0)
            {
                if ([kCommonFunction checkNetworkConnectivity])
                {
                    FeaturedMovies *objFeaturedMovies = [[FeaturedMovies alloc] init];
                    [objFeaturedMovies fetchFeaturedMovies:self selector:@selector(responseForFeaturedMovies:)];
                }
                else
                {
                    [lblNoVideoFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoVideoFound];
                }
            }
            lastSelectedIndex = 0;
            [tblMovies reloadData];
            break;
            
        case 1:
            [self showOrHideControls:vwAToZ];
            [segmentControl setUserInteractionEnabled:YES];
            [self showOrHideAlphabeticalTable];

            if([arrAlphabets count] == 0)
            {
                if ([kCommonFunction checkNetworkConnectivity])
                {
                    AtoZMovies *objAtoZMovies = [[AtoZMovies alloc]init];
                    [objAtoZMovies fetchAtoZMovies:self selector:@selector(responseForAtoZMovies:)];
                }
                else
                {
                    [lblNoVideoFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoVideoFound];
                }
            }
            else
            {
                [tblAlphabets reloadData];
                [tblGenreDetail reloadData];
            }
            lastSelectedIndex = 1;
            
            [tblGenreDetail reloadData];
            [tblAlphabets reloadData];
            break;
            
        case 2:
            
            [self showOrHideControls:vwGenre];
            [self showOrHideAlphabeticalTable];
            
            
            if([arrGenres count] == 0 && !genreDetail)
            {
                [lblNoVideoFound setHidden:NO];
                [self.view bringSubviewToFront:lblNoVideoFound];
            }
            else
                if ([arrGenres count]!=0) {
                    [tblGenre reloadData];
                }
            lastSelectedIndex = 2;
            [tblGenre reloadData];
            [tblGenreDetail reloadData];
            [tblAlphabets reloadData];
            break;
            
        case 3:
            lastSelectedIndex = 3;
            [tblCollections setContentOffset:CGPointZero];
            [self showOrHideControls:vwCollections];
            
            if([arrMoviesCollections count] ==0 && !collectionDetail)
            {
                [lblNoVideoFound setHidden:NO];
                [self.view bringSubviewToFront:lblNoVideoFound];
            }
            
            [tblCollections reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Collection View delagate methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [arrMoviesInCollection count];
        default:
            break;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.section) {
        case 0:
        {
            UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
            
            if (lblCollectionName==nil) {
                lblCollectionName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 21)];
                lblCollectionName.backgroundColor = [UIColor clearColor];
                lblCollectionName.textAlignment = NSTextAlignmentCenter;
                lblCollectionName.tag = 100;
                lblCollectionName.textColor = YELLOW_COLOR;
                lblCollectionName.font = [UIFont fontWithName:kProximaNova_Regular size:20.0];
                lblCollectionName.text = [CommonFunctions isEnglish]?self.strCollectionName:self.strCollectionNameAr;
                [cell addSubview:lblCollectionName];
            }
            lblCollectionName.text = [CommonFunctions isEnglish]?self.strCollectionName:self.strCollectionNameAr;
            return cell;
        }
        case 1:
        {
            static NSString *cellIdentifier = @"CollectionsDetailCustomCellReUse";
            CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            if(cell==nil)
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
            
            MovieInCollection *objMovieCollection = [arrMoviesInCollection objectAtIndex:indexPath.row];
            [cell setBackgroundColor:color_Background];
            [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objMovieCollection.thumbUrl] placeholderImage:[UIImage imageNamed:@""]];
            cell.lblName.numberOfLines = 0;
            cell.lblName.font = [UIFont fontWithName:kProximaNova_Bold size:14.0];
            
            cell.lblName.text = [CommonFunctions isEnglish]?objMovieCollection.movieName_en:objMovieCollection.movieName_ar;
            
            CGSize size = [cell.lblName.text sizeWithFont:[UIFont fontWithName:kProximaNova_Bold size:14.0] constrainedToSize:CGSizeMake(CGRectGetWidth(cell.lblName.frame), 28)];
            
            cell.lblName.frame = CGRectMake(0, 87, CGRectGetWidth(cell.frame), size.height);
            
            [cell.imgMovie setFrame:CGRectMake(0, 0, CGRectGetWidth(cell.frame), 82)];
            return cell;
        }
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *movieId = kEmptyString;
    NSString *movieThumbnail = kEmptyString;
    
    MovieInCollection *objMovieCollection = [arrMoviesInCollection objectAtIndex:indexPath.row];
    movieId = objMovieCollection.movieID;
    movieThumbnail = objMovieCollection.thumbUrl;
    
    [self redirectToMovieDetailPage:movieId movieThumbnail:movieThumbnail];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return CGSizeMake(300, 30);
        case 1:
            return CGSizeMake(144, 115);
        default:
            break;
    }
    
    return CGSizeMake(144, 115);
}

#pragma mark - redirect to movie detail page
-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail
{
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[MoviesDetailViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    if(!objMoviesDetailViewController)
        objMoviesDetailViewController = [[MoviesDetailViewController alloc] initWithNibName:@"MoviesDetailViewController~iphone" bundle:nil];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int) movie];
    [objMoviesDetailViewController setVideoType:1];
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}

#pragma mark - show or hide controls
-(void) showOrHideControls:(UIView *)vw
{
    [vwFeatured setHidden:YES];
    [vwAToZ setHidden:YES];
    [vwCollections setHidden:YES];
    [vwGenre setHidden:YES];
    [vw setHidden:NO];
   // [self.view bringSubviewToFront:vw];
}

#pragma ShowOrHideTable if no data
-(void) showOrHideAlphabeticalTable
{
    if([segmentControl selectedSegmentIndex] == 1)
    {
        if([arrAlphabets count] == 0)
        {
            [tblGenreDetail setHidden:YES];
            [tblAlphabets setHidden:YES];
        }
        else
        {
            [tblGenreDetail setHidden:NO];
            [tblAlphabets setHidden:NO];
        }
    }
    else
    {
        if([arrAlphabetsForGenre count] == 0)
        {
            [tblGenreDetail setHidden:YES];
            [tblAlphabets setHidden:YES];
        }
        else
        {
            [tblGenreDetail setHidden:NO];
            [tblAlphabets setHidden:NO];
        }
    }
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