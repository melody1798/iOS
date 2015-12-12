//
//  EpisodesCollectionCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 08/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
// episodes custom collection cell.

#import <UIKit/UIKit.h>
#import "Episode.h"
#import "MovieInCollection.h"

@interface EpisodesCollectionCell : UICollectionViewCell
{
    IBOutlet UIImageView*       imgEpisodeThumb;
    IBOutlet UILabel*           lblEpisodeName;
    IBOutlet UILabel*           lblSingerName;
}

- (void)setCellValuesSeriesEpisodes:(Episode*)objFeaturedMovie;
- (void)setCellValuesForCollectionMovies:(MovieInCollection*)objMovieInCollection;

@end
