//
//  AtoZTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "AtoZTableViewCell.h"
#import "Constant.h"
#import "CommonFunctions.h"

@implementation AtoZTableViewCell

@synthesize lblMovieName, lblMovieDuration, lblMovieType;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.lblMovieName.font = [UIFont fontWithName:kProximaNova_Bold size:15.0];
   // self.lblMovieType.font = [UIFont fontWithName:kProximaNova_Regular size:12.0];
}

- (void)setMusicatoZCellValues:(MusicSinger*)objMusicSinger
{
    self.lblMovieType.font = [UIFont fontWithName:kProximaNova_Regular size:15.0];
    CGRect singerLabelFrame = self.lblMovieType.frame;
    singerLabelFrame.origin.x = 54;
    singerLabelFrame.origin.y = 30;
    self.lblMovieType.frame = singerLabelFrame;
}

- (NSAttributedString*)setDurationText:(NSString*)str
{
    self.lblMovieDuration.font = [UIFont fontWithName:kProximaNova_Regular size:12.0];

    NSAttributedString *strAtt = [CommonFunctions changeMinTextFont:str fontName:kProximaNova_Regular];
    return strAtt;
}

@end