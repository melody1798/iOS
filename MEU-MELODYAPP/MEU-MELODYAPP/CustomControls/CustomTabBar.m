//
//  CustomTabBar.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 24/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CustomTabBar.h"
#import "Constant.h"
#import "CommonFunctions.h"
#import "AppDelegate.h"

@interface CustomTabBar ()

@end

@implementation CustomTabBar

@synthesize segmentProperty = segmentedControl;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self addCustomElements];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBar) name:@"HideTabbarNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideTabBar) name:@"UnhideTabbarNoti" object:nil];
}

- (void)addCustomElements
{
    UIImage *tabBackground = [[UIImage imageNamed:@"tab_bar"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UITabBar appearance] setBackgroundImage:tabBackground];
    [[self tabBar] setBackgroundImage:tabBackground];
    
    [self.tabBar setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    CGFloat y = [UIScreen mainScreen].bounds.size.height-10-kSegmentControlHeight;
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"HOME", @"MOVIES", @"SERIES", @"MUSIC", @"PACKS", @"LIVE TV", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    if IS_IOS7_OR_LATER
        segmentedControl.frame = CGRectMake(84, y, 601, kSegmentControlHeight);
    else
        segmentedControl.frame = CGRectMake(84, y, 601, kSegmentControlHeight);

    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(segmentControlAction) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.selectedSegmentIndex = 0;
    [self setSegmentedControlAppreance];
    [self.view addSubview:segmentedControl];
}

- (void)setTabbarIndex:(int)tabbarIndex {
    
    if (tabbarIndex == 5) {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [appDelegate.navigationController popViewControllerAnimated:NO];
        //        [currentNavController popViewControllerAnimated:NO];
    }
    else {
        self.selectedIndex = tabbarIndex;
        
        NSArray *arrNavControllers = [self viewControllers];
        UINavigationController *currentNavController = (UINavigationController *)[arrNavControllers objectAtIndex:tabbarIndex];
        [currentNavController popToRootViewControllerAnimated:NO];
    }
    
}

- (void)segmentControlAction
{
//    [delegate setTabBarIndex:(int)segmentedControl.selectedSegmentIndex];
    [self setTabbarIndex:(int)segmentedControl.selectedSegmentIndex];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVODHomeMethod) name:@"GotoVODHomeNoti" object:nil];
}

- (void)gotoVODHomeMethod
{
    segmentedControl.selectedSegmentIndex = 0;
    [self setTabbarIndex:0];
//    [delegate setTabBarIndex:(int)segmentedControl.selectedSegmentIndex];
}

- (void)hideTabBar
{
    segmentedControl.hidden = YES;
}

- (void)unhideTabBar
{
    segmentedControl.hidden = NO;
}

- (void)selectTabIndex:(int)index
{
    
}

- (void)setSegmentedControlAppreance
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLiveNowSegmentControl) name:@"updateLiveNowSegmentedControl" object:nil];

    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"home" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"collection" value:@"" table:nil] uppercaseString] forSegmentAtIndex:4];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livetv" value:@"" table:nil] uppercaseString] forSegmentAtIndex:5];
    
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.tintColor = [UIColor clearColor];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"vod_segment_bar"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIFont *Boldfont = [UIFont fontWithName:kProximaNova_Bold size:15.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont, YELLOW_COLOR,UITextAttributeTextColor,nil];
    
    [segmentedControl setTitleTextAttributes:selectionAttributes
                                    forState:UIControlStateSelected];
}

- (void)updateLiveNowSegmentControl
{
     [self setLocalizedText];
}

- (void)setLocalizedText
{
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"home" value:@"" table:nil] uppercaseString] forSegmentAtIndex:0];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"movies" value:@"" table:nil] uppercaseString] forSegmentAtIndex:1];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"series" value:@"" table:nil] uppercaseString] forSegmentAtIndex:2];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"music" value:@"" table:nil] uppercaseString] forSegmentAtIndex:3];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"collection" value:@"" table:nil] uppercaseString] forSegmentAtIndex:4];
    [segmentedControl setTitle:[[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livetv" value:@"" table:nil] uppercaseString] forSegmentAtIndex:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:@"HideTabbarNoti"];
//    [[NSNotificationCenter defaultCenter] removeObserver:@"UnhideTabbarNoti"];
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