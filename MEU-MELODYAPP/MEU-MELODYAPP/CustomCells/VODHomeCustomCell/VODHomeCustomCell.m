//
//  VODHomeCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 22/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODHomeCustomCell.h"

@implementation VODHomeCustomCell

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
    [_lblMovieName setFont:[UIFont fontWithName:kProximaNova_Bold size:16.0]];
    [_lblSeasonName setFont:[UIFont fontWithName:kProximaNova_Bold size:14.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
