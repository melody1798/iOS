//
//  EpisodeDetailViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/09/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Movie/Episode detail overlay
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol FlipAnimationCloseDelegate;

@interface EpisodeDetailViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    MPMoviePlayerViewController*        mpMoviePlayerViewController;
}

@property (strong, nonatomic) NSDictionary*     dictEpisodeData;
@property (strong, nonatomic) UIImage*          _imgViewBg;
@property (strong, nonatomic) NSArray*          arrCastCrew;
@property (strong, nonatomic) NSArray*          arrProducers;
@property (assign, nonatomic) BOOL              isFromVOD;
@property (assign, nonatomic) BOOL              isFromVODMovies;
@property (strong, nonatomic) NSString*         episodeId;
@property (strong, nonatomic) NSString*         seriesIdFromVOD;

@property (strong, nonatomic) MPMoviePlayerViewController*        mpMoviePlayerViewController;

@end

@protocol FlipAnimationCloseDelegate <NSObject>
- (void)closeViewAnimate:(UIViewController*)inController;
@end
