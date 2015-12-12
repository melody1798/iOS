//
//  LastViewedCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "LastViewedCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"

@implementation LastViewedCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellValues:(LastViewedMovie*)objLastViewedMovie
{
    [imgVwThumb sd_setImageWithURL:[NSURL URLWithString:objLastViewedMovie.movieThumb] placeholderImage:[UIImage imageNamed:@""]];
    lblMovieName.text = objLastViewedMovie.movieName_en;
    lblMovieName.textColor = YELLOW_COLOR;
    lblMovieName.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
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
