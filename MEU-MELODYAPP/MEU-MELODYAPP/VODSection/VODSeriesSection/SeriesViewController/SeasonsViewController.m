//
//  SeasonsViewController.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "SeasonsViewController.h"
#import "SeriesSeason.h"
#import "CommonFunctions.h"

@interface SeasonsViewController ()
{
    IBOutlet UITableView*   tblVwSeasons;
}

@end

@implementation SeasonsViewController

@synthesize strSeriesId;
@synthesize delegate;
@synthesize arrSeasons;

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
    
    self.contentSizeForViewInPopover = CGSizeMake(196, 70);
    [self setPopOverHeight];
    [tblVwSeasons reloadData];
}

#pragma mark - Customize PopOverController Method
- (void)setPopOverHeight
{
    UIImage *imageToResize = [UIImage imageNamed:@"channel_list_border"];
    UIImage *imageResized = [imageToResize resizableImageWithCapInsets:UIEdgeInsetsMake(60, 20, 40, 20) resizingMode:UIImageResizingModeStretch];
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:100];
    [imageView setImage:imageResized];
    
    float controllerHeight = 70;
    for (int i = 0; i < [self.arrSeasons count]; i++) {
        
        controllerHeight += 25;
    }
    if (controllerHeight>=160) {
        controllerHeight = 160;
    }
    
    self.contentSizeForViewInPopover = CGSizeMake(196, controllerHeight);
    CGRect tblVwFrame = tblVwSeasons.frame;
    tblVwFrame.size.height = controllerHeight-58;
    tblVwSeasons.frame = tblVwFrame;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrSeasons count];
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
    
    UIImageView *imgVwBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 156, 40)];
    imgVwBack.image = [UIImage imageNamed:@"channel_list_cell_bg"];
    
    UILabel *lblGenreName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 156, 40)];
    lblGenreName.textColor = [UIColor whiteColor];
    SeriesSeason *objSeriesSeason = (SeriesSeason*)[self.arrSeasons objectAtIndex:indexPath.row];
    lblGenreName.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"season" value:@"" table:nil], objSeriesSeason.seasonNum];
    lblGenreName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    lblGenreName.textAlignment = NSTextAlignmentCenter;
    lblGenreName.backgroundColor = [UIColor clearColor];
    [imgVwBack addSubview:lblGenreName];
    
    [cell.contentView addSubview:imgVwBack];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SeriesSeason *objSeriesSeason = (SeriesSeason*)[self.arrSeasons objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(fetchEpisodesForSelectedSeason:)]) {
        [self.delegate fetchEpisodesForSelectedSeason:objSeriesSeason.seasonNum];
    }
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end