//
//  GenresViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 30/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "GenresViewController.h"
#import "Genres.h"
#import "Genre.h"
#import "Constant.h"
#import "NSIUtility.h"
#import "CustomControls.h"
#import "WatchListViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"

@interface GenresViewController () <UITableViewDataSource, UITableViewDelegate>
{
  //  Genres*                 objGenres;
    IBOutlet UITableView*   tblVwGenres;
    LoginViewController*    objLoginViewController;
}

@end

@implementation GenresViewController

@synthesize strSectionType;
@synthesize arrGenresList;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWatchListCounter:) name:@"updateWatchListMovieCounter" object:nil];

    [self setNavigationBarButtons];

    self.contentSizeForViewInPopover = CGSizeMake(220, 87);
    [self setPopOverHeight];
    [tblVwGenres reloadData];
    
//    if (objGenres == nil) {
//        objGenres = [Genres new];
//        [objGenres fetchGenres:self selector:@selector(fetchGenresServerResponse:) methodName:strSectionType];
//    }
}

- (void)setNavigationBarButtons
{
    self.navigationItem.leftBarButtonItems = @[[CustomControls setNavigationBarButton:nil Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setWatchLisNavigationBarButton:@"watch_list" Target:self selector:@selector(watchListItemAction)]];
    
    self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:@"settings_icon" Target:self selector:@selector(settingsBarButtonItemAction)], [CustomControls setNavigationBarButton:@"search_icon" Target:self selector:@selector(searchBarButtonItemAction)]];
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
        
        if (objLoginViewController.view.superview) {
            return;
        }
        objLoginViewController = nil;
        objLoginViewController = [[LoginViewController alloc] init];        
        [self presentViewController:objLoginViewController animated:YES completion:nil];
    }
    else{
        WatchListViewController *objWatchListViewController = [[WatchListViewController alloc] initWithNibName:@"WatchListViewController" bundle:nil];
        
        //Fetch and pass current view cgcontext for background display
        UIImage *viewImage = [CommonFunctions fetchCGContext:self.view];
        objWatchListViewController._imgViewBg = viewImage;
        [self.navigationController pushViewController:objWatchListViewController animated:YES];
    }
}

- (void)settingsBarButtonItemAction
{
    [NSIUtility showAlertView:nil message:kUnderConstructionErrorMessage];
}

- (void)searchBarButtonItemAction
{
    [NSIUtility showAlertView:nil message:kUnderConstructionErrorMessage];
}

#pragma mark - Server Response Method
- (void)fetchGenresServerResponse:(NSArray*)arrResponse
{
    [self setPopOverHeight];
    [tblVwGenres reloadData];
}


#pragma mark - Customize PopOverController Method
- (void)setPopOverHeight
{
    UIImage *imageToResize = [UIImage imageNamed:@"newPopOver"];
    UIImage *imageResized = [imageToResize resizableImageWithCapInsets:UIEdgeInsetsMake(60, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:100];
    [imageView setImage:imageResized];
    
    float controllerHeight = 42;
    for (int i = 0; i < [arrGenresList count]; i++) {
        
        controllerHeight += 40;
    }
//    if (controllerHeight > 310) {
//        controllerHeight = 310;
//    }
    self.contentSizeForViewInPopover = CGSizeMake(220, controllerHeight);
    CGRect tblVwFrame = tblVwGenres.frame;
    tblVwFrame.size.height = controllerHeight-40;
    tblVwGenres.frame = tblVwFrame;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrGenresList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"genreList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]];
    }
    
    UIImageView *imgVwBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 208, 40)];
    imgVwBack.image = [UIImage imageNamed:@"channel_list_cell_bg"];
    
    UILabel *lblGenreName = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 195, 40)];
    lblGenreName.textColor = [UIColor whiteColor];
    Genre *objGenre = (Genre*)[arrGenresList objectAtIndex:indexPath.row];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblGenreName.text = objGenre.genreName_en;
    else
        lblGenreName.text = objGenre.genreName_ar;

    lblGenreName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    lblGenreName.textAlignment = NSTextAlignmentCenter;
    lblGenreName.backgroundColor = [UIColor clearColor];
    [imgVwBack addSubview:lblGenreName];
    
    [cell.contentView addSubview:imgVwBack];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Genre *objGenre = (Genre*)[arrGenresList objectAtIndex:indexPath.row];
    DLog(@"%@", objGenre.genreId);
    
    if ([self.delegate respondsToSelector:@selector(genreIDSelected:genreName_en:genreName_ar:)]){
        
        [self.delegate genreIDSelected:objGenre.genreId genreName_en:objGenre.genreName_en genreName_ar:objGenre.genreName_ar];
    }
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