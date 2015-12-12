//
//  VODCategoryViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODCategoryViewController.h"
#import "CategoriesCustomCell.h"
#import "MoviesViewController.h"
#import "CustomControls.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"
#import "CollectionsViewController.h"
#import "MusicViewController.h"
#import "SeriesViewController.h"
@interface VODCategoryViewController ()

@end

@implementation VODCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Page LifeCycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    
    if(IS_IOS7_OR_LATER && [CommonFunctions isIphone])
    {
        if(![CommonFunctions isIphone5])
        {
            CGRect rect = tblCategories.frame;
            rect.origin.y -=  10;
            [tblCategories setFrame:rect];
        }
        else
        {
            CGRect rect = tblCategories.frame;
            rect.origin.y -=  10;
            rect.size.height += 10;
            [tblCategories setFrame:rect];
        }
    }
    else if([CommonFunctions isIphone])
    {
        if([CommonFunctions isIphone5])
        {
            CGRect rect = vwheader.frame;
            rect.origin.y -= 15;
            [vwheader setFrame:rect];
            rect = tblCategories.frame;
            rect.origin.y -=  5;
            rect.size.height += 5;
            [tblCategories setFrame:rect];
        }
        else
        {
            CGRect rect = tblCategories.frame;
            rect.origin.y +=  60;
            [tblCategories setFrame:rect];
        }
    }
    
    
    [lblCategories setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [CommonFunctions addGoogleAnalyticsForView:@"Categories"];

    arrCategories = [[NSMutableArray alloc] init];
    
    [self removeMelodyButton];
    [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

    // Dummy code to be removed.
    [arrCategories addObject:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil]];
    [arrCategories addObject:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil]];
    [arrCategories addObject:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil]];
    [arrCategories addObject:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"collectionSmall" value:@"" table:nil]];
    
    [tblCategories reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [self removeMelodyButton];
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

#pragma mark - Setting Button Action event

- (void)btnMelodyIconAction
{
    self.tabBarController.selectedIndex = 0;
}

- (void)settingsBarButtonItemAction
{
    [CommonFunctions showAlertView:kUnderConstructionErrorMessage TITLE:kEmptyString Delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
}

#pragma mark - UITableView Datasource and delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    CategoriesCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoriesCustomCell" owner:self options:nil] firstObject];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblCategories.text = [arrCategories objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MoviesViewController *objMoviesViewController = [[MoviesViewController alloc] initWithNibName:@"MoviesViewController~iphone" bundle:Nil];
    CollectionsViewController *objCollectionsViewController = [[CollectionsViewController alloc] initWithNibName:@"CollectionsViewController~iphone" bundle:Nil];
    MusicViewController *objMusicViewController = [[MusicViewController alloc] initWithNibName:@"MusicViewController~iphone" bundle:Nil];
    SeriesViewController *objSeriesViewController = [[SeriesViewController alloc] initWithNibName:@"SeriesViewController~iphone" bundle:Nil];
    switch (indexPath.row)
    {
        case 0:
            for(UIViewController *controller in self.navigationController.viewControllers)
            {
                if([controller isKindOfClass:[MoviesViewController class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    return;
                }
            }
            [self.navigationController pushViewController:objMoviesViewController animated:YES];
            break;
        case 1:
            [CommonFunctions pushViewController:self.navigationController ViewController:objSeriesViewController];
            break;
        case 2:
            [CommonFunctions pushViewController:self.navigationController ViewController:objMusicViewController];
            break;
        case 3:
            for(UIViewController *controller in self.navigationController.viewControllers)
            {
                if([controller isKindOfClass:[CollectionsViewController class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    return;
                }
            }
            [self.navigationController pushViewController:objCollectionsViewController animated:YES];
            break;
            
        default:
            break;
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
