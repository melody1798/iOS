//
//  CastAndCrewDescriptionCellForArtists.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 04/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CastAndCrewDescriptionCellForArtists.h"

@implementation CastAndCrewDescriptionCellForArtists

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
    [_lblName setFont:[UIFont fontWithName:kProximaNova_Regular size:15.0]];
    [_lblRole setFont:[UIFont fontWithName:kProximaNova_Regular size:15.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
