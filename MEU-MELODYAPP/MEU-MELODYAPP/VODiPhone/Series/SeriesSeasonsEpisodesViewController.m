//
//  SeriesSeasonsEpisodesViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/11/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeriesSeasonsEpisodesViewController.h"
#import "UIImageView+WebCache.h"
#import "SeriesSeasons.h"
#import "SeriesSeason.h"
#import "CommonFunctions.h"
#import "Episodes.h"
#import "CollectionsDetailCustomCell.h"
#import "Episode.h"
#import "AppDelegate.h"
#import "CustomControls.h"
#import "SettingViewController.h"
#import "MoviesDetailViewController.h"

@interface SeriesSeasonsEpisodesViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UIImageView*       imgVwSeriesThumb;
    IBOutlet UILabel*           lblSeriesName;
    IBOutlet UILabel*           lblSeasonNumber;
    IBOutlet UILabel*           lblNoEpisodeFound;
    IBOutlet UIButton*          btnSelectSeason;
    IBOutlet UICollectionView*  collectionVw;
    UIPickerView *pckVw;
}

@property (strong, nonatomic) NSArray*      arrSeasons;
@property (strong, nonatomic) NSArray*      arrEpisodes;
@property (strong, nonatomic) NSString*     episodeId;
@property (strong, nonatomic) NSString*     episodeDesc;
@property (strong, nonatomic) NSString*     episodeVideoUrl;
@property (strong, nonatomic) NSString*     episodeDuration;
@property (strong, nonatomic) NSString*     strSeasonNum;

@property (assign, nonatomic) NSInteger     selectedIndex;

@end

@implementation SeriesSeasonsEpisodesViewController

@synthesize strSeriesId, seriesName_en, seriesName_ar, seriesUrl;
@synthesize isFromCollection, isFromSearch;

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

    [self registerCollectionViewCell];
    [self setNavigationBarButtons];
    
    SeriesSeasons *objSeriesSeasons = [SeriesSeasons new];
    [objSeriesSeasons fetchSeriesSeasons:self selector:@selector(seriesSeasonServerResponse:) parameter:strSeriesId];
    
    [self setUI];
    [self setFonts];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    lblSeriesName.text = [CommonFunctions isEnglish]?self.seriesName_en:self.seriesName_ar;
    
    [collectionVw reloadData];
    [pckVw reloadAllComponents];
    
    if (lblSeasonNumber.hidden == NO)
    {
        lblSeasonNumber.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], [[lblSeasonNumber.text componentsSeparatedByString:@" "] lastObject]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
}

-(void) setFonts
{
    [lblNoEpisodeFound setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [lblSeriesName setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    [lblSeasonNumber setFont:[UIFont fontWithName:kProximaNova_Bold size:10.0]];
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingBarButtonItemAction)];
}

#pragma mark - navigation controller button action events

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

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
}

-(void)settingBarButtonItemAction
{
    [self showTabBar];
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.parentViewController.navigationController ViewController:objSettingViewController];
}

-(void)backBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Register Collection view cell
-(void) registerCollectionViewCell
{
    [collectionVw registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:Nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReuse"];
}

#pragma mark - Selected Series Delegate Method

- (void)seriesSeasonServerResponse:(NSArray*)arrResponse
{
    self.arrSeasons = [[NSArray alloc] initWithArray:arrResponse];
    if ([self.arrSeasons count] > 0){
        
        SeriesSeason *objSeriesSeason = [arrResponse objectAtIndex:0];
        [lblSeasonNumber setText:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Season" value:@"" table:nil], objSeriesSeason.seasonNum]];
        
        if ([self.arrSeasons count] == 1 || [self.arrSeasons count] == 0) {
            btnSelectSeason.hidden = YES;
            lblSeasonNumber.hidden = YES;
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 300, CGRectGetHeight(lblSeriesName.frame));
        }
        else{
            btnSelectSeason.hidden = NO;
            lblSeasonNumber.hidden = NO;
            
            lblSeriesName.frame = CGRectMake(CGRectGetMinX(lblSeriesName.frame), CGRectGetMinY(lblSeriesName.frame), 180, CGRectGetHeight(lblSeriesName.frame));
        }
        
        
        Episodes *objEpisodes = [Episodes new];
        [objEpisodes fetchSeriesSeasonalEpisodes:self selector:@selector(seriesEpisodesServerResponse:) parameter:strSeriesId seasonId:objSeriesSeason.seasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
    }
    else
    {
        lblNoEpisodeFound.hidden = NO;
        btnSelectSeason.hidden = YES;
        lblSeasonNumber.hidden = YES;
    }
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

- (void)setUI
{
    [imgVwSeriesThumb sd_setImageWithURL:[NSURL URLWithString:seriesUrl] placeholderImage:nil];
    lblSeriesName.text = [CommonFunctions isEnglish]?self.seriesName_en:self.seriesName_ar;
}

#pragma mark - Collection View delagate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrEpisodes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"CollectionsDetailCustomCellReuse";
    CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell==nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
    
    Episode *objEpisode = [self.arrEpisodes objectAtIndex:indexPath.row];
    [cell setBackgroundColor:color_Background];
    cell.lblName.textColor = [UIColor whiteColor];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:[UIImage imageNamed:@""]];
    
    cell.lblEpisodeTitle.hidden = NO;
    cell.lblEpisodeTitle.textColor = [UIColor whiteColor];
    //NSString *name = [CommonFunctions isEnglish]?objEpisode.episodeNum:objEpisode.episodeNum;
    
    cell.lblEpisodeTitle.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], (objEpisode.episodeNum)];
    
    cell.lblName.numberOfLines = 1;
    cell.lblName.textColor = [UIColor whiteColor];
    
    NSString *name = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;

    cell.lblName.text = [CommonFunctions isEnglish]?(name.length>0?[NSString stringWithFormat:@" - %@", objEpisode.episodeName_en]:@""):(name.length>0?[NSString stringWithFormat:@" %@ -", objEpisode.episodeName_ar]:@"");
    
    //cell.lblName.text = [NSString stringWithFormat:@" - %@", [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar];
    
    cell.lblName.hidden = (cell.lblName.text.length>3?NO:YES);
    
    cell.lblEpisodeTitle.frame = CGRectMake(CGRectGetMinX(cell.lblEpisodeTitle.frame), CGRectGetMinY(cell.lblEpisodeTitle.frame), 32, CGRectGetHeight(cell.lblEpisodeTitle.frame));
    
    [cell.lblName setFrame:CGRectMake(CGRectGetMaxX(cell.lblEpisodeTitle.frame), cell.lblName.frame.origin.y, cell.frame.size.width-(cell.lblEpisodeTitle.frame.origin.x+cell.lblEpisodeTitle.frame.size.width),  cell.lblName.frame.size.height)];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   // NSString *movieId = kEmptyString;
    NSString *movieThumbnail = kEmptyString;
    
    Episode *objEpisode = [self.arrEpisodes objectAtIndex:indexPath.row];
    //movieId = objEpisode.seriesID;
    movieThumbnail = objEpisode.episodeThumb;
    //    self.episodeVideoUrl = objEpisode.episodeUrl;
    //    self.episodeDuration = objEpisode.episodeDuration;
    self.episodeId = objEpisode.episodeId;
    self.episodeDesc = objEpisode.episodeDesc_en;
    self.strSeasonNum = [NSString stringWithFormat:@"%@", objEpisode.seasonNum];
    
    NSString *name = [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar;

    if (objEpisode.seriesSeasonsCount > 1)
    {
        if ([name length]>0)
        {
            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ -%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
        }
        else
        {
            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ -%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum]];
        }
    }
    else
    {
        if ([name length]>0)
        {
            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@ - %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [CommonFunctions isEnglish]?objEpisode.episodeName_en:objEpisode.episodeName_ar]];
        }
        else
        {
            [self redirectToMovieDetailPage:objEpisode.seriesID movieThumbnail:movieThumbnail SeriesName:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum]];
        }
    }
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
    objMoviesDetailViewController.strSeasonNum = self.strSeasonNum;
    
//    objMoviesDetailViewController._episodeDesc = self.episodeDesc;
//    objMoviesDetailViewController.strMovieUrl = self.episodeVideoUrl;
//    objMoviesDetailViewController.strEpisodeDuration = self.episodeDuration;
//    objMoviesDetailViewController._arrEpisodes = arrSeriesEpisodes;
//    objMoviesDetailViewController.selectedEpisodeIndex = self.selectedIndex;
    
    objMoviesDetailViewController._episodeDesc = self.episodeDesc;
    objMoviesDetailViewController.strMovieUrl = self.episodeVideoUrl;
    objMoviesDetailViewController.strEpisodeDuration = self.episodeDuration;
    objMoviesDetailViewController._arrEpisodes = self.arrEpisodes;
    objMoviesDetailViewController.selectedEpisodeIndex = self.selectedIndex;
    objMoviesDetailViewController.strEpisodeId = self.episodeId;
    objMoviesDetailViewController.videoType = 3;
    
    if (isFromSearch == YES) {
        objMoviesDetailViewController.isFromSearch = YES;
    }
    else
        objMoviesDetailViewController.isFromCollection = YES;
    
    [self showTabBar];
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}

-(void)fetchSeriesEpisodesResponse :(NSArray *) arrResponse
{
    self.arrEpisodes = [[NSArray alloc] initWithArray:arrResponse];
    [collectionVw setHidden:NO];

    if([self.arrEpisodes count] == 0)
    {
        [lblNoEpisodeFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoEpisodeFound];
        [collectionVw setHidden:NO];
        
//        CGRect rect = lblNoRecordFound.frame;
//        rect.origin.y += 170;
//        [lblNoRecordFound setFrame:rect];
    }
    
    [collectionVw reloadData];
}

#pragma mark - PickerView action event
-(IBAction) selectSeasonClicked:(id)sender
{
    if([self.arrSeasons count] >0)
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

#pragma mark - Tabbar Show/Hide
-(void)showTabBar
{
    self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, [[UIScreen mainScreen] bounds].size.height-49, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
}

-(void)hideTabBar {
    self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.tabBarController.tabBar.frame.origin.y + self.tabBarController.tabBar.frame.size.height, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
}
#pragma mark - UIPickerView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
    }
    SeriesSeason *objSeriesSeason = [self.arrSeasons objectAtIndex:row];
    [tView setTextColor:[UIColor whiteColor]];
    [tView setText:[NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objSeriesSeason.seasonNum]];
    [tView setBackgroundColor:[UIColor colorWithRed:63.0/255.0 green:64.0/255.0 blue:68.0/255.0 alpha:1.0]];
    [tView setTextAlignment:NSTextAlignmentCenter];
    [tView setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    // Fill the label text here
    
    return tView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.arrSeasons count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    SeriesSeason *objSeriesSeason = [self.arrSeasons objectAtIndex:row];
    lblSeasonNumber.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Season" value:@"" table:nil], objSeriesSeason.seasonNum];
    
    //  lblSeriesName.text = [NSString stringWithFormat:@"%@ | %@",seriesName,[NSString stringWithFormat:@"SEASON %@",objSeriesSeason.seasonNum]];
    
    [[[Episodes alloc] init] fetchSeriesSeasonalEpisodes:self selector:@selector(fetchSeriesEpisodesResponse:) parameter:strSeriesId seasonId:objSeriesSeason.seasonNum userID:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"]];
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

#pragma mark -  Remove Picker View
-(void) removePickerView
{
   // [self showTabBar];
    //    if(pckVw)
    //    {
    [pckVw removeFromSuperview];
    // pckVw = nil;
    //    }
    
    [self showTabBar];
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
