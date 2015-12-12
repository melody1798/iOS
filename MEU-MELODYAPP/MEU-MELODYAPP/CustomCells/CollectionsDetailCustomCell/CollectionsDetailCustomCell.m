//
//  CollectionsDetailCustomCell.m
//  MEU-MELODYAPP
//
//  Created by Arvinder Singh on 07/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "CollectionsDetailCustomCell.h"

@implementation CollectionsDetailCustomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) awakeFromNib
{
    [_lblName setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
    [_lblEpisodeTitle setFont:[UIFont fontWithName:kProximaNova_Bold size:12.0]];
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
