//
//  CustomUITabBariphoneViewController.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 06/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CustomUITabBariphoneViewController.h"
#import "VODHomeViewController.h"
#import "VODCategoryViewController.h"
#import "VODSearchViewController.h"
#import "SearchVideoViewController.h"
#import "VODWatchListViewController.h"
#import "CustomNavBar.h"
#import "CommonFunctions.h"
#import "LiveNowFeaturedViewController.h"
#import "CustomControls.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "LiveNowTabController.h"
#import "ChannelsViewController.h"
#import <MessageUI/MessageUI.h>

@interface CustomUITabBariphoneViewController ()

@end

@implementation CustomUITabBariphoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppDelegate.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTabItemsText) name:@"VODTabBarChangeLanguage" object:nil];
    
    if (IS_IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    objLoginViewController = [[LoginViewController alloc] init];
    //Set Featured ViewController
    VODHomeViewController *objVODHomeViewController = [[VODHomeViewController alloc] initWithNibName:@"VODHomeViewController" bundle:nil];
    objVODHomeViewController.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    UINavigationController *navigationHomeViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationHomeViewController setViewControllers:@[objVODHomeViewController] animated:NO];
    
    //Set Movies viewController
    VODCategoryViewController *objVODCategoryViewController = [[VODCategoryViewController alloc] initWithNibName:@"VODCategoryViewController" bundle:nil];
    UINavigationController *navigationVODCategoryViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    
    objVODCategoryViewController.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    [navigationVODCategoryViewController setViewControllers:@[objVODCategoryViewController] animated:NO];
    
    //Set Series ViewController
    VODSearchViewController *objVODSearchViewController = [[VODSearchViewController alloc] initWithNibName:@"VODSearchViewController" bundle:nil];
    UINavigationController *navigationVODSearchViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationVODSearchViewController setViewControllers:@[objVODSearchViewController] animated:NO];
    
    //Set Music ViewController
    VODWatchListViewController *objVODWatchListViewController = [[VODWatchListViewController alloc] initWithNibName:@"VODWatchListViewController" bundle:nil];
    UINavigationController *navigationVODWatchListViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    objVODWatchListViewController.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    [navigationVODWatchListViewController setViewControllers:@[objVODWatchListViewController] animated:NO];
    
    UINavigationController *navigationVODLiveNowfeatured = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[LiveNowFeaturedViewController class]])
        {
            [navigationVODLiveNowfeatured setViewControllers:@[controller] animated:NO];
        }
    }
    
    
    [self setViewControllers:@[navigationHomeViewController, navigationVODCategoryViewController, navigationVODSearchViewController,  navigationVODWatchListViewController,navigationVODLiveNowfeatured]];
    
    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [self.tabBar.items objectAtIndex:4];
    
    self.delegate = self;
    
    tabBarItem1.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"home" value:@"" table:nil];
    tabBarItem2.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"categories" value:@"" table:nil];
    tabBarItem3.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil];
    tabBarItem4.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil];
    tabBarItem5.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
    
    tabBarItem1.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    tabBarItem2.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    tabBarItem3.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    tabBarItem4.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    tabBarItem5.titlePositionAdjustment = UIOffsetMake(0, -2.0);
    
    [tabBarItem1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateNormal];
    [tabBarItem2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateNormal];
    [tabBarItem3 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateNormal];
    [tabBarItem4 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateNormal];
    [tabBarItem5 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateNormal];
    
    
    [tabBarItem1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateHighlighted];
    [tabBarItem2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateHighlighted];
    [tabBarItem3 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateHighlighted];
    [tabBarItem4 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateHighlighted];
    [tabBarItem5 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIFont fontWithName:kProximaNova_Bold size:8.0f], UITextAttributeFont,
                                         nil] forState:UIControlStateHighlighted];
    
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:kTabBarBackgroundImageName]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:kTabBarSelectionIndicatorImageName]];
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:kTabBarHomeImageNameActive] withFinishedUnselectedImage:[UIImage imageNamed:kTabBarHomeImageName]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:kTabBarCategoriesImageNameActive] withFinishedUnselectedImage:[UIImage imageNamed:kTabBarCategoriesImageName]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:kTabBarSearchImageNameActive] withFinishedUnselectedImage:[UIImage imageNamed:kTabBarSearchImageName]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:kTabBarWatchlistImageNameActive] withFinishedUnselectedImage:[UIImage imageNamed:kTabBarWatchlistImageName]];
    [tabBarItem5 setFinishedSelectedImage:[UIImage imageNamed:kTabBarLiveNowImageNameActive] withFinishedUnselectedImage:[UIImage imageNamed:kTabBarLiveNowImageName]];
    
     [[UITabBar appearance] setTintColor:[UIColor colorWithRed:254.0/255.0 green:205.0/255.0 blue:63.0/255.0 alpha:1.0]];
//    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    
    if IS_IOS7_OR_LATER
        [[UITabBar appearance] setItemPositioning:UITabBarItemPositioningFill];
}

#pragma Nav Bar button Action events
-(void) settingsBarButtonItemAction
{
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [CommonFunctions pushViewController:self.navigationController ViewController:objSettingViewController];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods NS_AVAILABLE_IOS(6_0)
{
    return YES;
}

#pragma mark - selection
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (tabBarController.selectedIndex)
    {
        case 0:
            lastSelectedIndex = 0;
            break;
        case 1:
            lastSelectedIndex = 1;
            break;
        case 2:
            lastSelectedIndex = 2;
            break;
        case 4:
        {
            [objAppDelegate.navigationController setNavigationBarHidden:NO];
            self.selectedIndex = 0;
            [self setLiveNowTabBar];
            break;
        }
        case 3:
            if(![CommonFunctions userLoggedIn])
            {
                [self showLoginScreen];
                [self setSelectedIndex:lastSelectedIndex];
                return;
            }
            break;
            
        default:
            break;
    }
}

- (void)setTabItemsText
{
    UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
    tabBarItem1.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"home" value:@"" table:nil];
    
    UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
    tabBarItem2.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"categories" value:@"" table:nil];
    
    UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
    tabBarItem3.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil];
    
    UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
    tabBarItem4.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"watchlist" value:@"" table:nil];
    
    UITabBarItem *tabBarItem5 = [self.tabBar.items objectAtIndex:4];
    tabBarItem5.title = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
}

- (void)setLiveNowTabBar
{
    tabControllerLiveNow = [[UITabBarController alloc] init];
    
    //Set Featured ViewController
    LiveNowFeaturedViewController *objVODFeaturedViewController = [[LiveNowFeaturedViewController alloc] initWithNibName:@"LiveNowFeaturedViewController~iphone" bundle:nil];
    UINavigationController *navigationVODFeatured = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    objVODFeaturedViewController.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    [navigationVODFeatured setViewControllers:@[objVODFeaturedViewController] animated:NO];
    
    //Set Movies viewController
    ChannelsViewController *objChannelsViewController = [[ChannelsViewController alloc] initWithNibName:@"ChannelsViewController" bundle:nil];
    UINavigationController *navigationMoviesFeatured = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    objChannelsViewController.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    
    [navigationMoviesFeatured setViewControllers:@[objChannelsViewController] animated:NO];
    
    //Set Series ViewController
    SearchVideoViewController *objSearchVideoViewController = [[SearchVideoViewController alloc] initWithNibName:@"SearchVideoViewController~iphone" bundle:nil];
    UINavigationController *navigationSeriesAllViewController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
    [navigationSeriesAllViewController setViewControllers:@[objSearchVideoViewController] animated:NO];
    
    tabControllerLiveNow.delegate = self;
    
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [objAppDelegate.navigationController setNavigationBarHidden:NO];
    
    objAppDelegate.navigationController .navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
    
    
    [tabControllerLiveNow setViewControllers:@[navigationVODFeatured, navigationMoviesFeatured, navigationSeriesAllViewController]];
    
    [self setSegmentBarNotifications];
    
    if (IS_IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.navigationController pushViewController:tabControllerLiveNow animated:NO];
}

- (void)setSegmentBarNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTabItemsTexts) name:@"TabBarSelectAfterLanguageChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTabbarSelectedIndex) name:@"ResetTabbarSelectedIndex" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLiveNowTabbar) name:@"HideTabbarLiveNow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLiveNowTabbar) name:@"ShowTabbarLiveNow" object:nil];
    
    [self.navigationController.navigationBar setHidden:NO];
    
   // [self.tabBar setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    [self setSegmentBar];
    [self setSegmentedControlAppreance];
}

- (void)setSegmentBar
{
    CGFloat y = 0;
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Live Tv", @"Channel", @"Search", @"VOD", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    if IS_IOS7_OR_LATER
        segmentedControl.frame = CGRectMake(-5, y, 330, kSegmentControlHeightForiphone);
    else
        segmentedControl.frame = CGRectMake(0, y, 320, kSegmentControlHeightForiphone);
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(segmentControlAction) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.selectedSegmentIndex = 0;
    
    segmentedControl.enabled = YES;
    
    [tabControllerLiveNow.tabBar addSubview:segmentedControl];
    [tabControllerLiveNow.tabBar bringSubviewToFront:segmentedControl];
}

- (void)setSegmentedControlAppreance
{
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livetv" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"vod" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
    
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.tintColor = [UIColor blackColor];
    
    [segmentedControl setBackgroundImage:[UIImage imageNamed:kSegmentBackgroundImageName] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIFont *Boldfont = [UIFont fontWithName:kProximaNova_Bold size:[CommonFunctions isIphone] ? 11.0:15.0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentedControl setTitleTextAttributes:selectionAttributes
                                    forState:UIControlStateSelected];
    
    [segmentedControl setWidth:90 forSegmentAtIndex:3];
}

- (void)segmentControlAction
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            tabControllerLiveNow.selectedIndex = 0;
            break;
        }
        case 1:
        {
            tabControllerLiveNow.selectedIndex = 1;
            break;
        }
        case 2:
        {
            tabControllerLiveNow.selectedIndex = 2;
            break;
        }
        case 3:
        {
            AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
            appDelegate.isFromSearch = NO;
            for(UIViewController *controller in self.navigationController.viewControllers)
                if([controller isKindOfClass:[CustomUITabBariphoneViewController class]])
                    [self.navigationController popToViewController:controller animated:NO];
            break;
        }
        default:
            break;
    }
}


- (void)resetTabbarSelectedIndex
{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.isFromSearch = YES;
    self.selectedIndex = 1;
    segmentedControl.selectedSegmentIndex = 1;
}

- (void)setTabItemsTexts
{
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livetv" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"vod" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
}

- (void)hideLiveNowTabbar
{
    self.tabBar.hidden = YES;
    
    tabControllerLiveNow.tabBar.hidden = YES;
    segmentedControl.hidden = YES;
}

- (void)showLiveNowTabbar
{
    self.tabBar.hidden = NO;
    
    tabControllerLiveNow.tabBar.hidden = NO;
    segmentedControl.hidden = NO;
}

#pragma mark - show login screen
- (void)showLoginScreen
{
    if (objLoginViewController.view.superview)
    {
        return;
    }
    objLoginViewController = nil;
    objLoginViewController = [[LoginViewController alloc] init];
    CGFloat windowHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    [objLoginViewController.view setFrame:CGRectMake(0, windowHeight, self.view.frame.size.width, windowHeight)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:objLoginViewController.view];
    [UIView animateWithDuration:0.5f animations:^{
        [objLoginViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, windowHeight)];
    } completion:nil];
    
    //btnPlayVideo.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TabBarSelectAfterLanguageChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResetTabbarSelectedIndex" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideTabbarLiveNow" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowTabbarLiveNow" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end