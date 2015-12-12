//
//  MovieDetailViewController.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//
// Movies, series detail iPad.

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface MovieDetailViewController : UIViewController<MFMailComposeViewControllerDelegate>
{
}

@property (strong, nonatomic) NSString*         strMovieId; //Movie id
@property (assign, nonatomic) BOOL              isMusicVideo; //flag to check music video
@property (assign, nonatomic) BOOL              isEpisode;//flag to check episode video
@property (assign, nonatomic) BOOL              isSeries;//flag to check series video

@property (strong, nonatomic) NSArray*          arrCastAndCrew; //Cast and crew array
@property (strong, nonatomic) NSArray*          arrProducers;   //Producers/director
@property (strong, nonatomic) NSString*         strVideoUrl;    //Video url
@property (strong, nonatomic) NSString*         strVideoDesc;   //movie/series description
@property (strong, nonatomic) NSString*         strVideoTitle;  //Movie title
@property (strong, nonatomic) NSString*         strSeriesImageUrl;  //series image
@property (strong, nonatomic) NSString*         strEpisodeId;   //episode id to add in wtahclist.
@property (strong, nonatomic) NSString*         strGenreName;   //Genre of movie/episode
@property (strong, nonatomic) NSString*         strEpisodeNum;  //episode num
@property (strong, nonatomic) NSString*         strEpisodeDuration; //episode duration.
@property (assign, nonatomic) BOOL              isEpisodeInWatchList;   //flag to check if in watchlist.

@end
