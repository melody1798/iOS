//
//  LiveNowCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 01/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LiveNowCustomCell.h"

@implementation LiveNowCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)awakeFromNib
{
    // Setting fonts
    [self setFont];
}
#pragma mark - Set fonts
-(void) setFont
{
    [_lblChannelName setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [_lblTime setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
