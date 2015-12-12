//
//  VODMoviesFeaturedCollectionCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 25/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//  VOD movies featured

#import <UIKit/UIKit.h>
#import "FeaturedMovie.h"
#import "Episode.h"

@interface VODMoviesFeaturedCollectionCell : UICollectionViewCell
{
    IBOutlet UILabel*       lblMovieName;
    IBOutlet UIImageView*   imgVwThumb;
    IBOutlet UIImageView*   imgVwTitleBg;
}
- (void)setCellValues:(FeaturedMovie*)objFeaturedMovie;
- (void)setCellValuesSeriesEpisodes:(FeaturedMovie*)objFeaturedMovie;

@end