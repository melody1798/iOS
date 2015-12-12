//
//  RelatedTableViewCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 16/02/15.
//  Copyright (c) 2015 Nancy Kashyap. All rights reserved.
//

#import "RelatedTableViewCell.h"
#import "CommonFunctions.h"

@implementation RelatedTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.lblEpisodeNumPrev.textColor = [UIColor grayColor];
    self.lblEpisodeNumNext.textColor = [UIColor grayColor];
    self.lblEpisodeNamePrev.textColor = [UIColor whiteColor];
    self.lblEpisodeNameNext.textColor = [UIColor whiteColor];
}

- (void)setRelatedEpisodesPrev:(Episode*)objEpisode
{
    self.lblEpisodeNumPrev.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], (objEpisode.episodeNum)];
    self.lblEpisodeNamePrev.text = [objEpisode.episodeName_en length]>0?[NSString stringWithFormat:@"- %@", objEpisode.episodeName_en]:@"";
    [self.imgVwRelatedEpisodePrev sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb]];
}

- (void)setRelatedEpisodesNext:(Episode*)objEpisode
{
    self.lblEpisodeNumNext.hidden = NO;
    self.lblEpisodeNameNext.hidden = NO;
    self.lblEpisodeNumNext.text = [NSString stringWithFormat:@"%@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], (objEpisode.episodeNum)];
    
    self.lblEpisodeNameNext.text = [objEpisode.episodeName_en length]>0?[NSString stringWithFormat:@"- %@", objEpisode.episodeName_en]:@"";
    [self.imgVwRelatedEpisodeNext sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb]];
}

@end
