//
//  VODFeaturedCollectionCell.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 23/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//  Custom collection view cell.

#import <UIKit/UIKit.h>
#import "MovieInCollection.h"
#import "FeaturedMusic.h"
#import "MusicSinger.h"
#import "VODFeaturedVideo.h"
#import "DetailGenre.h"

@interface VODFeaturedCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView*   imageVwVideo;
@property (weak, nonatomic) IBOutlet UIImageView*   imgVwTitleBg;
@property (weak, nonatomic) IBOutlet UILabel*       lblVideoName;
@property (weak, nonatomic) IBOutlet UILabel*       lblSingerName;

- (void)setCellValuesForVODFeaturedMovies:(VODFeaturedVideo*)objVODFeaturedVideo;
- (void)setCellValuesForCollectionMovies:(MovieInCollection*)objMovieInCollection;
- (void)setCellValuesForMusic:(FeaturedMusic*)objMovieInCollection;
- (void)setCellValuesForSingers:(MusicSinger*)objMusicSinger;
- (void)setCellValuesForSingersVideos:(MovieInCollection*)objSingerVideo;
- (void)setCellValuesForAllSeries:(MovieInCollection*)objSingerVideo;
- (void)setCellValuesForMusicGenre:(DetailGenre*)objDetailGenre;

@end
