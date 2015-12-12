//
//  MusicViewController.m
//  MEU-MELODYAPP
//
//  Created by Channi on 8/20/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesViewController.h"
#import "CommonFunctions.h"
#import "CustomControls.h"
#import "VODCategoryViewController.h"
#import "FeaturedMusics.h"
#import "FeaturedMusic.h"
#import "UIImageView+WebCache.h"
#import "FeaturedTableViewCustomCell.h"
#import "MusicSinger.h"
#import "MusicSingers.h"
#import "Genres.h"
#import "Genre.h"
#import "CategoriesCustomCell.h"
#import "DetailGenres.h"
#import "GenreDetailCustomCell.h"
#import "DetailGenre.h"
#import "SingerVideo.h"
#import "SingerVideos.h"
#import "SingerDetailTableViewCell.h"
#import "MoviesDetailViewController.h"
#import "CollectionsDetailCustomCell.h"
#import "Series.h"
#import "Serie.h"
#import "Episode.h"
#import "Episodes.h"
#import "SeriesSeasons.h"
#import "SeriesSeason.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
@interface SeriesViewController ()
{
    IBOutlet UIImageView*       imgVwBarBg;
    NSString        *seasonNum;
}

@property (strong, nonatomic) NSString*     episodeDesc;
@property (strong, nonatomic) NSString*     episodeId;
@property (strong, nonatomic) NSString*     episodeVideoUrl;
@property (strong, nonatomic) NSString*     episodeDuration;
@property (assign, nonatomic) NSInteger     selectedIndex;

@property (strong, nonatomic) NSString*     genreNameEng, *genreNameAr;

@property int allSeriesIndex, genreSubDetailIndex;


- (IBAction)btnGenreAction:(id)sender;

@end

@implementation SeriesViewController

@synthesize genreNameAr, genreNameEng;


#define koriginalRectForNoRecord CGRectMake(10,170,300,29)
#define koriginalRectForNoRecordForiPhone4Ios6 CGRectMake(10,90,300,29)
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
    

    
    segmentControl.selectedSegmentIndex = 0;
    
    isGenreDetail = 0;
    tblSeries.sectionIndexColor = [UIColor colorWithRed:141/255.0 green:149/255.0 blue:158/255.0 alpha:1.0];
    if (IS_IOS7_OR_LATER)
        [tblSeries setSectionIndexBackgroundColor:[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:25.0/255.0 alpha:1.0]];
    else
        tblSeries.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:25.0/255.0 alpha:1.0];
    arrAlphabetsForGenre = [[NSMutableArray alloc] init];

    [self initUI];
    [self setFonts];
    [self registerCollectionViewCell];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Series"];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil];
    
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"all series" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured episodes" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];
    
    [lblNoRecordFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];
    
    if (![kCommonFunction checkNetworkConnectivity])
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        [self fetchSeries];
        [self fetchFeaturedEpisodes];
    }
    if (segmentControl.selectedSegmentIndex == 1 || segmentControl.selectedSegmentIndex == 0 || segmentControl.selectedSegmentIndex == 2)
        [tblSeries reloadData];
    
    if (vwSeriesDetail.hidden == NO && seriesDetailPage)
    {
        Serie *objSerie = [arrSeries objectAtIndex:self.allSeriesIndex];
        lblSeriesName.text = ([CommonFunctions isEnglish]?objSerie.serieName_en:objSerie.serieName_ar);
        
        [collView reloadData];
        [pckVw reloadAllComponents];
        
        if (lblSelectSeason.hidden == NO)
        {
            lblSelectSeason.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], [[lblSelectSeason.text componentsSeparatedByString:@" "] lastObject]];
            
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 180, CGRectGetHeight(lblSeriesName.frame));
        }
        
        else
        {
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 300, CGRectGetHeight(lblSeriesName.frame));
        }
    }
    
    if (isGenreDetail == 1)
    {
        Genre *objGenre = [arrGenres objectAtIndex:nestedSlctdIndex];
        lblMusicName.text = [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
        //[tblSeries reloadData];
        
        NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:objGenre.genreId forKey:@"GenereId"];
        genreDetailPage = YES;
        DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
        [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"series"];
    }
    if (isGenreDetail == 0) {
        [self fetchSeriesGenres];
    }
    if (genreSubDetailPage)//collView.hidden == NO ||
    {
        Serie *objSerieGenre = [arrGenreDetail objectAtIndex:self.genreSubDetailIndex];
        
        lblSeriesName.text = ([CommonFunctions isEnglish]?objSerieGenre.serieName_en:objSerieGenre.serieName_ar);
        
        [collView reloadData];
        [pckVw reloadAllComponents];
        
        if (lblSelectSeason.hidden == NO)
        {
            lblSelectSeason.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], [[lblSelectSeason.text componentsSeparatedByString:@" "] lastObject]];
            
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 180, CGRectGetHeight(lblSeriesName.frame));
        }
        
        else
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 300, CGRectGetHeight(lblSeriesName.frame));
    }
}


#pragma mark - Register Collection view cell
-(void) registerCollectionViewCell
{
    [collView registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:Nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReuse"];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
    [self removePickerView];
}

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
}

#pragma mark -  Remove Picker View
-(void) removePickerView
{
    [self showTabBar];
    [pckVw removeFromSuperview];
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

#pragma mark - Fetch Series
-(void) fetchSeries
{
    Series *objSeries = [Series new];
    [objSeries fetchAllSeries:self selector:@selector(seriesResponse:) isArb:[[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]?@"true":@"false"];
}


#pragma mark - InitUI

- (void)initUI
{
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil];
    
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"all series" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured episodes" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingBarButtonItemAction)];
    [self setSegmentedControlAppreance];
    
    [lblNoRecordFound setFrame:IS_IOS7_OR_LATER?koriginalRectForNoRecord:koriginalRectForNoRecordForiPhone4Ios6];
    
    if(iPhone4WithIOS7)
    {
        CGRect vwSeriesFrame = vwSeriesDetail.frame;
        vwSeriesFrame.size.height -= 85;
        vwSeriesDetail.frame = vwSeriesFrame;
        
        CGRect rect = collView.frame;
        rect.origin.y += 34;
        rect.origin.y -= 5;
        [collView setFrame:rect];
    }
    if(iPhone4WithIOS6)
    {
        CGRect rect = lblSeriesName.frame;
        rect.size.width -= 20;
        [lblSeriesName setFrame:rect];
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
    
    
    if(iPhone4WithIOS7)
    {
        CGRect rect = headerView.frame;
        rect.origin.y += 20;
        [headerView setFrame:rect];
        
        rect = tblSeries.frame;
        rect.origin.y += 30;
        rect.size.height -= 40;
        [tblSeries setFrame:rect];
        
        rect = collView.frame;
        rect.origin.y += 30;
        rect.size.height -= 45;
        [collView setFrame:rect];
    }
}

#pragma mark - navigation controller button action events
-(void)settingBarButtonItemAction
{
    [self showTabBar];
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}

-(void)backBarButtonItemAction
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    if (isGenreDetail == 1)
    {
        Genre *objGenre = [arrGenres objectAtIndex:nestedSlctdIndex];
        lblMusicName.text = [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
        [tblSeries reloadData];
    }
    
    else
        lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil];
    
    [self removePickerView];
    if(seriesDetailPage)
    {
        [self setDefaultUIForSegment];
        [vwSeriesDetail setHidden:YES];
        [imgVwBarBg setHidden:YES];
        
       // lblSelectSeason.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"select season" value:@"" table:nil];;
        [collView setHidden:YES];
        return;
    }
    
    if(genreSubDetailPage)
    {
        [self setDefaultUIForSegment];
        [vwSeriesDetail setHidden:YES];
        [imgVwBarBg setHidden:YES];

       // lblSelectSeason.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"select season" value:@"" table:nil];
        [collView setHidden:YES];
        isGenreDetail = 1;
        [tblSeries reloadData];
        return;
    }
    
    if(isGenreDetail)
    {
        [self segmentedIndexChanged];
        return;
    }
    
    VODCategoryViewController *objVODCategoryViewController = [[VODCategoryViewController alloc] init];
    [CommonFunctions pushViewController:self.navigationController ViewController:objVODCategoryViewController];
}

- (IBAction)btnGenreAction:(id)sender
{
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    [self setDefaultUIForSegment];
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil];
    
    if(isGenreDetail)
    {
        [self segmentedIndexChanged];
        return;
    }
    
    else
    {
        if (![arrGenres count]>0)
        {
            [self fetchSeriesGenres];
            segmentControl.selectedSegmentIndex = 2;
        }
        else if ([arrGenres count]>0 && isGenreDetail == 0)
        {
            segmentControl.selectedSegmentIndex = 2;
            [tblSeries reloadData];
        }
        else
        {
            segmentControl.selectedSegmentIndex = 2;
            [tblSeries reloadData];
        }
    }
}

#pragma mark - setFonts
-(void) setFonts
{
    [lblNoRecordFound setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [lblMusicName setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [lblSeriesName setFont:[UIFont fontWithName:kProximaNova_Bold size:16.0]];
    [lblSelectSeason setFont:[UIFont fontWithName:kProximaNova_Bold size:10.0]];
}

#pragma mark UITableView Delegate
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
{
//    if((segmentControl.selectedSegmentIndex == 2) && (isGenreDetail == 1))
//        return arrAlphabetsForGenre;
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if((segmentControl.selectedSegmentIndex == 2) && (isGenreDetail == 1))
    {
        //return [CommonFunctions returnViewForHeader:[arrAlphabetsForGenre objectAtIndex:section] UITableView:tblSeries];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if((segmentControl.selectedSegmentIndex == 2) && (isGenreDetail == 1))
    {
        if(([arrGenreDetail count] == 0))
        {
            DLog(@"%d",section);
            return 0;
        }
        
        if([arrGenreDetail count] == 0)
        {
            DLog(@"%d",section);
            return 0;
        }
        
        return 0;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(segmentControl.selectedSegmentIndex == 2 && isGenreDetail == 1)
    {
       // return [arrAlphabetsForGenre objectAtIndex:section];
        
    }
    return kEmptyString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (segmentControl.selectedSegmentIndex == 0)
        return 1;
    if (segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 1)
        {
            return 1;
           // return [arrGenreDetail count];
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 0)
        return [arrSeries count];
    else if (segmentControl.selectedSegmentIndex == 1)
    {
        return [arrEpisodes count];
    }
    else if (segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 0)
        {
            return [arrGenres count];
        }
        else
        {
            if([arrGenreDetail count] ==0)
                return 0;
            return  [arrGenreDetail count];
        }
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentControl.selectedSegmentIndex == 0)
        return 200;
    
    else if (segmentControl.selectedSegmentIndex == 1)
        return 200;
    
    else if (segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 0)
        {
            return 49;
        }
        else
        {
            return 200;
        }
    }
    else
        return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segmentControl.selectedSegmentIndex == 0)
    {
        static NSString *cellIdentifier = @"cell";
        FeaturedTableViewCustomCell *objFeaturedTableViewCustomCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(objFeaturedTableViewCustomCell== nil)
            objFeaturedTableViewCustomCell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
        [objFeaturedTableViewCustomCell setBackgroundColor:[UIColor blackColor]];
        Serie *objSerie = [arrSeries objectAtIndex:indexPath.row];
        [objFeaturedTableViewCustomCell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objSerie.serieThumb] placeholderImage:[UIImage imageNamed:@""]];
        
        objFeaturedTableViewCustomCell.lblMovieName.text =  ([CommonFunctions isEnglish]?objSerie.serieName_en:objSerie.serieName_ar);
        objFeaturedTableViewCustomCell.lblMovieName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
        objFeaturedTableViewCustomCell.selectionStyle = UITableViewCellSelectionStyleNone;
        objFeaturedTableViewCustomCell.backgroundColor = [UIColor clearColor];
        
        [objFeaturedTableViewCustomCell.lblMovieName sizeToFit];
        CGRect rect = objFeaturedTableViewCustomCell.lblMovieName.frame;
        CGRect rect1 = objFeaturedTableViewCustomCell.lblSeperator.frame;
        [objFeaturedTableViewCustomCell.lblSeperator setFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect1.origin.y, rect1.size.width, rect1.size.height)];
        rect1 = objFeaturedTableViewCustomCell.lblSeperator.frame;
        
        rect = objFeaturedTableViewCustomCell.lblEpisodeName.frame;
        rect.origin.x = rect1.origin.x + rect1.size.width + 2;
        [objFeaturedTableViewCustomCell.lblEpisodeName setFrame:rect];
        [objFeaturedTableViewCustomCell.lblEpisodeName sizeToFit];
        
        if([objFeaturedTableViewCustomCell.lblEpisodeName.text isEqualToString:@""])
        {
            [objFeaturedTableViewCustomCell.lblSeperator setHidden:YES];
        }
        
        return objFeaturedTableViewCustomCell;
    }
    else if (segmentControl.selectedSegmentIndex == 1)
    {
        static NSString *cellIdentifier = @"cellSinger";
        FeaturedTableViewCustomCell *objFeaturedTableViewCustomCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(objFeaturedTableViewCustomCell== nil)
            objFeaturedTableViewCustomCell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
        [objFeaturedTableViewCustomCell setBackgroundColor:[UIColor blackColor]];
        Episode *objEpisode = [arrEpisodes objectAtIndex:indexPath.row];
        [objFeaturedTableViewCustomCell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:[UIImage imageNamed:@""]];
        objFeaturedTableViewCustomCell.lblMovieName.text =  [CommonFunctions isEnglish]?objEpisode.seriesName_en:objEpisode.seriesName_ar;

        objFeaturedTableViewCustomCell.lblEpisodeName.hidden = NO;
        objFeaturedTableViewCustomCell.lblEpisodeName.textColor = [UIColor whiteColor];
        
        //Season Number - Episode Number - Episode Title
        
        NSString *name = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
        {
            if (objEpisode.seriesSeasonsCount == 1)
                objFeaturedTableViewCustomCell.lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, (name.length>0?[NSString stringWithFormat:@" - %@", [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]:@"")];
            else
                objFeaturedTableViewCustomCell.lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ - %@ %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, (name.length>0?[NSString stringWithFormat:@" - %@", [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]:@"")];
        }
        else
        {
            if (objEpisode.seriesSeasonsCount == 1)
                objFeaturedTableViewCustomCell.lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ %@",[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, (name.length>0?[NSString stringWithFormat:@" - %@", [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]:@"")];
            else
                objFeaturedTableViewCustomCell.lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ - %@ %@ %@",  [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil],objEpisode.episodeNum,(name.length>0?[NSString stringWithFormat:@" - %@", [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]:@"")];
        }
        
        
        objFeaturedTableViewCustomCell.backgroundColor = [UIColor clearColor];
        objFeaturedTableViewCustomCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [objFeaturedTableViewCustomCell.lblMovieName sizeToFit];
        CGRect rect = objFeaturedTableViewCustomCell.lblMovieName.frame;
        CGRect rect1 = objFeaturedTableViewCustomCell.lblSeperator.frame;
        [objFeaturedTableViewCustomCell.lblSeperator setFrame:CGRectMake(rect.origin.x + rect.size.width + 2, rect1.origin.y, rect1.size.width, rect1.size.height)];
        rect1 = objFeaturedTableViewCustomCell.lblSeperator.frame;
        
        rect = objFeaturedTableViewCustomCell.lblEpisodeName.frame;
        rect.origin.x = rect1.origin.x + rect1.size.width + 2;
        [objFeaturedTableViewCustomCell.lblEpisodeName setFrame:rect];
        [objFeaturedTableViewCustomCell.lblEpisodeName sizeToFit];
        
        if([objFeaturedTableViewCustomCell.lblEpisodeName.text isEqualToString:@""])
        {
            [objFeaturedTableViewCustomCell.lblSeperator setHidden:YES];
        }
        
        return objFeaturedTableViewCustomCell;
    }
    else if(segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 0)
        {
            static NSString *cellIdentifier = @"cellGenre";
            CategoriesCustomCell *objCategoriesCustomCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(objCategoriesCustomCell== nil)
                objCategoriesCustomCell = [[[NSBundle mainBundle] loadNibNamed:@"CategoriesCustomCell" owner:self options:nil] firstObject];
            [objCategoriesCustomCell setBackgroundColor:[UIColor clearColor]];
            
            Genre *objGenre = [arrGenres objectAtIndex:indexPath.row];
            objCategoriesCustomCell.lblCategories.text =  [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
            CGRect rect = objCategoriesCustomCell.imgArrow.frame;
            rect.origin.x = rect.origin.x-15;
            [objCategoriesCustomCell.imgArrow setFrame:rect];
            objCategoriesCustomCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return objCategoriesCustomCell;
            
        }
        else
        {
            
            static NSString *cellIdentifier = @"cell11";
            FeaturedTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell== nil)
                cell = [[[NSBundle mainBundle] loadNibNamed:@"FeaturedTableViewCustomCell" owner:self options:nil] firstObject];
            Serie *objGenreSerie = (Serie*) [arrGenreDetail objectAtIndex:indexPath.row];
            
            [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objGenreSerie.serieThumb] placeholderImage:[UIImage imageNamed:@""]];
            
            cell.lblMovieName.hidden = NO;
            cell.lblMovieName.text =  ([CommonFunctions isEnglish]?objGenreSerie.serieName_en:objGenreSerie.serieName_ar);
            cell.lblMovieName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
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
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell setBackgroundColor:[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:22.0/255.0 alpha:1.0]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    if(segmentControl.selectedSegmentIndex == 2 && isGenreDetail == 0)
    {
        Genre *objGenre = [arrGenres objectAtIndex:indexPath.row];
        lblMusicName.text = [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;
        nestedSlctdIndex = (int)indexPath.row;
        NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:objGenre.genreId forKey:@"GenereId"];
        genreDetailPage = YES;
        DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
        [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"series"];
    }
    else if(segmentControl.selectedSegmentIndex == 1)
    {
       // NSString *movieId = kEmptyString;
        NSString *movieThumbnail = kEmptyString;
        Episode *objEpisode = [arrEpisodes objectAtIndex:indexPath.row];
     //   movieThumbnail = kEmptyString;
        self.episodeDesc = [CommonFunctions isEnglish]?objEpisode.episodeDesc_en:objEpisode.episodeDesc_ar;
        self.episodeVideoUrl = objEpisode.episodeUrl;
      //  movieId = objEpisode.episodeId;
        movieThumbnail = objEpisode.episodeThumb;
        self.episodeVideoUrl = objEpisode.episodeUrl;
        self.episodeDuration = objEpisode.episodeDuration;
        self.episodeId = objEpisode.episodeId;
        seasonNum = objEpisode.seasonNum;
        seriesName = [CommonFunctions isEnglish]?objEpisode.seriesName_en:objEpisode.seriesName_ar;

        if (objEpisode.seriesSeasonsCount > 1)
            
            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
        else
        {
            NSString *episodeName = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;
            if ([episodeName length]!=0) {

                [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
            }
            else
            {
                [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum]];
            }
        }
    }
    else if(segmentControl.selectedSegmentIndex == 2 && isGenreDetail == 1)
    {
        Serie *objSerieGenre = [arrGenreDetail objectAtIndex:indexPath.row];
        [vwSeriesDetail setHidden:NO];
        [imgVwBarBg setHidden:NO];

        [self.view bringSubviewToFront:vwSeriesDetail];
        //Episodes *objEpisodes = [Episodes new];
        
        [imgSeries sd_setImageWithURL:[NSURL URLWithString:objSerieGenre.serieThumb] placeholderImage:[UIImage imageNamed:@""]];
        
        lblSeriesName.text = ([CommonFunctions isEnglish]?objSerieGenre.serieName_en:objSerieGenre.serieName_ar);
        self.genreSubDetailIndex = (int)indexPath.row;
        
        seriesName = [CommonFunctions isEnglish]?objSerieGenre.serieName_en:objSerieGenre.serieName_ar;
        genreSubDetailPage = true;
        serieId = objSerieGenre.serieId;
        SeriesSeasons *objSeriesSeasons = [SeriesSeasons new];
        [objSeriesSeasons fetchSeriesSeasons:self selector:@selector(seriesSeasonServerResponse:) parameter:objSerieGenre.serieId];
    }
    else if(segmentControl.selectedSegmentIndex == 0)
    {
        [vwSeriesDetail setHidden:NO];
        [imgVwBarBg setHidden:NO];
        [self.view bringSubviewToFront:vwSeriesDetail];
        Serie *objSerie = [arrSeries objectAtIndex:indexPath.row];
        seriesDetailPage = true;
        [imgSeries sd_setImageWithURL:[NSURL URLWithString:objSerie.serieThumb] placeholderImage:[UIImage imageNamed:@""]];
        lblSeriesName.text = ([CommonFunctions isEnglish]?objSerie.serieName_en:objSerie.serieName_ar);
        seriesName = [CommonFunctions isEnglish]?objSerie.serieName_en:objSerie.serieName_ar;
        serieId = objSerie.serieId;
        SeriesSeasons *objSeriesSeasons = [SeriesSeasons new];
        self.allSeriesIndex = (int)indexPath.row;
        [objSeriesSeasons fetchSeriesSeasons:self selector:@selector(seriesSeasonServerResponse:) parameter:objSerie.serieId];
//        [objEpisodes fetchSeriesEpisodes:self selector:@selector(fetchSeriesEpisodesResponse:) parameter:objSerie.serieId userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
}

#pragma mark - setDefault UI for Segment
-(void) setDefaultUIForSegment
{
    [lblNoRecordFound setFrame:IS_IOS7_OR_LATER?koriginalRectForNoRecord:koriginalRectForNoRecordForiPhone4Ios6];
    [lblNoRecordFound setHidden:YES];
    genreDetailPage = false;
    seriesDetailPage = false;
    genreSubDetailPage = false;
  //  [self.view bringSubviewToFront:tblSeries];
    CGRect rect = tblSeries.frame;
    rect.origin.x = 10;
    rect.size.width = 300;
    [tblSeries setFrame:rect];
}

#pragma mark Segment Bar delegate Methods
- (IBAction)segmentedIndexChanged
{
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    [self setDefaultUIForSegment];
    isGenreDetail = 0;
    switch (segmentControl.selectedSegmentIndex)
    {
        case 0:
            if (![arrSeries count]>0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                    [self fetchSeries];
            }
            else
            {
                [tblSeries reloadData];
            }
            break;
        case 1:
            if ([arrEpisodes count] == 0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                    [self fetchFeaturedEpisodes];
            }
            else
            {
                [tblSeries reloadData];
            }
            break;
        default:
            if (![arrGenres count]>0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                    [self fetchSeriesGenres];
            }
            else
            {
                [tblSeries reloadData];
            }
            break;
    }
}

#pragma mark Fetch Music Singers
- (void)fetchFeaturedEpisodes
{
    Episodes *objEpisodes = [Episodes new];
    [objEpisodes fetchFeaturedEpisodes:self selector:@selector(episodeServerResponse:) userId:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
}

#pragma mark fetch Genres
- (void)fetchSeriesGenres
{
    Genres *objGenres = [[Genres alloc] init];
    [objGenres fetchGenres:self selector:@selector(responseForGenres:) methodName:@"series"];
}

#pragma mark ServerResponse

- (void)seriesSeasonServerResponse:(NSArray*)arrResponse
{
    arrSeasons = [[NSArray alloc] initWithArray:arrResponse];
    
    if([arrSeasons count] > 0)
    {
        btnSelectSeason.hidden = NO;
        lblSelectSeason.hidden = NO;
        if ([arrResponse count] == 1) {
            btnSelectSeason.hidden = YES;
            lblSelectSeason.hidden = YES;
        }

        SeriesSeason *objSeriesSeason = (SeriesSeason*) [arrResponse objectAtIndex:0];
        lblSelectSeason.text = [NSString stringWithFormat:@"%@ %@",[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], objSeriesSeason.seasonNum];
        
        lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 180, CGRectGetHeight(lblSeriesName.frame));
        
        [[[Episodes alloc] init] fetchSeriesSeasonalEpisodes:self selector:@selector(fetchSeriesEpisodesResponse:) parameter:serieId seasonId:objSeriesSeason.seasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    else
    {
        arrSeriesEpisodes = [[NSArray alloc] init];
        lblNoRecordFound.hidden = NO;
        [collView reloadData];
        
        btnSelectSeason.hidden = YES;
        lblSelectSeason.hidden = YES;
        
        [self.view bringSubviewToFront:lblNoRecordFound];
        [collView setHidden:NO];
        
        CGRect rect = lblNoRecordFound.frame;
        rect.origin.y += 170;
        [lblNoRecordFound setFrame:rect];
    }
    [pckVw reloadAllComponents];
}

-(void)fetchSeriesEpisodesResponse :(NSArray *) arrResponse
{
    arrSeriesEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    [collView setHidden:NO];
    [lblNoRecordFound setFrame:IS_IOS7_OR_LATER?koriginalRectForNoRecord:koriginalRectForNoRecordForiPhone4Ios6];
    if([arrSeriesEpisodes count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
        [collView setHidden:NO];
        
        CGRect rect = lblNoRecordFound.frame;
        rect.origin.y += 170;
        [lblNoRecordFound setFrame:rect];
    }
    
    [collView reloadData];
}

- (void)seriesResponse:(NSArray *)arrResponse
{
    arrSeries = [[NSArray alloc] initWithArray:arrResponse];
    if([arrSeries count] == 0 && segmentControl.selectedSegmentIndex == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    else if (segmentControl.selectedSegmentIndex == 0)
        [tblSeries reloadData];
}

- (void)fetchSeriesEpisodes:(NSArray*)arrResponse
{
    isGenreDetail = 2;
    arrSeriesEpisodes = [arrResponse mutableCopy];
    [tblSeries reloadData];
}

-(void) episodeServerResponse:(NSArray *)arrResponse
{
    arrEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    if([arrEpisodes count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    else
    {
        [lblNoRecordFound setHidden:YES];
    }
    
    [tblSeries reloadData];
}

- (void)responseForGenres:(NSArray*)arrResponse
{
    arrGenres = [[NSArray alloc] initWithArray:arrResponse];
    if([arrGenres count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    else
    {
        [lblNoRecordFound setHidden:YES];
    }
    [tblSeries reloadData];
}

#pragma mark reponseForGenresService
-(void) reponseForGenresService:(NSMutableArray *) arrDetailGenreLocal
{
//    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    isGenreDetail = 1;
   // arrGenreDetail = [arrDetailGenreLocal mutableCopy];
    arrGenreDetail = [[NSMutableArray alloc] initWithArray:arrDetailGenreLocal];
    
   // arrGenreDetail = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenre:[arrDetailGenreLocal mutableCopy] arrayOfAphabetsToDisplay:arrAlphabetsForGenre] mutableCopy];
    
    if([arrGenreDetail count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    else
    {
        [lblNoRecordFound setHidden:YES];
    }
    
    [tblSeries reloadData];
}

#pragma mark - redirect to movie detail page
-(void) redirectToMovieDetailPage:(NSString *)movieId movieThumbnail:(NSString *)movieThumbnail SeriesName:(NSString *)seriesNameLocal
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
    [objMoviesDetailViewController setMovieName:seriesNameLocal];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int)series];
    objMoviesDetailViewController._episodeDesc = self.episodeDesc;
    objMoviesDetailViewController.strMovieUrl = self.episodeVideoUrl;
    objMoviesDetailViewController.strEpisodeDuration = self.episodeDuration;
    objMoviesDetailViewController._arrEpisodes = arrSeriesEpisodes;
    objMoviesDetailViewController.selectedEpisodeIndex = self.selectedIndex;
    objMoviesDetailViewController.strEpisodeId = self.episodeId;
    objMoviesDetailViewController.strSeasonNum = seasonNum;
    objMoviesDetailViewController.strSeriesName = seriesName;
    objMoviesDetailViewController.videoType = 3;
    
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}

#pragma mark - Collection View delagate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrSeriesEpisodes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"CollectionsDetailCustomCellReuse";
    CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell==nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
    
    Episode *objEpisode = [arrSeriesEpisodes objectAtIndex:indexPath.row];
    [cell setBackgroundColor:color_Background];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:[UIImage imageNamed:@""]];
    
    cell.lblEpisodeTitle.hidden = NO;
    cell.lblEpisodeTitle.textColor = [UIColor whiteColor];
    cell.lblEpisodeTitle.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], (objEpisode.episodeNum)];
    
    //CGSize size = [cell.lblEpisodeTitle.text sizeWithFont:cell.lblEpisodeTitle.font constrainedToSize:CGSizeMake(CGRectGetWidth(cell.lblEpisodeTitle.frame), CGRectGetHeight(cell.lblEpisodeTitle.frame))];
    
    cell.lblEpisodeTitle.frame = CGRectMake(CGRectGetMinX(cell.lblEpisodeTitle.frame), CGRectGetMinY(cell.lblEpisodeTitle.frame), 32, CGRectGetHeight(cell.lblEpisodeTitle.frame));
    
    [cell.lblName setFrame:CGRectMake(CGRectGetMaxX(cell.lblEpisodeTitle.frame)-1, cell.lblName.frame.origin.y, cell.frame.size.width-(cell.lblEpisodeTitle.frame.origin.x+cell.lblEpisodeTitle.frame.size.width),  cell.lblName.frame.size.height)];
    cell.lblName.numberOfLines = 1;
    cell.lblName.textColor = [UIColor whiteColor];
    
    NSString *name = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        if ([name length] > 0)
            cell.lblName.text = [NSString stringWithFormat:@" - %@", objEpisode.episodeName_en];
        else
            cell.lblName.text = @"";
    }
    else
    {
        if ([name length] > 0)
            cell.lblName.text = [NSString stringWithFormat:@"%@ -", objEpisode.episodeName_ar];
        else
            cell.lblName.text = @"";
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    NSString *movieId = kEmptyString;
    NSString *movieThumbnail = kEmptyString;
    
    Episode *objEpisode = [arrSeriesEpisodes objectAtIndex:indexPath.row];
    movieId = objEpisode.episodeId;
    movieThumbnail = objEpisode.episodeThumb;
    self.episodeVideoUrl = objEpisode.episodeUrl;
    self.episodeDuration = objEpisode.episodeDuration;
    self.episodeId = objEpisode.episodeId;
    seasonNum = objEpisode.seasonNum;
    
    if([objEpisode.seasonNum isKindOfClass:[NSNull class]])
    {
        [self redirectToMovieDetailPage:movieId movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@, %@",seriesName,[CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
    }
    else
    {
        self.episodeDesc = [CommonFunctions isEnglish]?objEpisode.episodeDesc_en:objEpisode.episodeDesc_ar;
        
        if (objEpisode.seriesSeasonsCount > 1)

            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
        else
        {
            NSString *episodeName = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;
        
            if ([episodeName length]!=0) {
                [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
            }
            else
            {
                [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum]];
            }
        }
    }
}

#pragma mark - PickerView action event
-(IBAction) selectSeasonClicked:(id)sender
{
    if([arrSeasons count] >0)
    {
        int pickerViewHeight = 150;
        AppDelegate *objAppdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        if(!pckVw)
//        {
        [pckVw removeFromSuperview];
        pckVw = nil;
            CGRect rect = [[UIScreen mainScreen] bounds];
            pckVw = [[UIPickerView alloc] initWithFrame:CGRectMake(0, rect.size.height - pickerViewHeight, 320, pickerViewHeight)];
            [pckVw setDelegate:self];
            [pckVw setDataSource:self];
            [objAppdelegate.window addSubview:pckVw];
            [self hideTabBar];
            [pckVw setBackgroundColor:[UIColor colorWithRed:63.0/255.0 green:64.0/255.0 blue:68.0/255.0 alpha:1.0]];
            
            [pckVw reloadAllComponents];
        //}
//        else
//        {
//            [self removePickerView];
//        }
    }
}


#pragma mark - UIPickerView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
    }
    SeriesSeason *objSeriesSeason = [arrSeasons objectAtIndex:row];
    [tView setTextColor:[UIColor whiteColor]];
    [tView setText:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], objSeriesSeason.seasonNum]];
    [tView setBackgroundColor:[UIColor colorWithRed:63.0/255.0 green:64.0/255.0 blue:68.0/255.0 alpha:1.0]];
    [tView setTextAlignment:NSTextAlignmentCenter];
    [tView setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    // Fill the label text here
    
    return tView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrSeasons count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    SeriesSeason *objSeriesSeason = [arrSeasons objectAtIndex:row];
    lblSelectSeason.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], objSeriesSeason.seasonNum];
    
  //  lblSeriesName.text = [NSString stringWithFormat:@"%@ | %@",seriesName,[NSString stringWithFormat:@"SEASON %@",objSeriesSeason.seasonNum]];
    
    [[[Episodes alloc] init] fetchSeriesSeasonalEpisodes:self selector:@selector(fetchSeriesEpisodesResponse:) parameter:serieId seasonId:objSeriesSeason.seasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    [self removePickerView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}


#pragma mark - UIView delegate
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removePickerView];
}

#pragma mark - Tabbar Show/Hide
-(void)showTabBar
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (statusBarFrame.size.height > 20)
        self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-49-20, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
    else
        self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-49, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
}

-(void)hideTabBar {
    self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.tabBarController.tabBar.frame.origin.y + self.tabBarController.tabBar.frame.size.height, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
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