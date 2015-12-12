//
//  VideoDetail.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 05/08/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoDetail : NSObject
{
    id          _delegate;
    SEL         _eventHandler;
}

@property (strong, nonatomic) NSString*             movieDesc_en;
@property (strong, nonatomic) NSString*             movieDesc_ar;
@property (strong, nonatomic) NSString*             movieTitle_en;
@property (strong, nonatomic) NSString*             movieTitle_eniPhone;
@property (strong, nonatomic) NSString*             movieTitle_ar;
@property (strong, nonatomic) NSString*             movieDuration;
@property (strong, nonatomic) NSString*             movieUrl;
@property (strong, nonatomic) NSString*             movieType_en;
@property (strong, nonatomic) NSString*             movieType_ar;
@property (strong, nonatomic) NSString*             movieThumbnail;
@property (strong, nonatomic) NSString*             videoType;
@property (strong, nonatomic) NSString*             seriesName;
@property (strong, nonatomic) NSString*             seriesDesc;
@property (strong, nonatomic) NSString*             seriesSeasonCount;
@property (strong, nonatomic) NSString*             seasonNum;
@property (strong, nonatomic) NSString*             episodeNum;
@property (strong, nonatomic) NSString*             duration;

@property (nonatomic) BOOL existsInWatchlist;
@property (strong, nonatomic) NSMutableArray*       arrCastAndCrew;
@property (strong, nonatomic) NSMutableArray*       arrProducers;


- (void)fetchVideoDetail:(id)target selector:(SEL)selector parameter:(NSString*)requestParameter UserID:(NSString*)userID;

@end
