//
//  ChannelsViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "ChannelsViewController.h"
#import "Channels.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"
#import "ChannelCustomCell.h"
#import "CustomControls.h"
#import "ChannelDetailViewViewController.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "CustomUITabBariphoneViewController.h"

@interface ChannelsViewController ()
{
    IBOutlet UITableView*   tblVwChannels;
    IBOutlet UILabel*       lblNoVideoFound;
}

@property (strong, nonatomic) NSArray*      arrChannels;    //Store channel list data.

@end

@implementation ChannelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void) viewDidLayoutSubviews {
//    // only works for iOS 7+
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        // Move the view down 20 pixels
//        CGRect bounds = self.view.bounds;
//        bounds.origin.y -= 0.0;
//        [self.view setBounds:bounds];
//        
//        // Create a solid color background for the status bar
//        CGRect statusFrame = CGRectMake(0.0, 0.0, bounds.size.width, 20);
//        UIView* statusBar = [[UIView alloc] initWithFrame:statusFrame];
//        statusBar.backgroundColor = [UIColor blackColor];
//        [self.view addSubview:statusBar];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (![CommonFunctions isIphone]) {
//        self.contentSizeForViewInPopover = CGSizeMake(160, 87); //Set popover size.
    }
    else
    {
        //Set UI
        lblNoVideoFound.font = [UIFont fontWithName:kProximaNova_Bold size:12.0];
        self.navigationItem.rightBarButtonItems = @[[CustomControls setNavigationBarButton:kSettingButtonImageName Target:self selector:@selector(settingsBarButtonItemAction)]];
        if (iPhone4WithIOS7) {
            CGRect tbtFrame = tblVwChannels.frame;
            tbtFrame.size.height = tblVwChannels.frame.size.height-70;
            tblVwChannels.frame = tbtFrame;
        }
        [self.view addSubview:[CommonFunctions addiAdBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50 delegate:self]];
    }
    if (![kCommonFunction checkNetworkConnectivity])  //Check network connection.
    {
        [lblNoVideoFound setHidden:NO];
        [CommonFunctions showAlertView:nil TITLE:[[CommonFunctions setLocalizedBundle] localizedStringForKey:@"internet connection check" value:@"" table:nil] Delegate:nil];
    }
    else
    {
        //Fetch list of channels.
        Channels *objChannels = [Channels new];
        [objChannels fetchChannels:self selector:@selector(channelListServerResponse:)];
    }
    if ([CommonFunctions isIphone]) {

        [self removeMelodyButton];
        [self.navigationController.navigationBar addSubview:[CustomControls melodyIconButton:self selector:@selector(btnMelodyIconAction)]];

        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if (appDelegate.isFromSearch) {
            ChannelDetailViewViewController *objChannelDetailViewViewController = [[ChannelDetailViewViewController alloc] initWithNibName:@"ChannelDetailViewViewController" bundle:nil];
            objChannelDetailViewViewController.strChannelName = appDelegate.channelName;
            [self.navigationController pushViewController:objChannelDetailViewViewController animated:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)ChannelDetailFromSearch
{
    //Show channel detail screnn if user came from search screen.
    if ([CommonFunctions isIphone]) {
        ChannelDetailViewViewController *objChannelDetailViewViewController = [[ChannelDetailViewViewController alloc] initWithNibName:@"ChannelDetailViewViewController" bundle:nil];
        [self.navigationController pushViewController:objChannelDetailViewViewController animated:YES];
    }
}

#pragma mark - UINavgation Bar button actions
- (void)settingsBarButtonItemAction
{
    SettingViewController *objSettingViewController = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:objSettingViewController animated:YES];
}

- (void)btnMelodyIconAction
{
    AppDelegate *objAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(UIViewController *controller in objAppDelegate.navigationController.viewControllers)
        if([controller isKindOfClass:[CustomUITabBariphoneViewController class]])
            [objAppDelegate.navigationController popToViewController:controller animated:NO];
}

#pragma mark - Server Response methods
- (void)channelListServerResponse:(NSArray*)arrResponse
{
    self.arrChannels = [[NSArray alloc] initWithArray:arrResponse];
    if (![CommonFunctions isIphone]) {

        [self setPopOverHeight];
    }
    [tblVwChannels reloadData];
}

#pragma mark - Customize PopOverController Method
- (void)setPopOverHeight
{
    UIImage *imageToResize = [UIImage imageNamed:@"channel_list_border"];
    UIImage *imageResized = [imageToResize resizableImageWithCapInsets:UIEdgeInsetsMake(60, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:100];
    [imageView setImage:imageResized];
    
    float controllerHeight = 42;
    for (int i = 0; i < [self.arrChannels count]; i++) {
        
        controllerHeight += 41;
    }
    self.contentSizeForViewInPopover = CGSizeMake(160, 295);
    CGRect tblVwFrame = tblVwChannels.frame;
    tblVwFrame.size.height = 240;
    tblVwChannels.frame = tblVwFrame;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrChannels count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![CommonFunctions isIphone]) {
        
        
        static NSString *cellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        //Add Background
        UIImageView *imageVwCellBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 126, 40)];
        imageVwCellBg.image = [UIImage imageNamed:@"channel_list_cell_bg"];
        
        //Add channel Logo
        
        Channel *objChannel = (Channel*) [self.arrChannels objectAtIndex:indexPath.row];
        UIImageView *imageVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, 35, 35)];
        [imageVwChannelLogo sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:[UIImage imageNamed:@"dummy_logo"]];
        imageVwChannelLogo.contentMode = UIViewContentModeScaleToFill ;
        imageVwChannelLogo.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageVwCellBg];
        [cell.contentView addSubview:imageVwChannelLogo];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"cell";
        ChannelCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell == Nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ChannelCustomCell" owner:self options:Nil] firstObject];
        }
        [cell setBackgroundColor:color_Background];
        Channel *objChannel = [self.arrChannels objectAtIndex:indexPath.row];
        [cell.imgLogo sd_setImageWithURL:[NSURL URLWithString:objChannel.channelLogoUrl] placeholderImage:[UIImage imageNamed:@""]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Channel *objChannel = (Channel*) [self.arrChannels objectAtIndex:indexPath.row];
    if ([CommonFunctions isIphone]) {
        
        [self removeMelodyButton];
        ChannelDetailViewViewController *objChannelDetailViewViewController = [[ChannelDetailViewViewController alloc] initWithNibName:@"ChannelDetailViewViewController" bundle:nil];
        objChannelDetailViewViewController.strChannelName = objChannel.channelName_en;
        [self.navigationController pushViewController:objChannelDetailViewViewController animated:YES];        
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(returnTableViewSelectedRow:)]){
            [self.delegate returnTableViewSelectedRow:objChannel];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([CommonFunctions isIphone]) {
        return 81;
    }
    return 40;
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

#pragma mark - IAd Banner Delegate Methods
//Show banner if can load ad.
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}

//Hide banner if can't load ad.
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //load admob if iads fails.
    [banner removeFromSuperview];
    [self.view addSubview:[CommonFunctions addAdmobBanner:[[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.frame.size.height - 50]];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end