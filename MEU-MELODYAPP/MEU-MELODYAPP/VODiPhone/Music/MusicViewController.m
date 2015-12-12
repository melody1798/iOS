//
//  MusicViewController.m
//  MEU-MELODYAPP
//
//  Created by Channi on 8/20/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "MusicViewController.h"
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
#import "SettingViewController.h"
#import "MoviePlayerViewController.h"
#import "LoginViewController.h"
#import "WatchListMovies.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "CustomControls.h"

@interface MusicViewController () <UIGestureRecognizerDelegate>
{
    int                                     loginCheck;
    MPMoviePlayerViewController*            mpMoviePlayerViewController;
    CustomControls*                         objCustomControls;
    UITapGestureRecognizer*                 singleTapGestureRecognizer;
    XCDYouTubeVideoPlayerViewController*    youtubeMoviePlayer;
}

@property (nonatomic, strong) NSString*     genreNameEng, *genreNameAr;
@property (nonatomic ,strong) NSString*     strMovieUrl;//music video url to play directly
@property (strong, nonatomic) NSString*     strPreviousLanguage;
@property (strong, nonatomic) NSString*     strGenreId;
@property (strong, nonatomic) NSString*     strMovieId;
@property (assign, nonatomic) BOOL          isCastingButtonHide;
@property (assign, nonatomic) BOOL          bIsLoad;
@property (strong, nonatomic) NSString*     strMovieNameOnCastingDevice;

- (IBAction)btnGenreAction:(id)sender;

@end

@implementation MusicViewController

@synthesize genreNameEng, genreNameAr, strMovieUrl;

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

    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil];

    if (![kCommonFunction checkNetworkConnectivity])
    {
        lblNoRecordFound.hidden = NO;
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        FeaturedMusics *objFeaturedMusics = [FeaturedMusics new];
        [objFeaturedMusics fetchFeaturedMusicVideos:self selector:@selector(featuredVideosServerResponse:)];
    }
    segmentControl.selectedSegmentIndex = 0;
    
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music a-z" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];

    
    isGenreDetail = 0;
    tblMusic.sectionIndexColor = [UIColor colorWithRed:141/255.0 green:149/255.0 blue:158/255.0 alpha:1.0];
    if (IS_IOS7_OR_LATER)
        [tblMusic setSectionIndexBackgroundColor:[UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:25.0/255.0 alpha:1.0]];
    else
        tblMusic.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:22.0/255.0 green:22.0/255.0 blue:25.0/255.0 alpha:1.0];
    arrAlphabetsForGenre = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
    [self setFonts];
    [self registerCollectionViewCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-50 delegate:self]];
    //Get real time data to google analytics
    [CommonFunctions addGoogleAnalyticsForView:@"Series"];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];
    
    [lblNoRecordFound setText:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"No record found" value:@"" table:nil]];

    if (![self.strPreviousLanguage isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey]]) {
        
        self.strPreviousLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey];
        if (![kCommonFunction checkNetworkConnectivity])
        {
            lblNoRecordFound.hidden = NO;
            [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
        }
        else
            [self fetchMusicSingers];
        
        if (isGenreDetail) {
            NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:self.strGenreId forKey:@"GenereId"];
            DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
            [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"music"];
        }
    }
    
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil];
    
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"featured" value:@"" table:nil] forSegmentAtIndex:0];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music a-z" value:@"" table:nil] forSegmentAtIndex:1];
    [segmentControl setTitle:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"genres" value:@"" table:nil] forSegmentAtIndex:2];
    
    if (isGenreDetail == 1)
        lblMusicName.text = [CommonFunctions isEnglish]?self.genreNameEng:self.genreNameAr;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if (loginCheck == 1 && [CommonFunctions userLoggedIn])
    {
        loginCheck = 0;
        [self redirectToPlayer:self.strMovieUrl movieId:@""];
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

#pragma mark - Register Collection view cell
-(void) registerCollectionViewCell
{
    [collView registerNib:[UINib nibWithNibName:@"CollectionsDetailCustomCell" bundle:Nil] forCellWithReuseIdentifier:@"CollectionsDetailCustomCellReuse"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ServerResponse

- (void)featuredVideosServerResponse:(NSArray *)arrResponse
{
    arrFeaturedMusicVideos = [[NSArray alloc] initWithArray:arrResponse];
    if([arrFeaturedMusicVideos count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    [tblMusic reloadData];
}


#pragma mark - InitUI

- (void)initUI {
    [lblMusicName setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    
    self.navigationItem.leftBarButtonItem = [CustomControls setNavigationBarButton:@"back_btn~iphone" Target:self selector:@selector(backBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem = [CustomControls setNavigationBarButton:@"setting_icon~iphone" Target:self selector:@selector(settingBarButtonItemAction)];
    [self setSegmentedControlAppreance];
    
    [self.view addSubview:[CommonFunctions addiAdBanner:self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height-70 delegate:self]];
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
        
        rect = tblMusic.frame;
        rect.origin.y += 30;
        rect.size.height -= 50;
        [tblMusic setFrame:rect];
        
        rect = collView.frame;
        rect.origin.y += 30;
        rect.size.height -= 35;
        [collView setFrame:rect];
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
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil];

    switch (isGenreDetail)
    {
        case 1:
        case 2:
            [self segmentedIndexChanged];
            return;
    }
    
    VODCategoryViewController *objVODCategoryViewController = [[VODCategoryViewController alloc] init];
    [CommonFunctions pushViewController:self.navigationController ViewController:objVODCategoryViewController];
}

- (IBAction)btnGenreAction:(id)sender
{
    segmentControl.selectedSegmentIndex = 2;
    [self setDefaultUIForSegment];
    
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil];

    switch (isGenreDetail)
    {
        case 0:
            
        case 1:
           // return;
        case 2:
            [self segmentedIndexChanged];
           // return;
    }

    if (![arrGenres count]>0)
    {
        [self fetchMusicGenres];
        segmentControl.selectedSegmentIndex = 2;
    }
    else if (isGenreDetail == 0 && [arrGenres count]>0)
    {
        segmentControl.selectedSegmentIndex = 2;
        [tblMusic reloadData];
    }
    else
    {
        [tblMusic reloadData];
    }
}

#pragma mark - setFonts
-(void) setFonts
{
    [lblMusicName setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
    [lblNoRecordFound setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
}

#pragma mark UITableView Delegate
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
{
    if((segmentControl.selectedSegmentIndex == 2) && (isGenreDetail == 1))
        return arrAlphabetsForGenre;
    
    else if (segmentControl.selectedSegmentIndex == 1 && !singerDetail)
        return arrAlphabets;
    
    return Nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:0 inSection:index];
    @try
    {
        [UIView animateWithDuration:0.2 animations:^{
            [tblMusic scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    if((segmentControl.selectedSegmentIndex == 2) && (isGenreDetail == 1))
    {
        return [CommonFunctions returnViewForHeader:[arrAlphabetsForGenre objectAtIndex:section] UITableView:tblMusic];
    }
    
    else if (segmentControl.selectedSegmentIndex == 1)
        return [CommonFunctions returnViewForHeader:arrAlphabets[section] UITableView:tblMusic];
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
        
        return 19;
    }
    
    else if (segmentControl.selectedSegmentIndex ==1)
        return 20;
    
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(segmentControl.selectedSegmentIndex == 2 && isGenreDetail == 1)
    {
        return [arrAlphabetsForGenre objectAtIndex:section];
        
    }
    
    else if (segmentControl.selectedSegmentIndex == 1 && !singerDetail)
        return arrAlphabets[section];
    
    return kEmptyString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (segmentControl.selectedSegmentIndex == 0)
        return 1;
    else if (segmentControl.selectedSegmentIndex == 1 && !singerDetail)
        return arrAlphabets.count;
    if (segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 1)
        {
            return arrAlphabetsForGenre.count;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 0)
        return [arrFeaturedMusicVideos count];
    else if (segmentControl.selectedSegmentIndex == 1 && !singerDetail)
    {
        if (isGenreDetail == 2)
        {
            if ([arrSingerVideos count]%2==0)
            {
                return [arrSingerVideos count]/2;
            }
            else
            {
                return ([arrSingerVideos count]/2)+1;
            }
        }
        else
        {
            if([arrMusicSingers count] ==0)
                return 0;
            return [[arrMusicSingers objectAtIndex:section] count];
        }
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
            return  [[arrGenreDetail objectAtIndex:section] count];
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
    {
        if (isGenreDetail == 2)
        {
            return 110;
        }
        else
        {
            return 104;
        }
    }
    else if (segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 0)
        {
            return 49;
        }
        else
        {
            return 104;
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
        [objFeaturedTableViewCustomCell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
        FeaturedMusic *objFeaturedMusic = [arrFeaturedMusicVideos objectAtIndex:indexPath.row];
        [objFeaturedTableViewCustomCell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objFeaturedMusic.musicThumbnail] placeholderImage:[UIImage imageNamed:@""]];
        
        objFeaturedTableViewCustomCell.lblMovieName.text =  [CommonFunctions isEnglish]?objFeaturedMusic.musicTitle_en:objFeaturedMusic.musicTitle_ar;
        
        objFeaturedTableViewCustomCell.lblEpisodeName.hidden = NO;
        objFeaturedTableViewCustomCell.lblEpisodeName.text = [CommonFunctions isEnglish]?objFeaturedMusic.singerName_en:objFeaturedMusic.singerName_ar;
        objFeaturedTableViewCustomCell.lblEpisodeName.textColor = [UIColor whiteColor];
        
//        CGRect lblNameFrame = objFeaturedTableViewCustomCell.lblEpisodeName.frame;
//        lblNameFrame.origin.y = 170;
//        objFeaturedTableViewCustomCell.lblEpisodeName.frame = lblNameFrame;
        
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
    else if (segmentControl.selectedSegmentIndex == 1)
    {
        if (isGenreDetail == 2)
        {
            static NSString *cellIdentifier = @"cellSingerVideo";
            SingerDetailTableViewCell *objSingerDetailTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(objSingerDetailTableViewCell== nil)
                objSingerDetailTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"SingerDetailTableViewCell" owner:self options:nil] firstObject];
            [objSingerDetailTableViewCell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
            SingerVideo *objSingerVideo = [arrSingerVideos objectAtIndex:indexPath.row];
            
            
            [objSingerDetailTableViewCell.imgVwVideo1 sd_setImageWithURL:[NSURL URLWithString:objSingerVideo.movieThumb] placeholderImage:[UIImage imageNamed:@""]];
            return objSingerDetailTableViewCell;
        }
        else
        {
            static NSString *cellIdentifier = @"cell";
            GenreDetailCustomCell *objFeaturedTableViewCustomCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(objFeaturedTableViewCustomCell== nil)
                objFeaturedTableViewCustomCell = [[[NSBundle mainBundle] loadNibNamed:@"GenreDetailCustomCell" owner:self options:nil] firstObject];
            
            [objFeaturedTableViewCustomCell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
            
            MusicSinger *objMusicSinger = [[arrMusicSingers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [objFeaturedTableViewCustomCell.imgMovies sd_setImageWithURL:[NSURL URLWithString:objMusicSinger.musicVideoThumb] placeholderImage:[UIImage imageNamed:@""]];
            
            objFeaturedTableViewCustomCell.lblName.text =  [CommonFunctions isEnglish]?objMusicSinger.musicVideoName_en:objMusicSinger.musicVideoName_ar;
            objFeaturedTableViewCustomCell.lblTime.text = [CommonFunctions isEnglish]?objMusicSinger.singerName_en:objMusicSinger.singerName_ar;
            
            //Swap position music video name and singer name label
            CGRect lblNameFrame = objFeaturedTableViewCustomCell.lblName.frame;
            CGRect lblTimeFrame = objFeaturedTableViewCustomCell.lblTime.frame;
            lblNameFrame.origin.y = objFeaturedTableViewCustomCell.lblTime.frame.origin.y;
            lblTimeFrame.origin.y = objFeaturedTableViewCustomCell.lblName.frame.origin.y+10;
            objFeaturedTableViewCustomCell.lblName.frame = lblNameFrame;
            objFeaturedTableViewCustomCell.lblTime.frame = lblTimeFrame;
            
            objFeaturedTableViewCustomCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return objFeaturedTableViewCustomCell;
        }
    }
    else if(segmentControl.selectedSegmentIndex == 2)
    {
        if (isGenreDetail == 0)
        {
            static NSString *cellIdentifier = @"cellGenre";
            CategoriesCustomCell *objCategoriesCustomCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(objCategoriesCustomCell== nil)
                objCategoriesCustomCell = [[[NSBundle mainBundle] loadNibNamed:@"CategoriesCustomCell" owner:self options:nil] firstObject];
            [objCategoriesCustomCell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
            
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
            static NSString *cellIdentifier = @"cell";
            GenreDetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell== nil)
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GenreDetailCustomCell" owner:self options:nil] firstObject];
            DetailGenre *objDetailGenre = (DetailGenre*) [[arrGenreDetail objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

            cell.lblTime.text = [CommonFunctions isEnglish]?objDetailGenre.musicVideoSingerName_en:objDetailGenre.musicVideoSingerName_ar;
            
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
            
            CGRect rect = cell.imgBackground.frame;
            rect.size.width += 20;
            [cell.imgBackground setFrame:rect];
            
            //Swap position music video name and singer name label
            CGRect lblNameFrame = cell.lblName.frame;
            CGRect lblTimeFrame = cell.lblTime.frame;
            lblNameFrame.origin.y = cell.lblTime.frame.origin.y;
            lblTimeFrame.origin.y = cell.lblName.frame.origin.y+10;
            cell.lblName.frame = lblNameFrame;
            cell.lblTime.frame = lblTimeFrame;

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        CGRect rect1 = tblMusic.frame;
        rect1.origin.x = 10;
        rect1.size.width = 310;
        [tblMusic setFrame:rect1];
        
        Genre *objGenre = [arrGenres objectAtIndex:indexPath.row];
        self.genreNameEng = objGenre.genreName_en;
        self.genreNameAr = objGenre.genreName_ar;
        
        lblMusicName.text = [CommonFunctions isEnglish]?objGenre.genreName_en:objGenre.genreName_ar;

        self.strGenreId = objGenre.genreId;
        //lblMovies.text = [objGenre.genreName_en uppercaseString];
        NSDictionary *dictParameters = [NSDictionary dictionaryWithObject:objGenre.genreId forKey:@"GenereId"];
        DetailGenres *objDetailGenres = [[DetailGenres alloc] init];
        [objDetailGenres fetchGenreDetails:self selector:@selector(reponseForGenresService:) parameters:dictParameters genreType:@"music"];
    }
    else if(segmentControl.selectedSegmentIndex == 1)
    {
        MusicSinger *objMusicSinger = [[arrMusicSingers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objMusicSinger.musicVideoName_en;
        }
        else
            self.strMovieNameOnCastingDevice = objMusicSinger.musicVideoName_ar;
        
        self.strMovieUrl = objMusicSinger.musicVideoUrl;
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            [self showLoginScreen];
        }
        
        else
            [self redirectToPlayer:objMusicSinger.musicVideoUrl movieId:objMusicSinger.musicVideoId];
    }
    else if(segmentControl.selectedSegmentIndex == 2 && isGenreDetail == 1)
    {
        DetailGenre *objDetailGenre = [[arrGenreDetail objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_en;
        }
        else
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_ar;
        
        
        self.strMovieUrl = objDetailGenre.movieUrl;
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            [self showLoginScreen];
        }
        
        else
            [self redirectToPlayer:objDetailGenre.movieUrl movieId:objDetailGenre.movieID];
    }
    else if(segmentControl.selectedSegmentIndex == 0)
    {
        FeaturedMusic *objFeaturedMusic = [arrFeaturedMusicVideos objectAtIndex:indexPath.row];
        self.strMovieUrl = objFeaturedMusic.musicUrl;
        if (![CommonFunctions userLoggedIn])
        {
            loginCheck = 1;
            [self showLoginScreen];
        }
        
        else
            [self redirectToPlayer:objFeaturedMusic.musicUrl movieId:objFeaturedMusic.musicId];
        
        //[self redirectToMovieDetailPage:objFeaturedMusic.musicId movieThumbnail:kEmptyString];
    }
}

#pragma mark - Segment Default UI
-(void) setDefaultUIForSegment
{
    [lblNoRecordFound setHidden:YES];
    [self.view bringSubviewToFront:tblMusic];
    CGRect rect = tblMusic.frame;
    rect.origin.x = 10;
    rect.size.width = 300;
    [tblMusic setFrame:rect];
    isGenreDetail = 0;
}

#pragma mark Segment Bar delegate Methods
- (IBAction)segmentedIndexChanged
{
    lblMusicName.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    [self setDefaultUIForSegment];
    switch (segmentControl.selectedSegmentIndex)
    {
        case 0:
            if (![arrFeaturedMusicVideos count]>0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                {
                    FeaturedMusics *objFeaturedMusics = [FeaturedMusics new];
                    [objFeaturedMusics fetchFeaturedMusicVideos:self selector:@selector(featuredVideosServerResponse:)];
                }
            }
            else
            {
                [tblMusic reloadData];
            }
            break;
        case 1:
        {
            singerDetail = NO;
            CGRect rect = tblMusic.frame;
            rect.origin.x = 10;
            rect.size.width = 310;
            [tblMusic setFrame:rect];
            
            if ([arrMusicSingers count]==0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                    [self fetchMusicSingers];
            }
            else
            {
                [tblMusic reloadData];
            }
            break;
        }
        default:
        {   if (![arrGenres count]>0)
            {
                if (![kCommonFunction checkNetworkConnectivity])
                {
                    [lblNoRecordFound setHidden:NO];
                    [self.view bringSubviewToFront:lblNoRecordFound];
                    [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
                }
                else
                    [self fetchMusicGenres];
            }
            else
            {
                [tblMusic reloadData];
            }
            
            break;
        }
    }
}

#pragma mark Fetch Music Singers
- (void)fetchMusicSingers
{
    MusicSingers *objMusicSingers = [MusicSingers new];
    [objMusicSingers fetchMusicSingers:self selector:@selector(musicServerResponse:)];
}

- (void)musicServerResponse:(NSArray*)arrResponse
{
    if ([arrResponse count] == 0) {
        lblNoRecordFound.hidden = NO;
    }
    else
    {
        arrMusicSingers = [arrResponse mutableCopy];
        arrAlphabets = [[NSMutableArray alloc] init];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
            
            arrMusicSingers = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForMusicArabic:arrMusicSingers arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
        }
        else
            arrMusicSingers = [[CommonFunctions returnArrayOfRecordForMusicSingersParticularAlphabet:arrMusicSingers arrayOfAphabetsToDisplay:arrAlphabets] mutableCopy];
    }
    [tblMusic reloadData];
}

- (void)saveLastViewedServerResponse:(NSArray*)arrResponse
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

#pragma mark fetch Genres
- (void)fetchMusicGenres
{
    Genres *objGenres = [[Genres alloc] init];
    [objGenres fetchGenres:self selector:@selector(responseForGenres:) methodName:@"music"];
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
        
    }
    [tblMusic reloadData];
}

#pragma mark - Show Login Screen

- (void)showLoginScreen
{
    LoginViewController *objLoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginCheck = 1;
    [self presentViewController:objLoginViewController animated:YES completion:nil];
}

#pragma mark reponseForGenresService
-(void) reponseForGenresService:(NSMutableArray *) arrDetailGenreLocal
{
    isGenreDetail = 1;
    // tblMusic.hidden = YES;
    arrGenreDetail = [arrDetailGenreLocal mutableCopy];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kArabic]) {
        
        arrAlphabetsForGenre = [CommonFunctions createArabicAlphabetsArrayArabic:arrGenreDetail];
        arrGenreDetail = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenreArabic:arrGenreDetail arrayOfAphabetsToDisplay:arrAlphabetsForGenre] mutableCopy];
    }
    else
    {
        arrGenreDetail = [[CommonFunctions returnArrayOfRecordForParticularAlphabetForDetailGenre:arrGenreDetail arrayOfAphabetsToDisplay:arrAlphabetsForGenre] mutableCopy];
    }
    if([arrGenreDetail count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    [tblMusic reloadData];
}

#pragma mark singerVideosServerResponse
- (void)singerVideosServerResponse:(NSArray*)arrResponse
{
    isGenreDetail = 2;
    singerDetail = YES;
   // tblMusic.hidden = YES;
    arrSingerVideos = [arrResponse mutableCopy];
   // [self.view bringSubviewToFront:collView];
    if([arrSingerVideos count] == 0)
    {
        [lblNoRecordFound setHidden:NO];
        [self.view bringSubviewToFront:lblNoRecordFound];
    }
    
    [collView reloadData];
}

- (void)convertBCoveUrl:(id)object
{
    NSString *movieUrl = [NSString stringWithFormat:@"%@", object];
    NSString *strMP4VideoUrl = [CommonFunctions brightCoveExtendedUrl:movieUrl];
    [self playInMediaPlayer:strMP4VideoUrl];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

#pragma mark - redirect to movie detail page

- (void) redirectToPlayer:(NSString *)url movieId:(NSString*)movieId
{
    self.strMovieId = [NSString stringWithFormat:@"%@", movieId];
    
    if ([url rangeOfString:@"bcove" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(convertBCoveUrl:) withObject:url afterDelay:0.1];
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
        objMoviePlayerViewController.strVideoUrl = url;
        objMoviePlayerViewController.strVideoId = movieId;
        [self.navigationController presentViewController:objMoviePlayerViewController animated:YES completion:nil];
    }
}

- (void)saveToLastViewed
{
    if (self.strMovieId != nil) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]valueForKey:@"userId"], self.strMovieId, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"movieid", nil]];
        
        WatchListMovies *objWatchListMovies = [WatchListMovies new];
        [objWatchListMovies saveMovieToLastViewed:self selector:@selector(saveLastViewedServerResponse:) parameter:dict];
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:youtubeMoviePlayer.moviePlayer];
    [youtubeMoviePlayer.moviePlayer stop];
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
    objCustomControls = [CustomControls new];
    objCustomControls.strVideoUrl = strMP4VideoUrl;
    objCustomControls.strVideoName = self.strMovieNameOnCastingDevice;
    objCustomControls.totalVideoDuration = mpMoviePlayerViewController.moviePlayer.duration;
    
    [mpMoviePlayerViewController.moviePlayer.view addSubview:[objCustomControls castingIconButton:mpMoviePlayerViewController.view moviePlayerViewController:mpMoviePlayerViewController]];
    
    ///
    [objCustomControls hideCastButton];
    self.isCastingButtonHide = YES;
    singleTapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickOnMediaViewToHideCastButton)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer setDelegate:self];
    [mpMoviePlayerViewController.view addGestureRecognizer:singleTapGestureRecognizer];
    
    ///
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
        self.isCastingButtonHide = !self.isCastingButtonHide;
        [objCustomControls unHideCastButton];
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
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
    
   // MPMoviePlayerViewController *moviePlayerViewController = [notification object];
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

#pragma mark - Redirect to movie detail page
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
    MoviesDetailViewController *objMoviesDetailViewController = [[MoviesDetailViewController alloc] initWithNibName:@"MoviesDetailViewController~iphone" bundle:nil];
    [objMoviesDetailViewController setMovieId:movieId];
    [objMoviesDetailViewController setMovieThumbnail:movieThumbnail];
    [objMoviesDetailViewController setTypeOfDetail:(int)music];
    objMoviesDetailViewController.isMusic = YES;
    objMoviesDetailViewController.videoType = 2;
    [self.navigationController pushViewController:objMoviesDetailViewController animated:YES];
}

#pragma mark - Collection View delagate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (isGenreDetail == 1) {
//        return [arrGenreDetail count];
//    }
    
    return [arrSingerVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"CollectionsDetailCustomCellReuse";
    CollectionsDetailCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell==Nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CollectionsDetailCustomCell" owner:self options:nil] firstObject];
    
    [cell setBackgroundColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:27.0/255.0 alpha:1.0]];
    SingerVideo *objSingerVideo = [arrSingerVideos objectAtIndex:indexPath.row];
    [cell.imgMovie sd_setImageWithURL:[NSURL URLWithString:objSingerVideo.movieThumb] placeholderImage:[UIImage imageNamed:@""]];
    cell.lblName.text = [CommonFunctions isEnglish]?objSingerVideo.movieName_en:objSingerVideo.movieName_ar;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *movieUrl = kEmptyString;
   // NSString *movieThumbnail = kEmptyString;
    NSString *movieId = kEmptyString;

    if (isGenreDetail == 1) {
        DetailGenre *objDetailGenre = [arrGenreDetail objectAtIndex:indexPath.row];
        movieUrl = objDetailGenre.movieUrl;
      //  movieThumbnail = kEmptyString;
        movieId = objDetailGenre.movieID;
        
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_en;
        }
        else
            self.strMovieNameOnCastingDevice = objDetailGenre.movieTitle_en;
        
    }
    else{
        SingerVideo *objSingerVideo = [arrSingerVideos objectAtIndex:indexPath.row];
        movieUrl = objSingerVideo.movieUrl;
       // movieThumbnail = kEmptyString;
        movieId = objSingerVideo.movieID;
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish]) {
            self.strMovieNameOnCastingDevice = objSingerVideo.movieName_en;
        }
        else
            self.strMovieNameOnCastingDevice = objSingerVideo.movieName_en;
    }

    if (![CommonFunctions userLoggedIn])
    {
        loginCheck = 1;
        self.strMovieUrl = movieUrl;
        
        [self showLoginScreen];
    }
    
    else
        [self redirectToPlayer:movieUrl movieId:movieId];
    
    //[self redirectToMovieDetailPage:movieId movieThumbnail:movieThumbnail];
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

@end