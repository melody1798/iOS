//
//  FeaturedTableViewCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "FeaturedTableViewCustomCell.h"

@implementation FeaturedTableViewCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    [_lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:15.0]];
    [_lblEpisodeName setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
