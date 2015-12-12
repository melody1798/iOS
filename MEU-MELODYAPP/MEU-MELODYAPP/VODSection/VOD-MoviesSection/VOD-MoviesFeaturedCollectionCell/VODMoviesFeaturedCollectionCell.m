//
//  VODMoviesFeaturedCollectionCell.m
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import "VODMoviesFeaturedCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "CommonFunctions.h"

@implementation VODMoviesFeaturedCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appdelegate.fImageWidth = imgVwThumb.frame.size.width;
    appdelegate.fImageHeight = imgVwThumb.frame.size.height;
    
    // Drawing code
    [lblMovieName setFont:[UIFont fontWithName:kProximaNova_Regular size:20.0]];
}

- (void)setCellValues:(FeaturedMovie*)objFeaturedMovie
{    
    [imgVwThumb sd_setImageWithURL:[NSURL URLWithString:objFeaturedMovie.movieThumbnail] placeholderImage:nil];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])

        lblMovieName.text = objFeaturedMovie.movieTitle_en;
    else
        lblMovieName.text = objFeaturedMovie.movieTitle_ar;

    float widthLbl = [self getTextHeight:lblMovieName.text AndFrame:CGRectMake(20, 5, lblMovieName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
}

- (void)setCellValuesSeriesEpisodes:(Episode*)objEpisode
{
   if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSelectedLanguageKey] isEqualToString:kEnglish])
     {
        if (objEpisode.seriesSeasonsCount == 0 || objEpisode.seriesSeasonsCount == 1)
            lblMovieName.text = [NSString stringWithFormat:@"%@ - %@ %@", objEpisode.seriesName_en, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum];
        else
            lblMovieName.text = [NSString stringWithFormat:@"%@ - %@ %@ - %@ %@", objEpisode.seriesName_en, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum];
    }
    else
    {
        if (objEpisode.seriesSeasonsCount == 0 || objEpisode.seriesSeasonsCount == 1)
            lblMovieName.text = [NSString stringWithFormat:@"%@ - %@ %@", objEpisode.seriesName_ar, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum];
        else
            lblMovieName.text = [NSString stringWithFormat:@"%@ - %@ %@ - %@ %@", objEpisode.seriesName_ar, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Sn" value:@"" table:nil], objEpisode.seasonNum, [[CommonFunctions setLocalizedBundle] localizedStringForKey:@"Ep" value:@"" table:nil], objEpisode.episodeNum];
    }
    float widthLbl = [self getTextHeight:lblMovieName.text AndFrame:CGRectMake(20, 5, lblMovieName.frame.size.width, 40)];
    
    imgVwTitleBg.frame = CGRectMake(imgVwTitleBg.frame.origin.x, imgVwTitleBg.frame.origin.y, widthLbl, imgVwTitleBg.frame.size.height);
    
    [imgVwThumb sd_setImageWithURL:[NSURL URLWithString:objEpisode.episodeThumb] placeholderImage:nil];
}

#pragma -mark Calculate The Width Of label
- (float) getTextHeight:(NSString*)str AndFrame:(CGRect)frame
{
    UIFont *font = [UIFont fontWithName:kProximaNova_Bold size:20.0];
    CGFloat widthLbl;
    if (IS_IOS7_OR_LATER) {
        
        CGRect rect = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX) options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
        
        frame.size.width = ceilf(CGRectGetWidth(rect));
        widthLbl = ceilf(frame.size.width) + 20;
        
    } else {
        CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(259, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        widthLbl = ceilf(size.width) + 20;
    }
    return MAX(widthLbl, 84.0);
}

@end