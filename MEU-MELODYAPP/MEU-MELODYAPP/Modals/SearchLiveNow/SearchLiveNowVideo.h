//
//  SearchLiveNowVideo.h
//  MEU-MELODYAPP
//
//  Created by Nancy Kashyap on 31/07/14.
//  Copyright (c) 2014 Nancy Kashyap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchLiveNowVideo : NSObject

@property (strong, nonatomic) NSString*     videoName_en;
@property (strong, nonatomic) NSString*     videoName_ar;
@property (strong, nonatomic) NSString*     videoDescription_en;
@property (strong, nonatomic) NSString*     videoDescription_ar;
@property (strong, nonatomic) NSString*     videoId;
@property (strong, nonatomic) NSString*     videoUrl;
@property (strong, nonatomic) NSString*     videoDuration;
@property (strong, nonatomic) NSString*     liveVideoDay;

@property (strong, nonatomic) NSString*     videoThumb;
@property (strong, nonatomic) NSString*     createdOn;
@property (strong, nonatomic) NSString*     channelName;
@property (strong, nonatomic) NSString*     channelURL;
@property (assign, nonatomic) BOOL          isSeries;
@property (assign, nonatomic) NSInteger     videoType;
@property (strong, nonatomic) NSString*     artistName_en;
@property (strong, nonatomic) NSString*     artistName_ar;

//Channel search

@property (strong, nonatomic) NSString*     upcomingVideoChannelLogoUrl;
@property (strong, nonatomic) NSString*     upcomingVideoDay;
@property (strong, nonatomic) NSString*     upcomingVideoName_en;
@property (strong, nonatomic) NSString*     upcomingVideoName_ar;
@property (strong, nonatomic) NSString*     upcomingVideoStartTime;
@property (strong, nonatomic) NSString*     upcomingChannelName;

- (void)fillInfo:(id)dict;
- (void)fillUpcomingProgramInfo:(id)dict;
- (void)fillVODInfo:(id)dict;

@end
