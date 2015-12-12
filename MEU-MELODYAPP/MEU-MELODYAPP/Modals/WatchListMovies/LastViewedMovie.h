//
//  LastViewedMovie.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 19/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastViewedMovie : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (strong, nonatomic) NSString*     movieName_en;
@property (strong, nonatomic) NSString*     movieName_ar;
@property (strong, nonatomic) NSString*     movieUrl;
@property (strong, nonatomic) NSString*     movieThumb;
@property (strong, nonatomic) NSString*     movieId;
@property (strong, nonatomic) NSString*     isExistsInWatchList;

@property (strong, nonatomic) NSString*     seriesID;
@property (strong, nonatomic) NSString*     episodeID;
@property (strong, nonatomic) NSString*     seasonNum;
@property (strong, nonatomic) NSString*     episodeNum;
@property (strong, nonatomic) NSString*     episodeDuration;
@property (strong, nonatomic) NSString*     seriesName_en;
@property (strong, nonatomic) NSString*     seriesName_ar;
@property (strong, nonatomic) NSString*     seriesDesc_en;
@property (strong, nonatomic) NSString*     seriesDesc_ar;
@property (assign, nonatomic) NSInteger     seriesSeasonsCount;
@property (assign, nonatomic) NSInteger     videoType;

@property (retain, nonatomic) NSString*     singerName_en;
@property (retain, nonatomic) NSString*     singerName_ar;

- (void)saveMovieToLastViewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;
- (void)fetchLastviewed:(id)target selector:(SEL)selector parameter:(NSDictionary*)requestParameters;

@end
