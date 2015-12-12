//
//  CustomPopOverView.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 21/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CustomPopOverView.h"

@implementation CustomPopOverView

@synthesize imgVwPopOver;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{
    CustomPopOverView *customView = [[[NSBundle mainBundle] loadNibNamed:@"CustomPopOverView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[CustomPopOverView class]])
        return customView;
    else
        return nil;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //Add Background
    UIImageView *imageVwCellBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 127, 40)];
    imageVwCellBg.image = [UIImage imageNamed:@"Channel_cell_bg"];
    
    //Add channel Logo
    UIImageView *imageVwChannelLogo = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, 35, 31)];
    imageVwChannelLogo.image = [UIImage imageNamed:@"channel_logo"];
    
    [cell.contentView addSubview:imageVwCellBg];
    [cell.contentView addSubview:imageVwChannelLogo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(returnTableViewSelectedRow:)]){
        [self.delegate returnTableViewSelectedRow:indexPath.row];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end