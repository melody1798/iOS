//
//  LiveFeaturedListViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveFeaturedListViewController.h"
#import "LiveNowListTableCell.h"
#import "CustomControls.h"
#import "Constant.h"
#import "LiveNowFeaturedVideo.h"
#import "CommonFunctions.h"

@interface LiveFeaturedListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel*       lblLiveNowText;
}

@end

@implementation LiveFeaturedListViewController

@synthesize _arrayLiveVideos;
@synthesize delegate;

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
    
    //Set UI
    lblLiveNowText.font = [UIFont fontWithName:kProximaNova_Bold size:24.0];
    lblLiveNowText.text = [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"livenow" value:@"" table:nil];
    
    self.contentSizeForViewInPopover = CGSizeMake(450, 379);
}

#pragma mark - Action methods

- (void)btnListPlayVideo:(id)sender
{
    //Handle tap on play button.
    if ([delegate respondsToSelector:@selector(playVideoOnListView:)]) {
        LiveNowFeaturedVideo *objLiveNowFeaturedVideo = (LiveNowFeaturedVideo*)[_arrayLiveVideos objectAtIndex:[sender tag]];
        
        [delegate playVideoOnListView:objLiveNowFeaturedVideo.videoUrl];
    }
}

#pragma mark - UITableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrayLiveVideos count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"listviewcell";
    LiveNowListTableCell *cell = (LiveNowListTableCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (LiveNowListTableCell*) [[[NSBundle mainBundle] loadNibNamed:@"LiveNowListTableCell" owner:self options:nil] objectAtIndex:0];
    }
    
    [cell setCellValues:[_arrayLiveVideos objectAtIndex:indexPath.row]];
    [cell.btnPlayVideo setTag:indexPath.row];
    [cell.btnPlayVideo addTarget:self action:@selector(btnListPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
