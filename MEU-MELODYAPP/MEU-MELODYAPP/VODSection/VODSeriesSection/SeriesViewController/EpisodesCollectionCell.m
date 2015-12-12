//
//  EpisodesCollectionCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "EpisodesCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "CommonFunctions.h"

@implementation EpisodesCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellValuesSeriesEpisodes:(Episode*)objEpisode
{
    CGRect imgEpisodeThumbFrame = imgEpisodeThumb.frame;
    imgEpisodeThumbFrame.size.height = 140;
    imgEpisodeThumb.frame = imgEpisodeThumbFrame;
    
    CGRect lblMovieNameFrame = lblEpisodeName.frame;
    lblMovieNameFrame.origin.y = 138;
    lblEpisodeName.frame = lblMovieNameFrame;
    
    NSString *episodeName;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        episodeName = [objEpisode.episodeName_en length]>0?[NSString stringWithFormat:@"- %@", objEpisode.episodeName_en]:@"";
        lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [episodeName length]>0?episodeName:@""];
    }
    else
    {
        episodeName = [objEpisode.episodeName_ar length]>0?[NSString stringWithFormat:@"- %@", objEpisode.episodeName_ar]:@"";
        lblEpisodeName.text = [NSString stringWithFormat:@"%@ %@ %@", [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum, [episodeName length]>0?objEpisode.episodeName_ar:@""];
    }
    [imgEpisodeThumb sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:nil];
    lblEpisodeName.textColor = YELLOW_COLOR;
}

- (void)setCellValuesForCollectionMovies:(MovieInCollection*)objMovieInCollection
{
    CGRect imgEpisodeThumbFrame = imgEpisodeThumb.frame;
    imgEpisodeThumbFrame.size.height = 132;
    imgEpisodeThumb.frame = imgEpisodeThumbFrame;
    
    CGRect lblMovieNameFrame = lblEpisodeName.frame;
    lblMovieNameFrame.origin.y = 130;
    lblEpisodeName.frame = lblMovieNameFrame;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
    {
        lblEpisodeName.text = objMovieInCollection.movieName_en;
        lblSingerName.text = objMovieInCollection.singerName_en;
    }
    else
    {
        lblEpisodeName.text = objMovieInCollection.movieName_ar;
        lblSingerName.text = objMovieInCollection.singerName_ar;
    }
    if (objMovieInCollection.movieType == 2)
        lblSingerName.hidden = NO;
   
    [imgEpisodeThumb sd_setImageWithURL:[NSURL URLWithString:objMovieInCollection.thumbUrl] placeholderImage:nil];
    lblEpisodeName.textColor = [UIColor whiteColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    lblEpisodeName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
    lblSingerName.font = [UIFont fontWithName:kProximaNova_Bold size:16.0];
}

@end