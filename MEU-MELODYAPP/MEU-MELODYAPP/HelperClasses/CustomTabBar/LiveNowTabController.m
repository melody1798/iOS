//
//  LiveNowTabController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "LiveNowTabController.h"
#import "AppDelegate.h"
#import "CustomNavBar.h"
#import "CommonFunctions.h"
#import "ChannelsViewController.h"
#import "VODSearchViewController.h"
#import "LiveNowFeaturedViewController.h"
#import "CustomControls.h"

@interface LiveNowTabController ()

@end

@implementation LiveNowTabController

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

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTabItemsText) name:@"TabBarSelectAfterLanguageChange" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTabbarSelectedIndex) name:@"ResetTabbarSelectedIndex" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLiveNowTabbar) name:@"HideTabbarLiveNow" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLiveNowTabbar) name:@"ShowTabbarLiveNow" object:nil];

    [self.navigationController.navigationBar setHidden:NO];
    [self setSegmentBar];
    [self setSegmentedControlAppreance];
}


- (void)setSegmentBar
{
    CGFloat y = [UIScreen mainScreen].bounds.size.height-kSegmentControlHeightForiphone+5;
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Live Tv", @"Channel", @"Search", @"VOD", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    if IS_IOS7_OR_LATER
        segmentedControl.frame = CGRectMake(-5, y, 330, kSegmentControlHeightForiphone);
    else
        segmentedControl.frame = CGRectMake(0, y, 320, kSegmentControlHeightForiphone);
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(segmentControlAction) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:segmentedControl];
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
            self.selectedIndex = 0;
            break;
        }
        case 1:
        {
            self.selectedIndex = 1;
            break;
        }
        case 2:
        {
            self.selectedIndex = 2;
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    switch (tabBarController.selectedIndex) {
        case 3:
        {
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

- (void)setTabItemsText
{
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livetv" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"channels" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"search" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"vod" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
}

- (void)hideLiveNowTabbar
{
    self.tabBar.hidden = YES;
    segmentedControl.hidden = YES;
}

- (void)showLiveNowTabbar
{
    self.tabBar.hidden = NO;
    segmentedControl.hidden = NO;
}

- (void)dealloc
{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end