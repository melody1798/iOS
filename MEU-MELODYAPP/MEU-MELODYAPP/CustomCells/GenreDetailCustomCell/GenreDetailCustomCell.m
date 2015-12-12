//
//  GenreDetailCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "GenreDetailCustomCell.h"

@implementation GenreDetailCustomCell

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
    [self initUI];
}

#pragma initUI


- (void) initUI
{
    _lblTime.font = [UIFont fontWithName:kProximaNova_SemiBold size:12.0];
    _lblName.font = [UIFont fontWithName:kProximaNova_Bold size:14.0];
    _lblAbbr.font = [UIFont fontWithName:kProximaNova_Regular size:14.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
